# OLAP Indexing Strategies

Indexing for analytical workloads differs significantly from OLTP. This guide covers PostgreSQL-specific index strategies for star schema models.

---

## OLTP vs OLAP Indexing

| Aspect | OLTP | OLAP |
|--------|------|------|
| **Query pattern** | Point lookups, small ranges | Full table scans, large aggregations |
| **Index goal** | Avoid table scans | Support common joins and filters |
| **Index count** | Many (every FK, WHERE column) | Fewer (query-specific) |
| **Index type** | B-tree (default) | B-tree, BRIN, Covering |
| **Write impact** | High (frequent updates) | Low (batch loads) |
| **Maintenance** | Continuous | Batch (rebuild after loads) |

---

## Fact Table Indexing

### 1. Index All Foreign Keys (Mandatory)

**Why:** Fact tables join to dimensions on every query.

```sql
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    store_key INT NOT NULL,
    ...
);

-- ✅ Index every dimension FK
CREATE INDEX idx_sales_date ON fact_sales(date_key);
CREATE INDEX idx_sales_product ON fact_sales(product_key);
CREATE INDEX idx_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_sales_store ON fact_sales(store_key);
```

### 2. Composite Indexes for Common Query Patterns

**Pattern:** Queries often filter/group by multiple dimensions together.

```sql
-- Common query: Sales by product category and month
SELECT 
    p.category_l1,
    d.year,
    d.month,
    SUM(f.total_amount)
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024  -- ← Filter
GROUP BY p.category_l1, d.year, d.month;

-- ✅ Composite index supports this query
CREATE INDEX idx_sales_date_product ON fact_sales(date_key, product_key);
```

**Guidelines:**
- Put most selective column first (typically date_key)
- Include columns used in WHERE, JOIN, GROUP BY
- Limit to 2-3 columns (diminishing returns)

### 3. BRIN Indexes for Time-Series Fact Tables

**BRIN (Block Range Index):** Extremely compact index for naturally ordered data.

**When to use:**
- Fact table is clustered by date (common for time-series data)
- Date range queries (WHERE date_key BETWEEN...)
- Very large fact tables (billions of rows)

```sql
-- ✅ BRIN index on date_key (time-series data)
CREATE INDEX idx_sales_date_brin ON fact_sales USING BRIN(date_key);

-- BRIN is 1000x smaller than B-tree (but requires clustered data)
```

**Performance:**
- ✅ Tiny index size (KB vs GB for B-tree)
- ✅ Fast range scans (date ranges)
- ❌ Requires data to be physically ordered by indexed column
- ❌ Not useful for random lookups

**Ensure clustering:**
```sql
-- Cluster table by date (one-time operation)
CLUSTER fact_sales USING idx_sales_date_brin;

-- Or load data in date order
INSERT INTO fact_sales (date_key, ...)
SELECT ... FROM source ORDER BY date_key;
```

### 4. Covering Indexes (Include Columns)

**Pattern:** Index includes frequently selected columns (index-only scans).

```sql
-- Query: Daily sales totals
SELECT date_key, SUM(total_amount)
FROM fact_sales
GROUP BY date_key;

-- ❌ Regular index: Requires table access
CREATE INDEX idx_sales_date ON fact_sales(date_key);

-- ✅ Covering index: No table access needed (faster)
CREATE INDEX idx_sales_date_covering ON fact_sales(date_key) 
    INCLUDE (total_amount);
```

**PostgreSQL INCLUDE syntax:**
```sql
CREATE INDEX idx_name ON table(indexed_columns) INCLUDE (covering_columns);
```

**Benefits:**
- ✅ Index-only scans (no table access)
- ✅ Faster queries (read from index only)
- ❌ Larger index size

---

## Dimension Table Indexing

### 1. Surrogate Key (Primary Key) - Automatic

```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,  -- ✅ Automatically indexed
    ...
);
```

### 2. Natural Key (Business Identifier)

**Why:** ETL processes lookup dimension keys by natural key.

```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,  -- Natural key
    ...
);

-- ✅ Index natural key (ETL lookups)
CREATE INDEX idx_customer_natural_key ON dim_customer(customer_id);
```

### 3. SCD Type 2: Current Flag Partial Index

**Why:** Most queries filter on `is_current = TRUE`.

```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    ...
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

-- ✅ Partial index (only index current rows)
CREATE INDEX idx_customer_current ON dim_customer(is_current) 
    WHERE is_current = TRUE;

-- ✅ Unique constraint on current rows
CREATE UNIQUE INDEX idx_customer_current_unique 
    ON dim_customer(customer_id) 
    WHERE is_current = TRUE;
```

**Benefits:**
- ✅ Small index (only current rows)
- ✅ Fast lookups (SELECT ... WHERE is_current = TRUE)
- ✅ Enforces uniqueness (one current row per customer)

### 4. SCD Type 2: Date Range Index

**Why:** Point-in-time queries filter by effective/expiration dates.

```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    effective_date DATE NOT NULL,
    expiration_date DATE,
    ...
);

-- ✅ Index for date range queries
CREATE INDEX idx_customer_dates ON dim_customer(effective_date, expiration_date);
```

**Query example:**
```sql
-- Get customer version as of specific date
SELECT *
FROM dim_customer
WHERE customer_id = 'C100'
  AND effective_date <= '2024-03-01'
  AND (expiration_date IS NULL OR expiration_date >= '2024-03-01');
```

### 5. Hierarchy Attributes (Common Filters)

```sql
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    category_l1 VARCHAR(100),
    category_l2 VARCHAR(100),
    category_l3 VARCHAR(100),
    brand VARCHAR(100),
    ...
);

-- ✅ Index category hierarchy (common GROUP BY)
CREATE INDEX idx_product_category ON dim_product(category_l1, category_l2, category_l3);

-- ✅ Index brand (common filter)
CREATE INDEX idx_product_brand ON dim_product(brand);
```

---

## Materialized Views (Pre-Aggregation)

**Pattern:** Pre-compute common aggregations for faster queries.

### Example: Daily Sales by Category

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW mv_daily_sales_by_category AS
SELECT 
    d.date_key,
    d.full_date,
    p.category_l1,
    p.category_l2,
    SUM(f.quantity) AS total_quantity,
    SUM(f.total_amount) AS total_sales,
    COUNT(*) AS transaction_count
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY d.date_key, d.full_date, p.category_l1, p.category_l2;

-- Index materialized view
CREATE INDEX idx_mv_date ON mv_daily_sales_by_category(date_key);
CREATE INDEX idx_mv_category ON mv_daily_sales_by_category(category_l1, category_l2);

-- Query materialized view (fast)
SELECT category_l1, SUM(total_sales)
FROM mv_daily_sales_by_category
WHERE date_key BETWEEN 20240101 AND 20241231
GROUP BY category_l1;
```

### Refresh Strategies

```sql
-- Full refresh (blocks queries)
REFRESH MATERIALIZED VIEW mv_daily_sales_by_category;

-- Concurrent refresh (requires unique index, allows queries)
CREATE UNIQUE INDEX idx_mv_unique 
    ON mv_daily_sales_by_category(date_key, category_l1, category_l2);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales_by_category;
```

**Refresh schedule:**
```bash
# Cron job (nightly at 2am)
0 2 * * * psql -c "REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales_by_category;"
```

---

## Partitioning (Large Fact Tables)

**Pattern:** Partition fact table by date range for easier maintenance.

### Range Partitioning by Date

```sql
-- Parent table (partitioned)
CREATE TABLE fact_sales (
    sale_id BIGSERIAL,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    quantity INT,
    total_amount DECIMAL(10,2),
    ...
) PARTITION BY RANGE (date_key);

-- Create partitions (monthly)
CREATE TABLE fact_sales_2024_01 PARTITION OF fact_sales
    FOR VALUES FROM (20240101) TO (20240201);

CREATE TABLE fact_sales_2024_02 PARTITION OF fact_sales
    FOR VALUES FROM (20240201) TO (20240301);

-- ... continue for each month

-- Indexes on each partition
CREATE INDEX idx_sales_2024_01_date ON fact_sales_2024_01(date_key);
CREATE INDEX idx_sales_2024_01_product ON fact_sales_2024_01(product_key);
```

**Benefits:**
- ✅ Faster queries (partition pruning - scan only relevant partitions)
- ✅ Easier maintenance (drop old partitions, load into current partition)
- ✅ Parallel queries (scan partitions in parallel)

**Query example:**
```sql
-- PostgreSQL scans only fact_sales_2024_01 partition (faster)
SELECT SUM(total_amount)
FROM fact_sales
WHERE date_key BETWEEN 20240101 AND 20240131;
```

---

## Index Maintenance Strategies

### During Bulk Loads

**Problem:** Indexes slow down bulk inserts.

**Solution:** Drop indexes, load data, rebuild indexes.

```sql
-- 1. Drop indexes (faster loads)
DROP INDEX idx_sales_date;
DROP INDEX idx_sales_product;
DROP INDEX idx_sales_customer;

-- 2. Bulk load (fast)
INSERT INTO fact_sales (date_key, product_key, ...)
SELECT ... FROM staging.orders;

-- 3. Rebuild indexes (parallel, faster)
CREATE INDEX idx_sales_date ON fact_sales(date_key);
CREATE INDEX idx_sales_product ON fact_sales(product_key);
CREATE INDEX idx_sales_customer ON fact_sales(customer_key);

-- 4. Analyze (update statistics)
ANALYZE fact_sales;
```

### Parallel Index Creation

```sql
-- Use all available CPUs (faster rebuild)
SET max_parallel_maintenance_workers = 4;

CREATE INDEX idx_sales_date ON fact_sales(date_key);
```

### VACUUM and ANALYZE

```sql
-- After bulk loads, update statistics
VACUUM ANALYZE fact_sales;

-- Or configure autovacuum
ALTER TABLE fact_sales SET (
    autovacuum_vacuum_scale_factor = 0.1,
    autovacuum_analyze_scale_factor = 0.05
);
```

---

## Query-Specific Index Analysis

### Use EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE
SELECT 
    p.category_l1,
    SUM(f.total_amount)
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
WHERE f.date_key BETWEEN 20240101 AND 20241231
GROUP BY p.category_l1;
```

**Look for:**
- **Seq Scan** on fact table → Add index on filtered columns
- **Index Scan** on dimension → Good (using PK index)
- **Bitmap Heap Scan** → OK for large result sets
- **High execution time** → Consider covering index or materialized view

### Missing Index Detection

```sql
-- Find tables with high sequential scans (candidates for indexes)
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    seq_tup_read / NULLIF(seq_scan, 0) AS avg_seq_tup_read
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC
LIMIT 20;
```

---

## Index Sizing and Performance

### Index Size Check

```sql
-- Index sizes
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Unused Index Detection

```sql
-- Find unused indexes (candidates for removal)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0  -- Never used
  AND indexrelid::regclass::text NOT LIKE '%_pkey'  -- Exclude PKs
ORDER BY pg_relation_size(indexrelid) DESC;
```

---

## Checklist

**Fact table indexes:**
- [ ] All foreign keys indexed (date, product, customer, etc.)
- [ ] Composite indexes for common query patterns
- [ ] BRIN index on date_key (if time-series data)
- [ ] Covering indexes for aggregation queries (optional)

**Dimension table indexes:**
- [ ] Primary key (surrogate key) - automatic
- [ ] Natural key indexed (for ETL lookups)
- [ ] Partial index on `is_current = TRUE` (SCD Type 2)
- [ ] Unique constraint on current rows (SCD Type 2)
- [ ] Date range index (effective_date, expiration_date)
- [ ] Common filter columns (category, brand, etc.)

**Performance:**
- [ ] Materialized views for common aggregations
- [ ] Partitioning for very large fact tables (>100M rows)
- [ ] Drop indexes before bulk loads, rebuild after
- [ ] VACUUM ANALYZE after loads
- [ ] EXPLAIN ANALYZE slow queries

---

## Key Takeaways

1. **Index all fact table FKs** - Critical for join performance
2. **Composite indexes for query patterns** - date + product, etc.
3. **BRIN for time-series** - 1000x smaller, requires clustering
4. **Partial indexes for SCD Type 2** - `WHERE is_current = TRUE`
5. **Materialized views for aggregations** - Pre-compute common queries
6. **Partitioning for large tables** - Easier maintenance, faster queries
7. **Drop indexes during bulk loads** - Rebuild after (parallel)
8. **Monitor with EXPLAIN ANALYZE** - Identify missing indexes

**Kimball's guidance:** "Index fact table foreign keys. Everything else is query-specific."

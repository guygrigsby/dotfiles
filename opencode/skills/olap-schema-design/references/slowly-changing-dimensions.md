# Slowly Changing Dimensions (SCD)

Dimensions change over time. Slowly Changing Dimensions (SCD) strategies determine how to track these changes while maintaining analytical accuracy.

---

## The Challenge

**Problem:** Customer moves from California to Texas. How do we handle this?

**Incorrect approach:** Update customer record
- ❌ Loses history (can't analyze past behavior in CA context)
- ❌ Historical facts change retroactively (wrong)

**Correct approach:** Use an SCD strategy (Type 1, 2, or 3)

---

## SCD Type 1: Overwrite (No History)

### Description
Update the dimension row in place. No history preserved.

### When to use
- History doesn't matter (current state only)
- Fixing data errors (typos, wrong values)
- Low-value attributes that change rarely
- "Right to be forgotten" scenarios

### Schema
```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) UNIQUE NOT NULL,  -- Natural key
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    customer_segment VARCHAR(50)
    -- No SCD tracking columns
);
```

### Example
**Initial state:**
```sql
customer_key | customer_id | customer_name | state
-------------|-------------|---------------|-------
1            | C100        | Alice Smith   | CA
```

**Customer moves to TX:**
```sql
UPDATE dim_customer
SET state = 'TX'
WHERE customer_key = 1;
```

**Result:**
```sql
customer_key | customer_id | customer_name | state
-------------|-------------|---------------|-------
1            | C100        | Alice Smith   | TX     -- ✅ Updated
```

**Historical facts now point to TX** (incorrect for analysis, but acceptable if history doesn't matter).

### Pros/Cons
✅ Simple (no extra columns or rows)  
✅ Minimal storage  
❌ No history (can't analyze past context)  
❌ Historical facts retroactively change  

---

## SCD Type 2: Add Row (Full History)

### Description
Insert a new row for each change. Full history preserved. **Kimball's preferred approach.**

### When to use
- History matters for analysis (most cases)
- Need to analyze facts in their original context
- Regulatory requirements (audit trails)
- Slowly changing attributes (address, price tier, status)

### Schema
```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,              -- Surrogate key (unique per row)
    customer_id VARCHAR(50) NOT NULL,              -- Natural key (multiple rows possible)
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    customer_segment VARCHAR(50),
    -- SCD Type 2 tracking columns
    effective_date DATE NOT NULL,                  -- When this version became active
    expiration_date DATE,                          -- When this version expired (NULL = current)
    is_current BOOLEAN NOT NULL DEFAULT TRUE       -- Flag for current version
);

-- Indexes
CREATE INDEX idx_customer_natural_key ON dim_customer(customer_id);
CREATE INDEX idx_customer_current ON dim_customer(is_current) WHERE is_current = TRUE;
CREATE UNIQUE INDEX idx_customer_current_unique ON dim_customer(customer_id) WHERE is_current = TRUE;
```

### Example
**Initial state:**
```sql
customer_key | customer_id | customer_name | state | effective_date | expiration_date | is_current
-------------|-------------|---------------|-------|----------------|-----------------|------------
1            | C100        | Alice Smith   | CA    | 2023-01-01     | NULL            | TRUE
```

**Customer moves to TX on 2024-06-15:**
```sql
-- Step 1: Expire old row
UPDATE dim_customer
SET expiration_date = '2024-06-14',
    is_current = FALSE
WHERE customer_key = 1;

-- Step 2: Insert new row
INSERT INTO dim_customer (
    customer_id, customer_name, email, city, state, country, customer_segment,
    effective_date, expiration_date, is_current
) VALUES (
    'C100', 'Alice Smith', 'alice@example.com', 'Austin', 'TX', 'USA', 'VIP',
    '2024-06-15', NULL, TRUE
);
```

**Result:**
```sql
customer_key | customer_id | customer_name | state | effective_date | expiration_date | is_current
-------------|-------------|---------------|-------|----------------|-----------------|------------
1            | C100        | Alice Smith   | CA    | 2023-01-01     | 2024-06-14      | FALSE
2            | C100        | Alice Smith   | TX    | 2024-06-15     | NULL            | TRUE
```

**Historical facts preserve context:**
- Sales from 2023 → customer_key = 1 (CA)
- Sales from 2024 Q3 → customer_key = 2 (TX)

### Querying Type 2 Dimensions

**Get current version:**
```sql
SELECT * 
FROM dim_customer 
WHERE customer_id = 'C100' 
  AND is_current = TRUE;
```

**Get version as of specific date:**
```sql
SELECT * 
FROM dim_customer 
WHERE customer_id = 'C100' 
  AND effective_date <= '2024-03-01'
  AND (expiration_date IS NULL OR expiration_date >= '2024-03-01');
```

**Join facts with dimension (automatic point-in-time accuracy):**
```sql
SELECT 
    c.customer_name,
    c.state,
    SUM(f.total_amount) AS revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key  -- Surrogate key ensures correct version
GROUP BY c.customer_name, c.state;
```

### Pros/Cons
✅ Full history preserved  
✅ Facts analyzed in original context (accurate)  
✅ Audit trail for compliance  
✅ Most flexible for analysis  
❌ More storage (multiple rows per entity)  
❌ More complex ETL  
❌ Larger dimension tables  

---

## SCD Type 3: Add Column (Limited History)

### Description
Add columns to track previous value(s). Limited history (current + previous).

### When to use
- Need only current + previous value
- "What changed since last time?" analysis
- Hard rollback scenarios (revert to previous)

### Schema
```sql
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    -- Current values
    current_price DECIMAL(10,2) NOT NULL,
    current_category VARCHAR(100),
    -- Previous values
    previous_price DECIMAL(10,2),
    previous_category VARCHAR(100),
    -- Tracking
    last_updated_date DATE NOT NULL
);
```

### Example
**Initial state:**
```sql
product_key | product_id | product_name | current_price | previous_price | current_category | previous_category
------------|------------|--------------|---------------|----------------|------------------|-------------------
1           | P100       | Widget       | 10.00         | NULL           | Electronics      | NULL
```

**Price changes to $12.00:**
```sql
UPDATE dim_product
SET previous_price = current_price,
    current_price = 12.00,
    last_updated_date = '2024-06-15'
WHERE product_key = 1;
```

**Result:**
```sql
product_key | product_id | product_name | current_price | previous_price | current_category | previous_category
------------|------------|--------------|---------------|----------------|------------------|-------------------
1           | P100       | Widget       | 12.00         | 10.00          | Electronics      | NULL
```

**Analysis:**
```sql
-- Products with recent price increases
SELECT 
    product_name,
    previous_price,
    current_price,
    (current_price - previous_price) AS price_increase,
    (current_price - previous_price)::DECIMAL / previous_price * 100 AS pct_increase
FROM dim_product
WHERE current_price > previous_price
ORDER BY pct_increase DESC;
```

### Pros/Cons
✅ Simple (no extra rows)  
✅ Easy to track current vs previous  
✅ Good for "what changed?" analysis  
❌ Limited history (only 1-2 versions)  
❌ Can't analyze deeper history  
❌ Not suitable for compliance/audit  

---

## SCD Type 0: No Changes

### Description
Dimension never changes (immutable).

### When to use
- Static reference data (countries, products with fixed attributes)
- Code tables (status codes, types)

### Schema
```sql
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,  -- 20240101
    full_date DATE NOT NULL,
    day_of_week VARCHAR(10) NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter INT NOT NULL,
    year INT NOT NULL
    -- No SCD tracking needed (immutable)
);
```

---

## SCD Type 6: Hybrid (Type 1 + 2 + 3)

### Description
Combines Type 1, 2, and 3 strategies. Track full history + current values.

### When to use
- Need full history AND easy access to current values
- Complex regulatory requirements
- Rare (adds complexity)

### Schema
```sql
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    -- Historical values (Type 2)
    historical_state VARCHAR(100),
    historical_segment VARCHAR(50),
    -- Current values (Type 1 - denormalized)
    current_state VARCHAR(100),
    current_segment VARCHAR(50),
    -- Previous values (Type 3)
    previous_state VARCHAR(100),
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);
```

**Not recommended** - complexity outweighs benefits. Use Type 2 instead.

---

## Choosing an SCD Strategy

| Scenario | Recommended Type |
|----------|------------------|
| Need full history | **Type 2** |
| History doesn't matter | Type 1 |
| Only need current + previous | Type 3 |
| Static reference data | Type 0 |
| Fixing data errors | Type 1 |
| Regulatory compliance | **Type 2** |
| CQRS query model | **Type 2** |
| Price history tracking | **Type 2** |
| Customer address changes | **Type 2** |
| Product category changes | **Type 2** |

**Kimball's default:** **Use Type 2** unless you have a specific reason not to.

---

## Implementation Patterns

### ETL Process for Type 2

```sql
-- Step 1: Detect changes (compare source to current dimension)
WITH source_data AS (
    SELECT 
        'C100' AS customer_id,
        'Alice Smith' AS customer_name,
        'TX' AS state,
        'VIP' AS segment
),
current_dim AS (
    SELECT *
    FROM dim_customer
    WHERE is_current = TRUE
),
changes AS (
    SELECT 
        s.*,
        d.customer_key,
        CASE 
            WHEN d.customer_key IS NULL THEN 'INSERT'
            WHEN (s.state, s.segment) IS DISTINCT FROM (d.state, d.segment) THEN 'UPDATE'
            ELSE 'NO_CHANGE'
        END AS change_type
    FROM source_data s
    LEFT JOIN current_dim d ON s.customer_id = d.customer_id
)

-- Step 2: Expire old rows
UPDATE dim_customer
SET expiration_date = CURRENT_DATE - INTERVAL '1 day',
    is_current = FALSE
WHERE customer_key IN (
    SELECT customer_key 
    FROM changes 
    WHERE change_type = 'UPDATE'
);

-- Step 3: Insert new rows (both new customers and changed customers)
INSERT INTO dim_customer (
    customer_id, customer_name, state, segment,
    effective_date, expiration_date, is_current
)
SELECT 
    customer_id, customer_name, state, segment,
    CURRENT_DATE, NULL, TRUE
FROM changes
WHERE change_type IN ('INSERT', 'UPDATE');
```

### Unknown Member Handling

**Problem:** Fact row arrives before dimension is populated.

**Solution:** Create "unknown" placeholder row.

```sql
-- Insert unknown member (customer_key = -1)
INSERT INTO dim_customer (
    customer_key, customer_id, customer_name, state, segment,
    effective_date, is_current
) VALUES (
    -1, 'UNKNOWN', 'Unknown Customer', 'Unknown', 'Unknown',
    '1900-01-01', TRUE
);

-- Fact table references unknown member until dimension loads
INSERT INTO fact_sales (customer_key, ...)
VALUES (-1, ...);  -- Unknown customer
```

---

## Performance Considerations

### Indexes for Type 2
```sql
-- Natural key (for lookups)
CREATE INDEX idx_customer_natural_key ON dim_customer(customer_id);

-- Current flag (for filtering)
CREATE INDEX idx_customer_current ON dim_customer(is_current) WHERE is_current = TRUE;

-- Unique constraint on current rows
CREATE UNIQUE INDEX idx_customer_current_unique 
    ON dim_customer(customer_id) 
    WHERE is_current = TRUE;

-- Date range (for point-in-time queries)
CREATE INDEX idx_customer_dates ON dim_customer(effective_date, expiration_date);
```

### Storage Impact
- Type 1: 1 row per entity (minimal)
- Type 2: N rows per entity (N = number of changes)
- Type 3: 1 row per entity + extra columns

**Typical Type 2 growth:**
- Customer dimension: 10-20% annual growth (low churn)
- Product dimension: 50-100% annual growth (frequent price changes)
- Most dimensions: < 10M rows (acceptable overhead)

---

## Common Mistakes

### ❌ Using natural keys as foreign keys
```sql
-- ❌ Wrong: natural key in fact table
CREATE TABLE fact_sales (
    customer_id VARCHAR(50),  -- ❌ Natural key (can't track history)
    ...
);
```

```sql
-- ✅ Correct: surrogate key in fact table
CREATE TABLE fact_sales (
    customer_key INT,  -- ✅ Surrogate key (tracks exact version)
    ...
);
```

### ❌ Updating surrogate keys
```sql
-- ❌ Wrong: updating fact table when dimension changes
UPDATE fact_sales
SET customer_key = 2  -- ❌ Changes historical context
WHERE customer_key = 1;
```

**Never update fact table foreign keys.** Type 2 works precisely because facts point to the correct historical dimension version.

### ❌ Deleting old dimension rows
```sql
-- ❌ Wrong: deleting expired rows
DELETE FROM dim_customer
WHERE is_current = FALSE;  -- ❌ Breaks historical facts
```

**Never delete dimension rows** referenced by facts. Archive if necessary, but don't delete.

---

## Key Takeaways

1. **Type 2 is the default** - full history, most flexible
2. **Use surrogate keys** - never natural keys as foreign keys
3. **Track effective/expiration dates** - enables point-in-time queries
4. **is_current flag** - simplifies current version queries
5. **Never update fact FKs** - Type 2 works because facts preserve context
6. **Unknown member pattern** - handle late-arriving dimensions
7. **Index appropriately** - natural key, is_current, date ranges
8. **ETL complexity** - Type 2 requires change detection logic

**Kimball's guidance:** "When in doubt, use Type 2."

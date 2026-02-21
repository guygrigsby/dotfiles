# Indexing Strategies for OLTP

Comprehensive guide to B-tree indexes for write-optimized transactional systems.

---

## When to Index

### Always Index

| Column Type | Reason | Example |
|-------------|--------|---------|
| **Primary keys** | Automatic (enforces uniqueness) | `id BIGSERIAL PRIMARY KEY` |
| **Foreign keys** | Speed up JOINs | `customer_id BIGINT REFERENCES customers(id)` |
| **WHERE clause columns** | Filter performance | `WHERE status = 'active'` |
| **ORDER BY columns** | Sorting performance | `ORDER BY created_at DESC` |
| **Unique constraints** | Prevent duplicates | `email VARCHAR UNIQUE` |

```sql
-- Foreign key index (CRITICAL for OLTP)
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- WHERE filter index
CREATE INDEX idx_orders_status ON orders(status);

-- ORDER BY index
CREATE INDEX idx_orders_created ON orders(created_at DESC);

-- Unique constraint (also creates B-tree index)
CREATE UNIQUE INDEX idx_users_email ON users(email);
```

---

## B-tree Indexes

**Default index type in PostgreSQL**, optimized for:
- Equality searches: `WHERE id = 123`
- Range queries: `WHERE created_at > '2024-01-01'`
- Sorted access: `ORDER BY name`
- OLTP workloads (balanced read/write)

```sql
-- Explicit B-tree (default, usually omitted)
CREATE INDEX idx_products_price ON products USING btree (price);

-- Equivalent (btree is default)
CREATE INDEX idx_products_price ON products(price);
```

---

## Composite Indexes

### Index Order Matters

```sql
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);

-- ✅ Uses index (left-most prefix)
WHERE customer_id = 123
WHERE customer_id = 123 AND status = 'pending'

-- ❌ Does NOT use index (status not first)
WHERE status = 'pending'
```

**Rule:** Most selective column first, or column queried alone.

### Query Pattern Examples

```sql
-- Pattern 1: Filter by customer, then status
SELECT * FROM orders 
WHERE customer_id = 123 AND status = 'pending'
ORDER BY created_at DESC;

-- Index:
CREATE INDEX idx_orders_customer_status_created 
  ON orders(customer_id, status, created_at DESC);

-- Pattern 2: Date range queries
SELECT * FROM orders 
WHERE created_at >= '2024-01-01' 
  AND created_at < '2024-02-01';

-- Index:
CREATE INDEX idx_orders_created ON orders(created_at);
```

---

## Partial Indexes

**Index only subset of rows** (saves space, faster writes).

```sql
-- Only index active users (filter common WHERE clause)
CREATE INDEX idx_users_active ON users(email) 
WHERE is_active = true;

-- Only index pending orders (90% of orders are completed)
CREATE INDEX idx_orders_pending ON orders(created_at) 
WHERE status = 'pending';

-- Null-safe index
CREATE INDEX idx_orders_assigned ON orders(assigned_to)
WHERE assigned_to IS NOT NULL;
```

**Use when:**
- Query always includes a WHERE clause
- Indexed subset is much smaller than full table
- Write-heavy table (reduce index maintenance)

---

## Covering Indexes (INCLUDE)

**Include non-key columns** for index-only scans (PostgreSQL 11+).

```sql
-- Index covers entire query (no table access needed)
CREATE INDEX idx_orders_customer_cover 
  ON orders(customer_id) 
  INCLUDE (status, total_amount, created_at);

-- Query uses index-only scan
SELECT status, total_amount, created_at
FROM orders
WHERE customer_id = 123;
```

**Benefits:**
- No table access (faster reads)
- Smaller disk footprint than composite index

**Trade-off:**
- Larger index (more write overhead)
- Use for frequently queried columns

---

## Unique Indexes

```sql
-- Enforce uniqueness (also creates B-tree index)
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- Composite unique constraint
CREATE UNIQUE INDEX idx_tenant_email ON users(tenant_id, email);

-- Partial unique (allow multiple NULLs)
CREATE UNIQUE INDEX idx_users_username ON users(username)
WHERE username IS NOT NULL;
```

**OLTP principle:** Unique indexes enforce business rules at DB level (not just app).

---

## Index Maintenance

### Reindexing (Reduce Bloat)

```sql
-- Rebuild single index
REINDEX INDEX idx_orders_customer;

-- Rebuild all indexes on table
REINDEX TABLE orders;

-- Concurrent rebuild (no locks, PostgreSQL 12+)
REINDEX INDEX CONCURRENTLY idx_orders_customer;
```

**When to reindex:**
- After bulk deletes (index bloat)
- Performance degradation
- Scheduled maintenance (low-traffic windows)

### Analyze (Update Statistics)

```sql
-- Update table statistics (query planner uses this)
ANALYZE orders;

-- Auto-vacuum handles this, but run manually after:
-- - Bulk inserts/updates
-- - Major schema changes
```

---

## Index Trade-offs

| Benefit | Cost |
|---------|------|
| **Faster reads** (WHERE, JOIN, ORDER BY) | **Slower writes** (INSERT, UPDATE, DELETE) |
| Enforces uniqueness | Storage overhead (disk space) |
| Index-only scans | Index maintenance (VACUUM) |

**OLTP principle:** Only index what's queried (over-indexing hurts write performance).

---

## Index Anti-Patterns

### Over-Indexing

```sql
-- ❌ Too many indexes on same table
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);
CREATE INDEX idx_orders_customer_created ON orders(customer_id, created_at);
CREATE INDEX idx_orders_status_created ON orders(status, created_at);

-- Problem: Every INSERT/UPDATE/DELETE touches 6+ indexes
```

**Fix:** Analyze actual query patterns, consolidate to 2-3 composite indexes.

### Indexing Low-Cardinality Columns

```sql
-- ❌ Bad: status has only 3 values ('pending', 'completed', 'cancelled')
CREATE INDEX idx_orders_status ON orders(status);

-- Problem: Index not selective, table scan often faster
```

**Exception:** Partial index if one value is rare:

```sql
-- ✅ Good: Only 5% of orders are pending
CREATE INDEX idx_orders_pending ON orders(customer_id, created_at)
WHERE status = 'pending';
```

### Not Indexing Foreign Keys

```sql
-- ❌ Missing foreign key index
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT REFERENCES customers(id)  -- NO INDEX!
);

-- Problem: JOINs and CASCADE deletes are slow
```

**Fix:** Always index foreign keys:

```sql
-- ✅ Index foreign key
CREATE INDEX idx_orders_customer ON orders(customer_id);
```

---

## Monitoring Indexes

### Find Unused Indexes

```sql
-- Indexes with zero scans (candidates for removal)
SELECT 
  schemaname, 
  tablename, 
  indexname, 
  idx_scan,
  pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;
```

### Find Missing Indexes

```sql
-- Tables with high sequential scans (might need indexes)
SELECT 
  schemaname, 
  tablename, 
  seq_scan, 
  seq_tup_read,
  idx_scan,
  seq_tup_read / seq_scan AS avg_seq_read
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC
LIMIT 20;
```

### Index Bloat

```sql
-- Check index size vs table size
SELECT 
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Index Naming Conventions

```sql
-- Format: idx_{table}_{columns}[_{condition}]

-- Single column
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Composite
CREATE INDEX idx_orders_customer_status ON orders(customer_id, status);

-- Partial
CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';

-- Unique
CREATE UNIQUE INDEX uk_users_email ON users(email);

-- Covering
CREATE INDEX idx_orders_customer_cover ON orders(customer_id) INCLUDE (total_amount);
```

**Prefixes:**
- `idx_` = Standard index
- `uk_` = Unique constraint
- `fk_` = Foreign key (if named separately)

---

## OLTP Indexing Checklist

Before deploying:

- [ ] All foreign keys indexed
- [ ] Unique constraints on business keys (email, username, etc.)
- [ ] Indexes on WHERE clause columns (if selective)
- [ ] Composite indexes match query patterns (left-most prefix)
- [ ] Consider partial indexes for filtered queries
- [ ] No indexes on low-cardinality columns (unless partial)
- [ ] Monitored unused indexes (idx_scan = 0)
- [ ] Named consistently (idx_{table}_{columns})

---

## Resources

- PostgreSQL Documentation: Indexes
- "SQL Performance Explained" - Markus Winand
- "Use The Index, Luke!" - https://use-the-index-luke.com/

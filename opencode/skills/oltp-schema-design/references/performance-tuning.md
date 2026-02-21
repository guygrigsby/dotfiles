# Performance Tuning for OLTP

PostgreSQL-specific tuning for write-heavy transactional workloads: transactions, locking, migrations, and monitoring.

---

## ACID Transactions

### Transaction Pattern

```sql
BEGIN;
  -- All operations succeed or all fail (atomicity)
  INSERT INTO orders (customer_id, total_amount) VALUES (123, 99.99);
  
  INSERT INTO order_items (order_id, product_id, quantity) 
    VALUES (currval('orders_id_seq'), 456, 2);
  
  UPDATE inventory SET stock = stock - 2 WHERE product_id = 456;
COMMIT;  -- Or ROLLBACK on error
```

**Best practices:**
- Keep transactions short (minimize lock duration)
- Group related operations
- Handle rollback in application code

---

## Isolation Levels

```sql
-- READ COMMITTED (default) - prevents dirty reads
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- REPEATABLE READ - prevents non-repeatable reads
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- SERIALIZABLE (strictest) - prevents phantom reads
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

| Level | Prevents | Use Case |
|-------|----------|----------|
| **READ COMMITTED** | Dirty reads | Default OLTP (balance of consistency/concurrency) |
| **REPEATABLE READ** | Non-repeatable reads | Reports within transaction |
| **SERIALIZABLE** | Phantom reads | Critical financial operations |

**OLTP default:** READ COMMITTED

---

## Row-Level Locking

### Explicit Locking

```sql
-- SELECT FOR UPDATE (exclusive lock, prevents concurrent updates)
BEGIN;
SELECT * FROM inventory WHERE product_id = 123 FOR UPDATE;
UPDATE inventory SET stock = stock - 1 WHERE product_id = 123;
COMMIT;

-- SELECT FOR SHARE (shared lock, multiple readers)
SELECT * FROM products WHERE id = 456 FOR SHARE;

-- NOWAIT (fail fast if locked)
SELECT * FROM orders WHERE id = 789 FOR UPDATE NOWAIT;

-- SKIP LOCKED (queue systems, job processing)
SELECT * FROM jobs WHERE status = 'pending' 
FOR UPDATE SKIP LOCKED LIMIT 1;
```

### Use Cases

**Inventory management (prevent overselling):**
```sql
BEGIN;
SELECT stock FROM inventory WHERE product_id = 123 FOR UPDATE;
-- Application checks if stock >= quantity
UPDATE inventory SET stock = stock - ? WHERE product_id = 123;
COMMIT;
```

**Job queues (prevent duplicate processing):**
```sql
-- Worker picks next job atomically
UPDATE jobs 
SET status = 'processing', worker_id = 123
WHERE id = (
  SELECT id FROM jobs 
  WHERE status = 'pending'
  ORDER BY priority DESC, created_at
  FOR UPDATE SKIP LOCKED
  LIMIT 1
)
RETURNING *;
```

---

## Primary Key Strategies

```sql
-- BIGSERIAL (auto-increment, simple)
id BIGSERIAL PRIMARY KEY

-- IDENTITY (SQL standard, PostgreSQL 10+)
id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY

-- UUID (distributed systems, sharding)
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- Composite (junction tables, natural keys)
PRIMARY KEY (student_id, course_id)
```

| Type | Use When | Pros | Cons |
|------|----------|------|------|
| **BIGSERIAL** | Single database | Simple, sequential | Reveals count, sharding issues |
| **UUID** | Distributed, multi-region | Globally unique, merge-safe | Larger (16 bytes), slower indexes |
| **Composite** | Junction tables | Enforces business logic | Complex queries |

---

## Data Types (OLTP)

### Critical Rules

```sql
-- ✅ ALWAYS use DECIMAL for money (exact precision)
price DECIMAL(10, 2)  -- $99,999,999.99

-- ❌ NEVER use FLOAT for money (rounding errors)
price FLOAT  -- Causes financial discrepancies

-- ✅ ALWAYS store timestamps in UTC
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
```

### Common Types

| Type | Use Case | Example |
|------|----------|---------|
| BIGSERIAL | Auto-increment IDs | `id BIGSERIAL PRIMARY KEY` |
| UUID | Distributed IDs | `id UUID PRIMARY KEY` |
| VARCHAR(n) | Variable text | `email VARCHAR(255)` |
| TEXT | Long content | `description TEXT` |
| DECIMAL(p,s) | Money, precise numbers | `price DECIMAL(10,2)` |
| BOOLEAN | True/false | `is_active BOOLEAN` |
| TIMESTAMP | Dates with time (UTC) | `created_at TIMESTAMP` |

---

## Foreign Key Strategies

```sql
-- CASCADE: Delete children with parent (dependent data)
CREATE TABLE order_items (
  order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE
);

-- RESTRICT: Prevent deletion if referenced (important data)
CREATE TABLE orders (
  customer_id BIGINT REFERENCES customers(id) ON DELETE RESTRICT
);

-- SET NULL: Nullify reference (optional relationships)
CREATE TABLE orders (
  salesperson_id BIGINT REFERENCES employees(id) ON DELETE SET NULL
);
```

| Strategy | Use Case |
|----------|----------|
| **CASCADE** | Order items, audit logs |
| **RESTRICT** | Critical references (prevent accidents) |
| **SET NULL** | Optional metadata |

---

## Zero-Downtime Migrations

### Adding a Column

```sql
-- Step 1: Add nullable
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2: Deploy code writing to new column

-- Step 3: Backfill
UPDATE users SET phone = '' WHERE phone IS NULL;

-- Step 4: Make required
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

### Renaming a Column

```sql
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN email_address VARCHAR(255);

-- Step 2: Dual-write (app writes to both)

-- Step 3: Backfill
UPDATE users SET email_address = email;

-- Step 4: Switch reads to new column

-- Step 5: Drop old column
ALTER TABLE users DROP COLUMN email;
```

### Adding an Index

```sql
-- Create index concurrently (no locks, safe for production)
CREATE INDEX CONCURRENTLY idx_orders_customer ON orders(customer_id);

-- If it fails, drop and retry
DROP INDEX CONCURRENTLY IF EXISTS idx_orders_customer;
```

**OLTP principle:** All migrations reversible, zero downtime.

---

## PostgreSQL OLTP Features

### Auto-Update Timestamps

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### Sequences (Custom ID Generation)

```sql
CREATE SEQUENCE order_number_seq START 1000 INCREMENT 1;

CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  order_number BIGINT NOT NULL DEFAULT nextval('order_number_seq'),
  UNIQUE (order_number)
);
```

### Named Constraints (Better Error Messages)

```sql
ALTER TABLE orders
  ADD CONSTRAINT fk_orders_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(id),
  ADD CONSTRAINT chk_orders_total_positive 
    CHECK (total_amount >= 0),
  ADD CONSTRAINT uk_orders_number 
    UNIQUE (order_number);

-- Error messages reference constraint name:
-- ERROR: violates check constraint "chk_orders_total_positive"
```

---

## Monitoring & Diagnostics

### Long-Running Queries

```sql
SELECT 
  pid,
  now() - query_start AS duration,
  state,
  query
FROM pg_stat_activity
WHERE state != 'idle'
  AND query NOT LIKE '%pg_stat_activity%'
ORDER BY duration DESC;
```

### Lock Conflicts

```sql
SELECT 
  blocked.pid AS blocked_pid,
  blocked.query AS blocked_query,
  blocking.pid AS blocking_pid,
  blocking.query AS blocking_query
FROM pg_stat_activity blocked
JOIN pg_locks blocked_locks ON blocked.pid = blocked_locks.pid
JOIN pg_locks blocking_locks ON blocked_locks.locktype = blocking_locks.locktype
JOIN pg_stat_activity blocking ON blocking.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;
```

### Table Bloat

```sql
SELECT 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## OLTP Performance Checklist

- [ ] Transactions kept short (< 100ms)
- [ ] Isolation level appropriate (READ COMMITTED for most)
- [ ] Row-level locking used for critical updates
- [ ] DECIMAL (not FLOAT) for money
- [ ] Timestamps in UTC
- [ ] Foreign key DELETE strategy specified
- [ ] Indexes on all foreign keys
- [ ] Migrations use CONCURRENTLY (no locks)
- [ ] Monitored slow queries (> 1s)
- [ ] Auto-vacuum enabled (default)

---

## Resources

- PostgreSQL Documentation: Concurrency Control, Performance Tips
- "Designing Data-Intensive Applications" - Martin Kleppmann (Chapter 7: Transactions)
- "PostgreSQL: Up and Running" - Regina Obe & Leo Hsu

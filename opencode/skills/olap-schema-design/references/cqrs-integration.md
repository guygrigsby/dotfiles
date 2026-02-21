# CQRS Integration: OLTP to OLAP Synchronization

Command Query Responsibility Segregation (CQRS) separates write models (OLTP) from read models (OLAP). This guide covers synchronization patterns between the two.

---

## CQRS Pattern Overview

```
┌─────────────────────────┐         ┌─────────────────────────┐
│     Command Side        │         │      Query Side         │
│     (Write Model)       │         │     (Read Model)        │
├─────────────────────────┤         ├─────────────────────────┤
│   OLTP Schema (5NF)     │         │  OLAP Schema (Star)     │
│   - Normalized          │         │  - Denormalized         │
│   - ACID transactions   │────────►│  - Query optimized      │
│   - Write optimized     │  Sync   │  - Read optimized       │
│   - Referential         │         │  - Aggregation friendly │
│     integrity           │         │                         │
└─────────────────────────┘         └─────────────────────────┘
```

**Benefits:**
- ✅ Write side optimized for integrity and consistency
- ✅ Read side optimized for query performance
- ✅ Scale independently
- ✅ Different data models for different needs

---

## Synchronization Strategies

### Strategy 1: Event-Driven (Domain Events)

**Best for:** Event-sourced systems, microservices, real-time updates

**Pattern:** OLTP emits domain events → Event handlers populate OLAP

```
OLTP (Command Side)          Events              OLAP (Query Side)
─────────────────────────────────────────────────────────────────
1. Order placed
   INSERT INTO orders        ──► OrderPlaced ──► INSERT INTO fact_sales
                                                  UPDATE dim_customer

2. Payment received
   INSERT INTO payments      ──► PaymentReceived ──► UPDATE fact_order_fulfillment

3. Order shipped
   UPDATE orders             ──► OrderShipped ──► UPDATE fact_order_fulfillment
```

**Implementation:**

```sql
-- OLTP: Domain event table
CREATE TABLE domain_events (
    event_id BIGSERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,  -- 'OrderPlaced', 'PaymentReceived', etc.
    aggregate_id UUID NOT NULL,        -- Order ID, Customer ID, etc.
    event_data JSONB NOT NULL,         -- Full event payload
    occurred_at TIMESTAMP NOT NULL DEFAULT NOW(),
    processed BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_events_unprocessed ON domain_events(processed) WHERE processed = FALSE;
```

**Event Handler (ETL process):**

```python
# Pseudocode: Event handler for OrderPlaced
def handle_order_placed(event):
    order_data = event['event_data']
    
    # 1. Upsert customer dimension (SCD Type 2)
    customer_key = upsert_customer_dimension(order_data['customer'])
    
    # 2. Ensure product dimension exists
    product_key = get_or_create_product_dimension(order_data['product_id'])
    
    # 3. Get date key
    date_key = get_date_key(order_data['order_date'])
    
    # 4. Insert into fact table
    db.execute("""
        INSERT INTO fact_sales (
            date_key, product_key, customer_key, store_key,
            order_number, quantity, unit_price, total_amount
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    """, (date_key, product_key, customer_key, store_key,
          order_data['order_number'], order_data['quantity'],
          order_data['unit_price'], order_data['total_amount']))
    
    # 5. Mark event as processed
    db.execute("UPDATE domain_events SET processed = TRUE WHERE event_id = %s", 
               (event['event_id'],))
```

**Pros:**
- ✅ Real-time or near-real-time sync
- ✅ Event log provides audit trail
- ✅ Can replay events to rebuild OLAP
- ✅ Decoupled (event handlers can evolve independently)

**Cons:**
- ❌ More complex (event infrastructure needed)
- ❌ Eventual consistency (OLAP lags behind OLTP)
- ❌ Idempotency required (same event processed multiple times)

---

### Strategy 2: Change Data Capture (CDC)

**Best for:** Existing systems, PostgreSQL databases, low-latency requirements

**Pattern:** Capture database changes → Stream to OLAP

**Tools:**
- **PostgreSQL:** Logical replication, pg_logical, Debezium
- **Commercial:** AWS DMS, Google Datastream, Fivetran

**Example: Debezium CDC**

```yaml
# Debezium connector config
connector.class: io.debezium.connector.postgresql.PostgresConnector
database.hostname: oltp-db.example.com
database.dbname: ecommerce
table.include.list: public.orders,public.order_items,public.customers
transforms: route
transforms.route.type: org.apache.kafka.connect.transforms.RegexRouter
transforms.route.regex: ([^.]+)\\.([^.]+)\\.([^.]+)
transforms.route.replacement: olap.$3
```

**CDC Consumer (writes to OLAP):**

```python
# Pseudocode: CDC consumer
def process_cdc_event(change):
    if change['table'] == 'orders' and change['op'] == 'INSERT':
        # New order placed
        sync_order_to_fact_sales(change['after'])
    
    elif change['table'] == 'customers' and change['op'] == 'UPDATE':
        # Customer updated (SCD Type 2)
        handle_customer_dimension_change(change['before'], change['after'])
```

**Pros:**
- ✅ Low latency (near real-time)
- ✅ No code changes to OLTP system
- ✅ Captures all changes (even from other systems)
- ✅ Mature tooling (Debezium, AWS DMS)

**Cons:**
- ❌ Database-level coupling
- ❌ Schema changes require updates
- ❌ Potential performance impact on OLTP

---

### Strategy 3: Batch ETL (Extract-Transform-Load)

**Best for:** Traditional data warehouses, large historical loads, scheduled reporting

**Pattern:** Periodically extract from OLTP → Transform → Load into OLAP

**Schedule:**
- **Hourly:** Real-time dashboards
- **Daily:** Overnight batch (most common)
- **Weekly:** Historical reporting

**Implementation:**

```sql
-- ETL script (runs nightly at 2am)

-- Step 1: Extract new/changed orders from OLTP (incremental)
WITH new_orders AS (
    SELECT 
        o.order_id,
        o.order_date,
        o.customer_id,
        oi.product_id,
        oi.quantity,
        oi.unit_price,
        oi.total_amount
    FROM oltp.orders o
    JOIN oltp.order_items oi ON o.order_id = oi.order_id
    WHERE o.updated_at >= CURRENT_DATE - INTERVAL '1 day'  -- Incremental
)

-- Step 2: Transform and load into OLAP
INSERT INTO olap.fact_sales (
    date_key,
    product_key,
    customer_key,
    order_number,
    quantity,
    unit_price,
    total_amount
)
SELECT 
    to_char(no.order_date, 'YYYYMMDD')::INT AS date_key,
    dp.product_key,
    dc.customer_key,
    no.order_id,
    no.quantity,
    no.unit_price,
    no.total_amount
FROM new_orders no
-- Lookup dimension keys
JOIN olap.dim_product dp ON no.product_id = dp.product_id AND dp.is_current = TRUE
JOIN olap.dim_customer dc ON no.customer_id = dc.customer_id AND dc.is_current = TRUE
ON CONFLICT (order_id, product_id) DO UPDATE  -- Handle reruns (idempotency)
SET quantity = EXCLUDED.quantity,
    total_amount = EXCLUDED.total_amount;
```

**Incremental vs Full Load:**

```sql
-- Incremental (daily changes only - fast)
WHERE updated_at >= CURRENT_DATE - INTERVAL '1 day'

-- Full load (entire table - slow, but simple)
TRUNCATE fact_sales;
INSERT INTO fact_sales SELECT ... FROM oltp.orders;
```

**Pros:**
- ✅ Simple (well-understood pattern)
- ✅ No real-time infrastructure needed
- ✅ Easier to debug and monitor
- ✅ Predictable load (off-peak hours)

**Cons:**
- ❌ Latency (hours to days)
- ❌ Batch window limitations (must finish before business hours)
- ❌ Full loads expensive for large tables

---

## Dimension Synchronization (SCD Type 2)

**Challenge:** OLTP updates customer → How to handle in OLAP with SCD Type 2?

### Example: Customer Address Change

**OLTP (normalized, update in place):**
```sql
-- Customer moves from CA to TX
UPDATE customers
SET state = 'TX', city = 'Austin'
WHERE customer_id = 'C100';
```

**OLAP (denormalized, SCD Type 2):**
```sql
-- Step 1: Detect change (in ETL process)
SELECT 
    oltp.customer_id,
    oltp.state AS new_state,
    olap.state AS old_state
FROM oltp.customers oltp
JOIN olap.dim_customer olap ON oltp.customer_id = olap.customer_id
WHERE olap.is_current = TRUE
  AND oltp.state <> olap.state;  -- Change detected

-- Step 2: Expire old row
UPDATE olap.dim_customer
SET expiration_date = CURRENT_DATE - INTERVAL '1 day',
    is_current = FALSE
WHERE customer_id = 'C100' AND is_current = TRUE;

-- Step 3: Insert new row
INSERT INTO olap.dim_customer (
    customer_id, customer_name, state, city,
    effective_date, expiration_date, is_current
) VALUES (
    'C100', 'Alice Smith', 'TX', 'Austin',
    CURRENT_DATE, NULL, TRUE
);
```

**Result:**
```
customer_key | customer_id | state | effective_date | expiration_date | is_current
-------------|-------------|-------|----------------|-----------------|------------
1            | C100        | CA    | 2023-01-01     | 2024-06-14      | FALSE
2            | C100        | TX    | 2024-06-15     | NULL            | TRUE
```

**Historical facts preserve context** - sales from 2023 still point to customer_key=1 (CA).

---

## Handling Late-Arriving Facts

**Problem:** Fact arrives before dimension is populated.

**Example:** Order placed for new product before product dimension sync runs.

### Solution 1: Unknown Member Pattern

```sql
-- Pre-populate unknown member (product_key = -1)
INSERT INTO dim_product (
    product_key, product_id, product_name, category_l1
) VALUES (
    -1, 'UNKNOWN', 'Unknown Product', 'Unknown'
);

-- Fact table references unknown member
INSERT INTO fact_sales (product_key, ...)
VALUES (-1, ...);  -- Unknown product

-- Later: Update fact when dimension loads
UPDATE fact_sales
SET product_key = (SELECT product_key FROM dim_product WHERE product_id = 'P100')
WHERE product_key = -1
  AND order_number = 'ORD123';  -- Identify specific fact row
```

### Solution 2: Late-Arriving Dimension (Inferred Member)

```sql
-- Create placeholder dimension row (inferred)
INSERT INTO dim_product (
    product_id, product_name, category_l1, is_inferred
) VALUES (
    'P100', 'P100 (Inferred)', 'Unknown', TRUE
) RETURNING product_key;

-- Fact table uses placeholder
INSERT INTO fact_sales (product_key, ...)
VALUES (123, ...);  -- Placeholder product_key

-- Later: Update dimension when real data arrives
UPDATE dim_product
SET product_name = 'Real Product Name',
    category_l1 = 'Electronics',
    is_inferred = FALSE
WHERE product_id = 'P100';
```

---

## Performance Considerations

### 1. Bulk Loading
```sql
-- ❌ Slow: Row-by-row inserts
FOR each order IN new_orders:
    INSERT INTO fact_sales VALUES (...);

-- ✅ Fast: Bulk insert
INSERT INTO fact_sales (date_key, product_key, ...)
SELECT 
    to_char(o.order_date, 'YYYYMMDD')::INT,
    dp.product_key,
    ...
FROM staging.new_orders o
JOIN dim_product dp ON o.product_id = dp.product_id;
```

### 2. Indexing During Loads
```sql
-- Drop indexes before large bulk load
DROP INDEX idx_sales_date;
DROP INDEX idx_sales_product;

-- Bulk insert (faster without indexes)
INSERT INTO fact_sales SELECT ... FROM staging.orders;

-- Rebuild indexes
CREATE INDEX idx_sales_date ON fact_sales(date_key);
CREATE INDEX idx_sales_product ON fact_sales(product_key);
```

### 3. Partitioning
```sql
-- Partition fact table by date (drop old partitions easily)
CREATE TABLE fact_sales (
    sale_id BIGSERIAL,
    date_key INT NOT NULL,
    ...
) PARTITION BY RANGE (date_key);

-- Create partitions
CREATE TABLE fact_sales_2024_01 PARTITION OF fact_sales
    FOR VALUES FROM (20240101) TO (20240201);

-- Load only into current partition (fast)
INSERT INTO fact_sales_2024_01 SELECT ...;
```

---

## Monitoring & Validation

### Data Quality Checks

```sql
-- Check: Fact count matches source
SELECT 
    'OLTP' AS source, COUNT(*) AS order_count
FROM oltp.orders
WHERE order_date >= '2024-01-01'
UNION ALL
SELECT 
    'OLAP' AS source, COUNT(DISTINCT order_number) AS order_count
FROM olap.fact_sales
WHERE date_key >= 20240101;

-- Check: Revenue reconciliation
SELECT 
    'OLTP' AS source, SUM(total_amount) AS total_revenue
FROM oltp.orders
WHERE order_date >= '2024-01-01'
UNION ALL
SELECT 
    'OLAP' AS source, SUM(total_amount) AS total_revenue
FROM olap.fact_sales
WHERE date_key >= 20240101;

-- Check: Orphaned facts (missing dimensions)
SELECT COUNT(*)
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_key = p.product_key
WHERE p.product_key IS NULL;  -- Should be 0 (or only unknown member)
```

### ETL Logging

```sql
-- ETL run log table
CREATE TABLE etl_run_log (
    run_id BIGSERIAL PRIMARY KEY,
    job_name VARCHAR(100) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    status VARCHAR(20),  -- 'running', 'success', 'failed'
    rows_processed INT,
    rows_inserted INT,
    rows_updated INT,
    error_message TEXT
);

-- Log each ETL run
INSERT INTO etl_run_log (job_name, start_time, status)
VALUES ('daily_sales_sync', NOW(), 'running')
RETURNING run_id;
```

---

## Key Takeaways

1. **CQRS separates concerns** - OLTP for writes, OLAP for reads
2. **Three sync strategies:**
   - Event-driven (real-time, complex)
   - CDC (near-real-time, transparent)
   - Batch ETL (simple, scheduled)
3. **SCD Type 2 preserves history** - expire old row, insert new row
4. **Unknown member pattern** - handle late-arriving dimensions
5. **Bulk loading** - faster than row-by-row
6. **Monitor data quality** - reconcile counts and totals
7. **Idempotency** - ETL should be rerunnable without duplicates

**Recommended approach:**
- Start with batch ETL (simplest)
- Move to CDC if latency requirements demand it
- Add event-driven sync for specific real-time needs

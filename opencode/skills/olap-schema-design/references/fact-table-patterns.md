# Fact Table Patterns

Fact tables are the core of dimensional models, containing the numeric measurements that answer business questions. Understanding the three types of fact tables is crucial for proper dimensional modeling.

---

## Three Types of Fact Tables

### 1. Transaction Fact Tables

**Definition:** One row per business event (most atomic grain).

**Characteristics:**
- Most common type (80% of fact tables)
- Atomic grain (individual transactions)
- Insert-only (immutable once written)
- Additive facts across all dimensions
- Grows continuously

**When to use:**
- Sales transactions, orders, payments
- Web clicks, page views, ad impressions
- Sensor readings, IoT events
- Financial transactions

**Example: E-commerce Sales**
```sql
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    -- Dimensions
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    store_key INT NOT NULL,
    promotion_key INT,
    -- Degenerate dimensions
    order_number VARCHAR(50) NOT NULL,
    line_item_number INT NOT NULL,
    -- Facts (additive)
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    shipping_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL
);
```

**Grain:** One row per order line item

**Query example:**
```sql
-- Daily sales by product category
SELECT 
    d.full_date,
    p.category_l1,
    SUM(f.quantity) AS units_sold,
    SUM(f.total_amount) AS revenue,
    SUM(f.profit) AS profit
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
WHERE d.year = 2024
GROUP BY d.full_date, p.category_l1;
```

---

### 2. Periodic Snapshot Fact Tables

**Definition:** One row per time period (daily, weekly, monthly).

**Characteristics:**
- Regular intervals (daily inventory, monthly account balance)
- Dense table (row for every entity × time period)
- Update or insert (depending on design)
- Semi-additive facts (can't SUM across time)
- Fixed size (rows = entities × periods)

**When to use:**
- Inventory levels (daily snapshot)
- Account balances (monthly snapshot)
- Performance metrics (weekly snapshot)
- Status tracking over time

**Example: Daily Inventory Snapshot**
```sql
CREATE TABLE fact_inventory_daily (
    inventory_snapshot_key BIGSERIAL PRIMARY KEY,
    -- Dimensions
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    warehouse_key INT NOT NULL,
    -- Facts (semi-additive - don't SUM across time)
    quantity_on_hand INT NOT NULL,
    quantity_reserved INT NOT NULL,
    quantity_available INT NOT NULL,
    -- Facts (additive)
    quantity_received_today INT NOT NULL,
    quantity_shipped_today INT NOT NULL,
    quantity_adjusted_today INT NOT NULL,
    -- Calculated
    days_of_supply INT,
    inventory_value DECIMAL(12,2) NOT NULL,
    -- Uniqueness constraint
    UNIQUE(date_key, product_key, warehouse_key)
);
```

**Grain:** One row per product per warehouse per day

**Query example:**
```sql
-- Current inventory levels by warehouse
SELECT 
    w.warehouse_name,
    p.product_name,
    f.quantity_available,
    f.inventory_value,
    f.days_of_supply
FROM fact_inventory_daily f
JOIN dim_warehouse w ON f.warehouse_key = w.warehouse_key
JOIN dim_product p ON f.product_key = p.product_key
WHERE f.date_key = (SELECT MAX(date_key) FROM fact_inventory_daily)
  AND f.quantity_available < 100  -- Low stock alert
ORDER BY f.days_of_supply;
```

**Important:** Don't SUM quantity_on_hand across dates (meaningless). Use for point-in-time analysis or change over time (current - previous).

---

### 3. Accumulating Snapshot Fact Tables

**Definition:** One row per process instance, updated as it progresses through stages.

**Characteristics:**
- Tracks process lifecycle (order → ship → deliver)
- Multiple date foreign keys (one per milestone)
- Updated in place (not insert-only)
- Includes lag calculations between stages
- Small table (one row per active process)

**When to use:**
- Order fulfillment pipeline
- Loan application workflow
- Manufacturing process tracking
- Customer onboarding journey

**Example: Order Fulfillment Pipeline**
```sql
CREATE TABLE fact_order_fulfillment (
    order_key BIGSERIAL PRIMARY KEY,
    -- Dimensions
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    warehouse_key INT NOT NULL,
    -- Multiple date dimensions (one per milestone)
    order_date_key INT NOT NULL,
    payment_date_key INT,
    shipment_date_key INT,
    delivery_date_key INT,
    -- Facts (measurements)
    quantity INT NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL,
    shipping_cost DECIMAL(10,2),
    -- Lag facts (days between stages)
    payment_lag_days INT,         -- payment - order
    fulfillment_lag_days INT,     -- shipment - order
    delivery_lag_days INT,        -- delivery - shipment
    total_cycle_time_days INT,    -- delivery - order
    -- Status tracking
    current_status VARCHAR(50) NOT NULL,  -- ordered, paid, shipped, delivered, cancelled
    is_complete BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes for tracking active orders
CREATE INDEX idx_order_status ON fact_order_fulfillment(current_status) 
    WHERE is_complete = FALSE;
CREATE INDEX idx_order_customer ON fact_order_fulfillment(customer_key);
```

**Grain:** One row per order

**Lifecycle updates:**
```sql
-- 1. Order placed
INSERT INTO fact_order_fulfillment (
    customer_key, product_key, warehouse_key,
    order_date_key, quantity, order_amount, current_status
) VALUES (1234, 5678, 10, 20240115, 2, 99.99, 'ordered');

-- 2. Payment received
UPDATE fact_order_fulfillment
SET payment_date_key = 20240115,
    payment_lag_days = 0,
    current_status = 'paid'
WHERE order_key = 999;

-- 3. Order shipped
UPDATE fact_order_fulfillment
SET shipment_date_key = 20240116,
    fulfillment_lag_days = 1,
    shipping_cost = 9.99,
    current_status = 'shipped'
WHERE order_key = 999;

-- 4. Order delivered
UPDATE fact_order_fulfillment
SET delivery_date_key = 20240118,
    delivery_lag_days = 2,
    total_cycle_time_days = 3,
    current_status = 'delivered',
    is_complete = TRUE
WHERE order_key = 999;
```

**Query example:**
```sql
-- Average cycle times by warehouse
SELECT 
    w.warehouse_name,
    AVG(f.payment_lag_days) AS avg_payment_lag,
    AVG(f.fulfillment_lag_days) AS avg_fulfillment_lag,
    AVG(f.delivery_lag_days) AS avg_delivery_lag,
    AVG(f.total_cycle_time_days) AS avg_total_cycle_time,
    COUNT(*) AS completed_orders
FROM fact_order_fulfillment f
JOIN dim_warehouse w ON f.warehouse_key = w.warehouse_key
WHERE f.is_complete = TRUE
  AND f.order_date_key >= 20240101
GROUP BY w.warehouse_name
ORDER BY avg_total_cycle_time;
```

---

## Fact Table Additivity

### Additive Facts
- **Definition:** Can SUM across all dimensions
- **Examples:** quantity, amount, cost, profit, count
- **Preferred:** Most flexible for analysis

```sql
-- ✅ Additive: can SUM quantity across all dimensions
SELECT 
    SUM(quantity) AS total_units,
    SUM(total_amount) AS total_revenue
FROM fact_sales
WHERE date_key BETWEEN 20240101 AND 20241231;
```

### Semi-Additive Facts
- **Definition:** Can SUM across some dimensions (not time)
- **Examples:** account balance, inventory level, headcount
- **Common in:** Periodic snapshot fact tables

```sql
-- ✅ Correct: Current inventory (single point in time)
SELECT 
    p.category_l1,
    SUM(f.quantity_on_hand) AS total_inventory
FROM fact_inventory_daily f
JOIN dim_product p ON f.product_key = p.product_key
WHERE f.date_key = 20240115  -- Single date
GROUP BY p.category_l1;

-- ❌ Incorrect: Don't SUM across dates (meaningless)
SELECT 
    SUM(f.quantity_on_hand) AS wrong_total
FROM fact_inventory_daily f
WHERE f.date_key BETWEEN 20240101 AND 20240131;  -- ❌ Nonsense result

-- ✅ Correct: Average inventory over time
SELECT 
    p.category_l1,
    AVG(f.quantity_on_hand) AS avg_inventory
FROM fact_inventory_daily f
JOIN dim_product p ON f.product_key = p.product_key
WHERE f.date_key BETWEEN 20240101 AND 20240131
GROUP BY p.category_l1;
```

### Non-Additive Facts
- **Definition:** Cannot SUM across any dimension
- **Examples:** ratios, percentages, averages, unit prices
- **Solution:** Store components instead, calculate in query

```sql
-- ❌ Don't store: profit_margin (ratio)
-- ✅ Store: profit, revenue → calculate margin in query
SELECT 
    p.category_l1,
    SUM(f.profit) AS total_profit,
    SUM(f.revenue) AS total_revenue,
    SUM(f.profit)::DECIMAL / NULLIF(SUM(f.revenue), 0) AS profit_margin
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category_l1;
```

---

## Fact Table Design Checklist

- [ ] **Grain defined:** Crystal clear what one row represents
- [ ] **All facts numeric:** No descriptive text (belongs in dimensions)
- [ ] **Additive facts preferred:** Store components of ratios, not ratios themselves
- [ ] **Foreign keys only:** To dimensions, no descriptive attributes
- [ ] **Null handling:** Allow NULLs for optional dimensions (use null key pattern)
- [ ] **Degenerate dimensions:** Order numbers, transaction IDs stored in fact
- [ ] **Indexes:** All foreign keys indexed
- [ ] **Primary key:** Surrogate key (BIGSERIAL) or natural key if truly unique
- [ ] **Partitioning:** Consider for very large tables (partition by date)

---

## Choosing the Right Fact Table Type

| Business Process | Fact Table Type | Grain | Example |
|------------------|----------------|-------|---------|
| Sales transactions | Transaction | One row per line item | E-commerce orders |
| Web analytics | Transaction | One row per page view | Google Analytics |
| Daily inventory | Periodic Snapshot | One row per product per day | Warehouse stock |
| Monthly account balance | Periodic Snapshot | One row per account per month | Banking balances |
| Order fulfillment | Accumulating Snapshot | One row per order (updated) | Order → Ship → Deliver |
| Loan application | Accumulating Snapshot | One row per application (updated) | Apply → Approve → Fund |

---

## Advanced: Factless Fact Tables

**Definition:** Fact table with no numeric measurements (only foreign keys).

**Use cases:**
- Event tracking (attendance, coverage, eligibility)
- Many-to-many relationships with dates

**Example: Student Course Attendance**
```sql
CREATE TABLE fact_attendance (
    attendance_key BIGSERIAL PRIMARY KEY,
    date_key INT NOT NULL,
    student_key INT NOT NULL,
    course_key INT NOT NULL,
    instructor_key INT NOT NULL,
    -- No numeric facts, just the event occurrence
    UNIQUE(date_key, student_key, course_key)
);

-- Query: How many students attended each course?
SELECT 
    c.course_name,
    d.full_date,
    COUNT(*) AS students_attended
FROM fact_attendance f
JOIN dim_course c ON f.course_key = c.course_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY c.course_name, d.full_date;
```

---

## Performance Optimization

### Partitioning (for large fact tables)
```sql
-- Partition by date range (monthly)
CREATE TABLE fact_sales (
    sale_id BIGSERIAL,
    date_key INT NOT NULL,
    -- other columns...
) PARTITION BY RANGE (date_key);

-- Create partitions
CREATE TABLE fact_sales_2024_01 PARTITION OF fact_sales
    FOR VALUES FROM (20240101) TO (20240201);

CREATE TABLE fact_sales_2024_02 PARTITION OF fact_sales
    FOR VALUES FROM (20240201) TO (20240301);
```

### BRIN Indexes (for time-series fact tables)
```sql
-- BRIN index on date_key (clustered data)
CREATE INDEX idx_sales_date_brin ON fact_sales USING BRIN(date_key);
```

### Materialized Views (for common aggregations)
```sql
-- Pre-aggregate daily sales by category
CREATE MATERIALIZED VIEW mv_daily_sales_by_category AS
SELECT 
    d.date_key,
    d.full_date,
    p.category_l1,
    SUM(f.quantity) AS total_quantity,
    SUM(f.total_amount) AS total_sales
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY d.date_key, d.full_date, p.category_l1;

-- Refresh nightly
CREATE INDEX idx_mv_date ON mv_daily_sales_by_category(date_key);
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales_by_category;
```

---

## Key Takeaways

1. **Transaction facts** are most common (insert-only, atomic grain)
2. **Periodic snapshots** track state over time (semi-additive)
3. **Accumulating snapshots** track process lifecycle (update in place)
4. **Always define grain first** - most important design decision
5. **Prefer additive facts** - store components of ratios, not ratios
6. **Keep facts numeric** - text belongs in dimensions
7. **Index all foreign keys** - critical for join performance
8. **Partition large tables** - by date for time-series data

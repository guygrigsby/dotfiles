# Special Dimension Patterns

Advanced dimension types beyond standard descriptive dimensions.

---

## 1. Date Dimension (Time Intelligence)

**Most important dimension** - nearly every fact table has a date foreign key.

### Why Not Use DATE Type?

❌ **Bad: Direct date column in fact**
```sql
CREATE TABLE fact_sales (
    order_date DATE,  -- ❌ Missing time intelligence
    ...
);

-- Query requires date functions (slow, complex)
SELECT 
    EXTRACT(YEAR FROM order_date),
    EXTRACT(QUARTER FROM order_date),
    SUM(total_amount)
FROM fact_sales
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(QUARTER FROM order_date);
```

✅ **Good: Date dimension**
```sql
CREATE TABLE fact_sales (
    date_key INT,  -- ✅ FK to dim_date (20240101)
    ...
);

-- Query is simple and fast
SELECT 
    d.year,
    d.quarter_name,
    SUM(f.total_amount)
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.quarter_name;
```

### Complete Date Dimension Schema

```sql
CREATE TABLE dim_date (
    -- Surrogate key (YYYYMMDD format)
    date_key INT PRIMARY KEY,  -- 20240101, 20240102, etc.
    
    -- Date value
    full_date DATE UNIQUE NOT NULL,
    
    -- Day attributes
    day_of_week INT NOT NULL,          -- 1-7 (1=Monday)
    day_of_week_name VARCHAR(10) NOT NULL,  -- Monday, Tuesday, ...
    day_of_week_abbr CHAR(3) NOT NULL, -- Mon, Tue, ...
    day_of_month INT NOT NULL,         -- 1-31
    day_of_year INT NOT NULL,          -- 1-366
    day_suffix VARCHAR(4) NOT NULL,    -- st, nd, rd, th
    
    -- Week attributes
    week_of_year INT NOT NULL,         -- 1-53
    week_of_month INT NOT NULL,        -- 1-5
    week_start_date DATE NOT NULL,     -- Monday of this week
    week_end_date DATE NOT NULL,       -- Sunday of this week
    
    -- Month attributes
    month INT NOT NULL,                -- 1-12
    month_name VARCHAR(10) NOT NULL,   -- January, February, ...
    month_abbr CHAR(3) NOT NULL,       -- Jan, Feb, ...
    month_start_date DATE NOT NULL,    -- First day of month
    month_end_date DATE NOT NULL,      -- Last day of month
    days_in_month INT NOT NULL,        -- 28-31
    
    -- Quarter attributes
    quarter INT NOT NULL,              -- 1-4
    quarter_name VARCHAR(2) NOT NULL,  -- Q1, Q2, Q3, Q4
    quarter_start_date DATE NOT NULL,  -- First day of quarter
    quarter_end_date DATE NOT NULL,    -- Last day of quarter
    
    -- Year attributes
    year INT NOT NULL,                 -- 2024
    year_month INT NOT NULL,           -- 202401 (YYYYMM)
    year_quarter INT NOT NULL,         -- 20241 (YYYYQ)
    
    -- Fiscal period (if different from calendar)
    fiscal_year INT NOT NULL,
    fiscal_quarter INT NOT NULL,
    fiscal_month INT NOT NULL,
    fiscal_week INT NOT NULL,
    
    -- Flags
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN NOT NULL,
    is_business_day BOOLEAN NOT NULL,
    
    -- Holiday details
    holiday_name VARCHAR(100),         -- Christmas, Thanksgiving, etc.
    holiday_type VARCHAR(50),          -- Federal, Religious, Company
    
    -- Relative periods (useful for filtering)
    is_current_day BOOLEAN NOT NULL DEFAULT FALSE,
    is_current_week BOOLEAN NOT NULL DEFAULT FALSE,
    is_current_month BOOLEAN NOT NULL DEFAULT FALSE,
    is_current_quarter BOOLEAN NOT NULL DEFAULT FALSE,
    is_current_year BOOLEAN NOT NULL DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_date_full_date ON dim_date(full_date);
CREATE INDEX idx_date_year_month ON dim_date(year, month);
CREATE INDEX idx_date_fiscal ON dim_date(fiscal_year, fiscal_quarter);
```

### Pre-Populating Date Dimension

```sql
-- Populate 10 years of dates (2020-2030)
INSERT INTO dim_date (
    date_key, full_date, day_of_week, day_of_week_name,
    day_of_month, day_of_year, month, month_name, quarter,
    quarter_name, year, is_weekend, is_holiday, holiday_name
)
SELECT 
    to_char(d, 'YYYYMMDD')::INT AS date_key,
    d AS full_date,
    EXTRACT(DOW FROM d) + 1 AS day_of_week,
    to_char(d, 'Day') AS day_of_week_name,
    EXTRACT(DAY FROM d) AS day_of_month,
    EXTRACT(DOY FROM d) AS day_of_year,
    EXTRACT(MONTH FROM d) AS month,
    to_char(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d) AS quarter,
    'Q' || EXTRACT(QUARTER FROM d) AS quarter_name,
    EXTRACT(YEAR FROM d) AS year,
    EXTRACT(DOW FROM d) IN (0, 6) AS is_weekend,
    FALSE AS is_holiday,  -- Update separately
    NULL AS holiday_name
FROM generate_series(
    '2020-01-01'::DATE,
    '2030-12-31'::DATE,
    '1 day'::INTERVAL
) AS d;

-- Add holidays (US federal holidays example)
UPDATE dim_date
SET is_holiday = TRUE,
    holiday_name = 'New Year''s Day'
WHERE month = 1 AND day_of_month = 1;

UPDATE dim_date
SET is_holiday = TRUE,
    holiday_name = 'Christmas'
WHERE month = 12 AND day_of_month = 25;

-- ... add more holidays
```

### Query Examples

```sql
-- Sales by day of week
SELECT 
    d.day_of_week_name,
    SUM(f.total_amount) AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.day_of_week, d.day_of_week_name
ORDER BY d.day_of_week;

-- Sales on weekends vs weekdays
SELECT 
    CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    SUM(f.total_amount) AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.is_weekend;

-- Sales during holiday periods
SELECT 
    d.holiday_name,
    SUM(f.total_amount) AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.is_holiday = TRUE
GROUP BY d.holiday_name
ORDER BY revenue DESC;
```

---

## 2. Time-of-Day Dimension

**When grain includes specific time** (clickstream, transaction timestamp).

```sql
CREATE TABLE dim_time (
    time_key INT PRIMARY KEY,          -- HHMMSS format (143000 = 2:30 PM)
    time_value TIME NOT NULL,
    
    -- Hour attributes
    hour INT NOT NULL,                 -- 0-23
    hour_12 INT NOT NULL,              -- 1-12
    am_pm CHAR(2) NOT NULL,            -- AM, PM
    hour_name VARCHAR(20) NOT NULL,    -- 2:00 PM
    
    -- Minute attributes
    minute INT NOT NULL,               -- 0-59
    minute_of_day INT NOT NULL,        -- 0-1439
    
    -- Second attributes
    second INT NOT NULL,               -- 0-59
    second_of_day INT NOT NULL,        -- 0-86399
    
    -- Time periods
    day_part VARCHAR(20) NOT NULL,     -- Morning, Afternoon, Evening, Night
    business_hour BOOLEAN NOT NULL,    -- 9am-5pm
    peak_hour BOOLEAN NOT NULL,        -- Rush hours (customize)
    
    -- 30-minute buckets
    time_bucket_30 VARCHAR(20) NOT NULL  -- '14:00-14:30'
);

-- Populate all times at minute granularity
INSERT INTO dim_time (time_key, time_value, hour, minute, second, day_part)
SELECT 
    to_char(t, 'HH24MISS')::INT AS time_key,
    t::TIME AS time_value,
    EXTRACT(HOUR FROM t) AS hour,
    EXTRACT(MINUTE FROM t) AS minute,
    0 AS second,
    CASE 
        WHEN EXTRACT(HOUR FROM t) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM t) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN EXTRACT(HOUR FROM t) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS day_part
FROM generate_series(
    '00:00:00'::TIME,
    '23:59:00'::TIME,
    '1 minute'::INTERVAL
) AS t;
```

---

## 3. Junk Dimension (Transaction Flags)

**Combine low-cardinality flags** to avoid cluttering fact table.

### Anti-Pattern: Flags in Fact Table

❌ **Bad: Many boolean columns in fact**
```sql
CREATE TABLE fact_sales (
    ...,
    is_taxable BOOLEAN,
    is_discounted BOOLEAN,
    is_rush_order BOOLEAN,
    is_gift_wrap BOOLEAN,
    is_international BOOLEAN,
    payment_type VARCHAR(20)
    -- ❌ Too many flags (wastes space, hard to analyze)
);
```

### Pattern: Junk Dimension

✅ **Good: Combine into junk dimension**
```sql
CREATE TABLE dim_order_flags (
    order_flags_key SERIAL PRIMARY KEY,
    is_taxable BOOLEAN NOT NULL,
    is_discounted BOOLEAN NOT NULL,
    is_rush_order BOOLEAN NOT NULL,
    is_gift_wrap BOOLEAN NOT NULL,
    is_international BOOLEAN NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    -- Unique constraint (avoid duplicates)
    UNIQUE(is_taxable, is_discounted, is_rush_order, 
           is_gift_wrap, is_international, payment_type)
);

-- Pre-populate all combinations (2^5 * 3 payment types = 96 rows)
INSERT INTO dim_order_flags (
    is_taxable, is_discounted, is_rush_order, 
    is_gift_wrap, is_international, payment_type
)
SELECT 
    t.is_taxable,
    t.is_discounted,
    t.is_rush_order,
    t.is_gift_wrap,
    t.is_international,
    pt.payment_type
FROM (SELECT TRUE AS val UNION SELECT FALSE) AS taxable(is_taxable)
CROSS JOIN (SELECT TRUE AS val UNION SELECT FALSE) AS discounted(is_discounted)
CROSS JOIN (SELECT TRUE AS val UNION SELECT FALSE) AS rush(is_rush_order)
CROSS JOIN (SELECT TRUE AS val UNION SELECT FALSE) AS gift(is_gift_wrap)
CROSS JOIN (SELECT TRUE AS val UNION SELECT FALSE) AS intl(is_international)
CROSS JOIN (VALUES ('Credit Card'), ('PayPal'), ('Cash')) AS pt(payment_type);

-- Fact table now has single FK
CREATE TABLE fact_sales (
    ...,
    order_flags_key INT NOT NULL REFERENCES dim_order_flags(order_flags_key)
);
```

**Query:**
```sql
-- Count of rush orders by payment type
SELECT 
    of.payment_type,
    COUNT(*) AS rush_order_count
FROM fact_sales f
JOIN dim_order_flags of ON f.order_flags_key = of.order_flags_key
WHERE of.is_rush_order = TRUE
GROUP BY of.payment_type;
```

---

## 4. Degenerate Dimension

**Dimension stored in fact table** (no separate dimension table).

**When to use:**
- Only one attribute (transaction ID, order number)
- High cardinality (unique or near-unique values)
- No other attributes needed

```sql
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    -- Regular dimensions (FKs)
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    -- Degenerate dimensions (stored directly in fact)
    order_number VARCHAR(50) NOT NULL,  -- ✅ Degenerate dimension
    invoice_number VARCHAR(50) NOT NULL,  -- ✅ Degenerate dimension
    -- Facts
    quantity INT,
    total_amount DECIMAL(10,2)
);

-- Index for lookups
CREATE INDEX idx_sales_order_number ON fact_sales(order_number);
```

**Use cases:**
- Order number (unique per order, no other attributes)
- Invoice number
- Transaction ID
- Confirmation code

---

## 5. Role-Playing Dimension

**Same dimension used multiple times** with different meaning.

### Example: Multiple Dates

```sql
CREATE TABLE fact_order_fulfillment (
    order_key BIGSERIAL PRIMARY KEY,
    -- Same dimension (dim_date) used 4 times
    order_date_key INT NOT NULL,      ──┐
    payment_date_key INT,               ├──► dim_date (role-playing)
    shipment_date_key INT,              │
    delivery_date_key INT,            ──┘
    ...
);

-- All FK reference same dim_date table
ALTER TABLE fact_order_fulfillment
    ADD FOREIGN KEY (order_date_key) REFERENCES dim_date(date_key),
    ADD FOREIGN KEY (payment_date_key) REFERENCES dim_date(date_key),
    ADD FOREIGN KEY (shipment_date_key) REFERENCES dim_date(date_key),
    ADD FOREIGN KEY (delivery_date_key) REFERENCES dim_date(date_key);
```

### Query with Role-Playing Dimension

```sql
-- Average days between order and delivery
SELECT 
    AVG(del.full_date - ord.full_date) AS avg_delivery_days
FROM fact_order_fulfillment f
JOIN dim_date ord ON f.order_date_key = ord.date_key
JOIN dim_date del ON f.delivery_date_key = del.date_key
WHERE f.delivery_date_key IS NOT NULL;
```

### Optional: Create Views for Clarity

```sql
-- Alias views for each role
CREATE VIEW dim_order_date AS SELECT * FROM dim_date;
CREATE VIEW dim_payment_date AS SELECT * FROM dim_date;
CREATE VIEW dim_shipment_date AS SELECT * FROM dim_date;
CREATE VIEW dim_delivery_date AS SELECT * FROM dim_date;

-- BI tools can use separate views (clearer)
```

**Common role-playing dimensions:**
- **dim_date:** order_date, ship_date, delivery_date, return_date
- **dim_customer:** bill_to_customer, ship_to_customer
- **dim_location:** origin, destination

---

## 6. Conformed Dimension

**Shared dimension across multiple fact tables** (same structure, same keys).

### Example: Customer Dimension Shared Across Facts

```sql
-- One customer dimension (conformed)
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(255),
    ...
);

-- Multiple fact tables reference same dimension
CREATE TABLE fact_sales (
    customer_key INT REFERENCES dim_customer(customer_key),  ← Conformed
    ...
);

CREATE TABLE fact_support_tickets (
    customer_key INT REFERENCES dim_customer(customer_key),  ← Conformed
    ...
);

CREATE TABLE fact_web_analytics (
    customer_key INT REFERENCES dim_customer(customer_key),  ← Conformed
    ...
);
```

### Benefits

**Drill-across queries** (combine metrics from multiple fact tables):
```sql
-- Customer lifetime value + support tickets
SELECT 
    c.customer_name,
    SUM(s.total_amount) AS lifetime_revenue,
    COUNT(DISTINCT st.ticket_id) AS support_ticket_count
FROM dim_customer c
LEFT JOIN fact_sales s ON c.customer_key = s.customer_key
LEFT JOIN fact_support_tickets st ON c.customer_key = st.customer_key
GROUP BY c.customer_key, c.customer_name;
```

**Common conformed dimensions:**
- **dim_date** - shared across all fact tables
- **dim_customer** - shared across sales, support, marketing
- **dim_product** - shared across sales, inventory, returns
- **dim_store** - shared across sales, inventory, employees

---

## 7. Mini-Dimension (Rapidly Changing Attributes)

**Problem:** Customer has millions of rows due to frequent changes (SCD Type 2 explosion).

**Solution:** Split into static dimension + mini-dimension for rapidly changing attributes.

```sql
-- Main customer dimension (static attributes)
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    customer_name VARCHAR(255),
    email VARCHAR(255),
    -- Static attributes (rarely change)
    date_of_birth DATE,
    gender VARCHAR(20),
    ...
);

-- Mini-dimension (rapidly changing attributes)
CREATE TABLE dim_customer_demographics (
    demographics_key SERIAL PRIMARY KEY,
    age_range VARCHAR(20),           -- Changes annually
    income_tier VARCHAR(20),         -- Changes frequently
    credit_score_tier VARCHAR(20),   -- Changes frequently
    customer_segment VARCHAR(50),    -- VIP, Regular, etc.
    ...
);

-- Fact table has FK to both
CREATE TABLE fact_sales (
    customer_key INT,            -- Main dimension
    demographics_key INT,        -- Mini-dimension
    ...
);
```

**Benefits:**
- ✅ Reduces dimension explosion (fewer customer rows)
- ✅ Tracks rapidly changing attributes separately
- ✅ Main dimension remains manageable size

---

## Key Takeaways

1. **Date dimension is mandatory** - Pre-populate 10+ years
2. **Time dimension for timestamp grain** - Pre-populate all times
3. **Junk dimensions combine flags** - Avoid fact table clutter
4. **Degenerate dimensions for IDs** - Order number, invoice number
5. **Role-playing dimensions reduce tables** - Same dim_date for multiple dates
6. **Conformed dimensions enable drill-across** - Share dim_customer, dim_product
7. **Mini-dimensions handle rapid changes** - Split static from volatile attributes

**Kimball's guidance:**
- "Pre-populate date dimension for 20 years"
- "Conform dimensions across business processes"
- "Use role-playing dimensions instead of copies"

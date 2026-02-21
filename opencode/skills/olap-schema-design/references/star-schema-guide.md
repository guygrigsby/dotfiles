# Star Schema Guide

The star schema is the simplest and most widely used dimensional modeling technique. Named for its star-like appearance when visualized, with a central fact table surrounded by dimension tables.

---

## Structure

```
Dimension Tables (Denormalized)
        │
        ▼
┌───────────────────────────────────────┐
│         Fact Table (Center)           │
│  ┌─────────────────────────────────┐  │
│  │ Foreign Keys to Dimensions      │  │
│  │ + Numeric Facts (Measurements)  │  │
│  └─────────────────────────────────┘  │
└───────────────────────────────────────┘
        ▲
        │
Dimension Tables (Denormalized)
```

---

## Key Principles

### 1. One Central Fact Table
- Contains measurements/metrics (numbers)
- Narrow table (columns: FKs + facts)
- Tall table (many rows - millions to billions)
- Grain defines what one row represents

### 2. Multiple Dimension Tables
- Contains descriptive attributes (text, categories)
- Wide tables (50-100+ columns common)
- Short tables (fewer rows - thousands to millions)
- Fully denormalized (no normalization)

### 3. Direct Relationships Only
- Fact table has FKs to dimensions
- **No FKs between dimensions** (key difference from snowflake)
- All joins go through fact table

---

## Example: E-commerce Sales

### Visual Schema

```
┌────────────────┐
│   dim_product  │
│  product_key   │◄─┐
│  product_id    │  │
│  product_name  │  │
│  category_l1   │  │
│  category_l2   │  │
│  brand         │  │
└────────────────┘  │
                    │
┌────────────────┐  │  ┌─────────────────┐
│   dim_date     │  │  │   fact_sales    │
│  date_key      │◄─┼──┤  sale_id        │
│  full_date     │  │  │  date_key       │──┐
│  day_of_week   │  │  │  product_key    │──┘
│  month         │  │  │  customer_key   │──┐
│  quarter       │  │  │  store_key      │──┤
│  fiscal_year   │  │  │  order_number   │  │
└────────────────┘  │  │  quantity       │  │
                    │  │  unit_price     │  │
                    │  │  total_amount   │  │
                    │  └─────────────────┘  │
                    │                       │
┌────────────────┐  │                       │
│  dim_customer  │  │                       │
│  customer_key  │◄─┘                       │
│  customer_id   │                          │
│  customer_name │                          │
│  city          │                          │
│  state         │                          │
│  country       │                          │
│  segment       │                          │
└────────────────┘                          │
                                            │
┌────────────────┐                          │
│   dim_store    │                          │
│  store_key     │◄─────────────────────────┘
│  store_id      │
│  store_name    │
│  city          │
│  region        │
│  store_type    │
└────────────────┘
```

### SQL Schema

```sql
-- Fact Table (Center)
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    -- Dimension foreign keys
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    store_key INT NOT NULL,
    -- Degenerate dimension
    order_number VARCHAR(50) NOT NULL,
    -- Facts (measurements)
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    -- Indexes
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
);

CREATE INDEX idx_sales_date ON fact_sales(date_key);
CREATE INDEX idx_sales_product ON fact_sales(product_key);
CREATE INDEX idx_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_sales_store ON fact_sales(store_key);

-- Dimension: Product
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    -- Denormalized hierarchy (no separate category table)
    category_l1 VARCHAR(100),  -- Department
    category_l2 VARCHAR(100),  -- Category
    category_l3 VARCHAR(100),  -- Subcategory
    brand VARCHAR(100),
    manufacturer VARCHAR(100),
    unit_of_measure VARCHAR(20),
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_product_natural_key ON dim_product(product_id);
CREATE INDEX idx_product_current ON dim_product(is_current) WHERE is_current = TRUE;

-- Dimension: Customer
CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    -- Denormalized address
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    -- Denormalized segments
    customer_segment VARCHAR(50),  -- VIP, Regular, New
    lifetime_value_tier VARCHAR(50),  -- High, Medium, Low
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_customer_natural_key ON dim_customer(customer_id);
CREATE INDEX idx_customer_current ON dim_customer(is_current) WHERE is_current = TRUE;

-- Dimension: Store
CREATE TABLE dim_store (
    store_key SERIAL PRIMARY KEY,
    store_id VARCHAR(50) UNIQUE NOT NULL,
    store_name VARCHAR(255) NOT NULL,
    -- Denormalized location
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    region VARCHAR(100),  -- Northeast, Southwest, etc.
    -- Store attributes
    store_type VARCHAR(50),  -- Flagship, Outlet, Pop-up
    square_footage INT,
    opening_date DATE,
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_store_natural_key ON dim_store(store_id);
CREATE INDEX idx_store_current ON dim_store(is_current) WHERE is_current = TRUE;

-- Dimension: Date (pre-populate)
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,  -- YYYYMMDD format (20240101)
    full_date DATE UNIQUE NOT NULL,
    day_of_week VARCHAR(10) NOT NULL,  -- Monday, Tuesday, ...
    day_of_month INT NOT NULL,
    day_of_year INT NOT NULL,
    week_of_year INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,  -- January, February, ...
    quarter INT NOT NULL,
    quarter_name VARCHAR(2) NOT NULL,  -- Q1, Q2, Q3, Q4
    year INT NOT NULL,
    fiscal_year INT NOT NULL,
    fiscal_quarter INT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN NOT NULL,
    holiday_name VARCHAR(100)
);

CREATE INDEX idx_date_full_date ON dim_date(full_date);
```

---

## Benefits of Star Schema

### 1. Query Simplicity
- Business users understand the model
- Simple joins (fact → dimension)
- Predictable query patterns

### 2. Query Performance
- Fewer joins (vs snowflake schema)
- Optimizer-friendly structure
- BI tools optimize for star schemas

### 3. ETL Simplicity
- Straightforward load process
- Clear insert/update targets
- Easy to maintain SCD logic

### 4. Flexibility
- Add dimensions without changing fact table (if surrogate keys used)
- Add attributes to dimensions without changing queries
- Easy to extend

---

## Common Query Patterns

### Total Sales by Category and Month
```sql
SELECT 
    p.category_l1,
    d.year,
    d.month_name,
    SUM(f.total_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
  AND p.is_current = TRUE
GROUP BY p.category_l1, d.year, d.month_name
ORDER BY d.year, d.month, total_sales DESC;
```

### Top Customers by Region
```sql
SELECT 
    c.country,
    c.state,
    c.customer_name,
    SUM(f.total_amount) AS lifetime_value
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.is_current = TRUE
GROUP BY c.country, c.state, c.customer_name
ORDER BY lifetime_value DESC
LIMIT 100;
```

### Sales Trend Over Time
```sql
SELECT 
    d.full_date,
    d.day_of_week,
    SUM(f.total_amount) AS daily_sales,
    AVG(SUM(f.total_amount)) OVER (
        ORDER BY d.full_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7day
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.full_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY d.full_date, d.day_of_week
ORDER BY d.full_date;
```

---

## Star Schema vs Snowflake Schema

| Aspect | Star Schema | Snowflake Schema |
|--------|-------------|------------------|
| **Dimension normalization** | Fully denormalized | Normalized (3NF) |
| **Number of tables** | Fewer (1 fact + N dims) | More (normalized dims) |
| **Query complexity** | Simple (few joins) | Complex (many joins) |
| **Query performance** | Faster (fewer joins) | Slower (join overhead) |
| **Storage** | More (redundant data) | Less (normalized) |
| **Maintainability** | Easier (fewer tables) | Harder (more tables) |
| **BI tool support** | Excellent | Good |
| **Kimball recommendation** | ✅ Use this | ❌ Avoid |

**Kimball's rule:** Storage is cheap. Query performance and simplicity are not. **Always use star schema.**

---

## When to Use Star Schema

✅ **Use star schema when:**
- Building data warehouse for analytics
- CQRS query side (read model)
- Supporting BI tools (Tableau, Power BI, Looker)
- Read-heavy workloads with complex aggregations
- Historical analysis and reporting
- Business users need to write their own queries

❌ **Don't use star schema when:**
- Transactional workloads (use OLTP instead)
- Write-heavy workloads (use OLTP instead)
- Need strong referential integrity on writes (use OLTP instead)
- Real-time operational systems (use OLTP instead)

---

## Design Tips

1. **Start with business process** - One fact table per process
2. **Define grain first** - Most important decision (atomic = most flexible)
3. **Denormalize dimensions** - No snowflaking, flatten hierarchies
4. **Use surrogate keys** - Never natural keys as PKs
5. **Pre-populate date dimension** - 10-20 years of dates
6. **Index foreign keys** - All fact table FKs should be indexed
7. **Keep facts numeric** - Descriptive text belongs in dimensions
8. **Conform dimensions** - Share dim_date, dim_customer across fact tables
9. **Avoid snowflaking** - Resist urge to normalize dimensions
10. **Test with realistic data** - Billions of fact rows, realistic queries

---

## Additional Resources

- **Book:** "The Data Warehouse Toolkit" (3rd Edition) - Ralph Kimball
- **Kimball Group:** kimballgroup.com (design patterns, best practices)
- **PostgreSQL OLAP:** Use BRIN indexes for time-series fact tables
- **Materialized Views:** Pre-aggregate common queries

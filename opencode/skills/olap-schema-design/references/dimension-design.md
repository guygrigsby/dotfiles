# Dimension Design Patterns

Comprehensive guide to designing dimension tables in star schema models.

---

## Dimension Fundamentals

**Characteristics:**
- **Wide tables** - 50-100+ columns common (denormalized)
- **Descriptive attributes** - Text, categories, hierarchies
- **Short tables** - Thousands to millions of rows (vs billions in facts)
- **Surrogate keys** - Auto-incrementing integers (not natural keys)
- **Denormalized** - Hierarchies flattened (no snowflaking)

**Purpose:** Provide context for filtering, grouping, and labeling facts.

---

## Mandatory Columns

Every dimension must have:

### 1. Surrogate Key (Primary Key)
```sql
product_key SERIAL PRIMARY KEY  -- Auto-incrementing integer
```

**Why not natural key?**
- ❌ Natural keys change (product_id, customer_id)
- ❌ Natural keys have business meaning (can't track history)
- ✅ Surrogate keys enable SCD Type 2 (multiple rows per entity)
- ✅ Smaller foreign keys in fact table (INT vs VARCHAR)

### 2. Natural Key (Business Identifier)
```sql
product_id VARCHAR(50) UNIQUE NOT NULL  -- Business key from source system
```

**Why include natural key?**
- ✅ ETL lookups (map source records to dimension keys)
- ✅ Debugging (human-readable identifiers)
- ✅ Integration with external systems

### 3. Descriptive Attributes
```sql
product_name VARCHAR(255) NOT NULL,
description TEXT,
brand VARCHAR(100),
manufacturer VARCHAR(100),
...
```

**Guidelines:**
- Include ALL attributes users might filter/group by
- Denormalize hierarchies (flatten)
- Use meaningful names (not codes)
- Include both codes AND descriptions

---

## Dimension Hierarchy Design

### Anti-Pattern: Snowflaking (Don't Do This)

❌ **Wrong: Normalized hierarchy**
```sql
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255),
    category_key INT  -- ❌ FK to separate category table
);

CREATE TABLE dim_category (
    category_key SERIAL PRIMARY KEY,
    category_name VARCHAR(100),
    department_key INT  -- ❌ FK to department table
);

CREATE TABLE dim_department (
    department_key SERIAL PRIMARY KEY,
    department_name VARCHAR(100)
);

-- ❌ Query requires 3 joins
SELECT d.department_name, SUM(f.total_amount)
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_category c ON p.category_key = c.category_key  -- Extra join
JOIN dim_department d ON c.department_key = d.department_key  -- Extra join
GROUP BY d.department_name;
```

### Best Practice: Flatten Hierarchy

✅ **Correct: Denormalized hierarchy**
```sql
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    -- Flattened hierarchy (denormalized)
    category_l1 VARCHAR(100),  -- Department
    category_l2 VARCHAR(100),  -- Category
    category_l3 VARCHAR(100),  -- Subcategory
    -- Other attributes
    brand VARCHAR(100),
    manufacturer VARCHAR(100)
);

-- ✅ Query requires 1 join
SELECT p.category_l1, SUM(f.total_amount)
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category_l1;
```

**Benefits:**
- ✅ Simpler queries (fewer joins)
- ✅ Faster queries (join overhead eliminated)
- ✅ BI tools understand flat hierarchies better
- ✅ Storage cost is minimal (text is cheap)

---

## Complete Dimension Examples

### Example 1: Customer Dimension

```sql
CREATE TABLE dim_customer (
    -- Mandatory: Surrogate key
    customer_key SERIAL PRIMARY KEY,
    
    -- Mandatory: Natural key
    customer_id VARCHAR(50) NOT NULL,
    
    -- Descriptive attributes
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(20),
    
    -- Denormalized address (no separate address table)
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Denormalized segments/classifications
    customer_segment VARCHAR(50),       -- VIP, Regular, New
    lifetime_value_tier VARCHAR(50),    -- High, Medium, Low
    acquisition_channel VARCHAR(50),    -- Web, Store, Referral
    
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

-- Indexes
CREATE INDEX idx_customer_natural_key ON dim_customer(customer_id);
CREATE INDEX idx_customer_current ON dim_customer(is_current) WHERE is_current = TRUE;
CREATE UNIQUE INDEX idx_customer_current_unique 
    ON dim_customer(customer_id) WHERE is_current = TRUE;
```

### Example 2: Product Dimension

```sql
CREATE TABLE dim_product (
    -- Mandatory: Surrogate key
    product_key SERIAL PRIMARY KEY,
    
    -- Mandatory: Natural key
    product_id VARCHAR(50) NOT NULL,
    
    -- Descriptive attributes
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Flattened category hierarchy
    category_l1 VARCHAR(100),  -- Department (Electronics, Apparel, Home)
    category_l2 VARCHAR(100),  -- Category (Computers, Accessories, TVs)
    category_l3 VARCHAR(100),  -- Subcategory (Laptops, Desktops, Monitors)
    
    -- Brand/manufacturer
    brand VARCHAR(100),
    manufacturer VARCHAR(100),
    
    -- Product attributes
    unit_of_measure VARCHAR(20),  -- EA, LB, GAL
    package_size VARCHAR(50),
    color VARCHAR(50),
    size VARCHAR(50),
    
    -- Pricing/cost (current values - facts store transaction prices)
    standard_price DECIMAL(10,2),
    standard_cost DECIMAL(10,2),
    
    -- Flags
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_taxable BOOLEAN NOT NULL DEFAULT TRUE,
    is_discontinued BOOLEAN NOT NULL DEFAULT FALSE,
    discontinued_date DATE,
    
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

-- Indexes
CREATE INDEX idx_product_natural_key ON dim_product(product_id);
CREATE INDEX idx_product_current ON dim_product(is_current) WHERE is_current = TRUE;
CREATE INDEX idx_product_category ON dim_product(category_l1, category_l2, category_l3);
```

### Example 3: Store/Location Dimension

```sql
CREATE TABLE dim_store (
    -- Mandatory: Surrogate key
    store_key SERIAL PRIMARY KEY,
    
    -- Mandatory: Natural key
    store_id VARCHAR(50) NOT NULL,
    
    -- Descriptive attributes
    store_name VARCHAR(255) NOT NULL,
    store_number VARCHAR(20),
    
    -- Denormalized address
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Denormalized geography hierarchy
    region VARCHAR(100),        -- Northeast, Southwest, etc.
    district VARCHAR(100),      -- New England, Gulf Coast, etc.
    territory VARCHAR(100),     -- Boston Metro, Houston Metro, etc.
    
    -- Store attributes
    store_type VARCHAR(50),     -- Flagship, Outlet, Pop-up
    square_footage INT,
    opening_date DATE,
    closing_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Manager (denormalized)
    manager_name VARCHAR(255),
    manager_email VARCHAR(255),
    
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);

-- Indexes
CREATE INDEX idx_store_natural_key ON dim_store(store_id);
CREATE INDEX idx_store_current ON dim_store(is_current) WHERE is_current = TRUE;
CREATE INDEX idx_store_geography ON dim_store(region, district);
```

---

## Best Practices

### 1. Include Both Codes and Descriptions

❌ **Bad: Only code**
```sql
customer_segment CHAR(1)  -- ❌ 'V', 'R', 'N' (not user-friendly)
```

✅ **Good: Descriptive value**
```sql
customer_segment VARCHAR(50)  -- ✅ 'VIP', 'Regular', 'New'
```

Or include both:
```sql
customer_segment_code CHAR(1),        -- 'V' (for joins to source)
customer_segment_name VARCHAR(50)     -- 'VIP' (for display)
```

### 2. Use Meaningful Nulls

```sql
-- Instead of NULL, use descriptive values
promotion_key INT NOT NULL DEFAULT -1,  -- -1 = "No Promotion"

-- Populate "unknown" member
INSERT INTO dim_promotion (promotion_key, promotion_id, promotion_name)
VALUES (-1, 'NONE', 'No Promotion');
```

### 3. Denormalize Aggressively

✅ Include redundant data for query simplicity:
```sql
CREATE TABLE dim_product (
    ...
    category_l1 VARCHAR(100),       -- Department
    category_l2 VARCHAR(100),       -- Category
    category_l3 VARCHAR(100),       -- Subcategory
    -- Redundant full path (easier for some queries)
    category_full_path VARCHAR(500) -- 'Electronics > Computers > Laptops'
);
```

### 4. Pre-Calculate Common Derivations

```sql
CREATE TABLE dim_customer (
    ...
    date_of_birth DATE,
    -- Pre-calculate age (updated in ETL)
    age INT,
    age_range VARCHAR(20)  -- '18-24', '25-34', '35-44', etc.
);
```

### 5. Use Flags for Common Filters

```sql
CREATE TABLE dim_product (
    ...
    is_active BOOLEAN,
    is_discontinued BOOLEAN,
    is_new_product BOOLEAN,  -- Added in last 90 days
    is_high_margin BOOLEAN   -- Margin > 40%
);
```

---

## Handling Attributes That Change

### Option 1: SCD Type 1 (Overwrite - No History)
```sql
-- Customer email changes (history doesn't matter)
UPDATE dim_customer
SET email = 'newemail@example.com'
WHERE customer_key = 123;
```

### Option 2: SCD Type 2 (Add Row - Full History)
```sql
-- Customer moves (history matters)
-- Expire old row
UPDATE dim_customer
SET expiration_date = CURRENT_DATE - INTERVAL '1 day',
    is_current = FALSE
WHERE customer_key = 123;

-- Insert new row
INSERT INTO dim_customer (customer_id, customer_name, state, ...)
VALUES ('C100', 'Alice Smith', 'TX', ...);
```

### Option 3: Type 1 + Type 2 Hybrid
```sql
-- Some attributes use Type 1 (overwrite)
email VARCHAR(255),           -- Type 1: Always update
phone VARCHAR(50),            -- Type 1: Always update

-- Other attributes use Type 2 (history)
state VARCHAR(100),           -- Type 2: Track changes
customer_segment VARCHAR(50)  -- Type 2: Track changes
```

**Recommended:** Use Type 2 by default, Type 1 only when history truly doesn't matter.

---

## Dimension Table Sizing

**Typical sizes:**
- **Date:** 3,650 rows (10 years)
- **Customer:** 100K - 10M rows
- **Product:** 10K - 1M rows
- **Store:** 100 - 10K rows
- **Employee:** 100 - 100K rows

**With SCD Type 2:**
- Multiply by change frequency
- Customer (10% annual churn) = 100K → 110K after 1 year
- Product (50% annual price changes) = 10K → 15K after 1 year

**Storage impact is minimal** - dimensions are small compared to fact tables.

---

## Common Anti-Patterns

### ❌ 1. Using Natural Keys as Foreign Keys
```sql
CREATE TABLE fact_sales (
    customer_id VARCHAR(50),  -- ❌ Natural key (can't track history)
    ...
);
```

### ❌ 2. Snowflaking (Normalizing Dimensions)
```sql
CREATE TABLE dim_product (
    category_key INT  -- ❌ FK to separate category table
);
```

### ❌ 3. Storing Facts in Dimensions
```sql
CREATE TABLE dim_customer (
    total_lifetime_value DECIMAL(10,2)  -- ❌ Fact (should be in fact table)
);
```

### ❌ 4. Too Many Dimensions
```sql
CREATE TABLE fact_sales (
    date_key INT,
    time_key INT,
    product_key INT,
    customer_key INT,
    store_key INT,
    promotion_key INT,
    payment_method_key INT,
    shipping_method_key INT,
    return_reason_key INT,  -- ❌ Too many dimensions (20+ FKs)
    ...
);
```

**Fix:** Combine low-cardinality dimensions into "junk dimension".

---

## Key Takeaways

1. **Surrogate keys always** - Never use natural keys as PKs
2. **Denormalize hierarchies** - Flatten, don't snowflake
3. **Wide dimensions are OK** - 100+ columns common
4. **Include natural keys** - For ETL and debugging
5. **Use SCD Type 2 by default** - Preserve history unless you have a reason not to
6. **Pre-calculate derivations** - Age, ranges, flags
7. **Meaningful values** - "VIP" not "V", "No Promotion" not NULL

**Kimball's rule:** "Make dimensions as wide and denormalized as possible."

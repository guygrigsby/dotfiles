# Kimball Dimensional Modeling Methodology

Ralph Kimball's four-step dimensional modeling process is the industry-standard approach for designing OLAP/data warehouse schemas.

---

## The Four-Step Process

### Step 1: Select the Business Process

**Question:** What business process are we analyzing?

**Goal:** Identify one business process to model (one fact table per process).

**Examples:**
- Sales transactions
- Website clickstream
- Inventory movements
- Customer support tickets
- Manufacturing operations
- Financial payments

**Guidelines:**
- **One process per fact table** - don't mix processes
- **Focus on processes, not departments** - processes cross org boundaries
- **Ask:** "What event or measurement do business users care about?"
- **Atomic grain preferred** - most detailed level available

**Example: E-commerce**
```
✅ Good: "Retail Sales" (one process)
❌ Bad: "All E-commerce" (multiple processes)

Better breakdown:
- Retail Sales (fact_sales)
- Inventory Management (fact_inventory_daily)
- Customer Service (fact_support_tickets)
- Web Analytics (fact_page_views)
```

---

### Step 2: Declare the Grain

**Question:** What does one row in the fact table represent?

**Goal:** Define the most atomic level of detail to be captured.

**This is the most important decision in dimensional modeling.**

**Examples:**
- One row per order line item
- One row per web page view
- One row per ATM transaction
- One row per product per warehouse per day (snapshot)

**Guidelines:**
- **Atomic grain preferred** - most flexible for future analysis
- **Be specific** - "one row per..." statement
- **Don't mix grains** - all facts must be at same grain
- **Define before adding columns** - grain drives everything else
- **Resist aggregation temptation** - store atomic, aggregate in queries/views

**Grain Statement Template:**
```
"One row represents one [ENTITY] at [TIME GRAIN] for [SCOPE]"

Examples:
- "One row represents one order line item"
- "One row represents one page view"
- "One row represents one product in one warehouse on one day"
```

**Example Decision Tree:**
```
Business Process: Retail Sales

Grain Options:
1. One row per order (order-level)
2. One row per order line item (line-level) ← ✅ Atomic grain (choose this)
3. One row per customer per day (aggregated)

Why choose line-level?
- ✅ Can aggregate up to order-level or customer-level in queries
- ✅ Can analyze product mix within orders
- ✅ Most flexible for unforeseen questions
- ❌ More rows, but storage is cheap
```

---

### Step 3: Identify the Dimensions

**Question:** How will business users slice and dice the data?

**Goal:** Identify all dimensions that provide context for the facts.

**Ask:** "Who, what, when, where, why, how?"
- **Who:** Customer, Employee, Vendor
- **What:** Product, Service, Campaign
- **When:** Date, Time
- **Where:** Store, Warehouse, Region
- **Why:** Promotion, Reason Code
- **How:** Payment Method, Channel

**Mandatory dimensions:**
- **Date** - almost always required
- **Time** (if grain is timestamp, separate from date)

**Guidelines:**
- **Think from user perspective** - how will they filter and group?
- **Denormalize hierarchies** - flatten in dimension (no snowflaking)
- **Role-playing dimensions** - same dimension used multiple ways (order_date, ship_date)
- **Conformed dimensions** - share across fact tables (dim_customer, dim_product)

**Example: E-commerce Sales**
```
Business Process: Retail Sales
Grain: One row per order line item

Dimensions:
✅ Date (when was the order placed?)
✅ Product (what was purchased?)
✅ Customer (who made the purchase?)
✅ Store (where was the purchase made?)
✅ Promotion (was there a promotion?)
✅ Payment Method (how did they pay?)
✅ Shipping Method (how was it shipped?)

Degenerate Dimensions (stored in fact):
✅ Order Number (no other attributes, just a reference)
✅ Line Item Number (position in order)
```

---

### Step 4: Identify the Facts

**Question:** What are we measuring?

**Goal:** Identify all numeric measurements that answer business questions.

**Guidelines:**
- **Must be numeric** - if it's text, it's a dimension attribute
- **Must be at declared grain** - consistent with Step 2
- **Additive facts preferred** - can SUM across all dimensions
- **Store components, not ratios** - calculate ratios in queries
- **True to source** - don't over-transform

**Fact Types:**
- **Additive:** Can SUM across all dimensions (quantity, amount, cost)
- **Semi-additive:** Can SUM across some dimensions (balance, inventory)
- **Non-additive:** Cannot SUM (ratios, percentages) - store components instead

**Example: E-commerce Sales**
```
Business Process: Retail Sales
Grain: One row per order line item

Facts (measurements):
✅ Quantity (additive)
✅ Unit Price (non-additive, but needed for calculation)
✅ Discount Amount (additive)
✅ Tax Amount (additive)
✅ Shipping Amount (additive)
✅ Total Amount (additive)
✅ Cost (additive)
✅ Profit (additive - Total Amount - Cost)

❌ Profit Margin (non-additive ratio - calculate in query instead)
```

---

## Complete Example: E-commerce Sales

### Step 1: Select Business Process
**Process:** Retail Sales

### Step 2: Declare Grain
**Grain:** One row per order line item (atomic grain)

### Step 3: Identify Dimensions
- dim_date (order date)
- dim_product (what was purchased)
- dim_customer (who purchased)
- dim_store (where purchased)
- dim_promotion (which promotion applied)
- dim_payment_method (how paid)
- dim_shipping_method (how shipped)
- Degenerate: order_number, line_item_number

### Step 4: Identify Facts
- quantity (units sold)
- unit_price (price per unit)
- discount_amount ($ discount)
- tax_amount ($ tax)
- shipping_amount ($ shipping)
- total_amount ($ total revenue)
- cost ($ cost of goods)
- profit ($ profit = revenue - cost)

### Resulting Schema

```sql
-- Fact Table
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    -- Step 3: Dimensions (foreign keys)
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    store_key INT NOT NULL,
    promotion_key INT,  -- Nullable (not all sales have promotions)
    payment_method_key INT NOT NULL,
    shipping_method_key INT NOT NULL,
    -- Step 3: Degenerate dimensions
    order_number VARCHAR(50) NOT NULL,
    line_item_number INT NOT NULL,
    -- Step 4: Facts (measurements)
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10,2) NOT NULL,
    shipping_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    -- Foreign keys
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    FOREIGN KEY (promotion_key) REFERENCES dim_promotion(promotion_key),
    FOREIGN KEY (payment_method_key) REFERENCES dim_payment_method(payment_method_key),
    FOREIGN KEY (shipping_method_key) REFERENCES dim_shipping_method(shipping_method_key)
);
```

---

## Design Patterns & Best Practices

### Pattern 1: Atomic Grain
**Always start with atomic grain** (most detailed level).

❌ **Bad: Aggregated grain**
```
Grain: One row per customer per day
Problem: Can't analyze individual orders or product mix
```

✅ **Good: Atomic grain**
```
Grain: One row per order line item
Benefit: Can aggregate to any level (daily, customer, product category, etc.)
```

### Pattern 2: Conformed Dimensions
**Share dimension tables across fact tables** for consistent analysis.

```
fact_sales        ──┐
fact_returns      ──┼──► dim_product (conformed)
fact_inventory    ──┘

Benefit: Can drill across fact tables with consistent product view
```

### Pattern 3: Role-Playing Dimensions
**Reuse date dimension for multiple date foreign keys.**

```sql
CREATE TABLE fact_order_fulfillment (
    order_key BIGSERIAL PRIMARY KEY,
    order_date_key INT NOT NULL,      ──┐
    payment_date_key INT,               ├──► dim_date (role-playing)
    ship_date_key INT,                  │
    delivery_date_key INT,            ──┘
    ...
);

-- Create views for clarity
CREATE VIEW dim_order_date AS SELECT * FROM dim_date;
CREATE VIEW dim_ship_date AS SELECT * FROM dim_date;
```

### Pattern 4: Junk Dimensions
**Combine low-cardinality flags into one dimension** (avoid fact table clutter).

❌ **Bad: Flags in fact table**
```sql
CREATE TABLE fact_sales (
    ...,
    is_taxable BOOLEAN,
    is_discounted BOOLEAN,
    is_rush_order BOOLEAN,
    payment_type VARCHAR(20)
);
```

✅ **Good: Junk dimension**
```sql
CREATE TABLE dim_order_flags (
    order_flags_key SERIAL PRIMARY KEY,
    is_taxable BOOLEAN,
    is_discounted BOOLEAN,
    is_rush_order BOOLEAN,
    payment_type VARCHAR(20),
    UNIQUE(is_taxable, is_discounted, is_rush_order, payment_type)
);

-- Pre-populate all combinations (2^3 * payment_types = small table)

CREATE TABLE fact_sales (
    ...,
    order_flags_key INT NOT NULL
);
```

---

## Common Mistakes

### Mistake 1: Mixing Grains
❌ **Wrong:**
```sql
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    order_number VARCHAR(50),
    order_total DECIMAL(10,2),    -- Order-level fact
    line_item_total DECIMAL(10,2) -- Line-item-level fact ❌ Mixed grains
);
```

✅ **Correct:** Separate fact tables
```sql
-- Line-item grain
CREATE TABLE fact_sales_line_items (...);

-- Order grain (if needed)
CREATE TABLE fact_sales_orders (...);
```

### Mistake 2: Storing Ratios Instead of Components
❌ **Wrong:**
```sql
profit_margin DECIMAL(5,2)  -- ❌ Can't SUM across rows
```

✅ **Correct:**
```sql
profit DECIMAL(10,2),       -- ✅ Store components
revenue DECIMAL(10,2),      -- ✅ Calculate ratio in query
-- Query: SUM(profit) / SUM(revenue) AS profit_margin
```

### Mistake 3: Descriptive Attributes in Fact Table
❌ **Wrong:**
```sql
CREATE TABLE fact_sales (
    ...,
    product_name VARCHAR(255),  -- ❌ Belongs in dim_product
    customer_city VARCHAR(100)  -- ❌ Belongs in dim_customer
);
```

✅ **Correct:** Only FKs and facts in fact table
```sql
CREATE TABLE fact_sales (
    ...,
    product_key INT,  -- ✅ FK to dim_product
    customer_key INT  -- ✅ FK to dim_customer
);
```

### Mistake 4: Snowflaking Dimensions
❌ **Wrong: Normalized (snowflake)**
```sql
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    category_key INT  -- ❌ FK to separate category table
);

CREATE TABLE dim_category (
    category_key SERIAL PRIMARY KEY,
    category_name VARCHAR(100)
);
```

✅ **Correct: Denormalized (star)**
```sql
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    category_l1 VARCHAR(100),  -- ✅ Denormalized
    category_l2 VARCHAR(100),
    category_l3 VARCHAR(100)
);
```

---

## Iterative Refinement

**The process is iterative.** Don't expect perfection on first pass.

```
1. Initial Design
   ↓
2. Review with Business Users
   ↓
3. Identify Missing Dimensions/Facts
   ↓
4. Refine Grain (if needed)
   ↓
5. Prototype with Real Data
   ↓
6. Test Queries
   ↓
7. Iterate
```

**Key questions to ask:**
- Can we answer all priority business questions?
- Is the grain atomic enough for future needs?
- Are dimensions conformed across processes?
- Are facts truly additive?
- Does the model perform well with realistic data volumes?

---

## Checklist

Before finalizing design:

- [ ] Step 1: Business process clearly identified (one process)
- [ ] Step 2: Grain explicitly declared ("one row per...")
- [ ] Step 2: Grain is atomic (most detailed level)
- [ ] Step 3: All relevant dimensions identified (who/what/when/where/why/how)
- [ ] Step 3: Dimensions denormalized (no snowflaking)
- [ ] Step 3: Conformed dimensions identified
- [ ] Step 4: All facts are numeric
- [ ] Step 4: Facts match declared grain
- [ ] Step 4: Additive facts preferred (store components of ratios)
- [ ] Reviewed with business users
- [ ] Tested with sample queries
- [ ] Performance validated with realistic data volumes

---

## Key Takeaways

1. **Four steps:** Business Process → Grain → Dimensions → Facts
2. **Grain is critical:** Most important decision (atomic = best)
3. **Dimensions answer:** Who, what, when, where, why, how
4. **Facts are numeric:** Measurements at declared grain
5. **Denormalize dimensions:** Star schema (never snowflake)
6. **Conform dimensions:** Share across fact tables
7. **Store components:** Not ratios (calculate in queries)
8. **Iterate:** Refine with business user feedback

**Kimball's mantra:** "The grain is the single most important decision in dimensional modeling."

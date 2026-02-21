---
name: olap-schema-design
description: Design dimensional models for analytical workloads using Star Schema and Kimball methodology. Covers fact tables, dimension tables, slowly changing dimensions, conformed dimensions, and query optimization for OLAP/CQRS read models. Optimizes for query performance over write complexity.
context: fork
license: MIT
---

# OLAP Schema Design (Star Schema / Kimball)

Design dimensional database schemas optimized for analytical queries, reporting, and business intelligence using Kimball's star schema methodology.

---

## Quick Start

**When to use OLAP design:**
- Analytics, reporting, dashboards, BI tools
- Read-heavy workloads (CQRS query side)
- Historical analysis, time-series queries
- Data warehousing, aggregation-heavy queries

**Quick decision:**
```
Need fast analytical queries? → Yes → OLAP (Star Schema)
Read-heavy workload? → Yes → OLAP
CQRS query model? → Yes → OLAP
Transactional writes? → No → Use oltp-schema-design instead
```

**Core principle:** Denormalize for query performance, optimize for read speed over write complexity.

---

## Triggers

| Trigger | Example |
|---------|---------|
| `OLAP` | "design OLAP schema for sales analytics" |
| `star schema` | "create star schema for revenue reporting" |
| `dimensional model` | "dimensional model for customer analytics" |
| `CQRS` | "CQRS read model for dashboards" |
| `data warehouse` | "data warehouse schema for BI" |
| `fact table` | "design fact table for orders" |
| `dimension` | "create dimension tables for products" |
| `Kimball` | "use Kimball methodology for analytics" |
| `read-heavy` | "optimize schema for read-heavy queries" |

---

## Key Terms

| Term | Definition |
|------|------------|
| **OLAP** | Online Analytical Processing - read-optimized, denormalized |
| **Star Schema** | Fact table surrounded by dimension tables (Kimball's core pattern) |
| **Fact Table** | Numeric measurements (sales, quantities, amounts) with foreign keys to dimensions |
| **Dimension Table** | Descriptive attributes (who, what, when, where, why) |
| **Grain** | Level of detail in a fact table (one row per order line, daily summary, etc.) |
| **SCD** | Slowly Changing Dimension - strategies for tracking dimension changes over time |
| **Conformed Dimension** | Shared dimension across multiple fact tables |
| **Degenerate Dimension** | Dimension key stored in fact table without separate dimension table |
| **Snowflake Schema** | Normalized dimension tables (avoid - adds complexity) |

---

## Core Concepts Overview

### Star Schema Fundamentals

**Structure:**
- **One fact table** at center (measurements, metrics, events)
- **Multiple dimension tables** around it (context, attributes)
- **Foreign keys** from fact → dimensions (never dimension → fact)
- **No joins between dimensions** (denormalized)

**Example:**
```
        ┌─────────────┐
        │   Product   │
        │  Dimension  │
        └──────┬──────┘
               │
┌──────────────┼──────────────┐
│         ┌────▼────┐         │
│  Time   │  Sales  │  Store  │
│Dimension│  Fact   │Dimension│
│         └────┬────┘         │
└──────────────┼──────────────┘
               │
        ┌──────▼──────┐
        │  Customer   │
        │  Dimension  │
        └─────────────┘
```

**See:** [references/star-schema-guide.md](references/star-schema-guide.md)

---

### Fact Tables

**Types:**
- **Transaction Fact:** One row per event (order placed, payment received)
- **Periodic Snapshot:** Regular intervals (daily inventory levels, monthly balances)
- **Accumulating Snapshot:** Process lifecycle (order → ship → deliver)

**Design rules:**
- **Grain first:** Define grain before adding columns (atomic = most flexible)
- **Additive facts preferred:** Can SUM across all dimensions (revenue, quantity)
- **Semi-additive facts:** Can SUM across some dimensions (account balance by time)
- **Non-additive facts:** Cannot SUM (ratios, percentages) - store components instead
- **Degenerate dimensions:** Store order_number in fact if no other attributes needed
- **Foreign keys only:** No descriptive text (belongs in dimensions)

**Example:**
```sql
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    -- Dimensions (foreign keys)
    date_key INT NOT NULL REFERENCES dim_date(date_key),
    product_key INT NOT NULL REFERENCES dim_product(product_key),
    store_key INT NOT NULL REFERENCES dim_store(store_key),
    customer_key INT NOT NULL REFERENCES dim_customer(customer_key),
    -- Degenerate dimension
    order_number VARCHAR(50) NOT NULL,
    -- Facts (measurements)
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL
);
```

**See:** [references/fact-table-patterns.md](references/fact-table-patterns.md)

---

### Dimension Tables

**Characteristics:**
- **Wide tables:** 50-100+ columns common (denormalized attributes)
- **Descriptive attributes:** Text, categories, hierarchies
- **Surrogate keys:** Auto-incrementing integers (never natural keys)
- **Natural keys preserved:** Business keys stored as attributes
- **Hierarchies flattened:** category_l1, category_l2, category_l3 (no normalization)

**Mandatory columns:**
- **Surrogate key:** `product_key` (PK, integer)
- **Natural key:** `product_id` (business identifier)
- **Attributes:** All descriptive fields (name, category, brand, etc.)
- **SCD tracking** (if Type 2): `effective_date`, `expiration_date`, `is_current`

**Example:**
```sql
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,              -- Surrogate key
    product_id VARCHAR(50) NOT NULL,              -- Natural key
    product_name VARCHAR(255) NOT NULL,
    -- Flattened hierarchy (denormalized)
    category_l1 VARCHAR(100),                     -- Department
    category_l2 VARCHAR(100),                     -- Category
    category_l3 VARCHAR(100),                     -- Subcategory
    brand VARCHAR(100),
    manufacturer VARCHAR(100),
    unit_of_measure VARCHAR(20),
    -- SCD Type 2 tracking
    effective_date DATE NOT NULL,
    expiration_date DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);
```

**See:** [references/dimension-design.md](references/dimension-design.md)

---

### Slowly Changing Dimensions (SCD)

**Type 1 - Overwrite:**
- Update in place (no history)
- Use when: History doesn't matter (fix typos, current state only)

**Type 2 - Add Row (Kimball's preference):**
- New row for each change (full history)
- Use when: Need to analyze historical context
- Requires: `effective_date`, `expiration_date`, `is_current` flag

**Type 3 - Add Column:**
- Store previous value in separate column (limited history)
- Use when: Only need current + previous (e.g., `previous_price`)

**Type 6 - Hybrid (1+2+3):**
- Combine all approaches (rare)

**Example (Type 2):**
```sql
-- Customer moved, new row created
product_key | product_id | price | effective_date | expiration_date | is_current
------------|------------|-------|----------------|-----------------|------------
1           | P100       | 10.00 | 2024-01-01     | 2024-06-30      | FALSE
2           | P100       | 12.00 | 2024-07-01     | NULL            | TRUE
```

**See:** [references/slowly-changing-dimensions.md](references/slowly-changing-dimensions.md)

---

### Special Dimension Types

**Date/Time Dimension:**
- Pre-populate all dates (e.g., 10 years)
- Include: day_of_week, month_name, quarter, fiscal_year, is_holiday, etc.
- Enables powerful time-based analysis

**Junk Dimension:**
- Combine low-cardinality flags (is_taxable, is_discounted, payment_type)
- Avoids cluttering fact table
- Pre-populate all combinations

**Degenerate Dimension:**
- Dimension key in fact table without separate dimension (order_number, invoice_number)
- Use when: No other attributes needed

**Role-Playing Dimension:**
- Same dimension used multiple times (ship_date, order_date, delivery_date → dim_date)
- Create views with aliases for clarity

**Conformed Dimension:**
- Shared across multiple fact tables (same dim_customer for sales, support, marketing)
- Critical for drill-across queries

**See:** [references/special-dimensions.md](references/special-dimensions.md)

---

### Indexing for Analytics

**Strategy:**
- **Fact tables:** Index foreign keys to dimensions (for joins)
- **Dimension tables:** Index surrogate key (PK) + natural key
- **Composite indexes:** Match common query patterns
- **Covering indexes:** Include frequently selected columns
- **Bitmap indexes:** Consider for low-cardinality dimensions (if DBMS supports)

**PostgreSQL-specific:**
- **BRIN indexes:** For time-series fact tables (clustered by date)
- **Partial indexes:** For `is_current = TRUE` on SCD Type 2 dimensions
- **Materialized views:** Pre-aggregate common queries

**Example:**
```sql
-- Fact table indexes
CREATE INDEX idx_sales_date ON fact_sales(date_key);
CREATE INDEX idx_sales_product ON fact_sales(product_key);
CREATE INDEX idx_sales_date_product ON fact_sales(date_key, product_key);

-- Dimension indexes
CREATE INDEX idx_product_natural_key ON dim_product(product_id);
CREATE INDEX idx_product_current ON dim_product(is_current) WHERE is_current = TRUE;
```

**See:** [references/olap-indexing.md](references/olap-indexing.md)

---

## Kimball Design Process

**Step 1: Select Business Process**
- Identify what process to model (sales, inventory, web clicks)
- One fact table per business process

**Step 2: Declare Grain**
- **Most important decision** - defines what one row represents
- Atomic grain preferred (most flexible for aggregation)
- Examples: "one row per order line item", "one row per web page view"

**Step 3: Identify Dimensions**
- Who, what, when, where, why, how
- Think: "How will business users slice this data?"
- Common: date, product, customer, location, promotion

**Step 4: Identify Facts**
- Numeric measurements that answer "how many?" or "how much?"
- Prefer additive facts (can SUM across all dimensions)
- Store at grain defined in step 2

**Process is iterative** - refine as you understand domain better.

**See:** [references/kimball-methodology.md](references/kimball-methodology.md)

---

## OLAP Schema Checklist

Before deploying:

- [ ] Grain clearly defined for each fact table
- [ ] All fact measures are numeric
- [ ] Dimensions use surrogate keys (not natural keys)
- [ ] Natural keys preserved in dimension tables
- [ ] SCD strategy chosen for each dimension (Type 1 or Type 2)
- [ ] Date dimension pre-populated
- [ ] Indexes on all fact table foreign keys
- [ ] Indexes on dimension natural keys
- [ ] No joins between dimension tables (denormalized)
- [ ] Conformed dimensions identified and shared
- [ ] ETL process handles SCD types correctly
- [ ] Query performance tested with realistic data volumes

---

## Star Schema vs Snowflake Schema

**Star Schema (Kimball's approach):**
- ✅ Denormalized dimensions (wide tables)
- ✅ Simpler queries (fewer joins)
- ✅ Faster queries (fewer joins)
- ✅ Easier for BI tools to understand
- ❌ More storage (redundant data in dimensions)

**Snowflake Schema (normalized dimensions):**
- ✅ Less storage (normalized)
- ❌ Complex queries (many joins)
- ❌ Slower queries (join overhead)
- ❌ Harder for business users

**Kimball's guidance:** **Always use Star Schema.** Storage is cheap, query performance and simplicity are not.

---

## CQRS Integration

**Pattern:**
- **Command side (write):** OLTP schema (normalized, transactional)
- **Query side (read):** OLAP schema (denormalized, analytical)
- **Synchronization:** Event sourcing, CDC, ETL pipelines

**Workflow:**
1. **domain-driven-design** - Model domain with aggregates/events
2. **oltp-schema-design** - Command side (write model)
3. **olap-schema-design** (this skill) - Query side (read model)
4. **ETL/Event handlers** - Sync OLTP → OLAP

**Example:**
- OLTP: `orders`, `order_items`, `products`, `customers` (5NF)
- OLAP: `fact_sales`, `dim_product`, `dim_customer`, `dim_date` (Star Schema)
- Sync: OrderPlaced event → Insert into fact_sales

**See:** [references/cqrs-integration.md](references/cqrs-integration.md)

---

## Skill Composition

**Workflow:**
1. **domain-driven-design** - Model business process and domain events
2. **oltp-schema-design** - Command side (transactional writes)
3. **olap-schema-design** (this skill) - Query side (analytical reads)
4. **mermaid-diagrams** - Visualize star schema (ERD, data flow)

---

## Common Examples

**E-commerce Sales:**
- Fact: `fact_sales` (grain: one row per order line item)
- Dimensions: `dim_date`, `dim_product`, `dim_customer`, `dim_store`, `dim_promotion`

**Website Analytics:**
- Fact: `fact_page_views` (grain: one row per page view)
- Dimensions: `dim_date`, `dim_page`, `dim_user`, `dim_session`, `dim_referrer`

**Inventory Snapshot:**
- Fact: `fact_inventory_daily` (grain: one row per product per day)
- Dimensions: `dim_date`, `dim_product`, `dim_warehouse`

---

## References

### Books
- **"The Data Warehouse Toolkit"** - Ralph Kimball (THE definitive guide)
- "Star Schema: The Complete Reference" - Christopher Adamson
- "Agile Data Warehouse Design" - Lawrence Corr

### Deep Dives
- [Star Schema Guide](references/star-schema-guide.md) - Structure, benefits, vs snowflake
- [Fact Table Patterns](references/fact-table-patterns.md) - Transaction, snapshot, accumulating types
- [Dimension Design](references/dimension-design.md) - Surrogate keys, hierarchies, attributes
- [Slowly Changing Dimensions](references/slowly-changing-dimensions.md) - Type 1, 2, 3, 6 strategies
- [Special Dimensions](references/special-dimensions.md) - Date, junk, degenerate, role-playing, conformed
- [OLAP Indexing](references/olap-indexing.md) - Index strategies, BRIN, materialized views
- [Kimball Methodology](references/kimball-methodology.md) - 4-step design process
- [CQRS Integration](references/cqrs-integration.md) - Sync OLTP → OLAP, event sourcing

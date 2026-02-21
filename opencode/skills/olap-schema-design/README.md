# OLAP Schema Design Skill

Design dimensional models for analytical workloads using Star Schema and Kimball methodology.

## Overview

This skill provides comprehensive guidance on designing OLAP schemas optimized for:
- Fast analytical queries and aggregations
- Business intelligence and reporting
- CQRS query-side models
- Data warehousing

Based on Ralph Kimball's dimensional modeling methodology from "The Data Warehouse Toolkit."

## When to Use

✅ **Use OLAP design when:**
- Building analytics, dashboards, or BI systems
- Read-heavy workloads with complex aggregations
- CQRS query side (read model)
- Historical analysis and reporting

❌ **Don't use OLAP when:**
- Transactional workloads (use `oltp-schema-design` instead)
- Write-heavy systems with ACID requirements
- Real-time operational systems

## Core Concepts

### Star Schema
- **Fact tables:** Numeric measurements (sales, quantities, amounts)
- **Dimension tables:** Descriptive attributes (products, customers, dates)
- **Denormalized:** Flat hierarchies for query performance

### Kimball's 4-Step Process
1. **Select business process** (sales, inventory, clicks)
2. **Declare grain** ("one row per order line item")
3. **Identify dimensions** (date, product, customer, store)
4. **Identify facts** (quantity, amount, cost, profit)

### Slowly Changing Dimensions (SCD)
- **Type 1:** Overwrite (no history)
- **Type 2:** Add row (full history) ← Kimball's preference
- **Type 3:** Add column (current + previous)

## Reference Files

Detailed guides in `references/`:

1. **[star-schema-guide.md](references/star-schema-guide.md)**
   - Star schema structure and benefits
   - Complete e-commerce example with SQL
   - Star vs snowflake comparison

2. **[fact-table-patterns.md](references/fact-table-patterns.md)**
   - Transaction, periodic snapshot, accumulating snapshot types
   - Additive vs semi-additive vs non-additive facts
   - Factless fact tables

3. **[dimension-design.md](references/dimension-design.md)**
   - Surrogate keys vs natural keys
   - Denormalizing hierarchies
   - Complete dimension examples (customer, product, store)

4. **[slowly-changing-dimensions.md](references/slowly-changing-dimensions.md)**
   - SCD Type 1, 2, 3, 6 strategies
   - ETL implementation patterns
   - Unknown member handling

5. **[special-dimensions.md](references/special-dimensions.md)**
   - Date/time dimensions (mandatory)
   - Junk dimensions (combine flags)
   - Degenerate dimensions (order numbers)
   - Role-playing dimensions (multiple dates)
   - Conformed dimensions (shared across facts)

6. **[olap-indexing.md](references/olap-indexing.md)**
   - Fact table indexing (FKs, composite, BRIN)
   - Dimension table indexing (natural keys, SCD)
   - Materialized views and partitioning

7. **[kimball-methodology.md](references/kimball-methodology.md)**
   - Complete 4-step process with examples
   - Design patterns and best practices
   - Common mistakes and anti-patterns

8. **[cqrs-integration.md](references/cqrs-integration.md)**
   - Event-driven sync (domain events)
   - Change Data Capture (CDC)
   - Batch ETL strategies
   - Dimension synchronization patterns

## Quick Example

```sql
-- Fact Table (center of star)
CREATE TABLE fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    date_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    order_number VARCHAR(50),  -- Degenerate dimension
    quantity INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL
);

-- Dimension Tables (denormalized)
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL,  -- Natural key
    product_name VARCHAR(255),
    category_l1 VARCHAR(100),  -- Flattened hierarchy
    category_l2 VARCHAR(100),
    brand VARCHAR(100)
);

-- Query (simple, fast)
SELECT 
    p.category_l1,
    SUM(f.total_amount) AS revenue
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category_l1;
```

## Integration with Other Skills

**Workflow:**
1. **domain-driven-design** - Model business processes and events
2. **oltp-schema-design** - Command side (write model)
3. **olap-schema-design** (this skill) - Query side (read model)
4. **mermaid-diagrams** - Visualize star schema

## Key Principles

1. **Atomic grain preferred** - Most detailed level, aggregate in queries
2. **Denormalize dimensions** - Star schema, never snowflake
3. **Use surrogate keys** - Auto-incrementing integers, not natural keys
4. **SCD Type 2 by default** - Preserve history unless you have a reason not to
5. **Pre-populate date dimension** - 10-20 years of dates
6. **Conform dimensions** - Share dim_date, dim_customer across fact tables
7. **Index all FK in facts** - Critical for join performance

## Resources

- **Book:** "The Data Warehouse Toolkit" (3rd Edition) - Ralph Kimball
- **Book:** "Star Schema: The Complete Reference" - Christopher Adamson
- **Website:** kimballgroup.com (design patterns, best practices)

## License

MIT

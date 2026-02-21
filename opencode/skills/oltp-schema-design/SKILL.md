---
name: oltp-schema-design
description: Design PostgreSQL OLTP schemas optimized for transactional workloads. Covers 5NF normalization, ACID guarantees, foreign key constraints, B-tree indexes, row-level locking, and DDD aggregate mapping. Ensures data integrity and write performance for high-concurrency systems.
context: fork
license: MIT
---

# OLTP Schema Design (PostgreSQL)

Design transactional database schemas optimized for write-heavy workloads with strong consistency guarantees.

---

## Quick Start

**When to use OLTP design:**
- Transactional systems (orders, payments, inventory)
- Write-heavy workloads requiring ACID guarantees
- Data integrity critical (financial, healthcare, legal)
- Multiple concurrent writers

**Quick decision:**
```
Need ACID guarantees? → Yes → OLTP
Write-heavy workload? → Yes → OLTP (5NF)
Read-heavy analytics? → No → Use olap-schema-design instead
```

**Core principle:** Normalize to 5NF when possible, optimize for write consistency over read performance.

---

## Triggers

| Trigger | Example |
|---------|---------|
| `OLTP` | "design OLTP schema for payment system" |
| `transactional schema` | "transactional schema for order processing" |
| `5NF` | "normalize to 5NF for inventory" |
| `ACID` | "ACID-compliant schema for banking" |
| `normalize` | "normalize customer data to 5NF" |
| `transaction` | "design transaction-safe schema" |
| `write-heavy` | "schema for write-heavy system" |

---

## Key Terms

| Term | Definition |
|------|------------|
| **OLTP** | Online Transaction Processing - write-optimized, normalized |
| **5NF** | Fifth Normal Form - most granular normalization |
| **ACID** | Atomicity, Consistency, Isolation, Durability |
| **B-tree Index** | Balanced tree index optimized for range queries and writes |
| **Foreign Key** | Referential integrity constraint linking tables |
| **Row-level Locking** | PostgreSQL mechanism for concurrent transactions |
| **Aggregate (DDD)** | Cluster of entities forming consistency boundary |

---

## Core Concepts Overview

### Normalization (1NF → 5NF)

- **1NF:** Atomic values, no repeating groups
- **2NF:** No partial dependencies (composite key issues)
- **3NF:** No transitive dependencies (most OLTP systems)
- **4NF:** No multi-valued dependencies
- **5NF:** No join dependencies (banking, complex inventory)

**Progressive approach:** Start with 3NF, move to 5NF when needed for write flexibility.

**See:** [references/normalization-guide.md](references/normalization-guide.md)

---

### Indexing Strategies

- **Always index:** Foreign keys, WHERE clauses, ORDER BY columns
- **B-tree indexes:** Default for OLTP (equality + range queries)
- **Composite indexes:** Match query patterns (left-most prefix rule)
- **Partial indexes:** Filter common WHERE clauses (saves space)
- **Covering indexes:** INCLUDE columns for index-only scans

**Trade-off:** Faster reads vs slower writes (index only what's queried).

**See:** [references/indexing-strategies.md](references/indexing-strategies.md)

---

### Schema Patterns & Examples

- **One-to-Many:** Customer → Orders
- **Many-to-Many:** Students ↔ Courses (junction table)
- **Self-Referencing:** Employee → Manager (hierarchy)
- **DDD Aggregates:** Order (root) → LineItems (internal entities)
- **Value Objects:** Money (embedded columns), Address (separate table)
- **Multi-Tenant:** Shared schema with tenant_id
- **Audit Trail:** JSONB + triggers
- **Soft Deletes:** deleted_at timestamp

**See:** [references/schema-examples.md](references/schema-examples.md)

---

### Performance Tuning

- **ACID Transactions:** BEGIN/COMMIT, isolation levels
- **Row-Level Locking:** FOR UPDATE, SKIP LOCKED (job queues)
- **Primary Keys:** BIGSERIAL (simple), UUID (distributed)
- **Data Types:** DECIMAL for money (not FLOAT), TIMESTAMP in UTC
- **Foreign Keys:** CASCADE, RESTRICT, SET NULL strategies
- **Zero-Downtime Migrations:** Add nullable, backfill, make required
- **Monitoring:** Slow queries, lock conflicts, table bloat

**See:** [references/performance-tuning.md](references/performance-tuning.md)

---

## OLTP Schema Checklist

Before deploying:

- [ ] Every table has primary key
- [ ] All foreign keys defined with ON DELETE strategy
- [ ] Indexes on all foreign keys
- [ ] DECIMAL for money (not FLOAT)
- [ ] Timestamps in UTC (created_at, updated_at)
- [ ] NOT NULL on required fields
- [ ] CHECK constraints for validation
- [ ] Unique constraints for business rules
- [ ] Normalized to 3NF minimum (5NF when appropriate)
- [ ] Migration scripts reversible
- [ ] Tested with concurrent transactions

---

## Skill Composition

**Workflow:**
1. **domain-driven-design** - Model aggregates and entities
2. **oltp-schema-design** (this skill) - Map to 5NF tables
3. **olap-schema-design** - Map events to star schema (if analytics needed)
4. **mermaid-diagrams** - Visualize schema (ERD, relationship diagrams)

---

## Common Examples

**E-commerce:**
- Tables: customers, orders, order_items, products, inventory
- Aggregates: Order (root) → LineItems

**Banking:**
- Tables: customers, accounts, transactions, products, branches
- 5NF: customer_accounts (independent relationships)

**SaaS Multi-Tenant:**
- Shared schema with tenant_id column
- Unique constraints: (tenant_id, email)

---

## References

### Books
- PostgreSQL Documentation: Transactions, Indexes, Constraints
- "Designing Data-Intensive Applications" - Martin Kleppmann
- "SQL Performance Explained" - Markus Winand

### Deep Dives
- [Normalization Guide](references/normalization-guide.md) - 1NF through 5NF with examples
- [Indexing Strategies](references/indexing-strategies.md) - B-tree, composite, partial, covering indexes
- [Schema Examples](references/schema-examples.md) - Common patterns, DDD mapping, constraints
- [Performance Tuning](references/performance-tuning.md) - Transactions, locking, migrations, monitoring

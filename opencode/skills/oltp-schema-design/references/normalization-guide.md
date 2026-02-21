# Normalization Guide (1NF → 5NF)

Comprehensive guide to database normalization for OLTP systems, from basic atomic values to advanced join dependency elimination.

---

## Normal Forms Hierarchy

| Form | Rule | When to Use |
|------|------|-------------|
| **1NF** | Atomic values, no repeating groups | Always (baseline) |
| **2NF** | 1NF + no partial dependencies | Standard OLTP |
| **3NF** | 2NF + no transitive dependencies | Most OLTP systems |
| **4NF** | 3NF + no multi-valued dependencies | Complex relationships |
| **5NF** | 4NF + no join dependencies | Banking, complex inventory, multi-tenant |

**Progressive approach:** Start with 3NF, move to 5NF when needed for write flexibility and data integrity.

---

## 1NF: Atomic Values

**Rule:** Each column contains atomic (indivisible) values, no repeating groups.

### Anti-Pattern: CSV in Column

```sql
-- ❌ BAD: Multiple values in one column
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  product_ids TEXT,  -- '101,102,103' - NOT ATOMIC
  quantities TEXT    -- '2,1,5' - NOT ATOMIC
);

-- Problems:
-- 1. Can't query "all orders with product 102"
-- 2. Can't enforce FK constraint to products table
-- 3. Must parse strings in application
```

### Solution: Separate Table

```sql
-- ✅ GOOD: Separate rows for each value
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id),
  quantity INT NOT NULL CHECK (quantity > 0),
  UNIQUE (order_id, product_id)  -- Prevent duplicate items
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
```

**Benefits:**
- Can query by product: `WHERE product_id = 102`
- FK constraint enforces product exists
- Can join orders ↔ products easily

---

## 2NF: No Partial Dependencies

**Rule:** Every non-key attribute depends on the **entire** primary key (not just part of it).

**Only applies to composite keys.**

### Anti-Pattern: Partial Dependency

```sql
-- ❌ BAD: customer_name depends only on customer_id (partial dependency)
CREATE TABLE order_items (
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  customer_id BIGINT NOT NULL,
  customer_name VARCHAR(100),  -- Depends on customer_id, NOT on (order_id, product_id)
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id)
);

-- Problems:
-- 1. customer_name duplicated for every item in order
-- 2. Update anomaly: change name, must update all rows
-- 3. Deletion anomaly: delete last item, lose customer name
```

### Solution: Separate Table

```sql
-- ✅ GOOD: Separate customer table
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id)
);

CREATE TABLE order_items (
  order_id BIGINT NOT NULL REFERENCES orders(id),
  product_id BIGINT NOT NULL REFERENCES products(id),
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id)
);
```

**Benefits:**
- Customer name stored once
- Update in one place
- No deletion anomalies

---

## 3NF: No Transitive Dependencies

**Rule:** Non-key attributes depend **only** on the primary key, not on other non-key attributes.

### Anti-Pattern: Transitive Dependency

```sql
-- ❌ BAD: country depends on postal_code (transitive)
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  postal_code VARCHAR(10) NOT NULL,
  city VARCHAR(100),     -- Depends on postal_code (transitive)
  country VARCHAR(50)    -- Depends on postal_code (transitive)
);

-- Problems:
-- 1. city/country duplicated for every customer with same postal code
-- 2. Update anomaly: postal code 94102 changes city, must update all rows
-- 3. Inconsistency: postal code 94102 could have different cities
```

### Solution: Reference Table

```sql
-- ✅ GOOD: Separate postal_codes reference table
CREATE TABLE postal_codes (
  code VARCHAR(10) PRIMARY KEY,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50),
  country VARCHAR(50) NOT NULL
);

CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  postal_code VARCHAR(10) NOT NULL REFERENCES postal_codes(code)
);
```

**Benefits:**
- City/country stored once per postal code
- Guaranteed consistency
- Easy to update postal code data

---

## 4NF: No Multi-Valued Dependencies

**Rule:** A table should not contain two or more independent multi-valued facts about an entity.

### Anti-Pattern: Multi-Valued Dependencies

```sql
-- ❌ BAD: phones and emails are independent multi-valued attributes
CREATE TABLE employees (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(255)
);

-- Storing multiple phones and emails creates Cartesian product:
-- Employee with 2 phones and 3 emails = 6 rows!
-- (phone1, email1), (phone1, email2), (phone1, email3)
-- (phone2, email1), (phone2, email2), (phone2, email3)
```

### Solution: Separate Tables

```sql
-- ✅ GOOD: Separate independent multi-valued attributes
CREATE TABLE employees (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE employee_phones (
  employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  phone VARCHAR(20) NOT NULL,
  phone_type VARCHAR(20) CHECK (phone_type IN ('mobile', 'home', 'work')),
  PRIMARY KEY (employee_id, phone)
);

CREATE TABLE employee_emails (
  employee_id BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  email_type VARCHAR(20) CHECK (email_type IN ('personal', 'work')),
  PRIMARY KEY (employee_id, email)
);
```

**Benefits:**
- 2 phones + 3 emails = 5 rows (not 6)
- Can add phone without adding email
- No redundancy

---

## 5NF: No Join Dependencies

**Rule:** Every join dependency is implied by candidate keys (most granular decomposition).

**Definition:** If a table can be decomposed into smaller tables that can be losslessly joined back, it should be.

### When to Use 5NF

- **Complex multi-party relationships** (suppliers × products × warehouses)
- **Banking systems** (accounts × customers × products × branches)
- **Multi-tenant SaaS** with complex authorization
- **Inventory systems** with independent supplier/warehouse relationships

### Example: Supplier-Product-Warehouse

**Business rules:**
1. Suppliers supply certain products
2. Products are stocked in certain warehouses
3. These relationships are **independent** (not all combinations exist)

**3NF/4NF approach:**

```sql
-- ❌ 3NF: Combined table (redundant)
CREATE TABLE supplier_product_warehouse (
  supplier_id BIGINT REFERENCES suppliers(id),
  product_id BIGINT REFERENCES products(id),
  warehouse_id BIGINT REFERENCES warehouses(id),
  PRIMARY KEY (supplier_id, product_id, warehouse_id)
);

-- Problem: If supplier S1 supplies product P1,
-- and product P1 is in warehouses W1 and W2,
-- you must insert (S1, P1, W1) AND (S1, P1, W2)
-- But S1 → P1 is independent of P1 → {W1, W2}
```

**5NF approach:**

```sql
-- ✅ 5NF: Split independent relationships
CREATE TABLE supplier_products (
  supplier_id BIGINT REFERENCES suppliers(id),
  product_id BIGINT REFERENCES products(id),
  PRIMARY KEY (supplier_id, product_id)
);

CREATE TABLE product_warehouses (
  product_id BIGINT REFERENCES products(id),
  warehouse_id BIGINT REFERENCES warehouses(id),
  stock_quantity INT NOT NULL DEFAULT 0,
  PRIMARY KEY (product_id, warehouse_id)
);

-- Query: Which warehouses have products from supplier S1?
SELECT DISTINCT pw.warehouse_id
FROM supplier_products sp
JOIN product_warehouses pw ON sp.product_id = pw.product_id
WHERE sp.supplier_id = 1;
```

**Benefits:**
- Add supplier for product: 1 row (not N rows for N warehouses)
- Add warehouse for product: 1 row (not M rows for M suppliers)
- Maximum write flexibility
- No redundancy

**Trade-off:**
- More JOINs for reads
- Use when write flexibility > read performance

---

## 5NF: Banking Example

**Business rules:**
1. Customers can have multiple accounts
2. Accounts are of certain product types (checking, savings, loan)
3. Accounts are held at certain branches
4. These are independent relationships

**5NF decomposition:**

```sql
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

CREATE TABLE account_products (
  id BIGSERIAL PRIMARY KEY,
  product_name VARCHAR(50) NOT NULL UNIQUE,  -- 'checking', 'savings'
  interest_rate DECIMAL(5,4)
);

CREATE TABLE branches (
  id BIGSERIAL PRIMARY KEY,
  branch_name VARCHAR(100) NOT NULL,
  location VARCHAR(255)
);

-- 5NF: Independent relationships
CREATE TABLE customer_accounts (
  account_id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id),
  product_id BIGINT NOT NULL REFERENCES account_products(id),
  branch_id BIGINT NOT NULL REFERENCES branches(id),
  balance DECIMAL(15,2) NOT NULL DEFAULT 0,
  opened_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (customer_id, product_id, branch_id)
);
```

---

## When NOT to Normalize to 5NF

### Read-Heavy Workloads

If queries require many JOINs and writes are rare:

```sql
-- Denormalize for read performance
CREATE TABLE order_summary (
  order_id BIGINT PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  customer_name VARCHAR(100),      -- Denormalized
  customer_email VARCHAR(255),     -- Denormalized
  total_amount DECIMAL(10,2),
  item_count INT
);
```

### Simple Relationships

For simple 1:N or N:M, 3NF is often sufficient:

```sql
-- 3NF is fine (not everything needs 5NF)
CREATE TABLE blog_posts (
  id BIGSERIAL PRIMARY KEY,
  author_id BIGINT REFERENCES users(id),
  title TEXT NOT NULL,
  content TEXT
);
```

---

## Normalization Decision Tree

```
Start: Design table
    ↓
Has repeating groups (CSV, arrays)? → Yes → Split to 1NF
    ↓ No
Has composite key? → Yes → Check partial dependencies → 2NF
    ↓ No (or after 2NF)
Non-key depends on non-key? → Yes → Split to 3NF
    ↓ No
Independent multi-valued attributes? → Yes → Split to 4NF
    ↓ No
Complex multi-party relationships? → Yes → Consider 5NF
    ↓ No
Done (3NF/4NF sufficient for most OLTP)
```

---

## Resources

- C.J. Date: "An Introduction to Database Systems"
- E.F. Codd: Original normalization papers
- PostgreSQL Wiki: Database Design Best Practices

# OLTP Schema Examples

Complete schema examples for common OLTP patterns: relationships, DDD mapping, constraints, and migrations.

---

## Common Relationship Patterns

### One-to-Many

```sql
-- Customer has many orders
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_status ON orders(status) WHERE status != 'completed';
```

---

### Many-to-Many (Junction Table)

```sql
-- Students enroll in courses
CREATE TABLE students (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE courses (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(10) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  credits INT NOT NULL CHECK (credits > 0)
);

-- Junction table with metadata
CREATE TABLE course_enrollments (
  student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
  course_id BIGINT REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  grade VARCHAR(2),
  PRIMARY KEY (student_id, course_id)
);

CREATE INDEX idx_enrollments_course ON course_enrollments(course_id);
```

---

### Self-Referencing (Hierarchy)

```sql
-- Employees with managers
CREATE TABLE employees (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  manager_id BIGINT REFERENCES employees(id) ON DELETE SET NULL,
  department VARCHAR(50),
  hired_at DATE NOT NULL
);

CREATE INDEX idx_employees_manager ON employees(manager_id);

-- Query: Find all direct reports
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

---

## DDD Aggregate Mapping

### Aggregate with Internal Entities

**Domain Model:**
```
Order (root)
├─ OrderID (identity)
├─ CustomerID (reference to Customer aggregate)
├─ LineItems[] (internal entities)
└─ Total (value object: Money)
```

**PostgreSQL Schema:**

```sql
-- Aggregate root
CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  total_amount DECIMAL(10,2) NOT NULL,
  total_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
  status VARCHAR(20) NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
  CONSTRAINT chk_orders_status CHECK (status IN ('draft', 'pending', 'completed', 'cancelled'))
);

-- Internal entities (CASCADE with aggregate root)
CREATE TABLE order_line_items (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity INT NOT NULL CHECK (quantity > 0),
  price_amount DECIMAL(10,2) NOT NULL,
  price_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
  
  UNIQUE (order_id, product_id)  -- Prevent duplicate items
);

-- Indexes for loading aggregate
CREATE INDEX idx_order_items_order ON order_line_items(order_id);
CREATE INDEX idx_order_items_product ON order_line_items(product_id);
```

**Loading aggregate:**
```sql
-- Load root + all internal entities in one query
SELECT 
  o.*,
  json_agg(
    json_build_object(
      'product_id', li.product_id,
      'quantity', li.quantity,
      'price_amount', li.price_amount
    )
  ) AS line_items
FROM orders o
LEFT JOIN order_line_items li ON o.id = li.order_id
WHERE o.id = 123
GROUP BY o.id;
```

---

### Value Object Strategies

#### Embedded Columns (Simple VO)

```sql
-- Money value object → embedded columns
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price_amount DECIMAL(10,2) NOT NULL,
  price_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
  
  CONSTRAINT chk_products_price CHECK (price_amount >= 0)
);
```

#### Separate Table (Reusable VO)

```sql
-- Address value object → separate table (if reused)
CREATE TABLE addresses (
  id BIGSERIAL PRIMARY KEY,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50),
  postal_code VARCHAR(10) NOT NULL,
  country VARCHAR(50) NOT NULL
);

CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  billing_address_id BIGINT REFERENCES addresses(id),
  shipping_address_id BIGINT REFERENCES addresses(id)
);
```

#### JSONB (Complex VO)

```sql
-- ContactInfo value object → JSONB
CREATE TABLE customers (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  contact_info JSONB
);

-- Query JSONB
SELECT * FROM customers 
WHERE contact_info->>'preferred_method' = 'email';

-- Index JSONB field
CREATE INDEX idx_customers_contact_method 
  ON customers USING gin ((contact_info->'preferred_method'));
```

---

### Domain Events (Event Sourcing)

```sql
CREATE TABLE order_events (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  event_type VARCHAR(50) NOT NULL,  -- 'OrderPlaced', 'OrderShipped', 'OrderCancelled'
  event_data JSONB NOT NULL,
  occurred_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT chk_event_type CHECK (event_type IN (
    'OrderPlaced', 'OrderShipped', 'OrderDelivered', 'OrderCancelled'
  ))
);

CREATE INDEX idx_order_events_order ON order_events(order_id, occurred_at);
CREATE INDEX idx_order_events_type ON order_events(event_type);
```

---

## Data Constraints

### Comprehensive Example

```sql
CREATE TABLE users (
  -- Primary key
  id BIGSERIAL PRIMARY KEY,
  
  -- Unique constraints
  email VARCHAR(255) UNIQUE NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  
  -- NOT NULL constraints
  name VARCHAR(100) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  
  -- CHECK constraints
  age INT CHECK (age >= 18 AND age <= 120),
  account_balance DECIMAL(10,2) DEFAULT 0 CHECK (account_balance >= 0),
  role VARCHAR(20) CHECK (role IN ('user', 'admin', 'moderator')),
  
  -- Defaults
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  -- Composite unique
  UNIQUE (tenant_id, email)
);
```

---

## Multi-Tenant Schema

### Shared Schema (tenant_id column)

```sql
CREATE TABLE tenants (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  subdomain VARCHAR(50) UNIQUE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(100) NOT NULL,
  
  -- Unique within tenant
  UNIQUE (tenant_id, email)
);

CREATE TABLE orders (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  total_amount DECIMAL(10,2) NOT NULL,
  
  -- Ensure user belongs to same tenant
  CONSTRAINT fk_orders_user_tenant 
    FOREIGN KEY (tenant_id, user_id) 
    REFERENCES users(tenant_id, id)
);

-- Partial indexes per tenant
CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_orders_tenant ON orders(tenant_id);
```

---

## Audit Trail

```sql
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  table_name VARCHAR(50) NOT NULL,
  record_id BIGINT NOT NULL,
  operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
  old_data JSONB,
  new_data JSONB,
  changed_by BIGINT REFERENCES users(id),
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_changed_at ON audit_log(changed_at);

-- Trigger to populate audit log
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_data, changed_by)
    VALUES (TG_TABLE_NAME, OLD.id, TG_OP, row_to_json(OLD), current_setting('app.user_id', true)::BIGINT);
    RETURN OLD;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (table_name, record_id, operation, old_data, new_data, changed_by)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(OLD), row_to_json(NEW), current_setting('app.user_id', true)::BIGINT);
    RETURN NEW;
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (table_name, record_id, operation, new_data, changed_by)
    VALUES (TG_TABLE_NAME, NEW.id, TG_OP, row_to_json(NEW), current_setting('app.user_id', true)::BIGINT);
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_audit
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

---

## Soft Deletes

```sql
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  deleted_at TIMESTAMP,  -- NULL = active, timestamp = soft deleted
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Partial index (only active products)
CREATE INDEX idx_products_active ON products(name) WHERE deleted_at IS NULL;

-- Application query (filter deleted)
SELECT * FROM products WHERE deleted_at IS NULL;
```

---

## Resources

- PostgreSQL Documentation: Data Definition, Constraints
- "Database Design for Mere Mortals" - Michael J. Hernandez
- Domain-Driven Design skill for aggregate patterns

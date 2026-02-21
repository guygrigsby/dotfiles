# DDD → Schema Mapping

How to map DDD models to OLTP (transactional) and OLAP (analytical) database schemas.

---

## DDD to OLTP (Transactional)

**Purpose:** Store current state of aggregates for transactional operations

**Mapping rules:**
1. **Aggregate → Table(s)** - Root → main table, internal entities → related tables
2. **Value Object → Columns or Table** - Simple → columns, reusable → table
3. **Entity ID → Primary Key** - Root ID → UUID/BIGSERIAL
4. **Aggregate boundary → Foreign keys** - References to other aggregates

### Example: Order Aggregate

**DDD Model:**
```go
type Order struct {
    id       OrderID          // Aggregate root
    customer CustomerID       // Reference to Customer aggregate
    status   OrderStatus
    total    Money            // Value object
    items    []LineItem       // Internal entities
}

type LineItem struct {
    productID ProductID
    quantity  int
    price     Money
}

type Money struct {
    amount   decimal.Decimal
    currency string
}
```

**PostgreSQL Schema:**
```sql
-- Aggregate root → main table
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,  -- FK to customer aggregate
    status VARCHAR(20) NOT NULL,
    total_amount NUMERIC(15,2) NOT NULL,
    total_currency VARCHAR(3) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    
    CONSTRAINT fk_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

-- Internal entities → related table
CREATE TABLE order_line_items (
    id SERIAL PRIMARY KEY,              -- Local ID (not globally meaningful)
    order_id UUID NOT NULL,             -- FK to aggregate root
    product_id UUID NOT NULL,           -- FK to product aggregate
    quantity INT NOT NULL CHECK (quantity > 0),
    price_amount NUMERIC(15,2) NOT NULL,
    price_currency VARCHAR(3) NOT NULL,
    
    CONSTRAINT fk_order FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE
);

-- Index for loading aggregate
CREATE INDEX idx_line_items_order ON order_line_items(order_id);
```

**Key points:**
- One table for aggregate root
- Separate table for internal entity collection
- Value objects (Money) → columns in same table
- Foreign keys enforce aggregate boundaries
- CASCADE deletes preserve aggregate atomicity

---

## Value Object Mapping Strategies

### Strategy 1: Embedded Columns (Simple VOs)

**When:** Value object used in one place, few fields

```go
type Address struct {
    street  string
    city    string
    zipCode string
}
```

```sql
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    name VARCHAR(100),
    address_street VARCHAR(100),
    address_city VARCHAR(50),
    address_zip_code VARCHAR(10)
);
```

---

### Strategy 2: Separate Table (Reusable VOs)

**When:** Value object reused across aggregates, many fields

```go
type Address struct {
    street     string
    city       string
    state      string
    zipCode    string
    country    string
    apartment  string
}
```

```sql
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    street VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(50) NOT NULL,
    apartment VARCHAR(20)
);

CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    name VARCHAR(100),
    billing_address_id INT REFERENCES addresses(address_id),
    shipping_address_id INT REFERENCES addresses(address_id)
);
```

---

### Strategy 3: JSON/JSONB (Complex VOs)

**When:** Flexible schema, not queried frequently

```go
type ContactInfo struct {
    phones []Phone
    emails []Email
}
```

```sql
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    name VARCHAR(100),
    contact_info JSONB
);

-- Still can index specific fields
CREATE INDEX idx_customer_email ON customers 
    USING GIN ((contact_info->'emails'));
```

---

## DDD to OLAP (Analytical)

**Purpose:** Store historical events for analysis and reporting

**Mapping rules:**
1. **Domain Event → Fact Table Row** - Each event instance → row
2. **Event Context → Dimension FKs** - OrderID, CustomerID → dimension FKs
3. **Aggregate State → Dimension (SCD Type 2)** - Track changes over time
4. **Event attributes → Fact measures** - Amounts, quantities, counts

### Example: Order Events

**DDD Events:**
```go
type OrderPlaced struct {
    OrderID      OrderID
    CustomerID   CustomerID
    PlacedAt     time.Time
    TotalAmount  Money
    ItemCount    int
    PaymentMethod string
}

type OrderShipped struct {
    OrderID    OrderID
    ShippedAt  time.Time
    Carrier    string
    TrackingID string
}
```

**Star Schema:**
```sql
-- Fact table (one row per event)
CREATE TABLE fact_orders (
    fact_id BIGSERIAL PRIMARY KEY,
    time_key BIGINT NOT NULL,           -- FK to dim_time
    customer_key BIGINT NOT NULL,       -- FK to dim_customer (SCD2)
    product_key BIGINT,                 -- FK to dim_product (SCD2)
    
    -- Measures (additive)
    order_total_amount NUMERIC(15,2),
    item_count INT,
    
    -- Degenerate dimensions (IDs from source)
    order_id UUID NOT NULL,
    payment_method VARCHAR(20),
    
    CONSTRAINT fk_time FOREIGN KEY (time_key)
        REFERENCES dim_time(time_key),
    CONSTRAINT fk_customer FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key)
);

-- Dimension: Time (Type 1)
CREATE TABLE dim_time (
    time_key BIGINT PRIMARY KEY,        -- YYYYMMDD format
    date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

-- Dimension: Customer (SCD Type 2 - track changes)
CREATE TABLE dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,  -- Surrogate key
    customer_id UUID NOT NULL,           -- Natural key
    customer_name VARCHAR(100),
    customer_tier VARCHAR(20),
    effective_date DATE NOT NULL,
    expiration_date DATE,                -- NULL = current
    is_current BOOLEAN NOT NULL,
    
    INDEX idx_customer_natural (customer_id, is_current)
);
```

**Populate from events:**
```go
// Event handler
func OnOrderPlaced(event OrderPlaced) {
    // Get dimension keys
    timeKey := toTimeKey(event.PlacedAt)
    customerKey := lookupCustomerKey(event.CustomerID, event.PlacedAt)
    
    // Insert fact
    db.Exec(`
        INSERT INTO fact_orders 
            (time_key, customer_key, order_id, order_total_amount, item_count, payment_method)
        VALUES ($1, $2, $3, $4, $5, $6)
    `, timeKey, customerKey, event.OrderID, 
       event.TotalAmount.Amount(), event.ItemCount, event.PaymentMethod)
}
```

---

## Workflow Decision Tree

```
Start: DDD Modeling
    ↓
Identify bounded contexts & aggregates
    ↓
Need transactional queries? → YES → oltp-schema-design (5NF)
    ↓
Need analytics/reporting? → YES → olap-schema-design (Star Schema)
    ↓
Both schemas can coexist (CQRS pattern)
```

---

## CQRS Pattern

**What:** Separate write model (OLTP) and read model (OLAP)

**Architecture:**
```
Domain Events
    ↓
┌───────────────┐         ┌───────────────┐
│  Write Model  │         │  Read Model   │
│    (OLTP)     │ -----→  │    (OLAP)     │
│               │ Events  │               │
│ - Orders      │         │ - fact_orders │
│ - Customers   │         │ - dim_customer│
│ - Products    │         │ - dim_product │
└───────────────┘         └───────────────┘
```

**Example:**
```go
// Write: Update OLTP
func PlaceOrder(order *Order) error {
    err := orderRepo.Save(order)  // Save to OLTP
    if err != nil {
        return err
    }
    
    // Publish event
    events.Publish(OrderPlaced{
        OrderID:    order.ID(),
        CustomerID: order.CustomerID(),
        Total:      order.Total(),
        PlacedAt:   time.Now(),
    })
    
    return nil
}

// Read: Project to OLAP
func OnOrderPlaced(event OrderPlaced) {
    // Insert into fact table
    insertFactOrder(event)
}

// Query OLAP for reporting
func GetOrdersByMonth(year, month int) ([]OrderReport, error) {
    return db.Query(`
        SELECT 
            dt.month,
            SUM(f.order_total_amount) as total_revenue,
            COUNT(*) as order_count
        FROM fact_orders f
        JOIN dim_time dt ON f.time_key = dt.time_key
        WHERE dt.year = $1 AND dt.month = $2
        GROUP BY dt.month
    `, year, month)
}
```

---

## Common Patterns

### Pattern: One Aggregate → Multiple Tables (OLTP)

**Aggregate:**
```go
type Customer struct {
    id        CustomerID
    profile   CustomerProfile
    addresses []Address
    orders    []OrderID  // References only
}
```

**Schema:**
```sql
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE customer_addresses (
    id SERIAL PRIMARY KEY,
    customer_id UUID REFERENCES customers(customer_id),
    address_type VARCHAR(20),  -- billing, shipping
    street VARCHAR(100),
    city VARCHAR(50)
);
```

---

### Pattern: Event Stream → Fact Tables (OLAP)

**Events:**
```go
OrderPlaced, OrderShipped, OrderDelivered, OrderCancelled
```

**Facts:**
```sql
-- One fact table per business process
CREATE TABLE fact_order_lifecycle (
    fact_id BIGSERIAL PRIMARY KEY,
    order_id UUID,
    event_type VARCHAR(20),      -- placed, shipped, delivered, cancelled
    event_time_key BIGINT,
    customer_key BIGINT,
    
    -- Measures
    order_amount NUMERIC(15,2),
    shipping_cost NUMERIC(15,2)
);
```

---

## Resources

- **OLTP details:** See `oltp-schema-design` skill
- **OLAP details:** See `olap-schema-design` skill
- Martin Fowler: "Patterns of Enterprise Application Architecture"
- Kimball Group: "The Data Warehouse Toolkit"

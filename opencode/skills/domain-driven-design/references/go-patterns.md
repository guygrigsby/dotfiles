# Go Implementation Patterns

Go-specific patterns for implementing DDD concepts: project structure, aggregate patterns, value objects, and repositories.

---

## Project Structure

```
project/
├── cmd/
│   └── server/
│       └── main.go
├── internal/
│   ├── orders/                    # Bounded context
│   │   ├── domain/                # Domain layer
│   │   │   ├── order.go           # Aggregate root
│   │   │   ├── line_item.go       # Entity
│   │   │   ├── money.go           # Value object
│   │   │   ├── repository.go      # Repository interface
│   │   │   └── events.go          # Domain events
│   │   ├── application/           # Application layer
│   │   │   └── place_order.go     # Use case
│   │   └── infrastructure/        # Infrastructure layer
│   │       ├── postgres/
│   │       │   └── order_repo.go  # Repository impl
│   │       └── http/
│   │           └── handlers.go    # HTTP handlers
│   └── inventory/                 # Another bounded context
└── pkg/                           # Shared kernel (minimal)
```

**Guidelines:**
- **internal/** - Bounded contexts as top-level packages
- **domain/** - Business logic, no external dependencies
- **application/** - Use cases, orchestration
- **infrastructure/** - External concerns (DB, HTTP, messaging)
- **pkg/** - Shared code (use sparingly)

---

## Aggregate Pattern

```go
// Aggregate Root
type Order struct {
    // Private fields enforce encapsulation
    id       OrderID
    customer CustomerID
    items    []LineItem
    status   OrderStatus
    total    Money
    events   []DomainEvent
}

// Constructor
func NewOrder(customerID CustomerID) *Order {
    return &Order{
        id:       generateOrderID(),
        customer: customerID,
        items:    []LineItem{},
        status:   OrderStatusDraft,
        events:   []DomainEvent{},
    }
}

// Behavior methods (not just getters/setters)
func (o *Order) AddItem(productID ProductID, qty int, price Money) error {
    // Validate
    if qty <= 0 {
        return errors.New("quantity must be positive")
    }
    if len(o.items) >= 100 {
        return errors.New("max 100 items per order")
    }
    
    // Mutate state
    item := LineItem{
        productID: productID,
        quantity:  qty,
        price:     price,
    }
    o.items = append(o.items, item)
    
    // Recalculate derived state
    o.recalculateTotal()
    
    // Record event
    o.events = append(o.events, ItemAddedToOrder{
        OrderID:   o.id,
        ProductID: productID,
        Quantity:  qty,
    })
    
    return nil
}

// Private helper (internal invariant)
func (o *Order) recalculateTotal() {
    total := Money{amount: decimal.Zero, currency: "USD"}
    for _, item := range o.items {
        itemTotal := item.price.Multiply(item.quantity)
        total = total.Add(itemTotal)
    }
    o.total = total
}

// Read-only accessor (no setter)
func (o Order) ID() OrderID { return o.id }
func (o Order) Total() Money { return o.total }
func (o Order) Events() []DomainEvent { return o.events }

func (o *Order) ClearEvents() {
    o.events = []DomainEvent{}
}
```

**Key principles:**
- Private fields (lowercase) enforce encapsulation
- Constructors validate and initialize
- Behavior methods enforce invariants
- Events recorded for side effects
- Read-only accessors, no setters

---

## Value Object Pattern

```go
type Money struct {
    amount   decimal.Decimal
    currency string
}

// Constructor validates
func NewMoney(amount decimal.Decimal, currency string) (Money, error) {
    if currency == "" {
        return Money{}, errors.New("currency required")
    }
    return Money{amount: amount, currency: currency}, nil
}

// No setters - create new instance
func (m Money) Add(other Money) (Money, error) {
    if m.currency != other.currency {
        return Money{}, errors.New("currency mismatch")
    }
    return Money{
        amount:   m.amount.Add(other.amount),
        currency: m.currency,
    }, nil
}

func (m Money) Multiply(factor int) Money {
    return Money{
        amount:   m.amount.Mul(decimal.NewFromInt(int64(factor))),
        currency: m.currency,
    }
}

// Equality based on attributes
func (m Money) Equals(other Money) bool {
    return m.amount.Equal(other.amount) && m.currency == other.currency
}

// Read-only accessors
func (m Money) Amount() decimal.Decimal { return m.amount }
func (m Money) Currency() string { return m.currency }
```

**Key principles:**
- Immutable (no mutation methods)
- Operations return new instances
- Validation in constructor
- Equality based on all fields

---

## Repository Pattern

```go
// Domain layer: define interface
package domain

type OrderRepository interface {
    Save(order *Order) error
    FindByID(id OrderID) (*Order, error)
    FindByCustomer(customerID CustomerID) ([]*Order, error)
}

// Infrastructure layer: implement
package postgres

import (
    "database/sql"
    "myapp/internal/orders/domain"
)

type OrderRepo struct {
    db *sql.DB
}

func NewOrderRepo(db *sql.DB) *OrderRepo {
    return &OrderRepo{db: db}
}

func (r *OrderRepo) Save(order *domain.Order) error {
    tx, err := r.db.Begin()
    if err != nil {
        return err
    }
    defer tx.Rollback()
    
    // Save aggregate root
    _, err = tx.Exec(`
        INSERT INTO orders (id, customer_id, status, total_amount, total_currency)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (id) DO UPDATE SET
            status = EXCLUDED.status,
            total_amount = EXCLUDED.total_amount,
            total_currency = EXCLUDED.total_currency
    `, order.ID(), order.CustomerID(), order.Status(), 
       order.Total().Amount(), order.Total().Currency())
    if err != nil {
        return err
    }
    
    // Save internal entities (line items)
    for _, item := range order.Items() {
        _, err = tx.Exec(`
            INSERT INTO order_line_items (order_id, product_id, quantity, price_amount, price_currency)
            VALUES ($1, $2, $3, $4, $5)
        `, order.ID(), item.ProductID(), item.Quantity(),
           item.Price().Amount(), item.Price().Currency())
        if err != nil {
            return err
        }
    }
    
    return tx.Commit()
}

func (r *OrderRepo) FindByID(id domain.OrderID) (*domain.Order, error) {
    // Load root
    var customerID domain.CustomerID
    var status domain.OrderStatus
    var totalAmount decimal.Decimal
    var totalCurrency string
    
    err := r.db.QueryRow(`
        SELECT customer_id, status, total_amount, total_currency
        FROM orders WHERE id = $1
    `, id).Scan(&customerID, &status, &totalAmount, &totalCurrency)
    if err != nil {
        return nil, err
    }
    
    // Load internal entities
    rows, err := r.db.Query(`
        SELECT product_id, quantity, price_amount, price_currency
        FROM order_line_items WHERE order_id = $1
    `, id)
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    // Reconstitute aggregate
    order := domain.RehydrateOrder(id, customerID, status)
    for rows.Next() {
        var productID domain.ProductID
        var quantity int
        var priceAmount decimal.Decimal
        var priceCurrency string
        
        rows.Scan(&productID, &quantity, &priceAmount, &priceCurrency)
        
        price, _ := domain.NewMoney(priceAmount, priceCurrency)
        order.AddItem(productID, quantity, price)
    }
    
    return order, nil
}
```

**Key principles:**
- Interface in domain, implementation in infrastructure
- Save entire aggregate in transaction
- Load entire aggregate (eager loading)
- Return fully reconstituted objects

---

## Domain Events Pattern

```go
// Domain layer
package domain

type DomainEvent interface {
    OccurredAt() time.Time
}

type OrderPlaced struct {
    orderID    OrderID
    customerID CustomerID
    total      Money
    occurredAt time.Time
}

func (e OrderPlaced) OccurredAt() time.Time { return e.occurredAt }

// Aggregate collects events
type Order struct {
    id     OrderID
    events []DomainEvent
}

func (o *Order) Place() error {
    o.status = OrderStatusPlaced
    
    o.events = append(o.events, OrderPlaced{
        orderID:    o.id,
        customerID: o.customer,
        total:      o.total,
        occurredAt: time.Now(),
    })
    
    return nil
}

// Repository publishes after save
func (r *OrderRepo) Save(order *domain.Order) error {
    tx := r.db.Begin()
    
    // Save aggregate state
    // ...
    
    tx.Commit()
    
    // Publish events after commit
    for _, event := range order.Events() {
        r.eventBus.Publish(event)
    }
    
    order.ClearEvents()
    return nil
}
```

---

## Application Layer Pattern

```go
package application

type PlaceOrderCommand struct {
    CustomerID CustomerID
    Items      []OrderItemDTO
}

type PlaceOrderHandler struct {
    orderRepo  domain.OrderRepository
    productCatalog ProductCatalogService
}

func (h *PlaceOrderHandler) Handle(cmd PlaceOrderCommand) (OrderID, error) {
    // Create aggregate
    order := domain.NewOrder(cmd.CustomerID)
    
    // Add items
    for _, itemDTO := range cmd.Items {
        // Fetch product info (from another context)
        product, err := h.productCatalog.GetProduct(itemDTO.ProductID)
        if err != nil {
            return "", err
        }
        
        // Add to order
        err = order.AddItem(itemDTO.ProductID, itemDTO.Quantity, product.Price)
        if err != nil {
            return "", err
        }
    }
    
    // Place order
    err := order.Place()
    if err != nil {
        return "", err
    }
    
    // Persist
    err = h.orderRepo.Save(order)
    if err != nil {
        return "", err
    }
    
    return order.ID(), nil
}
```

**Key principles:**
- Orchestrates domain objects
- Defines transaction boundaries
- Coordinates with external services
- Returns simple DTOs

---

## Resources

- Mat Ryer: "How I write HTTP services in Go"
- Kat Zien: "How Do You Structure Your Go Apps"
- Ben Johnson: "Standard Package Layout"

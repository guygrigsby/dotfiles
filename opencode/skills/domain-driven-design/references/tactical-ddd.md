# Tactical DDD

Tactical DDD provides building blocks for implementing domain models: entities, value objects, aggregates, repositories, domain services, and domain events.

---

## Entities

**What:** Objects with unique identity that persists over time.

**Characteristics:**
- Has unique ID
- Mutable (state can change)
- Equality based on ID, not attributes

**Example:**
```go
type OrderID string

type Order struct {
    id       OrderID
    customer Customer
    items    []LineItem
    status   OrderStatus
}

func (o Order) Equals(other Order) bool {
    return o.id == other.id  // Identity-based equality
}
```

**When to use:** Track object over time (User, Order, Product, Account)

---

## Value Objects

**What:** Immutable objects defined by their attributes, no identity.

**Characteristics:**
- No unique ID
- Immutable (return new instance instead of modifying)
- Equality based on all attributes

**Example:**
```go
type Money struct {
    amount   decimal.Decimal
    currency string
}

// Immutable: returns new Money
func (m Money) Add(other Money) (Money, error) {
    if m.currency != other.currency {
        return Money{}, errors.New("currency mismatch")
    }
    return Money{
        amount:   m.amount.Add(other.amount),
        currency: m.currency,
    }, nil
}

func (m Money) Equals(other Money) bool {
    return m.amount.Equal(other.amount) && m.currency == other.currency
}
```

**Common value objects:** `Address`, `Email`, `Money`, `DateRange`, `Coordinate`
**Benefits:** Thread-safe, easy to test, can be shared safely

---

## Aggregates

**What:** Cluster of entities/value objects with consistency boundary.

**Characteristics:**
- Has one **Aggregate Root** (entry point entity)
- Only root has global identity
- External references to root only
- Enforce invariants within boundary
- Transaction boundary

**Rules:**
1. Root entity is the only entry point
2. Internal entities have local IDs
3. External references to root only
4. One aggregate per transaction

**Example:**
```go
// Aggregate Root
type Order struct {
    id       OrderID          // Global identity
    customer CustomerID       // Reference to other aggregate
    items    []LineItem       // Internal entities
    total    Money            // Value object
}

// Internal entity (no global identity)
type LineItem struct {
    productID ProductID
    quantity  int
    price     Money
}

// Enforce invariant
func (o *Order) AddItem(productID ProductID, quantity int, price Money) error {
    if len(o.items) >= 100 {
        return errors.New("max 100 items per order")
    }
    
    item := LineItem{productID, quantity, price}
    o.items = append(o.items, item)
    o.recalculateTotal()
    return nil
}
```

**Design tips:**
- Keep aggregates small (fewer entities = better performance)
- One aggregate per transaction
- Use eventual consistency between aggregates (via events)

---

## Repositories

**What:** Abstraction for retrieving and persisting aggregates.

**Characteristics:**
- Interface defined in domain layer
- Implementation in infrastructure layer
- Works with aggregate roots only
- Returns fully reconstituted aggregates

**Example:**
```go
// Domain layer: interface
package orders

type OrderRepository interface {
    Save(order *Order) error
    FindByID(id OrderID) (*Order, error)
    FindByCustomer(customerID CustomerID) ([]*Order, error)
}

// Infrastructure layer: PostgreSQL implementation
package postgres

type OrderRepo struct {
    db *sql.DB
}

func (r *OrderRepo) Save(order *Order) error {
    // Save root + all internal entities in transaction
}

func (r *OrderRepo) FindByID(id OrderID) (*Order, error) {
    // Load root + all internal entities, return fully constructed aggregate
}
```

**One repository per aggregate:**
- `OrderRepository` for `Order` aggregate
- NO `LineItemRepository` (LineItem is internal)

---

## Domain Services

**What:** Stateless operations that don't belong to an entity or value object.

**When to use:**
- Operation involves multiple aggregates
- Logic doesn't fit naturally into one entity

**Example:**
```go
type PricingService struct {
    discountRules DiscountRules
}

func (s *PricingService) CalculateOrderTotal(order *Order, customer *Customer) Money {
    baseTotal := order.CalculateSubtotal()
    discount := s.discountRules.ApplyDiscount(baseTotal, customer.tier)
    tax := s.calculateTax(baseTotal.Subtract(discount))
    return baseTotal.Subtract(discount).Add(tax)
}
```

**Domain Service vs Application Service:**
- **Domain Service:** Business logic, lives in domain layer
- **Application Service:** Orchestrates use cases, lives in application layer

---

## Domain Events

**What:** Something that happened in the domain that domain experts care about.

**Characteristics:**
- Immutable
- Past tense naming (`OrderPlaced`, `PaymentProcessed`)
- Contains relevant data
- Published after aggregate state changes

**Example:**
```go
type OrderPlaced struct {
    OrderID    OrderID
    CustomerID CustomerID
    Items      []LineItem
    Total      Money
    PlacedAt   time.Time
}

type Order struct {
    id     OrderID
    events []DomainEvent
}

func (o *Order) Place() error {
    o.status = OrderStatusPlaced
    
    event := OrderPlaced{
        OrderID:    o.id,
        CustomerID: o.customer,
        Items:      o.items,
        Total:      o.total,
        PlacedAt:   time.Now(),
    }
    o.events = append(o.events, event)
    return nil
}

// Repository publishes events after save
func (r *OrderRepo) Save(order *Order) error {
    tx := r.db.Begin()
    // Save aggregate
    // Publish events
    for _, event := range order.Events() {
        r.eventBus.Publish(event)
    }
    tx.Commit()
    order.ClearEvents()
}
```

**Use cases:**
- Trigger actions in other contexts (eventual consistency)
- Audit log / event sourcing
- Analytics (events → OLAP fact tables)

---

## Anti-Patterns to Avoid

### Anemic Domain Model

**Problem:** Entities with only getters/setters, all logic in services

**Bad:**
```go
type Order struct {
    ID     string
    Items  []LineItem
    Status string
}

// All getters/setters, no behavior

type OrderService struct{}

func (s *OrderService) PlaceOrder(order *Order) {
    // All logic in service
    order.Status = "placed"
}
```

**Fix:**
```go
type Order struct {
    id     OrderID
    items  []LineItem
    status OrderStatus
}

// Behavior in entity
func (o *Order) Place() error {
    if len(o.items) == 0 {
        return errors.New("cannot place empty order")
    }
    o.status = OrderStatusPlaced
    return nil
}
```

---

### God Aggregate

**Problem:** Aggregate too large, performance issues

**Bad:**
```go
type Order struct {
    id          OrderID
    customer    Customer          // Entire customer entity
    items       []LineItem
    payments    []Payment
    shipments   []Shipment
    invoices    []Invoice
    // ... 20 more collections
}
```

**Fix:**
```go
type Order struct {
    id         OrderID
    customerID CustomerID  // Reference only
    items      []LineItem
}

// Separate aggregates
type Payment struct { orderID OrderID }
type Shipment struct { orderID OrderID }
```

---

### Aggregate Spanning Transactions

**Problem:** Modifying multiple aggregates in one transaction

**Bad:**
```go
func PlaceOrder(order *Order, inventory *Inventory) error {
    tx.Begin()
    order.Place()
    inventory.ReserveStock(order.Items())
    tx.Commit()  // Two aggregates in one transaction
}
```

**Fix:**
```go
func PlaceOrder(order *Order) error {
    order.Place()
    repo.Save(order)
    
    // Publish event for inventory
    events.Publish(OrderPlaced{
        OrderID: order.ID(),
        Items:   order.Items(),
    })
}

// Inventory context handles event
func OnOrderPlaced(event OrderPlaced) {
    inventory := repo.FindByID(...)
    inventory.ReserveStock(event.Items)
    repo.Save(inventory)
}
```

---

### Leaky Abstractions

**Problem:** Domain layer depends on infrastructure (DB, HTTP)

**Bad:**
```go
package domain

import "database/sql"

type Order struct {
    db *sql.DB  // Domain depends on infrastructure
}

func (o *Order) Save() error {
    o.db.Exec("INSERT INTO orders...")
}
```

**Fix:**
```go
// Domain layer
package domain

type OrderRepository interface {
    Save(order *Order) error
}

// Infrastructure layer
package postgres

type OrderRepo struct {
    db *sql.DB
}

func (r *OrderRepo) Save(order *domain.Order) error {
    // Implementation
}
```

---

## Common Patterns

### CQRS (Command Query Responsibility Segregation)

**What:** Separate models for writes (commands) and reads (queries)

**Example:**
```go
// Write model (domain aggregates)
package orders

type Order struct {
    id     OrderID
    items  []LineItem
}

func (o *Order) AddItem(item LineItem) error {
    // Business logic
}

// Read model (denormalized views)
package queries

type OrderView struct {
    OrderID      string
    CustomerName string
    TotalAmount  decimal.Decimal
    ItemCount    int
}

type OrderViewRepo interface {
    FindByID(id string) (*OrderView, error)
}
```

**Benefits:**
- Optimize writes and reads independently
- Domain events link the two models
- Write to OLTP, project events to OLAP

---

### Event Sourcing

**What:** Store events instead of current state

**Example:**
```go
type Order struct {
    id      OrderID
    version int
}

// Rebuild from events
func RehydrateOrder(events []DomainEvent) *Order {
    order := &Order{}
    for _, event := range events {
        order.Apply(event)
    }
    return order
}

func (o *Order) Apply(event DomainEvent) {
    switch e := event.(type) {
    case OrderCreated:
        o.id = e.OrderID
    case ItemAdded:
        o.items = append(o.items, e.Item)
    case OrderPlaced:
        o.status = OrderStatusPlaced
    }
    o.version++
}
```

**Benefits:**
- Complete audit trail
- Can rebuild state at any point in time
- Natural fit with domain events

---

### Saga Pattern

**What:** Coordinate transactions across aggregates/contexts

**Example:**
```go
type OrderSaga struct {
    sagaID  string
    orderID OrderID
    state   SagaState
}

func (s *OrderSaga) Start(order *Order) {
    s.state = SagaStateStarted
    
    // Step 1: Reserve inventory
    events.Publish(ReserveInventory{OrderID: order.ID()})
}

func (s *OrderSaga) OnInventoryReserved(event InventoryReserved) {
    // Step 2: Process payment
    events.Publish(ProcessPayment{OrderID: event.OrderID})
}

func (s *OrderSaga) OnPaymentFailed(event PaymentFailed) {
    // Compensating action: release inventory
    events.Publish(ReleaseInventory{OrderID: event.OrderID})
}
```

**Use cases:**
- Multi-step business processes
- Distributed transactions
- Compensating actions for rollback

---

## Resources

- Eric Evans: "Domain-Driven Design" (Blue Book) - Chapters 5-7 (Tactical Design)
- Vaughn Vernon: "Implementing Domain-Driven Design" (Red Book) - Chapters 5-8
- Martin Fowler: Repository, Domain Event patterns

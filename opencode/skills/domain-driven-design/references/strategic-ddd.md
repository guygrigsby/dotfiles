# Strategic DDD

Strategic DDD focuses on high-level modeling: identifying bounded contexts, establishing ubiquitous language, and mapping relationships between contexts.

---

## Ubiquitous Language

**What:** Shared vocabulary between developers and domain experts, used consistently in code, docs, and conversations.

**How to build:**
1. Interview domain experts
2. Identify key terms and precise definitions
3. Use terms in code (struct names, methods, variables)
4. Create glossary document

**Example:**
```go
// Good: Uses ubiquitous language
type Order struct {
    orderID   OrderID
    customer  Customer
    lineItems []LineItem
}

// Bad: Generic terminology
type Record struct {
    id   int
    data map[string]interface{}
}
```

**Domain: E-commerce**
- Terms: `Order`, `Cart`, `Checkout`, `Payment`, `Fulfillment`
- NOT: `Record`, `Data`, `Process`, `Thing`

---

## Bounded Contexts

**What:** Explicit boundaries where a model applies. Same word can mean different things in different contexts.

**Why:**
- `Customer` in Sales ≠ `Customer` in Support
- `Product` in Catalog ≠ `Product` in Inventory

**How to identify:**
1. Linguistic boundaries (same word, different meanings)
2. Organizational boundaries (different teams)
3. Functional boundaries (different capabilities)

**Example contexts:**
- **Order Management:** Order, LineItem, Payment, Fulfillment
- **Inventory:** Stock, Warehouse, Product, Replenishment
- **Customer Support:** Ticket, CustomerProfile, SLA, Resolution

**Go implementation:**
```
project/
├── internal/
│   ├── orders/        # Order Management context
│   ├── inventory/     # Inventory context
│   └── support/       # Support context
```

**Boundaries:**
- Each context has its own model
- No shared database tables between contexts
- Communication via APIs/events only

---

## Context Mapping

**What:** Relationships between bounded contexts.

**Patterns:**

1. **Shared Kernel** - Two contexts share subset of model (tight coupling, use sparingly)
2. **Customer/Supplier** - Upstream serves downstream (e.g., Catalog → Orders)
3. **Conformist** - Downstream adopts upstream model (for external systems)
4. **Anti-Corruption Layer (ACL)** - Downstream translates upstream model to protect domain
5. **Published Language** - Shared spec both sides conform to (REST contracts, event schemas)
6. **Separate Ways** - No relationship, duplicate if needed (least coupling)

**ACL Example:**
```go
package orders

type Order struct { /* domain model */ }

type PaymentACL struct {
    provider ExternalPaymentProvider
}

func (acl *PaymentACL) ProcessPayment(order Order) (PaymentResult, error) {
    // Translate Order → provider's format
    extRequest := acl.toProviderRequest(order)
    extResponse := acl.provider.Charge(extRequest)
    // Translate response → domain PaymentResult
    return acl.toDomainResult(extResponse)
}
```

---

## Subdomains

**Types:**
1. **Core Domain** - Competitive advantage, invest heavily (e.g., Netflix recommendations)
2. **Supporting Subdomain** - Necessary but not differentiating (user management, notifications)
3. **Generic Subdomain** - Solved problem, buy/use OSS (auth, payment, email)

**Strategy:**
- Core: Best developers, custom implementation
- Supporting: Simple in-house implementation
- Generic: Buy or use libraries

---

## Layered Architecture

```
┌─────────────────────────────────┐
│   Application Layer             │  ← Use cases, orchestration
├─────────────────────────────────┤
│   Domain Layer                  │  ← Business logic (entities, aggregates)
├─────────────────────────────────┤
│   Infrastructure Layer          │  ← DB, HTTP, external services
└─────────────────────────────────┘
```

**Domain Layer:** Business rules, no framework dependencies, pure Go
**Application Layer:** Coordinates domain objects, transaction boundaries
**Infrastructure Layer:** Database, HTTP, external APIs

---

## Context Mapping Patterns - Detailed

### Shared Kernel

**When to use:** Two teams need to share a small, stable subset of the domain model

**Example:**
```go
// pkg/shared/
package shared

type Money struct {
    amount   decimal.Decimal
    currency string
}

type Address struct {
    street  string
    city    string
    country string
}
```

**Risks:**
- Tight coupling between contexts
- Changes require coordination between teams
- Use sparingly

---

### Customer/Supplier

**When to use:** One context (supplier) provides services to another (customer)

**Example:**
```go
// Catalog context (upstream supplier)
package catalog

type ProductService interface {
    GetProduct(id ProductID) (*Product, error)
}

// Orders context (downstream customer)
package orders

type CatalogClient struct {
    productService catalog.ProductService
}
```

---

### Anti-Corruption Layer (ACL)

**When to use:** Protect your domain from external systems or legacy code

**Full example:**
```go
package orders

// Domain model (clean)
type Payment struct {
    orderID OrderID
    amount  Money
    status  PaymentStatus
}

// ACL translates between domain and external system
type StripeACL struct {
    client *stripe.Client
}

func (acl *StripeACL) ProcessPayment(payment Payment) error {
    // Translate domain → Stripe format
    stripeRequest := &stripe.ChargeParams{
        Amount:   stripe.Int64(payment.amount.Cents()),
        Currency: stripe.String(payment.amount.Currency()),
    }
    
    // Call external system
    charge, err := acl.client.Charges.New(stripeRequest)
    
    // Translate Stripe → domain
    if charge.Status == "succeeded" {
        payment.status = PaymentStatusCompleted
    }
    return err
}
```

**Benefits:**
- Domain model stays clean
- Easy to swap external systems
- Isolates breaking changes

---

## Common Domain Examples

**E-commerce**
- Contexts: Catalog, Orders, Inventory, Shipping, Billing
- Core aggregates: Order, Product, Cart, Shipment
- Context mapping:
  - Orders ← Catalog (ACL for product info)
  - Orders → Inventory (events for stock reservation)
  - Orders → Shipping (events for fulfillment)

**Banking**
- Contexts: Accounts, Transactions, Loans, Customers
- Core aggregates: Account, Transaction, Loan
- Context mapping:
  - Transactions → Accounts (events for balance updates)
  - Loans ← Customers (ACL for credit checks)

**SaaS Platform**
- Contexts: Users, Billing, Features, Analytics
- Core aggregates: Tenant, Subscription, User
- Context mapping:
  - Features ← Billing (check subscription status)
  - Analytics ← All contexts (consume domain events)

---

## Resources

- Eric Evans: "Domain-Driven Design" (Blue Book) - Chapter 3-4 (Strategic Design)
- Vaughn Vernon: "Implementing Domain-Driven Design" (Red Book) - Chapter 2-4
- Martin Fowler: "Bounded Context" pattern

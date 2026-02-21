---
name: domain-driven-design
description: Comprehensive Domain-Driven Design patterns covering strategic (bounded contexts, context mapping, ubiquitous language) and tactical (aggregates, entities, value objects, repositories, domain events) DDD. Includes Go-specific implementation patterns and DDD-to-Schema mapping guidance for OLTP and OLAP systems.
context: fork
license: MIT
---

# Domain-Driven Design

Apply strategic and tactical DDD patterns to model complex business domains with clear boundaries, shared language, and maintainable code architecture.

---

## Quick Start

**When to use DDD:**
- Complex business rules (not simple CRUD)
- Multiple teams/contexts requiring clear boundaries
- Need for shared language between developers and domain experts

**When NOT to use DDD:**
- Simple data models with minimal business logic
- Basic CRUD applications
- Small projects with straightforward requirements

**Quick decision:**
```
Complex business rules? → Yes → Use DDD
Multiple teams/contexts? → Yes → Strategic DDD
Simple CRUD? → Yes → Skip DDD
```

**Workflow:**
1. Start with Strategic DDD (bounded contexts, ubiquitous language)
2. Apply Tactical DDD (aggregates, entities, value objects)
3. Map to schemas:
   - Transactional data → `oltp-schema-design` (5NF)
   - Analytics data → `olap-schema-design` (Star Schema)
4. Visualize with `mermaid-diagrams`

---

## Triggers

| Trigger | Example |
|---------|---------|
| `DDD` | "apply DDD to order management" |
| `domain-driven design` | "domain-driven design for microservices" |
| `bounded context` | "identify bounded contexts for e-commerce" |
| `aggregate` | "design aggregate for shopping cart" |
| `domain model` | "create domain model for billing system" |
| `ubiquitous language` | "establish ubiquitous language with team" |
| `domain event` | "model domain events for order workflow" |
| `context mapping` | "map context relationships between services" |

---

## Key Terms

| Term | Definition |
|------|------------|
| **Bounded Context** | Explicit boundary where a domain model applies |
| **Ubiquitous Language** | Shared vocabulary between developers and domain experts |
| **Aggregate** | Cluster of entities/value objects with consistency boundary |
| **Aggregate Root** | Entry point entity for an aggregate |
| **Entity** | Object with unique identity that persists over time |
| **Value Object** | Immutable object defined by its attributes |
| **Repository** | Abstraction for retrieving/persisting aggregates |
| **Domain Event** | Something that happened in the domain that experts care about |
| **Domain Service** | Stateless operation that doesn't belong to an entity |

---

## Core Concepts Overview

### Strategic DDD (High-Level Modeling)

- **Ubiquitous Language:** Shared vocabulary in code and conversations
- **Bounded Contexts:** Explicit boundaries where models apply
- **Context Mapping:** Relationships between contexts (ACL, Customer/Supplier)
- **Subdomains:** Core (invest), Supporting (build simple), Generic (buy/OSS)
- **Layered Architecture:** Domain, Application, Infrastructure layers

**See:** [references/strategic-ddd.md](references/strategic-ddd.md)

---

### Tactical DDD (Implementation Patterns)

- **Entities:** Objects with identity (Order, Customer, Product)
- **Value Objects:** Immutable, no identity (Money, Address, Email)
- **Aggregates:** Consistency boundaries with one root entity
- **Repositories:** Load/save aggregates (interface in domain, impl in infrastructure)
- **Domain Services:** Operations spanning multiple entities
- **Domain Events:** Past-tense notifications (OrderPlaced, PaymentProcessed)

**See:** [references/tactical-ddd.md](references/tactical-ddd.md)

---

### Go Implementation

- **Project Structure:** Bounded contexts in `internal/`, layers per context
- **Aggregate Pattern:** Private fields, constructors, behavior methods
- **Value Object Pattern:** Immutable, operations return new instances
- **Repository Pattern:** Interface in domain, implementation in infrastructure
- **Domain Events:** Collected in aggregates, published after save

**See:** [references/go-patterns.md](references/go-patterns.md)

---

### Schema Mapping

**OLTP (Transactional):**
- Aggregate → Table(s): Root + internal entities
- Value Objects → Columns or table
- Foreign keys enforce aggregate boundaries

**OLAP (Analytical):**
- Domain Events → Fact table rows
- Aggregate state → Dimensions (SCD Type 2)
- CQRS: Separate write (OLTP) and read (OLAP) models

**See:** [references/schema-mapping.md](references/schema-mapping.md)

---

## Skill Composition

**Workflow:**
1. **domain-driven-design** (this skill) - Model domain
2. **mermaid-diagrams** - Visualize contexts, aggregates, events
3. **oltp-schema-design** - Map aggregates → 5NF tables
4. **olap-schema-design** - Map events → star schema

---

## Common Examples

**E-commerce**
- Contexts: Catalog, Orders, Inventory, Shipping, Billing
- Core aggregates: Order, Product, Cart, Shipment

**Banking**
- Contexts: Accounts, Transactions, Loans, Customers
- Core aggregates: Account, Transaction, Loan

**SaaS Platform**
- Contexts: Users, Billing, Features, Analytics
- Core aggregates: Tenant, Subscription, User

---

## References

### Books
- Eric Evans: "Domain-Driven Design" (Blue Book)
- Vaughn Vernon: "Implementing Domain-Driven Design" (Red Book)
- Martin Fowler: PoEAA (Patterns of Enterprise Application Architecture)

### Deep Dives
- [Strategic DDD](references/strategic-ddd.md) - Bounded contexts, context mapping, ubiquitous language
- [Tactical DDD](references/tactical-ddd.md) - Entities, value objects, aggregates, repositories, events
- [Go Patterns](references/go-patterns.md) - Go-specific implementation patterns
- [Schema Mapping](references/schema-mapping.md) - DDD → OLTP/OLAP mapping strategies

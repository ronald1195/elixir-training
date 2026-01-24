# Elixir Training - Progress Tracker

## Legend
- [ ] Not started
- [~] In progress
- [x] Completed

---

## Phase 1: Foundation Setup

### Project Infrastructure
- [x] Initialize Git repository
- [x] Set up GitHub repo with proper README
- [x] Configure CI for running exercises (GitHub Actions)
- [x] Set up mix aliases for running specific sessions

### Session Materials Template
- [x] Create standard template for session content
- [x] Define exercise structure (problem statement, hints, solution)
- [ ] Create automated test runner for exercises

---

## Phase 2: Session Content Development

### Session 1: From OOP to Functional
- [x] Write theory/slides content
- [x] Create `lib/session_01_basics/` module structure
- [x] Implement `Money` module exercise
- [x] Write tests for Money exercise
- [x] Create solution file (hidden by default)

### Session 2: Pattern Matching
- [x] Write theory/slides content
- [x] Create `lib/session_02_pattern_matching/` module structure
- [x] Implement `PaymentProcessor` exercise
- [x] Write tests for PaymentProcessor
- [x] Add additional exercises (API response parsing, Kafka routing)

### Session 3: Collections & Enum
- [x] Write theory/slides content
- [x] Create `lib/session_03_collections/` module structure
- [x] Implement transaction batch processing exercise
- [x] Write tests for batch processor
- [x] Add Stream exercises for large dataset handling
- [x] Create ReportGenerator module with Stream examples
- [x] Write comprehensive tests for all exercises
- [x] Create solution files

### Session 4: Umbrella Applications & Project Architecture
- [ ] Write theory/slides content
- [ ] Create `lib/session_04_umbrella/` module structure
- [ ] Create mini umbrella app for exploration
- [ ] Write exercises on bounded contexts
- [ ] Add Juno structure navigation exercises

### Session 5: Processes
- [ ] Write theory/slides content
- [ ] Create `lib/session_04_processes/` module structure
- [ ] Implement rate limiter exercise
- [ ] Write tests for rate limiter
- [ ] Add message passing exercises

### Session 6: GenServer
- [ ] Write theory/slides content
- [ ] Create `lib/session_05_genserver/` module structure
- [ ] Implement `CreditLimitCache` exercise
- [ ] Write tests for CreditLimitCache
- [ ] Add connection pool exercise

### Session 7: Supervision Trees
- [ ] Write theory/slides content
- [ ] Create `lib/session_06_supervision/` module structure
- [ ] Design payment processing supervision tree exercise
- [ ] Write tests for supervision scenarios
- [ ] Add failure injection exercises

### Session 8: Oban - Background Job Processing
- [ ] Write theory/slides content
- [ ] Create `lib/session_08_oban/` module structure
- [ ] Implement invoice processing worker exercise
- [ ] Write tests for Oban workers
- [ ] Add job scheduling and retry examples

### Session 9: Ecto Basics
- [ ] Write theory/slides content
- [ ] Create `lib/session_07_ecto/` module structure
- [ ] Set up test database configuration
- [ ] Implement `Transactions` context exercise
- [ ] Write changeset validation tests
- [ ] Add Ecto.Multi exercise

### Session 10: Advanced Ecto - Multi-tenancy & Complex Patterns
- [ ] Write theory/slides content
- [ ] Create `lib/session_10_advanced_ecto/` module structure
- [ ] Implement multi-tenant expense reporting exercise
- [ ] Add Ecto.Multi examples
- [ ] Write complex query exercises
- [ ] Add performance optimization exercises

### Session 11: HTTP Clients
- [ ] Write theory/slides content
- [ ] Create `lib/session_08_http/` module structure
- [ ] Implement credit bureau client exercise
- [ ] Add circuit breaker integration
- [ ] Write tests with mocked HTTP responses

### Session 12: GraphQL with Absinthe
- [ ] Write theory/slides content
- [ ] Create `lib/session_12_graphql/` module structure
- [ ] Implement GraphQL schema and resolvers
- [ ] Add Dataloader exercises
- [ ] Write authentication/authorization examples
- [ ] Add subscription exercises

### Session 13: Broadway & Kafka Integration
- [ ] Write theory/slides content
- [ ] Create `lib/session_09_testing/` module structure
- [ ] Create exercises testing previous session code
- [ ] Add Mox examples
- [ ] Document testing patterns used in org

- [ ] Write theory/slides content
- [ ] Create `lib/session_13_broadway/` module structure
- [ ] Set up local Kafka for development
- [ ] Implement Broadway pipeline exercise
- [ ] Add transaction event consumer with Broadway
- [ ] Write integration tests
- [ ] Add idempotency patterns

### Session 14: gRPC Services
- [ ] Write theory/slides content
- [ ] Create `lib/session_11_grpc/` module structure
- [ ] Define protobuf schemas
- [ ] Implement credit limit gRPC service
- [ ] Write gRPC tests

### Session 15: Protocols, Behaviours & Polymorphism
- [ ] Write theory/slides content
- [ ] Create `lib/session_15_protocols/` module structure
- [ ] Implement payment gateway behaviour exercise
- [ ] Add protocol implementation examples
- [ ] Write dependency injection patterns
- [ ] Add examples from Juno (BankClient pattern)

### Session 16: Testing in Elixir
- [ ] Write theory/slides content
- [ ] Create `lib/session_16_testing/` module structure
- [ ] Create exercises testing previous session code
- [ ] Add Mox examples with behaviours
- [ ] Document ExMachina factory patterns
- [ ] Add Broadway and GraphQL testing examples

### Session 17: WebSockets & Real-Time Features
- [ ] Write theory/slides content
- [ ] Create `lib/session_12_realtime/` module structure
- [ ] Implement WebSocket notification system
- [ ] Add webhook receiver exercise
- [ ] Write tests for real-time features

---

## Phase 3: Workshop Materials

### Presentation Decks
- [ ] Session 1 slides (From OOP to Functional)
- [ ] Session 2 slides (Pattern Matching)
- [ ] Session 3 slides (Collections & Enum)
- [ ] Session 4 slides (Umbrella Applications)
- [ ] Session 5 slides (Processes)
- [ ] Session 6 slides (GenServer)
- [ ] Session 7 slides (Supervision Trees)
- [ ] Session 8 slides (Oban)
- [ ] Session 9 slides (Ecto Basics)
- [ ] Session 10 slides (Advanced Ecto)
- [ ] Session 11 slides (HTTP Clients)
- [ ] Session 12 slides (GraphQL with Absinthe)
- [ ] Session 13 slides (Broadway & Kafka)
- [ ] Session 14 slides (gRPC Services)
- [ ] Session 15 slides (Protocols & Behaviours)
- [ ] Session 16 slides (Testing)
- [ ] Session 17 slides (WebSockets)

### Facilitator Guides
- [ ] Create facilitator notes template
- [ ] Document common questions/issues per session
- [ ] Create troubleshooting guide

---

## Phase 4: Polish & Release

### Documentation
- [ ] Write comprehensive README
- [ ] Add setup instructions for each session
- [ ] Create "How to use this repo" guide
- [ ] Add contribution guidelines

### Quality Assurance
- [ ] Review all exercises for clarity
- [ ] Test all exercises on fresh setup
- [ ] Get peer review from another Elixir engineer
- [ ] Pilot with 1-2 volunteers

---

## Future Expansion (Phase 5+)

### Advanced Topics Backlog
- [ ] GenStage and Flow (beyond Broadway)
- [ ] DynamicSupervisor patterns
- [ ] Custom Ecto adapters (OpenSearch integration)
- [ ] Telemetry and observability (Datadog, Spandex)
- [ ] Apache Flink integration patterns
- [ ] Distributed Elixir (libcluster strategies)
- [ ] Hot code upgrades and releases

### Juno-Specific Deep Dive Sessions
- [ ] Session 18: Navigating the Juno Codebase
  - Core.Supervisor walkthrough
  - Finding the right context for changes
  - Understanding the umbrella structure
- [ ] Session 19: Juno's Domain Model
  - Companies, Users, Cards, Transactions, Budgets
  - Banking partner abstractions
  - State machines with EctoStateMachine
- [ ] Session 20: Working with Juno's Test Suite
  - ExMachina factories deep dive
  - Testing strategies for complex scenarios
  - CI/CD and test performance

---

## Notes & Ideas

### Session Feedback
<!-- Add feedback from each session run here -->

### Content Ideas
<!-- Add ideas for new exercises or topics -->

### Known Issues
<!-- Track any issues with the material -->

---

## Completed Items Archive

<!-- Move completed items here with dates -->


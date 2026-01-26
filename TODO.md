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
- [x] Write theory/slides content
- [x] Create `lib/session_04_umbrella/` module structure
- [x] Create ProjectExplorer exercise for dependency analysis
- [x] Write exercises on bounded contexts
- [x] Add real-world application structure navigation exercises

### Session 5: Processes
- [x] Write theory/slides content
- [x] Create `lib/session_05_processes/` module structure
- [x] Implement rate limiter exercise
- [x] Write tests for rate limiter
- [x] Add message passing exercises

### Session 6: GenServer
- [x] Write theory/slides content
- [x] Create `lib/session_06_genserver/` module structure
- [x] Implement `CreditLimitCache` exercise
- [x] Write tests for CreditLimitCache
- [x] Add TTL and expiration examples

### Session 7: Supervision Trees
- [x] Write theory/slides content
- [x] Create `lib/session_07_supervision/` module structure
- [x] Design payment processing supervision tree exercise
- [x] Write tests for supervision scenarios
- [x] Add restart strategy examples

### Session 8: Oban - Background Job Processing
- [x] Write theory/slides content
- [x] Create `lib/session_08_oban/` module structure
- [x] Implement invoice processing worker exercise
- [x] Write tests for Oban workers
- [x] Add job scheduling and retry examples

### Session 9: Ecto Basics
- [x] Write theory/slides content
- [x] Create `lib/session_09_ecto/` module structure
- [x] Set up test database configuration (PostgreSQL)
- [x] Implement Account schema and Accounts context exercises
- [x] Write changeset validation tests
- [x] Add transaction exercises

### Session 10: Advanced Ecto - Multi-tenancy & Complex Patterns
- [x] Write theory/slides content
- [x] Create `lib/session_10_advanced_ecto/` module structure
- [x] Implement multi-tenant expense reporting exercise
- [x] Add Ecto.Multi examples
- [x] Write complex query exercises
- [x] Add aggregation and performance exercises

### Session 11: HTTP Clients
- [x] Write theory/slides content
- [x] Create `lib/session_11_http/` module structure
- [x] Implement credit bureau client exercise
- [x] Add circuit breaker integration (Fuse)
- [x] Write tests with configurable behaviors

### Session 12: GraphQL with Absinthe
- [x] Write theory/slides content
- [x] Create `lib/session_12_graphql/` module structure
- [x] Implement GraphQL schema and resolvers
- [x] Add expense management queries/mutations
- [x] Write resolver exercises

### Session 13: Broadway & Kafka Integration
- [x] Write theory/slides content
- [x] Create `lib/session_13_broadway/` module structure
- [x] Implement Broadway pipeline exercise
- [x] Add transaction event consumer with Broadway
- [x] Write integration tests
- [x] Add idempotency patterns

### Session 14: gRPC Services
- [x] Write theory/slides content
- [x] Create `lib/session_14_grpc/` module structure
- [x] Define protobuf schemas
- [x] Implement credit limit gRPC service
- [x] Write gRPC tests

### Session 15: Protocols, Behaviours & Polymorphism
- [x] Write theory/slides content
- [x] Create `lib/session_15_protocols/` module structure
- [x] Implement payment gateway behaviour exercise
- [x] Add protocol implementation examples
- [x] Write dependency injection patterns
- [x] Add real-world examples (PaymentGateway pattern)

### Session 16: Testing in Elixir
- [x] Write theory/slides content
- [x] Create `lib/session_16_testing/` module structure
- [x] Create PaymentService as testing subject
- [x] Add Mox examples with behaviours
- [x] Document ExMachina factory patterns

### Session 17: WebSockets & Real-Time Features
- [x] Write theory/slides content
- [x] Create `lib/session_17_websockets/` module structure
- [x] Implement PubSub-based notification system
- [x] Add webhook receiver exercise with HMAC verification
- [x] Write tests for real-time features

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

### Advanced Deep Dive Sessions
- [ ] Session 18: Navigating Large Codebases
  - Application Supervisor walkthrough
  - Finding the right context for changes
  - Understanding the umbrella structure
- [ ] Session 19: Complex Domain Models
  - Multi-entity relationships
  - External service abstractions
  - State machines with EctoStateMachine
- [ ] Session 20: Production Testing Strategies
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


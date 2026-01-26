# Elixir Training

[![CI](https://github.com/ronald1195/elixir_training/actions/workflows/ci.yml/badge.svg)](https://github.com/ronald1195/elixir_training/actions/workflows/ci.yml)

A hands-on training curriculum for engineers transitioning to Elixir from OOP languages.

## Overview

This repository contains workshop materials, exercises, and solutions for learning Elixir in the context of building reliable financial services. The curriculum targets engineers working on production Elixir applications, with a focus on fintech and SaaS patterns.

**Target Audience:** Engineers with Java, C#, Python or similar OOP backgrounds transitioning to Elixir

**Format:** 17 workshop sessions with hands-on exercises (15 core + 2 advanced)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/ronald1195/elixir-training
cd elixir_training

# Setup (install deps + compile)
mix setup

# Run all tests
mix test

# Run tests for a specific session
mix session1   # Session 1: From OOP to Functional
mix session2   # Session 2: Pattern Matching
# ... etc
```

## Available Commands

| Command | Description |
|---------|-------------|
| `mix setup` | Install dependencies and compile |
| `mix session1` | Run Session 1 tests |
| `mix session2` | Run Session 2 tests |
| `mix session3` ... `mix session17` | Run tests for sessions 3-17 |
| `mix test.sessions` | Run all session tests |
| `mix validate.session1` | Compile with warnings + run session 1 tests |
| `mix lint` | Check formatting and compile warnings |
| `mix test` | Run all tests |

## Curriculum

### Foundations (Sessions 1-3)
| Session | Topic | Focus | Status |
|---------|-------|-------|--------|
| 1 | From OOP to Functional | Immutability, basic syntax, pipe operator | ✅ Ready |
| 2 | Pattern Matching | Destructuring, function clauses, guards, `with` pipeline | ✅ Ready |
| 3 | Collections & Enum | Data transformation, streams, comprehensions | ✅ Ready |

### Architecture & Concurrency (Sessions 4-8)
| Session | Topic | Focus | Status |
|---------|-------|-------|--------|
| 4 | Umbrella Applications | Multi-app projects, bounded contexts, real-world structure | ✅ Ready |
| 5 | Processes | Actor model, spawning, message passing | ✅ Ready |
| 6 | GenServer | Stateful services, call vs cast, OTP patterns | ✅ Ready |
| 7 | Supervision Trees | Fault tolerance, restart strategies, let it crash | ✅ Ready |
| 8 | Oban | Background jobs, queues, retries, idempotency | ✅ Ready |

### Data Layer (Sessions 9-10)
| Session | Topic | Focus | Status |
|---------|-------|-------|--------|
| 9 | Ecto Basics | Schemas, changesets, queries, transactions | ✅ Ready |
| 10 | Advanced Ecto | Multi-tenancy, Ecto.Multi, complex queries, performance | ✅ Ready |

### Integration Patterns (Sessions 11-14)
| Session | Topic | Focus | Status |
|---------|-------|-------|--------|
| 11 | HTTP Clients | External integrations, retries, circuit breakers | ✅ Ready |
| 12 | GraphQL with Absinthe | Schemas, resolvers, Dataloader, subscriptions | ✅ Ready |
| 13 | Broadway & Kafka | Event-driven architecture, message processing pipelines | ✅ Ready |
| 14 | gRPC Services | Protobuf, servers, clients, streaming | ✅ Ready |

### Advanced Patterns (Sessions 15-17)
| Session | Topic | Focus | Status |
|---------|-------|-------|--------|
| 15 | Protocols & Behaviours | Polymorphism, contracts, dependency injection | ✅ Ready |
| 16 | Testing in Elixir | ExUnit, Mox, factories, testing Broadway/GraphQL | ✅ Ready |
| 17 | WebSockets & Real-Time | Phoenix Channels, webhooks, PubSub | ✅ Ready |

See [CURRICULUM.md](CURRICULUM.md) for detailed session content.

## Repository Structure

```
elixir_training/
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions CI pipeline
├── lib/
│   ├── session_01_basics/      # Session 1 exercises
│   │   ├── README.md           # Theory and instructions
│   │   └── money.ex            # Exercise module
│   ├── session_02_pattern_matching/
│   └── ...
├── test/
│   ├── session_01_basics/      # Tests for session 1
│   └── ...
├── solutions/                  # Reference solutions (gitignored for workshops)
├── CURRICULUM.md               # Detailed curriculum
├── TODO.md                     # Progress tracker
└── mix.exs                     # Project config with aliases
```

## How to Use This Repository

### For Workshop Participants

1. **Read the session guide** - Each session has `lib/session_XX/README.md` with theory and concepts
2. **Implement the exercises** - Functions are stubbed with `raise "TODO"`
3. **Run tests to verify** - Use `mix sessionX` to run that session's tests
4. **Check hints if stuck** - Hints are in `<details>` tags in the README

Example workflow:
```bash
# Start Session 1
cat lib/session_01_basics/README.md   # Read the theory

# Edit the exercise file
# (implement the functions in lib/session_01_basics/money.ex)

# Run tests to check your work
mix session1

# See which tests pass/fail and iterate
```

### For Workshop Facilitators

1. Check [TODO.md](TODO.md) for session preparation status
2. Each session has facilitator notes in `lib/session_XX/FACILITATOR.md`
3. Solutions are in `solutions/` (uncomment in `.gitignore` to hide from participants)
4. Run `mix lint` before workshops to ensure code quality

## Prerequisites

- Elixir 1.15+ installed ([installation guide](https://elixir-lang.org/install.html))
- Basic terminal familiarity
- Git basics
- A code editor (VS Code with ElixirLS recommended)

### Session-Specific Requirements

| Sessions | Additional Requirements |
|----------|------------------------|
| 8 (Oban) | PostgreSQL |
| 9-10 (Ecto) | PostgreSQL |
| 13 (Broadway/Kafka) | Docker or local Kafka (optional - in-memory producer for testing) |
| 14 (gRPC) | protoc compiler |

## CI/CD

This repo uses GitHub Actions for continuous integration:

- **Test** - Runs all tests on push/PR
- **Format** - Checks code formatting
- **Session Tests** - Validates each session independently

## Progress Tracking

See [TODO.md](TODO.md) for current development status.

## Contributing

Found an issue or want to add content? Please open a PR or issue.

## License

Copyright 2026 Ronald Munoz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



# Elixir Training

[![CI](https://github.com/YOUR_USERNAME/elixir_training/actions/workflows/ci.yml/badge.svg)](https://github.com/YOUR_USERNAME/elixir_training/actions/workflows/ci.yml)

A hands-on training curriculum for engineers transitioning to Elixir from OOP languages.

## Overview

This repository contains workshop materials, exercises, and solutions for learning Elixir in the context of building reliable financial services.

**Target Audience:** Engineers with Java, C#, Python or similar OOP backgrounds

**Format:** 12 workshop sessions with hands-on exercises

## Quick Start

```bash
# Clone the repository
git clone <repo-url>
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
| `mix session3` ... `mix session12` | Run tests for sessions 3-12 |
| `mix test.sessions` | Run all session tests |
| `mix validate.session1` | Compile with warnings + run session 1 tests |
| `mix lint` | Check formatting and compile warnings |
| `mix test` | Run all tests |

## Curriculum

| Session | Topic | Focus | Status |
|---------|-------|-------|--------|
| 1 | From OOP to Functional | Immutability, basic syntax, pipe operator | Ready |
| 2 | Pattern Matching | Destructuring, function clauses, guards | Ready |
| 3 | Collections & Enum | Data transformation, streams, comprehensions | Planned |
| 4 | Processes | Actor model, spawning, message passing | Planned |
| 5 | GenServer | Stateful services, call vs cast | Planned |
| 6 | Supervision Trees | Fault tolerance, restart strategies | Planned |
| 7 | Ecto | Schemas, changesets, queries, transactions | Planned |
| 8 | HTTP Clients | External integrations, retries, circuit breakers | Planned |
| 9 | Testing | ExUnit, mocking with Mox, async tests | Planned |
| 10 | Kafka Integration | Producers, consumers, idempotency | Planned |
| 11 | gRPC Services | Protobuf, servers, clients, streaming | Planned |
| 12 | WebSockets | Real-time features, webhooks | Planned |

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
| 7 (Ecto) | PostgreSQL |
| 10 (Kafka) | Docker or local Kafka |
| 11 (gRPC) | protoc compiler |

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

Internal training material - [Your Organization]

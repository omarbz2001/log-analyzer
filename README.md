# Log Analyzer — A Flix Demo Project

> **Advanced Programming — Homework 6**
> Technology: [Flix](https://flix.dev/) | Demo of: Functional Programming · Typing · Concurrency

---

## What is this?

A real-time log analyzer pipeline built in [Flix](https://flix.dev/), a functional-first JVM language with a powerful type and effect system.

The project demonstrates three core Flix features through a single, cohesive application:

| Feature | Where it appears |
|---|---|
| **Functional Programming** | Pure parsing, classification, and fold-based aggregation |
| **Typing** | Algebraic data types (`LogLevel`, `LogEntry`), typed channels, exhaustive pattern matching |
| **Concurrency** | Structured concurrency with `region`, `spawn`, and typed channels |

---

## Architecture

The analyzer runs as a concurrent pipeline of three independent processes:

```
[Producer]──Chan[String]──▶ [ParserStage] ──Chan[Option[LogEntry]]──▶ [AggregatorStage] ──▶ [Report]
```

Each stage runs concurrently via `spawn` inside a `region`. They communicate exclusively through **typed channels** — no shared mutable state.

---

## Project Structure

```
log-analyzer/
├── src/
│   ├── LogEntry.flix      # Types: LogLevel, LogEntry, LogSummary (ADTs)
│   ├── Parser.flix        # Pure log line parsing
│   ├── Classifier.flix    # Pure filtering logic
│   ├── Aggregator.flix    # Pure fold-based aggregation
│   └── Main.flix          # Concurrent pipeline wiring
├── test/
│   └── TestMain.flix      # Unit tests for pure functions
├── flix.toml
└── README.md
```

---

## Prerequisites

- **Java 21+** — verify with `java -version`
- **Flix compiler** — `flix.jar` in the project root (see setup below)

---

## Setup

**Option A — VS Code (recommended)**

1. Open the project folder in VS Code
2. Install the [Flix extension](https://marketplace.visualstudio.com/items?itemName=flix.flix) when prompted
3. Let the extension download the Flix compiler automatically
4. Click **Run** above `main` in `Main.flix`

**Option B — Command line**

```bash
# Download the latest flix.jar
curl -fsSL -o flix.jar https://github.com/flix/flix/releases/latest/download/flix.jar

# Run the project
java -jar flix.jar run

# Run tests
java -jar flix.jar test
```

---

## Expected Output

```
=== Log Summary ===
ERROR : 5
WARN  : 5
INFO  : 6
DEBUG : 0
```

The `DEBUG : 0` line is intentional — the **Classifier** filters out all debug-level entries before they reach the aggregator, demonstrating pure functional filtering in the pipeline.

---

## Key Flix Concepts Demonstrated

### Algebraic Data Types (Typing)
```flix
enum LogLevel with Eq, ToString {
    case Error
    case Warn
    case Info
    case Debug
}
```
The compiler enforces **exhaustive pattern matching** on `LogLevel` everywhere it is used.

### Pure Functions (Functional Programming)
```flix
// Parser.flix — no effects, returns Option instead of throwing
pub def parseLine(line: String): Option[LogEntry] = ...

// Aggregator.flix — immutable fold, returns a new LogSummary each step
pub def add(summary: LogSummary, entry: LogEntry): LogSummary = ...
```

### Typed Channels + Structured Concurrency
```flix
// Main.flix
region rc {
    let (rawTx, rawRx)       = Channel.buffered(10);  // Sender[String] / Receiver[String]
    let (parsedTx, parsedRx) = Channel.buffered(10);  // Sender[Option[LogEntry]] / ...

    spawn producer(rawTx)                  @ rc;
    spawn parserStage(rawRx, parsedTx, 20) @ rc;

    let summary = aggregatorStage(parsedRx);
    println(Aggregator.report(summary))
}
```
The `region` guarantees all spawned processes finish before `main` exits — **structured concurrency**.

### Effect Tracking (Typing)
```flix
def parseLine(line: String): Option[LogEntry]               // pure — no effects
def producer(tx: Sender[String]): Unit \ Chan               // only uses channels
def main(): Unit \ {Chan, NonDet, IO}                       // does IO + channels
```
The compiler **proves** which functions are pure and which have side effects — at compile time.

---

## Running the Tests

```bash
java -jar flix.jar test
```

Tests cover the three pure modules (`Parser`, `Classifier`, `Aggregator`) independently of the concurrent pipeline.

---

## CI

This project uses GitHub Actions. On every push to `main` and every pull request, the workflow:

1. Installs JDK 21
2. Downloads the Flix compiler version specified in `flix.toml`
3. Runs `flix check` (type-checks the whole project)
4. Runs `flix test` (runs all `@Test` functions)

---

## References

- [Flix official website](https://flix.dev/)
- [Programming Flix (book)](https://doc.flix.dev/)
- [Flix API documentation](https://api.flix.dev/)
- [Flix GitHub repository](https://github.com/flix/flix)
# Observability Interview Cheat Sheet

## Core Concepts

- **Observability**: How well you can understand a system's internal state from its external outputs (the data it produces).
- **Distributed System**: Independent computers that work together as a single system. Observability is crucial because of their complexity.

#### System Analysis Factors:
*   **Workload**: The operations a system performs (e.g., user requests, transactions).
*   **Resources**: The physical machines providing CPU, RAM, disk, etc.
*   **Structure**: The software components like services, containers, and load balancers.

---

## The Three Pillars of Observability
**Telemetry** is the raw data (logs, metrics, traces) collected to make a system observable.

### 1. Logs (Detailed Event Record)
- **What it is**: A detailed, timestamped record of a single, discrete event.
- **Best for**: Getting granular, context-rich information about a specific error or action.
- **Key Idea**: > Answers *"What happened at this exact moment?"*

### 2. Metrics (Overall System Health)
- **What it is**: Metrics track system performance over time (e.g., CPU usage %, requests per second).
- **Best for**: Getting a high-level, summarized view of system health and spotting trends or anomalies.
- **Key Idea**: > Answers *"How is the system performing overall?"*

### 3. Traces (End-to-End Request Journey)
- **What it is**: The end-to-end journey of a single request as it travels through multiple services.
- **Best for**: Debugging latency and understanding causality in a distributed system.
- **Key Idea**: > Answers *"Where did this request go and where did it slow down?"*

> **Why "Pillars"?** They are three distinct but complementary data types. You need all three for a stable and complete understanding of your system.

---

## Problems with Traditional Observability
*This is the "why" behind OpenTelemetry.*

- **Siloed Data**: Siloed telemetry means logs, metrics, and traces are stored separately for each service, making it hard to see the complete picture of how a request flows through the system.
- **No Standards**: Inconsistent data formats make it difficult to compare telemetry from different services.
- **Vendor Lock-in**: Instrumenting your code with a specific vendor's tools makes it extremely expensive and difficult to switch to a different tool later.
- **Open Source Burden**: OSS projects can't include vendor-specific instrumentation, forcing users to write and maintain custom adapters.

---

## OpenTelemetry (OTel) - The Solution

### What OTel IS ✅
A **vendor-neutral, open-source standard** and set of tools for generating and collecting telemetry data. Its main purpose is to standardize data collection so it can be sent to *any* backend.

### What OTel is NOT ❌
- It is **NOT** an observability platform like Datadog or New Relic. It's the agent that sends data *to* them.
- It is **NOT** a database or dashboard like Prometheus or Grafana. It doesn't store or visualize data.
- It is **NOT** an automatic performance optimizer. It provides the diagnostic data; you still have to fix the problem.

---

## OpenTelemetry Framework

### Signal Specification
- **What it is**: The language-agnostic rulebook that defines how signals (traces, metrics, logs) must behave.
- **Purpose**: Ensures consistency and interoperability across all languages and tools in the ecosystem.
- **Key Parts**:
    - **API Spec**: Defines the standard interfaces for instrumentation (what you code against).
    - **SDK Spec**: Defines the requirements for a compliant language-specific implementation (the "engine").
    - **Semantic Conventions**: Provides standardized names and attributes for telemetry data (e.g., `http.method`, `db.statement`) so that data is consistent and meaningful everywhere.

### Instrumentation (API vs. SDK)
*This is how telemetry is generated in your code. OpenTelemetry smartly separates it into two parts.*

#### API (Application Programming Interface) 📝
A lightweight, vendor-agnostic set of interfaces you use directly in your application or library code.
- **Key Idea**: You code against the API, not a specific vendor's tool. If no SDK is enabled, the API calls do nothing (they are "no-ops"), so there's no performance impact.

#### SDK (Software Development Kit) ⚙️
The "engine" that implements the API. It contains the complex logic for processing, batching, and exporting telemetry data.
- **Key Idea**: The SDK is the specific implementation you add to your application at startup to "turn on" and configure telemetry collection.

> **Why the split?**
> It allows open-source libraries to embed the lightweight API for instrumentation without forcing heavy dependencies or performance overhead from the SDK onto users who may not need it.

### Collector
- **What it is**: A standalone telemetry processor that acts as a highly flexible and powerful pipeline for your data. It's not part of your application.
- **Primary Jobs**:
    - **Receives**: Gathers data from many sources in many formats (e.g., OTLP, Jaeger, Prometheus).
    - **Processes**: Transforms the data (e.g., adds attributes, filters out noise, removes sensitive info, batches).
    - **Exports**: Sends the processed data to one or more backends (e.g., Datadog, Grafana, Splunk).

### OTLP (OpenTelemetry Protocol)
- **What it is**: The standard wire protocol for sending telemetry data between different components (e.g., from your app to the Collector, or from the Collector to a backend).
- **Purpose**: Ensures that all tools in the ecosystem can communicate reliably and efficiently without needing to constantly convert data between proprietary formats.
- **Key Features**:
    - **Transport**: Uses common network protocols like gRPC and HTTP.
    - **Encoding**: Typically uses efficient Protobuf for performance but also supports human-readable JSON.

---

## Key OpenTelemetry Environment Variables
*These are standard environment variables used to configure OpenTelemetry SDKs without changing any code.*

### `OTEL_RESOURCE_ATTRIBUTES`
- **Purpose**: To name and identify your service. This is the most important attribute for distinguishing one microservice from another.
- **How it works**: You set a `service.name` key, which gives your application a logical name that will appear in traces and metrics dashboards.
- **Example**:
```yaml
environment:
  - OTEL_RESOURCE_ATTRIBUTES=service.name=my-awesome-api
```

### `OTEL_EXPORTER_OTLP_ENDPOINT`
- **Purpose**: To tell the application where to send its telemetry data.
- **How it works**: It holds the URL of the destination, which is almost always an OpenTelemetry Collector.
- **Example**:
The variable is set to point to the collector's address and port.
```yaml
environment:
  - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
```
  This tells the application's OTel SDK to send all traces, metrics, and logs to the collector at that gRPC endpoint (`4317` is the default for gRPC).

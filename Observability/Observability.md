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

## Anatomy of a Span 🔬

A Span is the basic building block of a trace, representing a single operation (e.g., a database query, an HTTP call). Think of it as one step in a request's journey.

Each span contains the following key information:

- **Trace ID & Span ID**: Unique identifiers for the overall trace and this specific span.
- **Parent ID**: The ID of the span that initiated this one. If it's null, this is the root span (the start of the trace).
- **Name**: A human-readable name for the operation, like `HTTP GET /api/users`.
- **Timestamps**: The `start_time` and `end_time` that define the operation's duration.
- **SpanKind**: The role of the span (e.g., `SERVER`, `CLIENT`, `INTERNAL`).
- **Attributes**: A rich set of key-value pairs that provide context, like `http.method = "GET"` or `db.statement = "SELECT ..."`.
- **Events**: Timestamped logs attached to this specific span (e.g., "Cache miss occurred").
- **Status**: The outcome of the operation (`Ok` or `Error`).

## What is a Resource? 📍

A Resource represents the entity that generates telemetry. It's a collection of attributes that describe the "who" and "where" of your data source (e.g., the specific microservice, host, or container). This information is attached to all telemetry (traces, metrics, logs) emitted from that source.

It helps answer questions like:

- Which microservice sent this trace? (`service.name`)
- Which version of the service is it? (`service.version`)
- Which container or host is it running on? (`container.id`, `host.name`)
- Which cloud environment is it in? (`cloud.provider`, `cloud.region`)

## OpenTelemetry Metrics: The Core Concepts 📊

In OpenTelemetry, the process of creating metrics follows a specific hierarchy.

### Metric Creation Hierarchy

1. **Get a Meter**: To create metrics in your application, you first obtain a Meter object. A Meter acts as a "factory" for instruments.

2. **Create an Instrument**: Using the Meter, you create an Instrument (like a Counter, Gauge, etc.) that is appropriate for the type of metric you want to measure.

3. **Record a Measurement**: You use the instrument you created to record a Measurement (a single data point) within your code.

**Example**: Each time a server receives a request, a `request_counter` instrument records a measurement with the value of 1. These measurements are then aggregated to analyze behavior over time.

### Instrument Types

- **Counter**: Used for values that only increase (monotonically increasing).
  - *Example*: The total number of requests served.

- **UpAndDownCounter**: Used for values that can both increase and decrease.
  - *Example*: The number of active users or current database connections.

- **Gauge**: Used to measure the current value of something at a specific point in time. This instrument is asynchronous.
  - *Example*: The current CPU or memory usage percentage.

- **Histogram**: Used to record the statistical distribution of a set of measurements.
  - *Example*: The distribution of HTTP request latency (min, max, average, 99th percentile, etc.).

💡 **Synchronous vs. Asynchronous Instruments**

Instruments like Counter and UpAndDownCounter are typically used synchronously, meaning they are called in-line with your code. Asynchronous instruments like Gauge register a "callback" function that is invoked periodically. This is more efficient for values that are expensive to compute or change infrequently.

## The Four Golden Signals 🚦

Popularized by the Google SRE book, these four signals are considered the most critical high-level indicators for monitoring the health of a user-facing system. OpenTelemetry instruments are used to measure these signals.

- **Traffic**: The volume of requests your system is handling.
  - *How to Measure*: Typically measured as requests per second (RPS) using a Counter.

- **Latency**: The time it takes to serve a request.
  - *How to Measure*: Measured as a distribution of request durations (e.g., p95, p99 latency) using a Histogram.

- **Errors**: The rate of requests that fail.
  - *How to Measure*: Measured as a rate of failing requests (e.g., HTTP 5xx error rate) using a Counter that only increments on failure.

- **Saturation**: How "full" a resource is (CPU, memory, disk).
  - *How to Measure*: Measured as a percentage of utilization (e.g., CPU utilization %) using a Gauge to reflect the current state.

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

#### Practical Application: Instrumentation Types
There are three main ways to apply instrumentation, each with different trade-offs.

1. **Automatic Instrumentation (Zero-Code)** 🤖

*   **How it works**: Uses agents that attach to your application at runtime to instrument common libraries and frameworks without any code changes.
*   **Best for**: Quick setup, getting broad visibility on standard technologies (like HTTP calls, database queries) with minimal effort.
*   **Trade-off**: Offers the least control and customization.
*   **Example**: The OpenTelemetry Java Agent (`opentelemetry-javaagent.jar`) uses bytecode manipulation to automatically trace requests through your Java application.

2. **Instrumentation Libraries** 📚

*   **How it works**: Standalone libraries you add to your project to instrument specific frameworks that lack native OTel support.
*   **Best for**: Bridging the gap when a framework isn't covered by automatic instrumentation. It offers a balance between ease of use and control.
*   **Trade-off**: May require minimal code changes (e.g., configuring middleware) and adds a dependency to manage.
*   **Example**: Adding an `opentelemetry-instrumentation-django` library to your Python project to get traces for the Django framework.

3. **Manual Instrumentation (Code-Based)** ✍️

*   **How it works**: Directly adding OpenTelemetry API calls into your source code to create custom traces, metrics, or logs.
*   **Best for**: Gaining deep, fine-grained visibility into specific business logic or parts of your code that automatic tools can't see.
*   **Trade-off**: Requires the most effort and maintenance but provides full control.
*   **Example**: Manually starting and ending a custom span around a critical function to measure its exact duration and add business-specific attributes.

---

## Hands-On Labs: Instrumentation in Practice

### Lab 1: Automatic Instrumentation (Zero-Code) 🤖

Get baseline traces for HTTP requests, database calls, etc., from any Java app without changing its code.

**Process:**

```bash
# 1. Run a Jaeger container that includes an OTel Collector
# This listens for telemetry on port 4317 (gRPC)
docker run -d --name jaeger \
  -e COLLECTOR_OTLP_ENABLED=true \
  -p 4317:4317 -p 16686:16686 \
  jaegertracing/all-in-one

# 2. Configure the agent via environment variables
export OTEL_TRACES_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317

# 3. Start the app with the Java Agent attached
java -javaagent:opentelemetry-javaagent.jar -jar my-app.jar
```

**Pros:** 👍 Quick, no code changes, great starting point.

**Cons:** 👎 Blind to custom business logic; only sees common library calls (e.g., an incoming HTTP request, a database query).

### Lab 2: Enhancing with Annotations (Library-Based) ✍️

Allows you to "teach" the automatic agent which specific methods are important and should be traced, acting as a bridge between automatic and manual instrumentation.

**Process:**

```xml
<dependency>
  <groupId>io.opentelemetry.instrumentation</groupId>
  <artifactId>opentelemetry-instrumentation-annotations</artifactId>
</dependency>
```

```bash
# 2. Rebuild your project
mvn clean package

# 3. Add annotations to your source code (see example below)

# 4. Run the app with the same -javaagent command as before.
# The agent will now detect and process your annotations.
java -javaagent:opentelemetry-javaagent.jar -jar my-app.jar
```

**Code Example & Key Annotations:**

```java
import io.opentelemetry.instrumentation.annotations.SpanAttribute;
import io.opentelemetry.instrumentation.annotations.WithSpan;

/**
 * The agent now sees this method because of the annotations.
 */
// @WithSpan tells the agent to wrap this method in a new span.
@WithSpan
String someInternalMethod(@SpanAttribute String todo) {
    // @SpanAttribute captures the 'todo' parameter's value
    // and adds it as an attribute to the span for debugging.
    return "processed: " + todo;
}
```

**Result:** The method will now appear as a separate, nested segment in the Jaeger trace. This allows you to precisely measure its duration and see it as a distinct step in the request's lifecycle.

**Result:** In Jaeger, you can inspect the span and see the actual data that was passed into your method during that specific request, which is incredibly useful for debugging.

### Lab 3: Manual Instrumentation (Code-Based) ✍️

This lab demonstrates how to manually instrument a Python (Flask) application with OpenTelemetry to gain full control over your telemetry.

#### 1. The Setup: Initializing the Tracer

First, you must configure the OTel SDK, define your service's Resource attributes (using Semantic Conventions for consistency), and create a global Tracer object.

```python
# OTel SDK Imports
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import ConsoleSpanExporter, BatchSpanProcessor
from opentelemetry.sdk.resources import Resource
from opentelemetry.semconv.resource import ResourceAttributes

# 1. Define the Resource (who is sending telemetry?)
resource = Resource.create({
    ResourceAttributes.SERVICE_NAME: "my-python-app",
    ResourceAttributes.SERVICE_VERSION: "0.1.0",
})

# 2. Set up the Exporter and Processor pipeline
# (For this lab, we print spans to the console)
provider = TracerProvider(resource=resource)
processor = BatchSpanProcessor(ConsoleSpanExporter())
provider.add_span_processor(processor)

# 3. "Register" this configuration as the global trace provider
trace.set_tracer_provider(provider)

# 4. Get a tracer to use in the application
tracer = trace.get_tracer(__name__)
```

💡 **Best Practice: Separating Configuration**

In a real project, it's good practice to put all the OTel setup code above in a separate helper file (e.g., `trace_utils.py`). This keeps your main application code (`app.py`) clean and separates your business logic from observability configuration.

#### 2. Creating Spans & Adding Detail

Once you have a tracer, you can create spans and enrich them with dynamic, request-specific attributes.

```python
from flask import request
from opentelemetry.semconv.trace import SpanAttributes

# Use a decorator for a simple way to create a span around a function
@tracer.start_as_current_span("my_function_span")
def my_function():
    # Get the current span to add attributes to it
    span = trace.get_current_span()

    # Add attributes using Semantic Conventions for standard keys
    span.set_attributes({
        SpanAttributes.HTTP_REQUEST_METHOD: request.method,
        SpanAttributes.URL_PATH: request.path,
    })
    # ... your function logic ...
```

#### 3. Context Propagation (The Key to Distributed Tracing)

To link spans across network boundaries, you must manually pass the trace context.

**Injecting Context (Client-Side / Outgoing Request)** 📤

When your app calls another service, inject the current trace context into the outgoing HTTP headers.

```python
import requests
from opentelemetry.propagate import inject

@tracer.start_as_current_span("call_downstream_api")
def call_api():
    headers = {}
    # inject() adds the 'traceparent' header to the dictionary
    inject(headers)
    # The downstream service will receive this header
    requests.get("http://downstream-service/api", headers=headers)
```

**Extracting Context (Server-Side / Incoming Request)** 📥

When your app receives a request, extract the context from the incoming headers to continue the trace. This is often done in middleware.

```python
from flask import request
from opentelemetry import context
from opentelemetry.propagate import extract

# This runs before every request in Flask
@app.before_request
def before_request_func():
    # Extract the context from incoming headers (e.g., 'traceparent')
    ctx = extract(request.headers)
    # Set this extracted context as the currently active one
    context.attach(ctx)
```

### Lab 4: Manual Instrumentation Metrics in Practice: Python Example 📊

This lab covers the core patterns for manually instrumenting a Python application to collect custom metrics with OpenTelemetry, focusing on the Four Golden Signals.

#### 1. The Setup: Initializing the Meter

First, configure the OTel SDK's metrics pipeline. This involves setting up a MetricReader to periodically collect data and connecting it to a MeterProvider. From this provider, you get a Meter object, which is your "factory" for creating metric instruments.

```python
from opentelemetry import metrics
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import ConsoleMetricExporter, PeriodicExportingMetricReader

# 1. Set up the export pipeline (for this lab, print metrics to the console)
metric_reader = PeriodicExportingMetricReader(
    exporter=ConsoleMetricExporter(),
    export_interval_millis=5000  # Export every 5 seconds
)

# 2. Create a MeterProvider and register the reader
provider = MeterProvider(metric_readers=[metric_reader])
metrics.set_meter_provider(provider)

# 3. Get a Meter to create instruments
meter = metrics.get_meter("my-app-meter", "0.1.0")

# 4. Create your instruments (Counters, Histograms, etc.)
traffic_counter = meter.create_counter("traffic.volume", unit="request")
latency_histogram = meter.create_histogram("http.server.request.duration", unit="s")
cpu_gauge = meter.create_observable_gauge("process.cpu.utilization", callbacks=[...])
```

#### 2. Measuring the Four Golden Signals

Use Flask's request hooks (`@before_request`, `@after_request`) to efficiently measure the golden signals for all endpoints.

**Traffic & Errors (Counter)**

Use a Counter to track the total number of requests and another to track failures.

```python
# Create instruments
traffic_counter = meter.create_counter("traffic.volume")
error_counter = meter.create_counter("error.rate")

@app.before_request
def before_request_func():
    # Increment traffic counter for every request
    traffic_counter.add(1, {"http.route": request.path})
    # Store start time for latency calculation
    request.environ["request_start_time"] = time.time_ns()

@app.after_request
def after_request_func(response):
    # Increment error counter if status code is 4xx or 5xx
    if response.status_code >= 400:
        error_counter.add(1, {"http.route": request.path})
    return response
```

**Latency (Histogram)**

Use a Histogram to record the duration of each request.

```python
# Create instrument
latency_histogram = meter.create_histogram("http.server.request.duration", unit="s")

@app.after_request
def after_request_func(response):
    # Calculate duration from the start time set in before_request
    start_time = request.environ["request_start_time"]
    duration_sec = (time.time_ns() - start_time) / 1_000_000_000
    
    # Record the duration in the histogram
    latency_histogram.record(duration_sec, {"http.route": request.path})
    return response
```

**Saturation (ObservableGauge)**

Use an ObservableGauge with a callback to periodically report the current state of a resource, like CPU utilization.

```python
import psutil

# The callback function that the SDK will invoke periodically
def get_cpu_utilization_callback(options):
    yield metrics.Observation(psutil.cpu_percent() / 100)

# Create the asynchronous instrument and register the callback
cpu_gauge = meter.create_observable_gauge(
    "process.cpu.utilization",
    callbacks=[get_cpu_utilization_callback]
)
```

#### 3. Customizing with Views

Views allow you to modify the metric stream (e.g., change aggregation, drop attributes) before it's exported. They are registered with the MeterProvider.

```python
from opentelemetry.sdk.metrics.view import View, ExplicitBucketHistogramAggregation, DropAggregation

# Example: Define custom latency buckets for all Histograms
custom_histogram_view = View(
    instrument_type=Histogram,
    aggregation=ExplicitBucketHistogramAggregation(
        boundaries=(0.01, 0.05, 0.1, 0.5, 1.0, 5.0)
    )
)

# Example: Drop an entire instrument you don't want to export
drop_cpu_view = View(
    instrument_name="process.cpu.utilization",
    aggregation=DropAggregation()
)

# Register the views when creating the provider
provider = MeterProvider(metric_readers=[reader], views=[custom_histogram_view, drop_cpu_view])
```

---

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

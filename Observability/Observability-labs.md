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
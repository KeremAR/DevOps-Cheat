# Istio Traffic Management 🚦

## Table of Contents
- [Introduction](#introduction)
- [Gateways](#gateways)
- [Routing](#routing)
- [Resiliency & Fault Injection](#resiliency--fault-injection)
- [ServiceEntry](#serviceentry)
- [Security in Istio](#security-in-istio)
- [Quick Reference](#quick-reference)

## Introduction

Istio's traffic management capabilities provide powerful, declarative control over how traffic flows through your service mesh. This guide covers the core resources and techniques for managing traffic at the edge and within your mesh.

## Gateways 🚪

Gateways are the "front door" of your service mesh. They are dedicated Envoy proxies that run at the edge of the mesh to handle all incoming and outgoing traffic.

### Types of Gateways

#### Ingress Gateway
Manages traffic entering the mesh from the outside world. It's the single entry point for all your users. It is typically exposed to the internet via a Kubernetes Service of type LoadBalancer.

#### Egress Gateway
Manages traffic leaving the mesh to an external service. This gives you a central point to control and secure outbound connections.

### The Gateway Resource

You configure the gateway proxies using a Kubernetes Custom Resource (CRD) called `Gateway`. This resource tells the Envoy proxy which ports to open, what protocols to expect, and which hostnames to allow.

A Gateway resource defines:

- **selector**: Which proxy Deployment this configuration applies to (e.g., the default `istio: ingressgateway`)
- **servers.port**: Which network port to open (e.g., 80 for HTTP, 443 for HTTPS)
- **servers.hosts**: A list of hostnames that are allowed through this port. Traffic for any other host will be rejected

### Example Configuration

This YAML configures the default ingress gateway to listen on port 80 for HTTP traffic intended for `dev.example.com` or `test.example.com`.

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: my-gateway
spec:
  # Apply this config to the default ingress gateway deployment
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    # Only allow traffic for these specific hosts
    hosts:
    - "dev.example.com"
    - "test.example.com"
```

> **Important**: The Next Step
> 
> A Gateway only opens the port at the edge. It does not know where to send the traffic inside the mesh.
> 
> To route the traffic from the gateway to an internal service, you must link it to a VirtualService. The Gateway and VirtualService work together to control ingress traffic.

## Routing 👮

Once traffic enters the mesh (via a Gateway or from another service), Istio's core routing resources, VirtualService and DestinationRule, give you precise control over where it goes.

### The Core Routing Duo

#### VirtualService (The "Traffic Cop")
Answers the question: "Where should this request go?" It matches requests and applies routing rules to them.

#### DestinationRule (The "Driver's Manual")
Answers the question: "How do we talk to the destinations?" It defines versions of a service (called subsets) and configures client-side policies like circuit breakers.

**Key Pattern**: You first use a DestinationRule to define your service versions (v1, v2, etc.) based on pod labels. Then, you use a VirtualService to route traffic to those specific versions.

```yaml
# Step 1: DestinationRule defines the 'v1' and 'v2' subsets.
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: customers
spec:
  host: customers
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

### Primary Routing Strategies (VirtualService)

Here are the four main ways a VirtualService can direct traffic.

#### 1. Weight-Based Routing (Traffic Splitting)
**Use Case**: Canary releases or blue/green deployments.

This splits traffic by percentage between different service subsets.

```yaml
# Sends 90% of traffic to v1 and 10% to v2.
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: customers
spec:
  hosts:
  - customers
  http:
  - route:
    - destination:
        host: customers
        subset: v1
      weight: 90
    - destination:
        host: customers
        subset: v2
      weight: 10
```

#### 2. Content-Based Routing (Request Matching)
**Use Case**: Routing specific users (e.g., internal team, beta testers) or device types to a new version.

This routes traffic based on request properties like headers, URI, or method.

```yaml
# Sends requests from Firefox users to v2, all others go to v1.
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: customers
spec:
  hosts:
  - customers
  http:
  - match:
    - headers: # Match condition
        user-agent:
          regex: ".*Firefox.*"
    route: # Action if matched
    - destination:
        host: customers
        subset: v2
  - route: # Default route if no match
    - destination:
        host: customers
        subset: v1
```

#### 3. HTTP Redirects
**Use Case**: Migrating a URI to a new path or a different service entirely.

This returns an HTTP 301 redirect response to the client.

```yaml
# Redirects requests for '/old-path' to '/new-path' on a different service.
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: customers
spec:
  hosts:
  - customers
  http:
  - match:
    - uri:
        exact: /old-path
    redirect:
      uri: /new-path
      authority: new-service.default.svc.cluster.local
```

#### 4. Traffic Mirroring (Shadowing)
**Use Case**: Safely testing a new version with real production traffic without impacting users.

This sends a "fire-and-forget" copy of the live traffic to a mirrored service. The original user's request is still sent to the main destination, and its response is returned.

```yaml
# Sends 100% of live traffic to v1, and also sends a copy to v2.
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: customers
spec:
  hosts:
  - customers
  http:
  - route:
    - destination:
        host: customers
        subset: v1
    mirror: # The mirrored traffic is sent here
      host: customers
      subset: v2
```

### Advanced VirtualService Techniques

You can combine the following techniques for highly granular control.

#### Granular Request Matching

You can match requests based on a variety of properties and methods.

**Matchable Properties**:
- `uri`: The path part of the URL
- `scheme`: The request scheme (http, https)
- `method`: The HTTP method (GET, POST)
- `authority`: The host/domain name
- `headers`: Any request header

**Match Types**:
- `exact`: The value must be an exact string match
- `prefix`: The value must start with the specified string
- `regex`: The value must match the specified ECMAscript-style regular expression

#### URI Rewrites

Unlike a redirect, a rewrite changes the request path before forwarding it to the destination service. The client is unaware of this change.

**Use Case**: Exposing a clean `/v1/api` path to users, while the backend service actually listens on `/v2/api`.

```yaml
# Matches requests to '/v1/api' but rewrites the path to '/v2/api' before sending.
...
http:
- match:
  - uri:
      prefix: /v1/api
  rewrite:
    uri: "/v2/api"
  route:
  - destination:
      host: customers
```

#### Header Manipulation

You can modify headers on the fly for both requests and responses. The actions are `set` (overwrite), `add`, and `remove`.

**Use Case**: Adding a debug header for all requests, and stripping a sensitive API key from responses before they leave the service.

```yaml
...
http:
- headers: # Applies to ALL routes in this block
    request:
      set: # Sets or overwrites the 'debug' header
        debug: "true"
  route:
  - destination:
      host: customers
      subset: v1
    headers: # Applies only to the response from subset v1
      response:
        remove: # Removes the 'x-api-key' header
        - x-api-key
```

#### AND / OR Logic for Matches

**AND Logic**: Conditions listed inside a single match block must ALL be true.

```yaml
# Match if URI is /v1 AND header is 'hello'
- match:
  - uri:
      prefix: /v1
    headers:
      my-header:
        exact: hello
```

**OR Logic**: Multiple separate match blocks are evaluated in order. The first one that matches wins.

```yaml
# Match if URI is /v1 OR if header is 'hello'
- match:
  - uri:
      prefix: /v1
- match:
  - headers:
      my-header:
        exact: hello
```

## Resiliency & Fault Injection

Resiliency isn't about avoiding failures; it's about gracefully responding to them to maintain service availability. Istio provides powerful, declarative tools to build resilient microservice architectures.

### Timeouts and Retries (Configured in VirtualService)

These are client-side policies that a service's Envoy proxy applies when calling another service.

#### Timeouts ⏱️

**Goal**: Prevent a client service from waiting indefinitely for a slow or unresponsive upstream service.

**How it Works**: If the upstream service doesn't respond within the specified duration, the Envoy proxy gives up and returns an HTTP 504 Gateway Timeout error to the calling application.

```yaml
# In a VirtualService's http route rule...
...
route:
- destination:
    host: customers
    subset: v1
  timeout: 5s # Abort the request if it takes longer than 5 seconds.
```

#### Retries 🔁

**Goal**: Automatically handle transient failures by re-attempting a failed request.

**How it Works**: If a request fails with a specific condition (like a 5xx error or connection failure), Envoy will automatically retry it a configured number of times. It's smart enough not to retry on the same failed pod. The endpoint that caused the retry is no longer in the load balancing pool.

```yaml
# In a VirtualService's http route rule...
...
route:
- destination:
    host: customers
    subset: v1
  retries:
    attempts: 3 # Try up to 3 times.
    perTryTimeout: 2s # Each attempt has a 2-second timeout.
    # Retry only on connection failures or 503 errors.
    retryOn: connect-failure,retriable-status-codes
    retriableStatusCodes: [503]
```

### Circuit Breaking (Configured in DestinationRule)

**Goal**: Prevent cascading failures. If a service is overwhelmed or failing, you want to stop sending traffic to it for a while to let it recover.

**How it Works**: Istio implements circuit breaking using Outlier Detection. The client-side Envoy proxy passively monitors the health of each upstream pod. If a pod starts failing consistently (e.g., returning consecutive 5xx errors), Envoy will temporarily "eject" it from the load-balancing pool.

```yaml
# In a DestinationRule...
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: customers
spec:
  host: customers
  trafficPolicy:
    outlierDetection:
      # If a pod returns one 5xx error...
      consecutive5xxErrors: 1
      # ...check for failures every 1 second...
      interval: 1s
      # ...and eject it from the pool for 3 minutes.
      baseEjectionTime: 3m
      # At most, 100% of the pods can be ejected.
      maxEjectionPercent: 100
```

### Fault Injection (Configured in VirtualService)

**Goal**: A Chaos Engineering technique to test your system's resilience by deliberately injecting failures.

**How it Works**: You configure rules in a VirtualService to make the Envoy proxy artificially delay or fail a certain percentage of requests.

#### HTTP Delay ⏳

**Use Case**: Simulate a slow network or an overloaded service to test how downstream services handle latency.

```yaml
# In a VirtualService's http route rule...
...
fault:
  delay:
    # Apply a 3-second delay to 5% of requests.
    percentage:
      value: 5.0
    fixedDelay: 3s
```

#### HTTP Abort 💥

**Use Case**: Simulate a faulty or crashed upstream service to test how downstream services handle failures.

```yaml
# In a VirtualService's http route rule...
...
fault:
  abort:
    # Abort 30% of requests with an HTTP 404 Not Found error.
    percentage:
      value: 30.0
    httpStatus: 404
```

## ServiceEntry 🛂

This note covers how to make services that live outside your mesh visible inside it, allowing you to control traffic to them.

### The "Why?": Managing Traffic to External Services

By default, Istio's service mesh is unaware of traffic leaving the mesh to external endpoints (e.g., third-party APIs, legacy databases on VMs). This means you can't apply Istio's powerful traffic rules to these outbound calls.

The ServiceEntry resource acts like a "passport," officially adding an external service to Istio's internal service registry. Once registered, you can use VirtualServices and DestinationRules to manage calls to this external service just like any other service in your mesh.

**Use Case**: Your application calls an unreliable third-party API. Instead of adding retry logic to your application code, you can create a ServiceEntry for the API and then use a VirtualService to configure Istio to automatically handle retries and timeouts for you.

### Common Use Cases & Examples

There are two primary types of ServiceEntry configurations.

#### 1. External Public API (MESH_EXTERNAL)

Use this for services that are truly outside your organization's network, like public APIs, which are typically resolved via DNS.

**Goal**: Register `api.github.com` so you can apply Istio policies to it.

**Key Fields**:
- `location: MESH_EXTERNAL`: Tells Istio this service is outside the mesh
- `resolution: DNS`: Tells Istio to use DNS to find the service's IP address

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: external-api-github
spec:
  # The domain name of the external service
  hosts:
  - api.github.com
  # This service is outside our mesh
  location: MESH_EXTERNAL
  # Use DNS to find its IP address
  resolution: DNS
  ports:
  - number: 443
    name: https
    protocol: TLS
```

#### 2. Internal, Non-Mesh Service (MESH_INTERNAL)

Use this for services that are part of your infrastructure but not in the Kubernetes mesh, such as a database cluster running on VMs with fixed IP addresses.

**Goal**: Register a MongoDB cluster running on known VMs.

**Key Fields**:
- `location: MESH_INTERNAL`: Tells Istio this service is part of the internal infrastructure, just not in the mesh
- `resolution: STATIC`: Tells Istio that you will provide the IP addresses manually
- `endpoints`: The list of static IP addresses for the service

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: internal-db-mongo
spec:
  hosts:
  - my-internal-mongo.prod.local
  # This service is internal but not in the mesh
  location: MESH_INTERNAL
  ports:
  - number: 27017
    name: mongo
    protocol: MONGO
  # We will provide the IPs directly
  resolution: STATIC
  endpoints:
  - address: "192.168.10.1"
  - address: "192.168.10.2"
  - address: "192.168.10.3"
```

## Security in Istio 🛡️

Istio provides a robust security model for microservices, focusing on Authentication (who are you?) and Authorization (what are you allowed to do?). This is achieved by giving every workload a strong identity and securing the communication channels between them.

### The Foundation: Identity with SPIFFE

Authentication (Authn) is the process of verifying identity. In Istio, the fundamental identity for a workload is its Kubernetes Service Account.

Istio takes this Service Account and creates a stronger, cryptographically verifiable identity using the **SPIFFE standard**.

This SPIFFE ID is encoded into an X.509 certificate, which is automatically provisioned for every workload in the mesh. The ID looks like a URI, for example: `spiffe://cluster.local/ns/default/sa/my-service-account`.

This certificate becomes the workload's passport, which it presents to other services to prove its identity.

### Securing Communication: Mutual TLS (mTLS)

Mutual TLS (mTLS) is the cornerstone of Istio's security. Unlike traditional TLS where only the server proves its identity, with mTLS, both the client and the server exchange certificates and verify each other's identity.

#### How it Works
This entire process is handled transparently by the Envoy sidecar proxies. Your application code continues to send plain HTTP traffic, but the sidecar intercepts it, automatically wraps it in an encrypted mTLS tunnel, sends it to the destination sidecar, which then unwraps it and forwards the plain HTTP traffic to the destination application.

#### Default Behavior
By default, Istio enforces mTLS for all traffic within the mesh.

### Configuring mTLS: PeerAuthentication & DestinationRule

You control the mTLS behavior for inbound and outbound traffic using two different resources.

#### 1. Inbound Traffic: PeerAuthentication

This resource tells a service's sidecar what kind of traffic to accept. It is applied to the server workload.

**Modes**:

- **STRICT** (Most Secure): Only accepts encrypted mTLS traffic
- **PERMISSIVE** (Default): Accepts both mTLS and plain-text traffic. This is useful for gradually migrating services into the mesh
- **DISABLE**: Only accepts plain-text traffic

```yaml
# Enforce STRICT mTLS for all workloads in the 'foo' namespace.
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: foo
spec:
  mtls:
    mode: STRICT
```

#### 2. Outbound Traffic: DestinationRule

This resource tells a service's sidecar how to initiate traffic when it's acting as a client.

**Modes**:

- **ISTIO_MUTUAL** (Default): Use the automatically provisioned SPIFFE certificates to initiate an mTLS connection
- **SIMPLE**: Initiate a standard one-way TLS connection (not mTLS)
- **DISABLE**: Send plain-text traffic

```yaml
# When calling any service ending in '.example.com', initiate a simple TLS connection.
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: tls-for-external-service
spec:
  host: "*.example.com"
  trafficPolicy:
    tls:
      mode: SIMPLE
```

### Security at the Edge: Gateways

The Gateway resource also has a `tls` section to manage security for traffic entering the mesh. You can configure it to terminate TLS from the outside world (SIMPLE mode) or require clients to present a certificate (MUTUAL mode).

### The AuthorizationPolicy Resource

In Istio, you define authorization rules using the `AuthorizationPolicy` Custom Resource. It gives you fine-grained control over which requests are permitted or denied.

An AuthorizationPolicy has three main parts:

#### 1. selector (The Target)
Specifies which workload(s) the policy applies to, based on their labels. If omitted, it applies to all workloads in the namespace.

#### 2. action (The Effect)
- **ALLOW**: Defines a list of rules that, if matched, will permit the request
- **DENY**: Defines a list of rules that, if matched, will reject the request

#### 3. rules (The Conditions)
A list of conditions specifying who can do what. A rule has two main parts:

- **from** (The "Who"): Specifies the allowed source of the request (e.g., a specific service principal, namespace, or IP address)
- **to** (The "What"): Specifies the allowed operation (e.g., an HTTP GET method on the `/api/users` path)

### Example Policy

This policy allows requests from services with the `app: frontend` label to make GET requests to paths starting with `/api/v1` on workloads with the `app: backend` label.

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: backend-access-policy
  namespace: my-app
spec:
  # 1. Target: Apply this policy to the 'backend' service.
  selector:
    matchLabels:
      app: backend
  
  # 2. Effect: This is an ALLOW policy.
  action: ALLOW

  # 3. Conditions: Define the rules for what is allowed.
  rules:
  - from:
    - source:
        # The "Who": Allow requests from 'frontend' services.
        principals: ["cluster.local/ns/my-app/sa/frontend-sa"]
    to:
    - operation:
        # The "What": Allow 'GET' method on '/api/v1/*' paths.
        methods: ["GET"]
        paths: ["/api/v1/*"]
```

### How Policies are Evaluated (Crucial Rules)

Understanding the evaluation order is key to using Istio security effectively.

#### No Policy = ALLOW All
If no AuthorizationPolicy targets a workload, all traffic to it is permitted.

#### DENY Overrides ALLOW
DENY policies are always checked first. If a request matches any DENY policy, it is immediately rejected, even if it also matches an ALLOW policy.

#### ALLOW Policies Enforce Deny-by-Default
If there are one or more ALLOW policies applied to a workload, the request must match at least one of them to be permitted. Any traffic that does not match an ALLOW rule will be denied by default.

#### Best Practice
For a secure-by-default posture, start by creating a "deny-all" policy for a namespace, then add specific ALLOW policies for only the traffic you need.

```yaml
# A "deny-all" policy for the 'my-app' namespace
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: deny-all
  namespace: my-app
spec: {} # An empty spec with the default ALLOW action means it matches nothing,
         # therefore denying all traffic once applied.
```

### Security Configuration Summary

| Resource | Purpose | Key Fields |
|----------|---------|------------|
| **PeerAuthentication** | Inbound mTLS control | `mtls.mode` (STRICT/PERMISSIVE/DISABLE) |
| **DestinationRule** | Outbound TLS control | `trafficPolicy.tls.mode` |
| **AuthorizationPolicy** | Access control | `selector`, `action`, `rules` |
| **Gateway** | Edge TLS termination | `tls` configuration |

### Security Best Practices

1. **Start with STRICT mTLS**: Use STRICT mode for all internal communication
2. **Implement deny-all policies**: Begin with restrictive policies and add specific ALLOW rules
3. **Use service principals**: Leverage SPIFFE identities for fine-grained authorization
4. **Monitor security events**: Use observability tools to track authentication and authorization events
5. **Regular policy review**: Audit and update authorization policies regularly
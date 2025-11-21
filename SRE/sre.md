# GOOGLE SITE RELIABILITY ENGINEERING (SRE)

## What is SRE? (Site Reliability Engineering)
SRE is what happens when you ask a software engineer to design an operations team. Instead of manually fixing problems again and again, SREs write software to fix them automatically.

## Core Philosophy
*   **Automate Yourself Out of a Job:** The goal of SRE is to write automation that makes itself unnecessary.
*   **Software Engineering Approach:** Treat operations as a software problem. Instead of manually fixing issues, write software to fix them.
*   **Balance:** SRE balances the speed of new features (Developers) with the stability of the system (Operations).
*   **Automation:** If a task needs to be done more than once, automate it.

## The Metric Trinity: SLI, SLO, SLA
These three acronyms are the foundation of measuring reliability in SRE.

### 1. SLI (Service Level Indicator)
**What is it?** A direct measurement of a service's behavior. It is the "reality" of what is happening.

**Examples:**
*   **Request Latency:** How long it takes to return a response.
*   **Error Rate:** The fraction of all requests received that resulted in an error.
*   **System Throughput:** Requests per second.

### 2. SLO (Service Level Objective)
**What is it?** The target value or range of values for a service level that is measured by an SLI. It is the "goal".

**Logic:** If SLI ≤ SLO, the system is healthy. If SLI > SLO, the system needs attention.

**Rule:** SLOs are for internal team goals and usually define the user experience.

### 3. SLA (Service Level Agreement)
**What is it?** An explicit contract with users that includes consequences (financial or otherwise) if the SLOs are missed.

**Difference:** SRE teams care about SLOs. Lawyers and Business teams care about SLAs. SLAs are typically looser than SLOs to provide a safety buffer.

## Concept: Error Budget (Hata Bütçesi)
This concept comes from a simple idea: 100% reliability is the wrong target.

### How it Works
**Calculation:** 100% - SLO = Error Budget.

**Example:** If your Availability SLO is 99.9%, your Error Budget is 0.1%. You are allowed to be down for 0.1% of the time.

### Managing the Budget
*   **Spend it on Innovation:** Use this budget to launch new features, perform risky updates, or run experiments.
*   **Budget Exhausted:** If the budget runs out (too many outages), all new feature launches are frozen. The team must focus 100% on reliability and testing until the budget resets.

## Concept: Toil (Angarya)
Toil is the work that is manual, repetitive, and does not help the service grow.

### Characteristics of Toil
*   **Manual & Repetitive:** Running a script by hand every day.
*   **Automatable:** A machine could do it.
*   **No Enduring Value:** The service state is the same after you finish the task as it was before.
*   **Linear Scaling:** If the service grows, the amount of toil grows with it (bad!).

### The 50% Rule
*   **Limit:** SREs should spend a maximum of 50% of their time on "Ops/Toil" work.
*   **Project Work:** The remaining 50% must be spent on engineering projects (coding, automation) to reduce future toil.

## Monitoring & Alerting
You cannot fix what you cannot see. Monitoring tells you if your service is working.

### The Four Golden Signals
These are the four most critical metrics to monitor for any user-facing system:
1.  **Latency:** Time it takes to service a request (differentiate between success vs. failure latency).
2.  **Traffic:** How much demand is being placed on the system (e.g., HTTP requests per second).
3.  **Errors:** The rate of requests that fail (HTTP 500s, wrong content).
4.  **Saturation:** How "full" the service is (CPU usage, memory limits).

### Alerting Philosophy
*   **Pages (Pager):** For urgent problems where a human must take action immediately (e.g., "The site is down").
*   **Tickets:** For problems that need action but can wait a few days (e.g., "Disk is 80% full").
*   **Logs:** For information that is useful for debugging but requires no active response.

## Incident Management & Postmortems

### Blameless Postmortem
**What is it?** A document written after an incident to understand what went wrong, not who caused it.

**Philosophy:** We do not point fingers at people. We assume everyone tried their best. If a person made a mistake, the system allowed that mistake.

**Goal:** To ensure the same incident never happens twice.

### Incident Command System
*   **Commander:** Holds the high-level state and directs the team.
*   **Ops Lead:** Applies operational tools to fix the system.
*   **Comms Lead:** Communicates with the rest of the company/public.

### MTTR and Test
**MTTR and Test:** Good tests can reduce "Mean Time To Repair" to zero by preventing errors from reaching production.

## Automation & Release Engineering

### Canary Releases
**What is it?** A technique where a new version of software is deployed to a small subset of users/servers first.

**Benefit:** If the new version crashes, only a small percentage of traffic is affected. It allows for "burning in" the binary.

### Hermetic Builds
**What is it?** A build process that is insensitive to the libraries installed on the build machine. It depends only on known, versioned tools.

**Benefit:** Consistency. A build running on Machine A produces the exact same binary as Machine B.

### Infrastructure as Code
**Principle:** Treat configuration (DNS, Load Balancer rules) as code. Store it in version control, review it, and deploy it via automation.

## Load Balancing & Traffic Management

### Cascading Failures
**What is it?** A failure that grows over time due to positive feedback. One server fails -> load increases on remaining servers -> remaining servers fail -> total outage.

**Mitigation:**
*   **Load Shedding:** Rejecting some traffic to save the rest of the system.
*   **Exponential Backoff:** Clients waiting longer periods between retries to avoid hammering a struggling server.

### Load Balancing Levels
*   **DNS Load Balancing:** Simple, but client behavior is hard to control due to caching.
*   **Virtual IP (VIP):** Uses a network load balancer to forward packets to backends.
*   **Backend Subsetting:** Limiting the number of backend tasks a client connects to, to avoid resource exhaustion (maintaining too many TCP connections).

# THE SITE RELIABILITY WORKBOOK: LECTURE NOTES

## SRE vs. DevOps
SRE and DevOps are not competitors, they are complementary.

### Relationship
*   **DevOps:** A culture, a philosophy ("Break down walls between Development and Operations").
*   **SRE:** A concrete implementation of this philosophy.
*   **Formula:** `class SRE implements DevOps`.

### Commonalities
Both reject organizational silos, accept failure as normal, advocate for gradual change, and leverage automation.

## Implementing SLOs
The first book covered "What is an SLO", this book covers "How to write an SLO".

### Step-by-Step SLO Creation Recipe
1.  **Draw System Boundaries:** Determine what constitutes your system and how users interact with it (API, Web Interface, Data Pipeline, etc.).
2.  **Define User Journey:** Identify critical paths users take when using the system (e.g., "Add to Cart", "Checkout", "Search").
3.  **Select SLI:** Choose the metric that best reflects user experience.
    *   **Request/Response systems:** Availability, Latency.
    *   **Data Pipelines:** Freshness (How up-to-date is the data?), Correctness (Is the data correct?).
4.  **Set Target (SLO):** Set a realistic target based on past performance (e.g., "We achieved 99.5% in the last month, let's aim for 99.0%"). Perfectionism is the enemy.

### Example SLO Document
*   **User Journey:** A user updates their profile picture.
*   **SLI:** Success rate of profile picture upload requests.
*   **SLO:** 99.9% of requests must be successful over a 28-day period.
*   **Consequence:** If the error budget is exhausted, new feature releases related to image upload are halted.

## Error Budget Policy
Calculating a number is not enough; a "written constitution" (Policy) is needed for what to do when that number is exceeded.

### Policy Content
A Error Budget Policy should include:
*   **Escalation:** Who is notified when the budget is close to exhaustion (80%)?
*   **Freeze:** Which feature releases are halted when the budget is exhausted (100%)?
*   **Exceptions:** In which emergencies (e.g., security patch) can a release be made even without budget?

### Silver Bullet
If Developers refuse to stop or the Product Manager (PM) says "let's take a risk" when the budget is gone, SRE culture won't work. This policy must be signed by upper management (CTO/VP).

## Monitoring & Alerting
This book highlights the concept of "Alerting on SLOs".

### Traditional vs. SLO-Based Alerting
*   **Traditional (Bad):** "CPU is at 90%, wake me up." -> User might not be affected, unnecessary wakeup (Pager Fatigue).
*   **SLO-Based (Good):** "Error budget is burning fast, wake me up." -> This definitely means the user is affected.

### Burn Rate Concept
Shows how fast the error budget is being consumed.
*   **Burn Rate 1:** Budget is spent at a rate to last exactly 30 days (Normal).
*   **Burn Rate 14.4:** Budget will be gone in 2 days! (Urgent Action/Page Required).

**Strategy:** Only Page if Burn Rate is high and there is a risk of budget exhaustion. If it's burning slowly, open a Ticket to be looked at in the morning.

## On-Call Management
How to sustain on-call without burning people out?

### Measuring Operational Load
Measure not just "how many incidents occurred", but "how much time these incidents took".

### Rules
*   **Team Size:** At least 6 SREs are required for a team doing 24/7 on-call (8 is recommended for sustainability). Fewer people leads to burnout.
*   **On-Call Pair:** Number of on-call people per team is usually 2 (Primary and Secondary).

### Compensation
Every call received outside of working hours (night, weekend) should be deducted from work hours or compensated with extra leave/pay.

## Postmortem Culture
Analyzing incidents is not enough, it must become a "culture".

### Characteristics of a Good Postmortem
*   **Clear Trigger:** When did the incident start, when did it end?
*   **Impact:** How many users were affected? Is there revenue loss?
*   **Root Cause:** "Server crashed" is not a root cause. "Validation was missing in configuration file" is a root cause.
*   **Action Items:** "We will be more careful" is not an action. "Add this test to configuration file (Jira-123)" is an action.

### Postmortem Sharing
Postmortems are not "documents of shame", but "learning opportunities". They should be published openly within the company to prevent other teams from making similar mistakes.

## SRE Engagement Models
How does the SRE team work with other teams? You can't give SRE to everyone.

### 1. Kitchen Sink (Everything)
SRE team does everything that comes their way.
*   **Risk:** SREs turn into "SysAdmins running for everything". Not scalable.

### 2. Infrastructure
SREs manage common platforms like Kubernetes, Logging, Monitoring.
*   **Advantage:** Impacts the whole company. The most common and efficient model.

### 3. Product/Application
SREs are dedicated to a critical product (e.g., Payment System).
*   **Condition:** Product must be very critical and receive high traffic.

### 4. Embedded
SRE sits within the developer team, writes code with them.
*   **Goal:** To spread the culture or complete a specific project (e.g., Migration to Cloud). Usually temporary.

## Configuration Management
Configuration is as dangerous as code.

### Principles
*   **Version Control:** Configuration files must be kept in Git.
*   **Review:** Like code, configuration changes must go through Code Review.
*   **Automation:** Changes should not be manually copied to servers, but applied via CI/CD pipeline.
*   **Simplification:** As configuration languages (YAML, JSON) get complex, error risk increases. Use validation tools if possible.

## Summary: The Core Message of the Workbook
Theory is nice, but practice is hard.

*   **Don't Wait for Perfect:** A bad SLO is better than no SLO. Start and improve over time.
*   **Push the Culture:** SRE is not just using tools (Prometheus, Terraform); it is managing the software lifecycle with policies like Error Budget.
*   **Human Factor:** If you can't manage On-Call load, you will lose your best engineers.

## What is Agile?

Agile is an iterative approach to project management that focuses on delivering value to customers quickly and adapting to changes. Unlike traditional methods where long-term planning is done upfront, Agile emphasizes planning small increments, receiving customer feedback, and adjusting as needed.

## Characteristics of Agile

Agile emphasizes several key characteristics:

-   **Adaptive Planning:** Planning occurs in small iterations rather than for the entire project duration upfront.
-   **Evolutionary Development:** The product is built incrementally and evolves based on feedback.
-   **Early Delivery:** Delivering functional software to the customer early and frequently is crucial for gathering feedback.
-   **Continuous Improvement:** Feedback loops enable continuous improvement of both the product and the team's process.
-   **Responsiveness to Change:** Agile embraces changing requirements and allows teams to adapt quickly without being rigidly bound to initial plans.

## Traditional Waterfall Development

Waterfall is a **sequential, phase-based approach** to software development.

-   **Phases:** Requirements -> Design -> Coding -> Integration -> Testing -> Deployment.
-   Each phase must be completed before the next begins (strict entrance/exit criteria).
-   Difficult and costly to go back to earlier phases ("swimming upstream").

### Problems with Waterfall

-   **No provision for change:** Rigid structure makes adapting to changing requirements difficult.
-   **Late feedback:** You don't know if the software truly works until the very end.
-   **Siloed work:** Teams work in isolation, potentially leading to integration issues and lost information.
-   **Costly late-stage mistakes:** Errors found later (e.g., in testing) are expensive to fix.
-   **Long lead times:** Delays delivery of value to the customer.

## Extreme Programming (XP)

![ROADMAP](/Media/xp.svg)
Introduced by Kent Beck, XP is an **iterative and incremental** approach, considered one of the first Agile methods. It focuses on improving software quality and responsiveness.

-   Emphasizes **tight feedback loops** (releases, iterations, daily stand-ups, pair programming).

### XP Values

-   **Simplicity:** Do what's needed and no more; avoid over-engineering.
-   **Communication:** Foster high levels of interaction within the team.
-   **Feedback:** Use frequent feedback loops to guide development.
-   **Respect:** Value all team members' contributions equally.
-   **Courage:** Be honest about estimates and commitments.

## Kanban

Originating from Japanese manufacturing (meaning "billboard" or "sign"), Kanban focuses on **continuous flow** and visualizing work.

### Kanban Core Principles

-   **Visualize the workflow:** Make work visible to manage it effectively (e.g., Kanban boards).
-   **Limit Work In Progress (WIP):** Avoid bottlenecks and multitasking by limiting simultaneous tasks.
-   **Manage and enhance flow:** Continuously seek ways to improve the workflow speed and efficiency.
-   **Make policies explicit:** Ensure everyone understands processes and definitions (e.g., Definition of Done).
-   **Continuously improve:** Use feedback loops to refine the process.

## Agile Working Practices

These practices help teams implement the Agile philosophy effectively:

### 1. Working in Small Batches

-   **Concept:** Process work in small, manageable increments instead of large chunks (like single-piece flow vs. batch processing).
-   **Benefit:** Allows for faster feedback, quicker detection of errors, and reduced waste if changes are needed.

### 2. Minimum Viable Product (MVP)

-   **Definition:** The *smallest* thing you can build to *test a hypothesis* and gain validated learning about customers.
-   **Purpose:** It's primarily about **learning**, not just delivering a partial product or phase one.
-   **Outcome:** Helps decide whether to **pivot** (change direction) or **persevere** (continue) based on feedback.
-   **Example Contrast:**
    -   *Good MVP (Learning Focused):* Skateboard -> Scooter -> Bicycle -> Motorcycle -> Convertible (adapting to learned desire).
    -   *Bad MVP (Delivery Focused):* Wheel -> Chassis -> Car body -> Final Car (just incremental delivery).

### 3. Behavior Driven Development (BDD)

-   **Approach:** Describes and tests system behavior from the **outside-in** (user's perspective).
-   **Focus:** Ensures you are building the *right thing*.
-   **Level:** Typically used for integration or acceptance testing, often interacting with the UI.
-   **Syntax:** Uses **Gherkin** (Given-When-Then) language for scenarios, readable by both technical and non-technical stakeholders.
    -   `Feature: As a [role], I want [feature], so that [benefit]`
    -   `Scenario: Given [context], When [action], Then [outcome]`

### 4. Test Driven Development (TDD)

-   **Approach:** Designs and tests code from the **inside-out** (module/unit level).
-   **Focus:** Ensures you are building the *thing right*.
-   **Workflow (Red-Green-Refactor):**
    1.  **Red:** Write a small, failing test case for the desired functionality.
    2.  **Green:** Write the *simplest* code possible to make the test pass.
    3.  **Refactor:** Improve the code design while ensuring all tests still pass.

### 5. Pair Programming

-   **Concept:** Two developers work together at one workstation.
    -   One **driver** writes code.
    -   One **navigator** observes, reviews, suggests, and thinks strategically.
    -   Roles switch frequently.
-   **Benefits:**
    -   **Higher Code Quality:** Fewer defects due to real-time review.
    -   **Knowledge Sharing:** Spreads understanding of the codebase.
    -   **Mentorship:** Effective way for junior/senior or new/experienced developers to learn from each other.
    -   **Reduced Long-Term Cost:** Cheaper to find bugs during development than in production.

## Scrum

Scrum is a specific, **prescriptive methodology** for implementing the **Agile philosophy**.

### Agile vs. Scrum

-   **Agile:** A philosophy, a set of principles (not prescriptive).
-   **Scrum:** A framework/methodology for working in an Agile fashion (prescriptive).

### Key Characteristics of Scrum

-   A management framework for **incremental product development**.
-   Emphasizes **small, cross-functional, self-managing teams**.
-   Provides structure: **roles, rules, artifacts, meetings**.
-   Uses fixed-length iterations called **Sprints**.
-   Goal: Produce a **potentially shippable increment** each Sprint.
-   Often described as "easy to understand, difficult to master."

### The Sprint

-   One iteration through the **design, code, test, deploy** cycle.
-   Has a clear **Sprint Goal**.
-   Typically **two weeks** long (recommended over 1 or 4 weeks).

### Steps in the Scrum Process

1.  **Product Backlog:** A prioritized list of *everything* desired for the product (features, fixes, etc.).
2.  **Backlog Refinement (Grooming):** Reviewing and preparing Product Backlog items to make them "sprint ready."
3.  **Sprint Planning:** Team selects items from the Product Backlog to work on in the upcoming Sprint, creating the **Sprint Backlog**.
4.  **Sprint Execution (e.g., 2 weeks):**
    -   **Daily Scrum (Stand-up):** Daily 15-min meeting. Each member answers:
        -   What did I do yesterday?
        -   What will I do today?
        -   Are there any impediments?
5.  **Potentially Shippable Increment:** The completed work from the Sprint, ready for deployment/feedback.
6.  **(Sprint Review):**  Demo increment to stakeholders & Sprint Retrospective (team process improvement).

**Note:** Scrum is highly iterative; the cycle (Plan -> Develop -> Deploy -> Feedback) repeats for each Sprint.

## Scrum vs. Kanban Comparison

| Feature             | Scrum                                                                 | Kanban                                         |
| :------------------ | :-------------------------------------------------------------------- | :--------------------------------------------- |
| **Cadence**           | Fixed length sprints                                                  | Continuous flow                                |
| **Release Method**  | End of each sprint                                                    | Continuous delivery                            |
| **Roles**             | Product Owner, Scrum Master, Development Team                         | No predefined roles (optional Agile Coach)     |
| **Key Metrics**       | Velocity                                                              | Cycle time                                     |
| **Change Philosophy** | Strive not to change sprint forecast *during* the sprint              | Change can happen at any time                  |


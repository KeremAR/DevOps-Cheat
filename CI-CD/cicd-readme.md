# Continuous Integration and Deployment Learning Notes
- ![CICD](/Media/ci-cd.png)

## What is Continuous Integration?

Continuous Integration (CI) is  the practice of regularly merging all developer working copies to a shared mainline.

### Basic Principles of CI
- Maintain a managed repository of code
- Integrate changes as frequently as possible
- Build every commit
- Implement self-tested builds to identify errors early
- Store and maintain a history of builds (archive)
- Use multiple environments sorted by code stability

How often do you need to run a Continuous Integration pipeline?
- Every commit

### CI/CD Pipeline
A CI/CD pipeline is a series of steps from code commit to deployment, automating build, test, and release processes.

## Advantages of CI/CD Pipeline

The CI/CD pipeline provides quick feedback after each change.

## Deployment Pipeline

An automated manifestation of your process for getting software from version control into the hands of software users.


### Continuous Delivery (CD)
Continuous Delivery ensures that code is always in a deployable state and can be released to production at any time with minimal manual intervention.

## Continuous Deployment

Continuous deployment (CD) is a software release process that uses automated testing to validate if changes to a codebase are correct and stable for immediate autonomous deployment to a production environment.


## Jenkins

### Jenkins Extensibility
Jenkins extensibility is implemented via Jenkins plugins.

### Jenkins Backup
How to create a full backup in Jenkins?
- Copy Jenkins home directory and create database backup

- ![Regression Testing](/Media/media1.svg)

## Testing in CI/CD

### Smoke Testing
Smoke testing is a basic level of software testing that checks whether the most crucial functions of an application work properly. It helps identify major issues before deeper testing.

### Unit Testing
**Unit testing** is a software testing procedure that examines individual software units. A unit refers to a section of an application—a function, method, procedure, or entire module.

### Regression Testing
The goal of testing is to ensure that code changes haven't introduced bugs to the software.

### Performance Testing
Performance tests determine:
- Whether the application responds quickly
- The maximum user load the software application can handle
- If the application is stable under varying loads

### Vulnerability Testing
Vulnerability testing is used to reduce the chances of intruders or hackers gaining unauthorized access to systems.

### End-to-End Testing
The purpose is to test the entire software product for dependencies, data integrity, and connectivity with other systems, interfaces, and databases.

### User Interface (UI) Testing
The goal of UI testing is to ensure all UI elements meet performance and functionality requirements and are free from defects.

## Code Quality Analysis

### SonarQube
SonarQube is a web-based open-source platform used to measure and analyze the quality of source code.

### SonarQube Benefits
SonarQube boosts productivity by:
- Detecting and eliminating code duplications and redundancy
- Making code easier to read and understand
- Reducing maintenance time
- Optimizing application size


## Artifact Management

### Retention Function
 In CI/CD, artifact retention ensures that outdated or irrelevant artifacts (like build or deployment packages) are automatically deleted based on defined criteria. This helps manage storage and maintain a clean environment.

### Repository Types
 The concept of mutable repositories (like snapshot repositories) refers to a storage type where artifacts can be modified, typically before they are finalized and released. In CI/CD pipelines, this applies to situations where code is being built, tested, and iterated on before being marked as a stable release.

# Behavior-Driven Development (BDD)

## Overview

Behavior-Driven Development (BDD) is a software development methodology that focuses on defining system behavior from an external perspective. Unlike Test-Driven Development (TDD), which emphasizes individual component correctness, BDD ensures that all components work together to meet business goals.

## Key Differences Between BDD and TDD

| Feature  | BDD                                            | TDD                                           |
| -------- | ---------------------------------------------- | --------------------------------------------- |
| Approach | Outside-in (system behavior)                   | Inside-out (component correctness)            |
| Goal     | Ensuring the system does the right thing       | Ensuring individual components work correctly |
| Audience | Developers, testers, domain experts, customers | Developers                                    |
| Language | Gherkin (natural language)                     | Unit test assertions                          |




## Deployment Strategies

### Blue/Green Deployment
A blue/green deployment is a deployment strategy in which you create two separate, but identical environments. One environment (blue) is running the current application version and one environment (green) is running the new application version.

### Canary Deployment
The practice of making staged releases is known in software engineering as **canary deployment.** You start by releasing a software update to a small group of users to test it and receive feedback. The update is rolled out to the rest of the users once the change is accepted.

### Rolling Deployment
A rolling deployment is a strategy that gradually replaces older versions of an application with newer versions by completely replacing the infrastructure on which it runs.

### Shadow Deployment
A shadow deployment is a technique that involves releasing a new version of an application (version B) alongside the existing version (version A), but without impacting production traffic. Instead, incoming requests to version A are forked and sent to version B for testing and evaluation. This allows developers to monitor the performance and stability of the new version without affecting the user experience.

### A/B Deployment
A/B deployment strategy is a technique used to test and compare two different versions of a software or feature. It involves dividing users into two groups: Group A, which receives the existing version (control group), and Group B, which receives the new version (experimental group).

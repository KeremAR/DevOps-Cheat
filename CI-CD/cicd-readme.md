# Continuous Integration and Deployment Learning Notes

## What is Continuous Integration?

Continuous Integration (CI) is a development practice in which developers often integrate code into a shared repository.

## Advantages of CI/CD Pipeline

The CI/CD pipeline provides quick feedback after each change.

## Deployment Pipeline

An automated manifestation of your process for getting software from version control into the hands of software users.

## Continuous Integration Best Practices

How often do you need to run a Continuous Integration pipeline?
- Every commit

## Jenkins

### Jenkins Extensibility
Jenkins extensibility is implemented via Jenkins plugins.

### Jenkins Backup
How to create a full backup in Jenkins?
- Copy Jenkins home directory and create database backup

## Testing in CI/CD

### Unit Testing
**Unit testing** is a software testing procedure that examines individual software units. A unit refers to a section of an application—a function, method, procedure, or entire module.

### Regression Testing
The goal of testing is to ensure that code changes haven't introduced bugs to the software.

![Regression Testing](media/media1.svg)

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

The following sections of code quality does Sonar cover:
- Duplicated code and coding standards

## Artifact Management

### Retention Function
Retention function carries out deleting irrelevant artifacts according to certain criteria.

### Repository Types
✅ **Mutable** *(Snapshot repositories allow modifications before final release.)* **applies to the snapshot repository**

## Continuous Deployment

Continuous deployment (CD) is a software release process that uses automated testing to validate if changes to a codebase are correct and stable for immediate autonomous deployment to a production environment.

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

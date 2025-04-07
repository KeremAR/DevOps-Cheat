# Continuous Integration and Deployment Learning Notes
- ![CICD](/Media/ci-cd.png)

## What is Continuous Integration?**
Continuous Integration (CI) is the practice of regularly merging all developer working copies to a shared mainline. It involves continuously building, testing, and integrating every developer change into the master branch after tests have passed. This results in potentially deployable code.

### Basic Principles of CI
- Maintain a managed repository of code
- Integrate changes as frequently as possible (ideally daily)
- Build every commit
- Implement self-tested builds to identify errors early
- Store and maintain a history of builds (archive)
- Use multiple environments sorted by code stability
- Ensure that the master branch is always deployable
- Use automated tools to monitor the version control system and trigger builds
- Perform automated tests on every pull request before merging
- Encourage code reviews via pull requests to improve code quality
- Assume that untested code does not work and should not be merged into the master branch
- Reduce merge conflicts by working in short-lived feature branches
- Delete branches after merging to keep the repository clean

### How often do you need to run a Continuous Integration pipeline?
- Every commit
- At least once per feature build

## CI/CD Pipeline
A CI/CD pipeline is a series of steps from code commit to deployment, automating build, test, and release processes.

### Advantages of CI/CD Pipeline
- Provides quick feedback after each change
- Reduces the risk of integration issues by working in small batches
- Ensures that code is reviewed by multiple developers through pull requests
- Improves overall code quality and stability
- Reduces deployment risks by automating the testing process
- Speeds up development cycles by allowing developers to focus on building features instead of manually testing

## Deployment Pipeline
An automated manifestation of your process for getting software from version control into the hands of software users. Each change is verified through automated testing before deployment.

## Continuous Delivery (CD)
- Ensures that code is always in a deployable state and can be released to production at any time with minimal manual intervention.
- Code is deployed to a "production-like" environment before reaching production.
- Enables safe and rapid deployments.
- If production runs on Kubernetes, a development environment should also be set up in Kubernetes.

## Continuous Deployment
Continuous deployment (CD) is a software release process that uses automated testing to validate if changes to a codebase are correct and stable for immediate autonomous deployment to a production environment.

### Continuous Deployment vs. Continuous Delivery
- Continuous Deployment is one step beyond Continuous Delivery and means that deployment to the production environment is fully automated.
- In Continuous Delivery, the code is production-ready, but deployment can be done with a manual approval step. In Continuous Deployment, the code is always automatically deployed to production.

## Jenkins

### Jenkins Extensibility
Jenkins extensibility is implemented via Jenkins plugins.

### Jenkins Backup
How to create a full backup in Jenkins?
- Copy Jenkins home directory and create database backup





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

## GitHub Actions: CI/CD Automation

GitHub Actions allows you to automate your software development workflows directly within your GitHub repository. It's commonly used for Continuous Integration (CI) and Continuous Delivery (CD).

### How GitHub Actions Works

1.  **Setup**: Create a `.github/workflows/` directory in the root of your repository.
2.  **Workflow Files**: Place one or more workflow definition files (YAML format, e.g., `main.yml`) inside this directory.
3.  **Trigger**: Workflows are triggered by specific **events** occurring in your repository (e.g., a push to a branch, a pull request creation, a new release).
4.  **Execution**: When triggered, the workflow runs one or more **jobs**.
5.  **Jobs**: Jobs consist of **steps** that execute on a specified **runner** (a virtual machine hosted by GitHub or self-hosted).

### Key Workflow Components

*   **`on` (Event)**: Defines the trigger for the workflow. Common events include `push`, `pull_request`, `release`. You can specify branches, types (e.g., `opened`, `published`), etc.
*   **`jobs`**: Contains one or more jobs to be executed. By default, jobs run in parallel.
    *   **Job Name** (e.g., `build`, `test`): A user-defined name for the job.
    *   **`runs-on`**: Specifies the type of runner machine to use (e.g., `ubuntu-latest`, `windows-latest`, `macos-latest`).
    *   **`needs`**: Defines dependencies between jobs. A job with `needs: other_job` will only start after `other_job` completes successfully, forcing serial execution.
    *   **`steps`**: A sequence of tasks to be executed within a job. Steps run on the same runner and can share data.
        *   **`name`**: An optional name for the step.
        *   **`uses`**: Specifies a reusable **action** to run (pre-built scripts/tasks from the marketplace or community, e.g., `actions/checkout@v3` to check out code).
        *   **`run`**: Executes shell commands directly on the runner.

### Example Workflow: Basic CI on Push

This example workflow triggers whenever code is pushed to the `main` branch. It runs a single job called `build` on an Ubuntu runner, checks out the code, and then simulates running build and test commands.

```yaml
# .github/workflows/ci_pipeline.yml

name: CI workflow  # Name of the workflow that appears in GitHub Actions tab

on:  # Events that trigger the workflow
  push:
    branches: [ "main" ]  # Triggered when code is pushed to main branch
  pull_request:
    branches: [ "main" ]  # Triggered when a PR is created against main branch

jobs:
  build:  # Job name
    runs-on: ubuntu-latest  # The type of runner that the job will run on
    container: python:3.9-slim  # Uses Docker container with Python 3.9 installed
    steps:  # List of steps to be executed
      - name: Checkout  # Get the code
        uses: actions/checkout@v3  # Official GitHub checkout action

      - name: Install dependencies  # Install required packages
        run: |  # Use pipe (|) to run multiple commands
          python -m pip install --upgrade pip  # Upgrade pip to latest version
          pip install -r requirements.txt  # Install dependencies from requirements.txt

      - name: Lint with flake8  # Check code quality
        run: |
          # Check for critical errors (syntax errors, undefined names)
          flake8 service --count --select=E9,F63,F7,F82 --show-source --statistics
          # General code quality check (complexity, line length)
          flake8 service --count --max-complexity=10 --max-line-length=127 --statistics

      - name: Run unit tests with nose  # Execute unit tests
        run: nosetests -v --with-spec --spec-color --with-coverage --cover-package=app
     

```

**To use this example:**
1. Create the `.github/workflows/` directory in your project.
2. Save the YAML content above as a file named `ci_pipeline.yml` (or any other `.yml` name) inside that directory.
3. Commit and push the changes to your `main` branch on GitHub.
4. Go to the "Actions" tab in your GitHub repository to see the workflow run.

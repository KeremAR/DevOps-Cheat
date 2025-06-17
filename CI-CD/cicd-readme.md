# Continuous Integration and Deployment Learning Notes
![CICD](/Media/ci-cd.png)


## What is CI/CD?
The CI/CD method helps solve any problems that the integration of new code may bring to development and operations teams. It offers continuous automation and monitoring throughout the lifecycle of an application—from integration and testing to delivery and deployment.



## What is Continuous Integration?**
The fundamental purpose of Continuous Integration (CI) is to provide rapid feedback on code changes. It's a development practice where developers frequently merge their code changes into a central repository, after which an automated build and test sequence is triggered. The goal is to detect integration issues as early as possible, reduce risks, and ensure the main codebase remains healthy and deployable. The focus is on frequent integration and feedback, not just build automation.

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

### Core Steps of a CI Pipeline
When building a CI pipeline from scratch, you would typically include the following fundamental steps:

1.  **Commit & Trigger:** Developers commit code to a shared version control repository (like Git). This action automatically triggers the pipeline.
2.  **Checkout Code:** The pipeline's first job is to check out the latest version of the code from the repository.
3.  **Build:** The source code is compiled or built into an executable or package. This step verifies that the code doesn't have syntax or compilation errors.
4.  **Unit & Integration Testing:** A suite of automated tests (unit tests, integration tests) runs against the built code. This is a critical step to ensure new changes haven't broken existing functionality.
5.  **Code Analysis:** Static code analysis tools (linters, security scanners) are run to check for code quality, style violations, and potential vulnerabilities. This is a highly recommended, though sometimes optional, step.
6.  **Package & Create Artifact:** If all previous steps pass, the built code is packaged into a deployable artifact (e.g., a Docker image, a JAR file) and stored in an artifact repository.
7.  **Feedback:** The pipeline reports the result (success or failure) back to the development team. If it fails, developers are notified to fix the issue immediately.

### Advantages of CI/CD Pipeline
- Provides quick feedback after each change
- Reduces the risk of integration issues by working in small batches
- Enables fault isolation by making it easier to identify which code change caused a failure
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

### Jenkins Plugin Management
Jenkins plugins can be managed through the web interface or using the Jenkins CLI. Here are the common plugin management commands using jenkins-cli.jar:

```bash
# List all installed plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ list-plugins

# Enable plugin(s)
java -jar jenkins-cli.jar -s http://localhost:8080/ enable-plugin PLUGIN_NAME [PLUGIN_NAME2 ...] [-restart]

# Disable plugin(s)
java -jar jenkins-cli.jar -s http://localhost:8080/ disable-plugin PLUGIN_NAME [PLUGIN_NAME2 ...] [-restart]

# Install plugin(s)
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin PLUGIN_NAME [PLUGIN_NAME2 ...] [-restart]
```

**Notes:**
- Replace `http://localhost:8080/` with your Jenkins server URL if different
- The `-restart` flag is optional and will restart Jenkins after the operation
- You can specify multiple plugin names in a single command
- These commands require the jenkins-cli.jar file and Java to be installed

### Manual Plugin Removal
Jenkins CLI does not support direct plugin removal. To manually remove a plugin:

1. Navigate to the plugins directory on your Jenkins server:
```bash
$JENKINS_HOME/plugins/
```

2. Delete the following files for the plugin you want to remove:
   - The plugin's `.jpi` or `.hpi` file
   - The `.jpi.pinned` file (if it exists)

3. Restart Jenkins

**Note:** Make sure to backup your Jenkins configuration before manually removing plugins.

### Jenkins Backup
How to create a full backup in Jenkins?
- Copy Jenkins home directory and create database backup

### Jenkins Master-Slave Architecture
Jenkins supports distributed builds through a master-slave (controller-agent) architecture, which allows you to distribute workload across multiple machines.(Running builds on different OS/environments)
- **Master (Controller)**: Central server that manages build configuration, distributes builds to agents and handles UI
- **Slave (Agent)**: Worker machines that execute build jobs
- **Benefits**: Scalability, load balancing, environment isolation

### Jenkins Pipeline
Jenkins Pipeline is a set of plugins that supports implementing and integrating Continuous Delivery pipelines into Jenkins.

Key Points:
- Pipeline is defined in a `Jenkinsfile` (Pipeline as Code)
- Two syntax types: Declarative (newer, easier) and Scripted (traditional, Groovy-based)
- Blue Ocean provides visual pipeline editor and monitoring

## Build Automation Tools
Build automation tools automate the process of compiling source code, running tests, and packaging applications.

### Popular Build Tools
- **Maven**: Java-based, uses POM (Project Object Model)
  - Key features: Dependency management, standardized builds, multiple project support
  - Common phases: validate, compile, test, package, install, deploy

- **Gradle**: Modern build tool using Groovy DSL
  - Features: Flexible build configuration, multi-project builds
  - Uses build.gradle file for configuration
  - Task-based build system

### Benefits
- Reduces manual errors
- Ensures consistent builds
- Saves development time
- Integrates with CI/CD pipelines

## Automated Testing in CI
Automated testing is the backbone of a reliable CI/CD process. It ensures that new changes are safe and meet quality standards before they reach users. Different types of tests are used to validate the application at different levels.

### Common Types of Automated Tests

*   **Unit Tests**:
    *   **Scope**: These tests focus on the smallest piece of testable software, like a single function, method, or class, in isolation from the rest of the application.
    *   **Purpose**: To verify that each component works as designed. They are fast to run and form the base of the testing pyramid.
    *   **Example**: Testing a function that calculates a sum to ensure it returns the correct value for a given input.

*   **Integration Tests**:
    *   **Scope**: These tests verify the interaction between two or more integrated components or services.
    *   **Purpose**: To catch errors in the interfaces and interactions between different parts of the system (e.g., how your application communicates with a database or an external API).
    *   **Example**: Testing if a user registration function correctly saves user data to the database.

*   **End-to-End (E2E) Tests**:
    *   **Scope**: These tests simulate a real user's workflow from start to finish. They validate the entire application stack, including the user interface, backend services, and databases.
    *   **Purpose**: To ensure the complete application flow works as expected from the user's perspective.
    *   **Example**: Automating a browser to simulate a user logging in, adding an item to a shopping cart, and checking out.

*   **Component Tests**:
    *   **Scope**: A middle ground between unit and integration tests. A component test limits the scope of the system under test to a portion of the application (e.g., a single microservice with its database mocked or containerized).
    *   **Purpose**: To test the behavior of a component in isolation without testing its integration with other external services.

### The Testing Pyramid
The testing pyramid is a concept that helps visualize how to balance these different types of tests. The general idea is:
1.  **Write lots of fast, simple Unit Tests** (the wide base of the pyramid).
2.  **Write fewer, slightly slower Integration Tests**.
3.  **Write even fewer, complex, and slow E2E Tests** (the narrow top of the pyramid).

Following this model creates a fast, stable, and reliable test suite.

## Code Quality Analysis

### Code Quality Testing
Code quality analysis tools help evaluate code's maintainability and long-term usefulness by checking for potential bugs and security issues.

Key Benefits:
- Improved readability and consistency
- Easier maintenance and reusability
- Better testability and robustness
- Reduced development time and effort

### Common Types of Static Analysis Tools
Static analysis can be broken down into several categories of tools, each with a specific focus:

*   **Linters**:
    *   **Purpose**: To enforce programming conventions and identify "code smells." They check for stylistic errors, programming mistakes, and suspicious constructs.
    *   **Examples**: ESLint (JavaScript), Flake8 (Python), Checkstyle (Java).

*   **Formatters**:
    *   **Purpose**: To automatically reformat source code to conform to a consistent style guide. This eliminates debates over style and makes the code more uniform and readable.
    *   **Examples**: Prettier (JavaScript/CSS/etc.), Black (Python), gofmt (Go).

*   **Security Scanners (SAST)**:
    *   **Purpose**: Static Application Security Testing (SAST) tools scan the source code for known security vulnerabilities, such as SQL injection, cross-site scripting (XSS), and insecure library usage.
    *   **Examples**: Snyk, Veracode, Checkmarx, and the security features within tools like SonarQube.

*   **Code Quality Platforms**:
    *   **Purpose**: These are comprehensive platforms that combine many aspects of static analysis (including linting, complexity, duplications, and security) into a single dashboard. They track code quality over time.
    *   **Example**: SonarQube is the most prominent example in this category.

### SonarQube
SonarQube is a code quality analysis tool that evaluates source code using static analysis, code coverage, and unit tests over time. It manages seven key aspects of code quality:

- **Architecture and design**: Evaluates code structure, module dependencies, and overall project organization
- **Code duplications**: Identifies repeated code blocks that violate DRY (Don't Repeat Yourself) principle
- **Unit test coverage**: Measures how much of the code is covered by automated tests
- **Potential bugs**: Detects code patterns that might cause issues in the future
- **Code complexity**: Analyzes code complexity metrics like cyclomatic complexity
- **Coding standards**: Ensures code follows defined style and best practices
- **Code documentation**: Checks if code is properly documented with comments and documentation

#### SonarQube Components
- **SonarLint**: IDE plugin for real-time code analysis
- **SonarScanner**: Command-line tool to analyze code
- **SonarQube Server**: Main server that processes analysis
- **SonarQube Database**: Stores analysis results and configuration

#### Security and Pipeline Integration
- Quality gates can pause pipeline until analysis is complete
- Webhook secrets should be configured to secure SonarQube notifications
- Secure notifications prevent unauthorized access and ensure data integrity

## Artifact Management
Artifacts ensure that software outputs are reproducible, shareable, traceable, and secure. They are essential for CI/CD processes, versioning, test/deploy separation, and performance.

### What is an Artifact?
An artifact is any file generated during the build process (e.g., JAR, WAR, Docker image, test reports).

### What is a Pipeline Artifact?
A pipeline artifact is a temporary file used within a CI/CD pipeline, typically for passing build outputs between pipeline stages.

### Why Use Artifacts?
1. **Reusability Without Rebuilding**
    - Build once and deploy to test/prod instead of rebuilding for each environment

2. **Traceability and Version Control**
   - Track which commit → which artifact → which environment (1.0.0, 1.0.1, 2.0.0-SNAPSHOT)
   - Answer questions like "What version is running in prod?"

3. **Security and License Control**
   - Allow only components with approved licenses

4. **CI/CD Automation and Consistency**
   - Use same artifact in Build → Test → Deploy steps


### Artifact Management Features
- **Creating Fully Traceable Builds**: Stores build metadata (build number, timestamp, branch, commit) with artifacts
- **Searching for Artifacts**: Enables finding artifacts by name, version, or tags
- **Manipulating Artifacts**: Supports moving, copying, and updating artifacts while maintaining metadata

### Artifact Types
- **Releases**: Stable, immutable versions (e.g., 1.0.0)
- **Snapshots**: Development versions that can change (e.g., 1.0.0-SNAPSHOT)

### Key Functions
- **Versioning**: Tracks metadata (build time, version number)
- **Retention**: Automatically deletes old and unnecessary artifacts based on defined rules
- **Permissions**: Controls access to repository
- **Promotion**: Moves artifacts between environments (dev → test → prod)
- **License Screening**: Ensures compliance with approved licenses
- **Performance**: Provides backup and load balancing

### Popular Tools
- **JFrog Artifactory**: Most comprehensive, supports multiple formats
- **Sonatype Nexus**: Open-source, stable for Maven
- **Docker Registry**: Official container image registry
- **GitHub Packages**: Tight integration with GitHub Actions
- **GitLab Package Registry**: Native GitLab CI integration
- **Azure Artifacts**: Part of Azure DevOps
- **AWS/GCP Artifacts**: Cloud-native solutions

### Maven Artifact Structure
- **GroupId**: Organization identifier (e.g., org.apache.maven)
- **ArtifactId**: Component name (e.g., simple-webapp)
- **Version**: Release version (e.g., major.minor.patch)
- **Packaging**: File format (e.g., JAR, WAR, ZIP)

## Deployment Strategies

## Zero Downtime Deployment
Zero downtime deployment is a deployment strategy that ensures that the application is always available to users during the deployment process. It is achieved by deploying the new version of the application alongside the existing version, and then gradually switching the traffic to the new version.

### Blue/Green Deployment
You create two identical environments. Initially, Blue runs the current version handling all production traffic while Green is idle. After deploying and testing the new version on Green, the load balancer switches all production traffic to Green. Blue remains as a backup. Once Green is verified bug-free, Blue is retired and becomes the new idle environment for future deployments.

### Canary Deployment
You start by releasing a software update to a small group of users to test it and receive feedback. The update is rolled out to the rest of the users once the change is accepted.

### Rolling Deployment
A rolling deployment is a strategy that gradually replaces older versions of an application with newer versions by completely replacing the infrastructure on which it runs. Unlike blue-green, there is no environment isolation between versions, making it faster but riskier with more complex rollback.

### Shadow Deployment
A shadow deployment is a technique that involves releasing a new version of an application (version B) alongside the existing version (version A), but without impacting production traffic. Instead, incoming requests to version A are forked and sent to version B for testing and evaluation. This allows developers to monitor the performance and stability of the new version without affecting the user experience.

### A/B Deployment
A/B deployment strategy is a technique used to test and compare two different versions of a software or feature. It involves dividing users into two groups: Group A, which receives the existing version (control group), and Group B, which receives the new version (experimental group).

### Recreate Deployment
The recreate strategy is a simple deployment approach where version A is completely shut down before deploying version B. This results in downtime during the transition period, which depends on both shutdown and boot duration of the application.

### Key Differences: A/B vs Canary
* **Canary Deployment**: Focuses on safe rollout of a new version to detect issues early
* **A/B Deployment**: Aims to compare performance metrics between two different versions

## Versioning, Branching, and Metrics

### Semantic Versioning (SemVer)
Semantic Versioning (SemVer) is a widely adopted versioning scheme that gives meaning to version numbers. Its primary goal is to help manage dependencies and avoid "dependency hell". A version number is specified in a `MAJOR.MINOR.PATCH` format.

- **MAJOR (e.g., 1.0.0 -> 2.0.0)**: Incremented when you make incompatible API changes (i.e., a breaking change).
- **MINOR (e.g., 1.1.0 -> 1.2.0)**: Incremented when you add functionality in a backward-compatible manner.
- **PATCH (e.g., 1.1.1 -> 1.1.2)**: Incremented when you make backward-compatible bug fixes.

Additionally, pre-release labels (e.g., `1.0.0-alpha.1`) or build metadata (e.g., `1.0.0+20130313144700`) can be appended. Using SemVer makes releases predictable and communicates the nature of changes to users.

### Branching Strategies
A branching strategy is a set of rules that defines how a team uses branches in a version control system like Git. A consistent strategy is key to managing complexity and collaboration.

*   **GitFlow**:
    *   A robust and structured model with long-running branches: `main` (for production releases) and `develop` (for integration).
    *   **Supporting branches**:
        *   `feature/*`: Branched from `develop` for new features. Merged back into `develop`.
        *   `release/*`: Branched from `develop` to prepare for a new production release. Allows for bug fixes and final testing. Merged into both `main` and `develop`.
        *   `hotfix/*`: Branched from `main` to quickly patch production issues. Merged into both `main` and `develop`.
    *   **Best for**: Projects with scheduled release cycles.

*   **GitHub Flow**:
    *   A simpler, lightweight strategy centered around the `main` branch, which is always deployable.
    *   **Process**: Create a feature branch from `main`, open a Pull Request when ready, and merge back into `main` after review and successful CI checks for immediate deployment.
    *   **Best for**: Projects that practice Continuous Delivery and deploy frequently.

*   **Trunk-Based Development**:
    *   All developers work on a single branch called the "trunk" (`main`). Changes are integrated in small, frequent batches. Feature flags are often used to hide incomplete features.
    *   **Best for**: Experienced teams with strong automated testing and CI practices.

#### Applying Versioning with Branching (GitFlow Example)
- The `develop` branch might have `-SNAPSHOT` or `-dev` versions (e.g., `1.2.0-SNAPSHOT`).
- When a `release` branch is created (e.g., `release/1.2.0`), the `-SNAPSHOT` suffix is removed.
- When the release is ready, the `release/1.2.0` branch is merged into `main` and tagged with the version number (e.g., `v1.2.0`). It's also merged back to `develop`.
- The `develop` branch is then updated to the next minor version snapshot (e.g., `1.3.0-SNAPSHOT`).

### DORA Metrics
DORA (DevOps Research and Assessment) metrics are four key metrics used to measure the performance of a software delivery process. High-performing teams consistently score well on these.

1.  **Deployment Frequency**: How often an organization successfully releases to production. (Elite: On-demand, multiple times a day).
2.  **Lead Time for Changes**: The time it takes to get a commit into production. (Elite: Less than one hour).
3.  **Change Failure Rate**: The percentage of deployments that cause a failure in production. (Elite: 0-15%).
4.  **Time to Restore Service**: How long it takes to recover from a failure in production. (Elite: Less than one hour).

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

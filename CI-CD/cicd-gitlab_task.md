# GitLab CI/CD Pipeline Setup Report

This report explains, step-by-step, how a CI/CD (Continuous Integration / Continuous Delivery) pipeline was set up for the `epm-practice-lab-cicd-tasks` project and how the challenges encountered during the process were overcome.

### Step 1: Project Analysis and Pipeline Design

The process began by analyzing the project's existing structure, the `makefile`, and its Python dependencies (`requirements.txt`). The goal was to design a pipeline that included the steps required in the task description: **lint, test, build, and push**.

### Step 2: Creating the `.gitlab-ci.yml` File

The `.gitlab-ci.yml` file, which directs GitLab's CI/CD engine, was created in the project's root directory. In this file:
- Four stages (`lint`, `test`, `build`, `push`) were defined.
- The `python:3.9-slim` image was used for the `lint` and `test` stages.
- For the `build` and `push` stages, a `docker:20.10.16` environment, supported by the `docker:dind` service, was set up to run Docker commands.
- The image name and tag were dynamically configured according to the task description using the variables `IMAGE_NAME: "$CI_REGISTRY/$CI_PROJECT_NAMESPACE/$CI_PROJECT_NAME:$IMAGE_TAG"` and `IMAGE_TAG: "v1.0.0"`.

### Step 3: Resolving Issues in the `lint` Stage

When the pipeline was first run, the `lint` stage failed with an `E501 line too long` error from the `flake8` tool. We followed several steps to resolve this:
1.  **Conflicting Standards:** We identified that the default 88-character line length of the `black` code formatter conflicted with `flake8`'s 79-character rule.
2.  **Centralized Configuration:** A `pyproject.toml` file was added to the project to ensure both tools adhered to the 79-character rule.
3.  **Dependency Upgrade:** While troubleshooting locally, we encountered an `ImportError` caused by an incompatibility between the old version of `black` and its own dependencies (`click`). We resolved this by upgrading `black` to a modern version (`23.3.0`) in `requirements.txt`.
4.  **Manual Intervention:** We manually fixed some lines that the `black` tool did not automatically correct due to their complex structure (especially triggered by an excessively long comment line, which you cleverly identified), allowing the `lint` stage to pass successfully.

### Step 4: Solving Dependency Errors in the `test` Stage

After passing the `lint` stage, we encountered a series of `ImportError` exceptions in the `test` stage. The root cause of these errors was the incompatibility between the old `Flask==1.1.2` library, which had unpinned dependencies in `requirements.txt`, and the newer versions of `Jinja2`, `itsdangerous`, and `Werkzeug` installed by the pipeline.

**Solution:** To make the project stable and consistent across all environments, we pinned the specific versions compatible with `Flask 1.1.2` in the `requirements.txt` file:
- `Jinja2==3.0.3`
- `itsdangerous==2.0.1`
- `Werkzeug==2.0.3`

### Step 5: Fixing the `build` and `push` Stages

After the tests passed successfully, we faced two different issues in the final two stages:
1.  **Docker Naming Convention Error:** Initially, building the image name manually (`$CI_REGISTRY/$CI_PROJECT_NAMESPACE/...`) caused an error because Docker requires repository names to be in lowercase, and the project's namespace contained uppercase characters. We solved this by reverting to the standard `$CI_REGISTRY_IMAGE` predefined variable, which GitLab automatically converts to lowercase, ensuring compliance with Docker's rules.
2.  **Docker Daemon Connection Error:** In the `build` stage, we identified that the port number in the `DOCKER_HOST` variable was incorrect (it should have been `2375` instead of `2545`) and corrected it.
3.  **Missing Image Error:** We observed that the `push` stage could not find the Docker image created in the `build` stage because each job runs in an isolated environment. We solved this using GitLab's `artifacts` feature. In the `build` job, we saved the image as a `.tar` file and marked it as an artifact. In the `push` job, we loaded this artifact, allowing the image to be successfully pushed to the GitLab Container Registry.

### Step 6: Adding the `.gitignore` File

A standard `.gitignore` file was created to prevent the Python virtual environment (`.venv` folder), which is generated locally, from being accidentally committed to the Git repository.

### Final Configuration Files

Below are the final versions of the key configuration files created or modified during this process.

#### `.gitlab-ci.yml`

This file defines the entire CI/CD pipeline, including stages, jobs, and rules.

```yaml
image: docker:20.10.16

services:
  - docker:20.10.16-dind

variables:
  IMAGE_TAG: "v1.0.0"
  IMAGE_NAME: "$CI_REGISTRY_IMAGE:$IMAGE_TAG"
  DOCKER_HOST: "tcp://docker:2375"      # Ensures the job connects to the dind service on the correct default port.
  DOCKER_DRIVER: overlay2             # Enforces the use of the modern and efficient overlay2 storage driver for performance.
  DOCKER_TLS_CERTDIR: ""                # Disables TLS for the internal, trusted network communication, preventing connection errors.

stages:
  - lint
  - test
  - build
  - push

lint:
  stage: lint
  image: python:3.9-slim
  script:
    - |
      echo "Running linting..."
      pip install -r src/requirements.txt
      flake8 src/app/ src/run.py
      black --check src/

test:
  stage: test
  image: python:3.9-slim
  script:
    - |
      echo "Running tests..."
      pip install -r src/requirements.txt
      pytest src/app/tests/

build:
  stage: build
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
  script:
    - |
      echo "Building Docker image..."
      docker build -f build/Dockerfile -t "$IMAGE_NAME" .
      echo "Image built: $IMAGE_NAME"
      echo "Saving Docker image as an artifact..."
      docker save -o image.tar "$IMAGE_NAME"
  artifacts:
    paths:
      - image.tar
    expire_in: 1 hour

push:
  stage: push
  needs:
    - build
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
  script:
    - |
      echo "Loading Docker image from artifact..."
      docker load -i image.tar
      echo "Pushing Docker image..."
      docker push "$IMAGE_NAME"
      echo "Image pushed to GitLab Container Registry."
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
```

#### `requirements.txt`

This file was updated to pin all critical dependencies to specific versions, ensuring a stable and reproducible build environment.

```
Flask==1.1.2
py-cpuinfo==7.0.0
psutil==5.8.0
gunicorn==20.1.0
black==23.3.0
flake8==3.9.0
pytest==6.2.2
Jinja2==3.0.3
itsdangerous==2.0.1
Werkzeug==2.0.3
```

#### `pyproject.toml`

This file was created to centralize the configuration for `black` and `flake8`, ensuring they both adhere to the same line length rule.

```toml
[tool.black]
line-length = 79

[tool.flake8]
max-line-length = 79
extend-ignore = "E203"
```

#### `.gitignore`

This file was created to prevent local development folders and temporary files from being committed to the repository.

```
# Python virtual environment
src/.venv/
.venv/
venv/

# Python cache
__pycache__/
*.pyc

# OS-specific files
.DS_Store

# IDE files
.vscode/
.idea/
```

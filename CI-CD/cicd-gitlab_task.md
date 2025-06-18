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

### Step 7: Advanced Pipeline Optimization

After establishing a working pipeline, a series of advanced optimizations were implemented to significantly improve its speed and efficiency, reflecting professional CI/CD practices.

1.  **Parallel Verification Jobs:** The initial sequential jobs were restructured. The `lint` and `run_tests` jobs were placed in a single `test` stage and configured with `needs: []`. This allows them to start simultaneously, creating a Directed Acyclic Graph (DAG) and dramatically cutting down the total execution time for the verification steps.

2.  **Python Dependency Caching:** To speed up the setup of `lint` and `run_tests` jobs, a global cache was implemented for the Python virtual environment (`.venv`). This cache is shared between jobs, ensuring that once dependencies are downloaded and installed, they are quickly restored from the cache in subsequent pipeline runs, avoiding repeated installations.

3.  **DRY (Don't Repeat Yourself) Principle:** The identical Python setup steps for both `lint` and `run_tests` were abstracted using a YAML anchor (`&python_setup`). This removes code duplication, making the pipeline configuration cleaner and much easier to maintain.

4.  **Advanced Docker Layer Caching:** This is the most significant optimization. The `build` process was enhanced to reuse Docker layers from previous builds.
    *   The pipeline first attempts to pull the `latest` version of the image from the registry.
    *   The `docker build` command then uses the `--cache-from` flag to treat the layers of this pulled image as a cache.
    *   When code changes are minimal, Docker can reuse most of the existing layers, resulting in a much faster build process.
    *   After a successful build, the new image is tagged with both its specific version (`v1.0.0`) and the `latest` tag. Both tags are then pushed to the registry, ensuring the `latest` tag is always available as a cache source for the next pipeline run.

### Final Configuration Files

Below are the final versions of the key configuration files created or modified during this process.

#### `.gitlab-ci.yml`

This file defines the final CI/CD pipeline, incorporating parallel jobs, shared caching, and advanced Docker layer caching for maximum speed and efficiency.

```yaml
image: docker:20.10.16

services:
  - docker:20.10.16-dind

variables:
  IMAGE_TAG: "v1.0.0"
  IMAGE_NAME: "$CI_REGISTRY_IMAGE:$IMAGE_TAG"
  DOCKER_HOST: "tcp://docker:2375"
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: ""
  VENV_PATH: ".venv"

stages:
  - test
  - build
  - push

cache:
  key:
  paths:
    - ${VENV_PATH}/

.python_setup: &python_setup
  - echo "Setting up Python virtual environment..."
  - python3 -m venv ${VENV_PATH}
  - . ${VENV_PATH}/bin/activate
  - echo "Installing dependencies from src/requirements.txt "
  - pip install -r src/requirements.txt

lint:
  stage: test
  image: python:3.9-slim
  needs: []
  script:
    - *python_setup
    - echo "Running linting..."
    - flake8 src/app/ src/run.py
    - black --check src/

run_tests:
  stage: test
  image: python:3.9-slim
  needs: []
  script:
    - *python_setup
    - echo "Running tests..."
    - pytest src/app/tests/

build:
  stage: build
  needs: [lint, run_tests]
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
  script:
    - |
      echo "Building Docker image with layer caching..."
      # Pull the latest image to use its layers as a cache
      docker pull "$CI_REGISTRY_IMAGE:latest" || true
      # Build the new image using the pulled image as a cache
      docker build \
        --cache-from "$CI_REGISTRY_IMAGE:latest" \
        --tag "$IMAGE_NAME" \
        --tag "$CI_REGISTRY_IMAGE:latest" \
        -f build/Dockerfile .
      echo "Image built: $IMAGE_NAME"
      echo "Saving Docker image as an artifact..."
      docker save -o image.tar "$IMAGE_NAME" "$CI_REGISTRY_IMAGE:latest"
  artifacts:
    paths:
      - image.tar
    expire_in: 1 hour

push:
  stage: push
  needs: [build]
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" "$CI_REGISTRY"
  script:
    - |
      echo "Loading Docker image from artifact..."
      docker load -i image.tar
      echo "Pushing Docker image..."
      # Push the specific version tag
      docker push "$IMAGE_NAME"
      # Also push the 'latest' tag to be used as cache for the next run
      docker push "$CI_REGISTRY_IMAGE:latest"
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

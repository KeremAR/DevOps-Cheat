# Jenkins Pipeline Recovery Report

This report documents the step-by-step process of diagnosing and attempting to repair a broken multi-stage CI/CD pipeline for a Python/Flask application. The task involved a pre-configured environment with Jenkins, SonarQube, and Nexus, with the goal of making the pipeline pass successfully.

### Phase 1: Initial Jenkins & Pipeline Configuration

The first set of challenges involved correcting the basic Jenkins job configuration to allow the pipeline to start.

#### Step 1: Correcting Branch and Jenkinsfile Path
- **Problem**: The pipeline failed immediately because it could not find the source code or the pipeline definition file.
- **Analysis**: We identified two separate issues in the Jenkins job configuration:
    1. The "Branch Specifier" was set to the default `*/master`, but the project's main branch is `main`.
    2. The "Script Path" for the `Jenkinsfile` was incorrect.
- **Solution**:
    1. We updated the "Branch Specifier" in the Jenkins UI to `*/main`.
    2. We corrected the "Script Path" to `jenkins/Jenkinsfile`.

#### Step 2: Parameterizing the Build and Fixing the Git URL
- **Problem**: The pipeline still failed during the checkout phase.
- **Analysis**:
    1. The `Jenkinsfile` was designed to be run with a Git tag parameter, but the job was being run without one.
    2. The `checkout` stage in the `Jenkinsfile` contained a hardcoded, incorrect Git repository URL (`git.epam.com/...`).
- **Solution**:
    1. We started using the "Build with Parameters" option in Jenkins. Since no tags existed, we created and pushed the first tag, `0.0.1`, from the local repository.
    2. The hardcoded Git URL in the `Jenkinsfile` was manually updated to point to the correct forked repository URL on GitLab.

### Phase 2: Code, Quality, and Test Failures

With the pipeline able to check out the correct code, we moved on to fixing errors in the application itself.

#### Step 3: Passing the SonarQube Quality Gate
- **Problem**: The pipeline failed at the "Sonarqube scan" stage.
- **Analysis**: The SonarQube analysis reported a critical code quality issue: a Python indentation error in `flaskr/db.py`.
- **Solution**: We corrected the indentation in `flaskr/db.py`. This also required creating and pushing a new tag (`0.0.2`) to ensure the pipeline ran with the latest fix.

#### Step 4: Resolving Unit Test Failures
- **Problem**: With the quality gate passed, the pipeline proceeded to the "Unit Test" stage, which failed with multiple errors.
- **Analysis**: We diagnosed three separate bugs in the application code that were causing the unit tests to fail:
    1.  `flaskr/auth.py`: Incorrect logic for handling user data.
    2.  `flaskr/db.py`: A database query was malformed.
    3.  `flaskr/blog.py`: An update function was not returning the correct data to its template.
- **Solution**: We applied fixes to all three files. This required creating new tags (`0.0.3` and `0.0.4`) to incrementally test the fixes until all unit tests passed.

### Phase 3: Docker and Deployment Stages

This phase focused on errors related to building, pushing, and running the application's Docker container.

#### Step 5: Fixing the Docker Build
- **Problem**: The "Docker build" stage failed.
- **Analysis**: The `Jenkinsfile` was using an incorrect command, `docker create`, instead of the correct `docker build`.
- **Solution**: We replaced `docker create` with `docker build` in the `Jenkinsfile` (`tag 0.0.5`).

#### Step 6: Correcting the Dockerfile Logic
- **Problem**: The Docker build failed again, this time due to a flawed `Dockerfile`.
- **Analysis**: The `Dockerfile` was attempting to run application commands (like `flask db init`) *before* copying the application source code into the image or installing its dependencies.
- **Solution**: We rewrote the `Dockerfile` to follow the correct sequence: copy source code, install dependencies, then run commands (`tag 0.0.6`).

#### Step 7: Pushing the Image to Nexus
- **Problem**: The "Image push to nexus" stage failed.
- **Analysis**: The `Jenkinsfile` was using an invalid command (`docker put`) and was not logging into the Nexus registry before attempting to push.
- **Solution**: We replaced `docker put` with `docker push` and added a `docker login` command, using credentials stored in Jenkins (`tag 0.0.7`).

#### Step 8: Fixing the Application Deployment
- **Problem**: The "Deploy application" stage failed.
- **Analysis**: We found three errors in the deployment script within the `Jenkinsfile`:
    1. `docker get` was used instead of `docker pull`.
    2. `docker exec` was used instead of `docker run` to start a new container.
    3. A hardcoded, incorrect version tag (`TAG=0.0.0`) was being used.
- **Solution**: All three commands were corrected in the `Jenkinsfile` (`tag 0.0.8`).

### Phase 4: The Integration Test Challenge

The final and most complex stage involved debugging the running application.

#### Step 9: Debugging the Crashing Application
- **Problem**: The pipeline reached the "Integration tests" stage and failed. The logs showed the application container was not running.
- **Analysis**: The application was crashing on startup. The `docker logs` command was piped to `grep`, which hid the actual error message.
- **Solution**:
    1. We modified the `Jenkinsfile` to first run `docker logs ${app_name}` to see the full, unfiltered output.
    2. The logs revealed the error: `Error: Could not locate a Flask application`.
    3. We fixed this by adding the `-e FLASK_APP=flaskr` environment variable to the `docker run` command in the `Jenkinsfile`.

#### Step 10: Correcting Version Display and Fixing the Integration Test
- **Problem**: The application was running, but the final integration test was failing. A user-provided screenshot revealed that the version should be displayed in the main title (e.g., "Flaskr - 0.0.X"), but the application was not doing this. Furthermore, the test itself was flawed, checking the wrong port and searching for an incorrect string.
- **Analysis**: We identified a two-part problem:
    1.  The `TAG` environment variable was not being passed to the Flask application's `config`, so the HTML templates couldn't access it to display the version in the title.
    2.  The integration test in the `Jenkinsfile` was checking the wrong port (`8080` instead of `8888`) and searching for a string that did not match the desired visual output.
- **Solution**: A combined fix was implemented:
    1.  **Code Fix**: We modified `flaskr/__init__.py` to load the `TAG` environment variable directly into the application's configuration (`app.config`). This made the version number available to the `base.html` template, which already had logic to display it in the title.
    2.  **Test Fix**: We corrected the `Integration tests` stage in the `Jenkinsfile`. The `curl` command was updated to query the correct application port (`http://${app_name}:8888`), and the `grep` command was changed to search for the correct title string (`"Flaskr - ${GIT_TAG_TO_DEPLOY}"`), aligning the test with the required output.
    3.  **UI Cleanup**: As a final cleanup step, the confusing and now-defunct `<h2>Version: None</h2>` line was removed from the `flaskr/templates/blog/index.html` file.

With these final changes, the pipeline achieved a successful run across all stages, and the application's user interface correctly reflected the deployed version as per the task's implicit requirements.

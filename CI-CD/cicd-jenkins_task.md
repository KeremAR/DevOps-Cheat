# Jenkins CI/CD Pipeline Setup Notes

This document provides a step-by-step personal development log detailing how a complete Continuous Integration / Continuous Delivery (CI/CD) pipeline was set up for a React application using Jenkins, Docker, and Trivy, including the challenges faced and the solutions implemented.

### Step 1: Jenkins Installation and Initial Setup

The first step was to prepare the Jenkins infrastructure that would serve as the CI/CD server.
- **Jenkins Installation:** The Jenkins LTS (Long-Term Support) version was successfully installed on an Ubuntu virtual machine using its official repository.
- **Required Plugins:** Critical plugins for the task, such as `Docker Pipeline`, `Docker plugin`, and `NodeJS Plugin`, were installed in Jenkins.
- **Global Tool Configuration:** The `NodeJS 7.8.0` installation, required for the project's build and test stages, was defined in Jenkins's "Global Tool Configuration" section.

### Step 2: Multibranch CI Pipeline (`CICD`) and Initial Challenges

A series of common issues were encountered and resolved while creating the project's main automation engine, the Multibranch Pipeline.

1.  **`Jenkinsfile` Creation:** A `Jenkinsfile` was added to the project's root directory to define the pipeline logic as "Infrastructure as Code." This file included conditional logic to dynamically set the application's port and logo file based on the branch name (`main` or `dev`).
2.  **Docker Permission Error (`Permission Denied`):** When the pipeline first ran, it failed with a `permission denied while trying to connect to the Docker daemon socket` error because it lacked the authority to execute `docker` commands. This was resolved by adding the `jenkins` user to the `docker` group with the `sudo usermod -aG docker jenkins` command and restarting the Jenkins service.
3.  **Performance and Build Error (`Context Canceled`):** During the `docker build` process, the attempt to copy the massive `node_modules` folder into the image consumed the virtual machine's resources, causing the build to be canceled. This critical issue was overcome by adding a `.dockerignore` file to the project root to exclude the `node_modules` folder.

### Step 3: Manual Deployment Pipeline (`CD_deploy_manual`)

The second main objective of the task, a manually triggered deployment pipeline with parameters, was created.
- **Parametric Structure:** The pipeline was designed to accept two parameters from the user: `TARGET_ENV` (main/dev) and `IMAGE_TAG`.
- **Syntax Error:** In the first attempt, trying to define parameters both through the Jenkins UI and within the `Jenkinsfile` script led to a configuration conflict and a `startup failed` error. The issue was resolved by removing the "This project is parameterized" option from the UI and relying solely on the `parameters` block within the script.

### Step 4: Advanced Optimizations and Security Integration

After establishing a stable pipeline, a series of optimizations and security measures were implemented to bring the process up to professional standards.

1.  **Dockerfile Layer Caching:** To dramatically reduce build times, the `Dockerfile` was restructured. The `COPY package.json`, `RUN npm install`, and `COPY . .` steps were ordered sequentially to maximize the use of Docker's layer caching mechanism. This optimization reduced subsequent build times from **10+ minutes to under 2 minutes**.
2.  **Security Scanning with Trivy:** A new stage was added to scan the created Docker images for vulnerabilities with `Trivy` before pushing them to Docker Hub.
    - **First Error (`DB Download Failed`):** Trivy failed because it couldn't find a cache directory to download its vulnerability database. The problem was solved by manually creating the `/var/lib/jenkins/.cache/trivy` directory and giving the `jenkins` user ownership.
    - **Second Error (`Context Deadline Exceeded`):** The scan timed out due to the virtual machine's slow disk performance. This was permanently fixed by adding the `--timeout 15m`, `--skip-dirs /app/node_modules` (to prevent unnecessary scanning), and `--scanners vuln` (to only scan for vulnerabilities) parameters to the `trivy` command.

### Step 5: Decoupling Deployment and Resolving Jenkins Deadlock

To separate CI and CD concerns, the deployment logic was moved to separate pipelines.
1.  **Separate Deployment Pipelines:** Two new pipelines, `Deploy_to_main` and `Deploy_to_dev`, were created solely for pulling images from Docker Hub and deploying them.
2.  **Pipeline Triggering:** The `CICD` pipeline was updated to trigger the appropriate deployment pipeline from within a `post` block after a successful build.
3.  **Deadlock Issue:** This triggering mechanism caused a deadlock, as Jenkins's two available "executors" were both occupied. The `CICD` pipeline was waiting for the `Deploy_*` pipeline to finish, while the `Deploy_*` pipeline was waiting for a free executor. This deadlock was resolved by adding the `wait: false` parameter to the `build job` command, allowing the main pipeline to complete its task without waiting for the downstream job.

### Final Configuration Files

Below are the final versions of the key configuration files created or modified during this process.

#### `Jenkinsfile` (`CICD` Pipeline)
```groovy
pipeline {
    agent any
    environment {
        DOCKER_CREDS = credentials('dockerhub-credentials') 
    }
    stages {
        stage('Prepare Environment') {
            steps {
                script {
                    def dockerhubUser = "keremar" 
                    def dockerhubRepo = "epam-jenkins-lab"
                    if (env.BRANCH_NAME == 'main') {
                        env.DOCKER_IMAGE_NAME = "${dockerhubUser}/${dockerhubRepo}:main-v1.0"
                        env.LOGO_FILE_PATH = 'src/logo-main.svg'
                    } else if (env.BRANCH_NAME == 'dev') {
                        env.DOCKER_IMAGE_NAME = "${dockerhubUser}/${dockerhubRepo}:dev-v1.0"
                        env.LOGO_FILE_PATH = 'src/logo-dev.svg'
                    }
                }
            }
        }
        stage('Change Logo') {
            steps {
                sh "cp -f ${env.LOGO_FILE_PATH} src/logo.svg"
            }
        }
        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${env.DOCKER_IMAGE_NAME} ."
            }
        }
        stage('Scan Docker Image for Vulnerabilities') {
            steps {
                sh "trivy image --timeout 15m --skip-dirs /app/node_modules --scanners vuln --exit-code 0 --severity HIGH,CRITICAL ${env.DOCKER_IMAGE_NAME}"
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    sh 'echo $DOCKER_CREDS_PSW | docker login -u $DOCKER_CREDS_USR --password-stdin'
                    sh "docker push ${env.DOCKER_IMAGE_NAME}"
                }
            }
        }
    }
    post {
        success {
            script {
                echo "Build successful. Triggering deployment..."
                if (env.BRANCH_NAME == 'main') {
                    build job: 'Deploy_to_main', wait: false, parameters: [string(name: 'IMAGE_TO_DEPLOY', value: env.DOCKER_IMAGE_NAME)]
                } else if (env.BRANCH_NAME == 'dev') {
                    build job: 'Deploy_to_dev', wait: false, parameters: [string(name: 'IMAGE_TO_DEPLOY', value: env.DOCKER_IMAGE_NAME)]
                }
            }
        }
        always {
            echo "Logging out from Docker Hub..."
            sh 'docker logout'
            cleanWs()
        }
    }
}
```

#### `CD_deploy_manual` Pipeline Script
```groovy
pipeline {
    agent any

    parameters {
        choice(name: 'TARGET_ENV', choices: ['main', 'dev'], description: 'Select the environment to deploy (main or dev).')
        string(name: 'IMAGE_TO_DEPLOY', defaultValue: 'keremar/epam-jenkins-lab:main-v1.0', description: 'Enter the full Docker image tag to deploy.')
    }

    stages {
        stage('Deployment Configuration') {
            steps {
                script {
                    echo "Deploying image '${params.IMAGE_TO_DEPLOY}' to '${params.TARGET_ENV}' environment."
                    if (params.TARGET_ENV == 'main') {
                        env.APP_PORT = '3000'
                    } else {
                        env.APP_PORT = '3001'
                    }
                }
            }
        }

        stage('Deploy Application') {
            steps {
                script {
                    def containerName = "app-${params.TARGET_ENV}"
                    sh """
                        if [ \$(docker ps -a -q -f name=${containerName}) ]; then
                            docker stop ${containerName}
                            docker rm ${containerName}
                        fi
                    """
                    sh "docker run -d --name ${containerName} -p ${env.APP_PORT}:3000 ${params.IMAGE_TO_DEPLOY}"
                }
            }
        }
    }
}
```

#### `Dockerfile`
```dockerfile
FROM node:7.8.0

WORKDIR /app

COPY package.json ./

RUN npm install

COPY . .

EXPOSE 3000

ENTRYPOINT ["npm", "start"]
```

#### `.dockerignore`
```
node_modules
```

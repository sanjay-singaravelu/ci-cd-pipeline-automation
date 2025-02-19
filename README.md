---

# CI/CD Pipeline with Jenkins, Docker, and Kubernetes

This project demonstrates how to implement a **CI/CD pipeline** using **Jenkins**, **Docker**, and **Kubernetes** (or **Minikube** for local setups). The pipeline will automatically build a Docker image, run tests, push the image to **Docker Hub**, deploy the application to a **Kubernetes cluster**, and verify that the deployment works.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Setting Up Jenkins](#setting-up-jenkins)
4. [Pipeline Configuration](#pipeline-configuration)
5. [Docker Setup](#docker-setup)
6. [Kubernetes Setup](#kubernetes-setup)
7. [Using ngrok](#using-ngrok)
8. [Setting Up GitHub Webhooks](#setting-up-github-webhooks)

## Prerequisites

- **Jenkins**: You must have Jenkins installed and running. You can follow the installation guide for Jenkins from [here](https://www.jenkins.io/doc/book/installing/).
  
- **Docker**: Docker should be installed on the machine running Jenkins. You can install Docker from [here](https://docs.docker.com/get-docker/).
  
- **Kubernetes**: For local development, Minikube is recommended. Install Minikube by following the official instructions [here](https://minikube.sigs.k8s.io/docs/).
  
- **Docker Hub Account**: You will need a Docker Hub account to store your images. Sign up for a free account [here](https://hub.docker.com/signup).

- **GitHub Repository**: The source code for your application (e.g., Node.js, Python, etc.) should be available in a GitHub repository (or another version control system).

## Project Structure

```
ci-cd-pipeline-automation/
│
├── Jenkinsfile                # The Jenkins pipeline script
├── Dockerfile                 # Docker configuration file for building the image
├── docker-compose.yml         # (Optional) Docker Compose configuration for local development
├── k8s/                       # Kubernetes manifests for deployment
│   ├── deployment.yaml        # Kubernetes deployment configuration
│   └── service.yaml           # Kubernetes service 
└── README.md                  # This README file
```

## Setting Up Jenkins

### 1. Install Jenkins

Follow the official Jenkins documentation to install Jenkins on your local machine or server.

### 2. Install Jenkins Plugins

In Jenkins, install the following plugins:
- **Docker Pipeline**: For Docker-related steps.
- **Kubernetes CLI Plugin**: For interacting with Kubernetes (if using Kubernetes or Minikube).
- **Credentials Binding Plugin**: For securely handling credentials such as Docker Hub login.

### 3. Configure Jenkins Credentials

In Jenkins, configure your **Docker Hub credentials**:
1. Go to **Manage Jenkins** > **Manage Credentials**.
2. Add a new **Username and Password** credential for Docker Hub:
   - **Username**: Your Docker Hub username.
   - **Password**: Your Docker Hub password or personal access token.
   - **ID**: `dockerhub-credentials`.

### 4. Configure Jenkins Pipeline

Create a new **Pipeline project** in Jenkins:
1. Go to **Jenkins Dashboard** > **New Item**.
2. Choose **Pipeline** and provide a name for your project.
3. In the **Pipeline** section, select **Pipeline script from SCM** and link to your GitHub repository.
4. Set the **Script Path** to `Jenkinsfile`.

## Pipeline Configuration

The **Jenkinsfile** defines the steps of your pipeline, which include:

1. **Cloning the Repository**: The pipeline starts by cloning your Git repository to pull the source code.
2. **Building the Docker Image**: The Docker image is built using the `Dockerfile`.
3. **Running Tests**: The pipeline runs tests on the built Docker image.
4. **Pushing to Docker Hub**: If tests pass, the image is pushed to **Docker Hub**.
5. **Deploying to Kubernetes**: The image is deployed to Kubernetes (or Minikube for local development).
6. **Post Deployment Test**: The pipeline verifies the application by making an HTTP request to ensure it's running.

## Docker Setup

### 1. Dockerfile

Your **Dockerfile** should be located in the root of your project. Here's a basic example for a Node.js application:

```Dockerfile
# Use an official Node.js runtime as a parent image
FROM node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 3007

# Command to run the app
CMD ["npm", "start"]
```

## Kubernetes Setup

### 1. Kubernetes Deployment

Your **`deployment.yaml`** file defines how to deploy the app to Kubernetes. It looks like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: <dockerhub_username>/my-app:latest  # Ensure this matches the image pushed to Docker Hub
        ports:
        - containerPort: 3007
```

### 2. Kubernetes Service

Your **`service.yaml`** file defines how to expose the app to the outside world. It should look something like this:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3007
  type: LoadBalancer  # You can also use ClusterIP or NodePort
```


## Using ngrok

**[ngrok](https://ngrok.com/)** is a tool that allows you to create secure tunnels to your localhost. It's particularly useful for exposing local development environments to the internet. You can use ngrok to expose your Jenkins or local Kubernetes services for remote testing.

### Steps to use ngrok:

1. Install **ngrok** on your local machine:
   ```bash
   brew install ngrok  # MacOS
   sudo apt install ngrok-client  # Linux
   ```
2. Run **ngrok** to expose your Jenkins or application port:
   ```bash
   ngrok http 8080  # Expose Jenkins on port 8080 or any other app port
   ```
3. ngrok will provide you with a public URL, which you can use to test your application externally.

## Setting Up GitHub Webhooks

To automatically trigger the Jenkins pipeline when code is pushed to GitHub, you can use GitHub webhooks.

### Steps to create a GitHub webhook:

1. In your **GitHub repository**, go to **Settings** > **Webhooks**.
2. Click on **Add webhook**.
3. In the **Payload URL**, add your Jenkins webhook URL:
   ```
   http://<jenkins-server>/github-webhook/
   ```
4. Set **Content type** to `application/json`.
5. Choose which events you want to trigger the webhook (usually, **Push events**).
6. Click **Add webhook**.

Once configured, Jenkins will automatically trigger the pipeline whenever a push is made to your GitHub repository.

---
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'sanjayvelu14/my-app:latest'  // Name of the image including Docker Hub username
        DOCKER_REGISTRY = 'sanjayvelu14'  // Docker Hub username (or your registry address)
        DOCKER_REPO = 'my-app-repo'  // Repository name on Docker Hub
        KUBE_CONTEXT = 'minikube'  // Kubernetes context if using Minikube or your Kubernetes cluster context
        DOCKER_CREDENTIALS = 'DockerRegistryCreds'  // Jenkins credentials for Docker Hub login
    }

    stages {
        stage('Clone Repository') {
            steps {
                // Checkout the code from GitHub or your version control system
                git branch: 'main', credentialsId: 'github-credentials', url: 'https://github.com/sanjay-singaravelu/ci-cd-pipeline-automation'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    echo "Building Docker image..."
                    sh '/bin/sh -c "docker build -t ${DOCKER_IMAGE} ."'
                }
            }
        }

        stage('Run Tests') {
            steps {
                script {
                    // Run tests on the built Docker container
                    echo "Running tests on the Docker container..."
                    sh '/bin/sh -c "docker run --rm ${DOCKER_IMAGE} npm test"'  // Replace with your test command
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub using Jenkins credentials
                    echo "Logging into Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'DockerRegistryCreds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '/bin/sh -c "echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin"'
                    }

                    // Push the Docker image to Docker Hub
                    echo "Pushing Docker image to Docker Hub..."
                    sh '/bin/sh -c "docker push ${DOCKER_IMAGE}"'
                }
            }
        }

        stage('Deploy to Kubernetes or Minikube') {
            steps {
                script {
                    // Check if Minikube is available or use Docker for direct deployment
                    echo "Deploying application..."

                    if (fileExists('/usr/local/bin/minikube')) {
                        echo "Using Minikube for Kubernetes deployment"
                        // Set kubectl context to Minikube
                        sh '/bin/sh -c "kubectl config use-context ${KUBE_CONTEXT}"'

                        // Create Kubernetes deployment using kubectl or Helm
                        sh '''
                        /bin/sh -c "kubectl apply -f k8s/deployment.yaml"
                        /bin/sh -c "kubectl apply -f k8s/service.yaml"
                        '''
                    }
                }
            }
        }

        stage('Post Deployment Test') {
            steps {
                script {
                    // After deployment, test if the app is running
                    echo "Testing the deployed application..."

                    // Example: Use curl or browser to check the application
                    sh '/bin/sh -c "curl -f http://localhost:3007 || exit 1"'  // Adjust based on your app's URL
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for errors.'
        }
    }
}

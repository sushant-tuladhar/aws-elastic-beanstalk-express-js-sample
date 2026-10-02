pipeline {
    agent {
        docker {
            image 'node:16-alpine'
            // Added -u root so the agent container has permission to access docker.sock
            args '-u root -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker'
        }
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        APP_IMAGE = 'dethronix/aws-express-sample'
    }

    stages {
        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm ci'
            }
        }

        stage('Run Unit Tests') {
            steps {
                echo 'Running test suite...'
                sh 'npm test --if-present'
            }
        }

        stage('Security Vulnerability Scan') {
            steps {
                echo 'Executing dependency audit...'
                // Security Gate: Fails the pipeline if High or Critical vulnerabilities exist
                sh 'npm audit --audit-level=high'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker container image...'
                sh "docker build -t ${APP_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${APP_IMAGE}:${BUILD_NUMBER} ${APP_IMAGE}:latest"
            }
        }

        stage('Publish to Container Registry') {
            steps {
                echo 'Authenticating and pushing image to Docker Hub...'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh "docker push ${APP_IMAGE}:${BUILD_NUMBER}"
                sh "docker push ${APP_IMAGE}:latest"
            }
        }
    }

    post {
        always {
            echo 'Cleaning up registry credentials...'
            sh 'docker logout || true'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed due to errors or critical security vulnerabilities.'
        }
    }
}
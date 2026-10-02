pipeline {
    agent none

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        APP_IMAGE = 'dethronix/aws-express-sample'
    }

    stages {
        stage('Install Dependencies') {
            agent {
                docker { image 'node:16-alpine' }
            }
            steps {
                echo 'Installing Node.js dependencies...'
                sh 'npm ci'
            }
        }

        stage('Run Unit Tests') {
            agent {
                docker { image 'node:16-alpine' }
            }
            steps {
                echo 'Running test suite...'
                sh 'npm test --if-present'
            }
        }

        stage('Security Vulnerability Scan') {
            agent {
                docker { image 'node:16-alpine' }
            }
            steps {
                echo 'Executing dependency audit...'
                // Security Gate: Fails pipeline if High or Critical issues are detected
                sh 'npm audit --audit-level=high'
            }
        }

        stage('Build Docker Image') {
            agent any
            steps {
                echo 'Building Docker container image...'
                sh "docker build -t ${APP_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${APP_IMAGE}:${BUILD_NUMBER} ${APP_IMAGE}:latest"
            }
        }

        stage('Publish to Container Registry') {
            agent any
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
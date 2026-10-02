pipeline {
    agent none

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials-id')
        APP_IMAGE = 'dethronix/aws-express-sample'
    }

    stages {
        stage('Checkout & Stash') {
            agent any
            steps {
                checkout scm
                stash name: 'workspace-files', includes: '**/*'
            }
        }

        stage('Install Dependencies') {
            agent {
                docker { image 'node:16-alpine' }
            }
            steps {
                unstash 'workspace-files'
                echo 'Installing Node.js dependencies...'
                sh 'npm ci'
            }
        }

        stage('Run Unit Tests') {
            agent {
                docker { image 'node:16-alpine' }
            }
            steps {
                unstash 'workspace-files'
                echo 'Running test suite...'
                sh 'npm test --if-present'
            }
        }

        stage('Security Vulnerability Scan') {
            agent {
                docker { image 'node:16-alpine' }
            }
            steps {
                unstash 'workspace-files'
                echo 'Executing dependency audit...'
                sh 'npm audit --audit-level=high'
            }
        }

        stage('Build Docker Image') {
            agent any
            steps {
                unstash 'workspace-files'
                echo 'Building Docker application image...'
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
            script {
                node('') {
                    echo 'Cleaning up registry credentials...'
                    sh 'docker logout || true'
                }
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed due to errors or critical security vulnerabilities.'
        }
    }
}
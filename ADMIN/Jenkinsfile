pipeline {
    agent any

    environment {
        HOME_PATH = '/home/ubuntu'
    }

    stages {
        stage('Env Prepare') {
            steps {
                withCredentials([
                    file(credentialsId: 'admin-env', variable: 'ENV'),
                    ]) {

                script{
                    sh 'cp "${ENV}" ADMIN/ice-cream/.env.production'
                    }
                }   
            }
        }

        stage('Build ADMIN') {
            steps {
                echo 'Building ADMIN...'
                dir('ADMIN/ice-cream') {
                    sh 'docker build -t admin .'
                }
            }
        }

        stage('Deploy ADMIN') {
            steps {
                echo 'Deploying ADMIN...'
                sh 'docker stop admin || true'
                sh 'docker rm admin || true'
                sh 'docker run -d -p 3000:3000 --name admin admin'
            }
        }
    }
}

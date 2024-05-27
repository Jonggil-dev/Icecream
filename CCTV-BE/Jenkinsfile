pipeline {
    agent any

    environment {
        HOME_PATH = '/home/ubuntu'
    }

    stages {
        // 빌드
        stage('Build BE') {
            steps {
                echo 'Building BE...'
                dir('CCTV-BE') {
                    sh 'docker build -t cctv .'
                }
            }
        }
        // 테스트
        stage('Test') {
            steps {
                echo 'Test는 일단 패스'
            }
        }

        // 배포
        stage('Deploy BE') {
            steps {
                echo 'Deploying BE...'
                sh 'docker stop cctv || true'
                sh 'docker rm cctv || true'
                sh 'docker run -d -p 1996:1996 --name cctv cctv'
            }
        }
    }
}

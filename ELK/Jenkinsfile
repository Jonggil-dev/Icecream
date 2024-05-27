pipeline {
    agent any

    environment {
        HOME_PATH = '/home/ubuntu'
    }

    stages {
        // env 적용
        stage('ELK Env Prepare') {
            steps {
                withCredentials([
                    file(credentialsId: 'ENV-ELK', variable: 'ENV_ELK'),
                    ]) {

                    script {
                        sh 'cp "${ENV_ELK}" ELK/.env'
                    }
                }   
            }
        }

        // 배포
        stage('Deploy ELK') {
            steps {
                dir('ELK') {
                    // 배포 관련 작업을 여기에 추가
                    echo 'Deploying ELK...'
                    // 빌드가 진행되면 기존의 컨테이너 중지 및 제거 & 컨테이너가 없어도 실패하지 않고계속 수행
                    sh 'docker-compose down || true'
                    // 백엔드 이미지 실행
                    sh 'docker-compose up -d'
                }
            }
        }

    }
}


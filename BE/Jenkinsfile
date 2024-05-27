pipeline {
    agent any

    environment {
        HOME_PATH = '/home/ubuntu'
    }

    stages {
        // prod 적용
        stage('BE Env Prepare') {
            steps {
                withCredentials([
                    file(credentialsId: 'icecream-prod', variable: 'PROD_PROPERTIES'),
                    file(credentialsId: 'icecream-fcm', variable: 'FCM_JSON'),
                    file(credentialsId: 'icecream-log', variable: 'LOG_SPRING')
                    ]) {

                script{
                    // Jenkins가 EC2 내에서 특정 디렉토리를 수정할 수 있도록 권한 변경
                    // sh 'chmod -R 755 icecream/src/main/resources/'

                    // Secret File Credential을 사용하여 설정 파일을 Spring 프로젝트의 resources 디렉토리로 복사
                    sh 'cp "${PROD_PROPERTIES}" BE/icecream/src/main/resources/application-prod.properties'
                    sh 'cp "${FCM_JSON}" BE/icecream/src/main/resources/fcm-admin-sdk.json'
                    sh 'cp "${LOG_SPRING}" BE/icecream/src/main/resources/logback-spring.xml'
                    }
                }   
            }
        }

        // 빌드
        stage('Build BE') {
            steps {
                echo 'Building BE'
                // 백엔드 소스코드가 있는 경로로 이동
                dir('BE/icecream') {
                    // Docker 이미지 빌드 명령어
                    sh 'docker build -t icecream .'
                }
            }
        }

        // 테스트
        stage('Test') {
            steps {
                // 테스트 관련 작업을 여기에 추가
                echo 'Test는 일단 패스'
            }
        }

        // 배포
        stage('Deploy BE') {
            steps {
                // 배포 관련 작업을 여기에 추가
                echo 'Deploying Bank...'
                // 빌드가 진행되면 기존의 컨테이너 중지 및 제거 & 컨테이너가 없어도 실패하지 않고계속 수행
                sh 'docker stop icecream || true'
                sh 'docker rm icecream || true'
                // 백엔드 이미지 실행
                sh 'docker run -d -p 8070:8080 --name icecream icecream'
            }
        }

    }
}


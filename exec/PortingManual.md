## 1. 개발환경

|Tech|Stack|Version|
|:---:|:---:|:---:|
|웹 서버|Nginx|1.18.0(Ubuntu)|
|WAS|Tomcat||
|FrontEnd|Flutter|3.19.2|
||Firebase|10.4.10|
|BackEnd|OpenJDK|17|
||SpringBoot|3.2.2|
||Gradle|8.5|
||RabbitMQ|3.13.1|
||Elasticsearch|7.10.2|
||Logstash|7.10.2|
||Kibana|7.10.2|
|DataBase|PostgreSQL / PostGIS|16.2 / 3.4|
||MongoDB|7.0.8 Atlas|
||Redis|7.2.4|
|Admin Server|Node.Js|20.11.0|
||Next.Js|14.2.3|
|CCTV Server|Node.Js|20.11.0|
||Express.Js|4.19.2|
|AI|Python|3.10.14|
||FastAPI|0.65.0|


## 2. 설정파일 및 환경 변수
- **application.properties (SpringBoot)**

```bash
spring.application.name=icecream

# Postgres Settings
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_NAME}
spring.datasource.password=${DB_PASSWORD}
spring.datasource.driver-class-name=org.postgresql.Driver

# MongoDB Settings
spring.data.mongodb.uri=${MONGO_DB_URL}
spring.data.mongodb.database=${MONGO_DB_DATABASE}

# Redis Settings
spring.data.redis.host=${REDIS_URL}
spring.data.redis.database=${REDIS_DATABASE}
spring.data.redis.password=${REDIS_PASSWORD}
spring.data.redis.port=${REDIS_PORT}

# RabbitMQ Settings
spring.rabbitmq.host=${RABBITMQ_URL}
spring.rabbitmq.port=${RABBITMQ_PORT}
spring.rabbitmq.username=${RABBITMQ_USERNAME}
spring.rabbitmq.password=${RABBITMQ_PASSWORD}

# Hibernate Settings
spring.jpa.show-sql=false
spring.jpa.hibernate.ddl-auto=none
spring.jpa.properties.hibernate.validator.apply_to_ddl=false
spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation=true

management.endpoints.web.exposure.include=health,info,metrics

# Logging Level
logging.level.org.springframework.web=DEBUG
#logging.level.org.hibernate.SQL=DEBUG
#logging.level.org.hibernate.type=TRACE
#logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

server.servlet.context-path=/api

#JWT SECRET_KEY
com.icecream.auth.access.secretKey=${ACCESS_SECRET_KEY}
com.icecream.auth.refresh.secretKey=${REFRESH_SECRET_KEY}

#S3
cloud.aws.credentials.accessKey=${S3_ACCESS_KEY}
cloud.aws.credentials.secretKey=${S3_SECRET_KEY}
cloud.aws.s3.bucketName=${S3_BUCKET_NAME}
cloud.aws.region.static=${S3_REGION}
cloud.aws.stack.auto-=false

##Elaticsearch
spring.elasticsearch.uris=${ELASTICSEARCH_URL}
spring.elasticsearch.username=${ELASTICSEARCH_USERNAME}
spring.elasticsearch.password=${ELASTICSEARCH_PASSWORD}
spring.data.elasticsearch.repositories.enabled=false

spring.servlet.multipart.max-file-size=5MB
spring.servlet.multipart.max-request-size=5MB
```


## 3. 배포 시 특이사항 기재

### A. Letsencrypt 인증서 발급

### B. Nginx conf 

**nginx.conf**
```bash
       server {
                listen          80;
                server_name     {domain};
                return          301 https://$server_name$request_uri;
        }

        server {
                listen          443 ssl;
                server_name     {domain};

                ssl_certificate         /etc/letsencrypt/live/{domain}/fullchain.pem;
                ssl_certificate_key     /etc/letsencrypt/live/{domain}/privkey.pem;

                location /cctv {
                        proxy_pass      http://localhost:{포트번호};
                }

                location /camera {
                        proxy_pass      http://localhost:{포트번호};
                }
                location /socket.io {
                        proxy_pass              http://localhost:{포트번호};
                        proxy_set_header        Upgrade $http_upgrade;
                        proxy_set_header        Connection "upgrade";
                }
                location / {
                        proxy_pass      http://localhost:{포트번호};
                }
                location /icecream{
                        alias /home/ubuntu/icecream/;
                        try_files /icecream.apk =404;
                        add_header Content-Disposition 'attachment; filename="icecream.apk"';
                }
                location /admin {
                        proxy_pass      http://localhost:{포트번호};
                }
                location /kibana {
                        proxy_pass      http://localhost:{포트번호};
                }
                location /api {
                        proxy_pass      http://localhost:{포트번호};
                }
        }

```



### C. Docker

✅ EC2에 Docker 설치

✅ Docker Hub Login

### D. DB & MessageQueue Container

✅ Postgis Container 실행  
```$ docker run -d -p {외부포트}:{내부포트} -e POSTGRES_PASSWORD=vhtmxlr --name postgis postgis/postgis:16-3.4```  

✅ MongoDB 실행
```MongoDB는 클라우드 버전 사용``` 

✅ Redis Container 실행 
```sudo docker run -d -p {외부포트}:{내부포트} --name redis redis:7.2.4 --requirepass vhtmxlr```

✅ RabbitMQ Container 실행 
```docker run -d -p {외부포트}:{내부포트} -p {관리자 페이지 외부포트}:{관리자 페이지 내부포트} --name rabbitmq rabbitmq:3-management```

### E. Jenkins Container

✅ Jenkins Container 실행  

- 젠킨스 컨테이너가 도커를 사용할 수 있도록 볼륨 설정

```
$ sudo docker run -d -u root -v /var/run/docker.sock:/var/run/docker.sock \
-v /var/data/jenkins_home:/var/jenkins_home \
-v /home/ubuntu/flutter:/var/flutter \
-v /home/ubuntu/android-studio:/home/ubuntu/android-studio \
-v /home/ubuntu/icecream:/home/ubuntu/icecream \
-v $(which docker):/usr/bin/docker \
-p {외부포트}:{내부포트} --name jenkins jenkins/jenkins:latest --httpPort={내부포트}
```



### F. CI/CD

- **Jenkins PipeLine을 이용한 4개 서버 자동배포 수행**

1.  **SpringBoot Container**

   - Dockerfile

     ```docker
     # 1단계: 애플리케이션 빌드
     FROM gradle:8.7-jdk17 AS build
     WORKDIR /app
     
     # Gradle 빌드에 필요한 파일들 복사
     COPY build.gradle settings.gradle /app/
     COPY src /app/src
     
     # 빌드 수행
     RUN gradle build -x test --parallel --continue
     
     # 2단계: 실행 가능한 JAR 파일 빌드
     FROM openjdk:17.0.1
     
     # 서울 시간대로 설정
     ENV TZ=Asia/Seoul
     
     # 이전 단계에서 빌드된 JAR 파일을 복사
     COPY --from=build /app/build/libs/*.jar /app/
     RUN ls -al /app
     
     # JAR 파일의 이름 출력
     RUN ls /app/*.jar
     
     # 애플리케이션 실행
     ENTRYPOINT ["java","-jar","-Dspring.profiles.active=prod","/app/icecream-0.0.1-SNAPSHOT.jar"]
     ```
   - Jenkinsfile

     - EC2에 설치한 ffmpeg 실행파일 사용을 위해 볼륨 설정 

     ```groovy
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
     
             // 배포
             stage('Deploy BE') {
                 steps {
                     // 배포 관련 작업을 여기에 추가
                     echo 'Deploying Bank...'
                     // 빌드가 진행되면 기존의 컨테이너 중지 및 제거 & 컨테이너가 없어도 실패하지 않고계속 수행
                     sh 'docker stop icecream || true'
                     sh 'docker rm icecream || true'
                     // 백엔드 이미지 실행
                     sh 'docker run -d -p {외부포트}:{내부포트} --name icecream icecream'
                 }
             }
     
         }
     }
     ```

   

2. **CCTV Container**

   - Dockerfile

     ```dockerfile
     FROM node:20.10.0
     
     
     WORKDIR /usr/src/app
     
     COPY package*.json ./
     
     RUN npm install
     
     COPY . .
     
     CMD ["node", "server.ts"]
     ```

   - Jenkinsfile

     ```groovy
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
     
             // 배포
             stage('Deploy BE') {
                 steps {
                     echo 'Deploying BE...'
                     sh 'docker stop cctv || true'
                     sh 'docker rm cctv || true'
                     sh 'docker run -d -p {외부포트}:{내부포트} --name cctv cctv'
                 }
             }
         }
     }
     ```

   

3. **Admin Container**

   - Dockerfile

     ```dockerfile
     FROM node:20.11.0
     
     WORKDIR /usr/src/app
     
     COPY . .
     
     RUN npm install
     RUN npm run build
     
     ENTRYPOINT ["npm", "start"]
     ```

   - Jenkinsfile

     ```groovy
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
                     sh 'docker run -d -p {외부포트}:{내부포트} --name admin admin'
                 }
             }
         }
     }
     
     ```

   

4. **ElasticSearch, Logstash, Kibana Container**

   - docker-compose.yml

     ```yaml
     version: "3.7"
     services:
       elasticsearch:
         image: docker.elastic.co/elasticsearch/elasticsearch:7.10.2
         container_name: elasticsearch
         environment:
           - node.name=elasticsearch
           - cluster.name=docker-cluster
           - discovery.type=single-node
           - xpack.security.enabled=true
           - ELASTIC_USERNAME=${ELASTIC_USERNAME}
           - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
         ports:
           - {외부포트}:{내부포트}
           - {외부포트}:{내부포트}
         volumes:
           - esdata:/usr/share/elasticsearch/data
     
       kibana:
         image: docker.elastic.co/kibana/kibana:7.10.2
         container_name: kibana
         environment:
           - ELASTICSEARCH_HOSTS=http://elasticsearch:{포트번호}
           - ELASTICSEARCH_USERNAME=${ELASTIC_USERNAME}
           - ELASTICSEARCH_PASSWORD=${ELASTIC_PASSWORD}
         ports:
           - {외부포트}:{내부포트}
         depends_on:
           - elasticsearch
     
       logstash:
         image: docker.elastic.co/logstash/logstash:7.10.2
         container_name: logstash
         environment:
           - xpack.monitoring.enabled=true
           - xpack.monitoring.elasticsearch.username=${ELASTIC_USERNAME}
           - xpack.monitoring.elasticsearch.password=${ELASTIC_PASSWORD}
           - ELASTIC_USERNAME=${ELASTIC_USERNAME}
           - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
         ports:
           - {외부포트}:{내부포트}
           - {외부포트}:{내부포트}
         # volumes:
         # - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
         depends_on:
           - elasticsearch
     
       setup:
         image: curlimages/curl:7.73.0
         container_name: setup
         entrypoint: >
           sh -c "
           until curl -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -X PUT 'http://elasticsearch:{포트번호}/_template/default_template' -H 'Content-Type: application/json' -d @/usr/share/elasticsearch/config/index-template.json
           do
             echo 'Waiting for Elasticsearch...'
             sleep 5
           done"
         volumes:
           - ./index-template.json:/usr/share/elasticsearch/config/index-template.json
         depends_on:
           - elasticsearch
     
     volumes:
       esdata:
         driver: local
     
     ```

   - jenkinsfile
   
     ```groovy
     pipeline {
         agent any
     
         environment {
             HOME_PATH = '/home/ubuntu'
         }
     
         stages {
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
     
             stage('Deploy ELK') {
                 steps {
                     dir('ELK') {
                         echo 'Deploying ELK...'
                         sh 'docker-compose down || true'
                         sh 'docker-compose up -d'
                     }
                 }
                 
             }
     
         }
     }
     ```
   
     
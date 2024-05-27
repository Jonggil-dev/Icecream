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
# Importing a maven image for the builder
FROM maven:3.9.9-eclipse-temurin-17 as builder


# Setting up the working directory to /app
WORKDIR /app


# Copying  only pom first (for better Docker caching)
COPY pom.xml .

# Download dependencies first
RUN mvn dependency:go-offline


# Copying the source code from local to container
COPY src ./src

# Building the application and skipping the tests
RUN mvn clean package -DskipTests=true


# Exposing the port to 8080
EXPOSE 8080

# Starting the application
ENTRYPOINT [ "java" , "-jar" , "bankapp.jar" ]

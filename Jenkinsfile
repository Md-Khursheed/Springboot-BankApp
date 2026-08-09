pipeline {
    agent any

    environment {
        DOCKER_REPO = "mdkhursheed/bank-app"
    }

    stages {

        stage("Workspace Cleanup") {
            steps {
                cleanWs()
            }
        }

        stage("Checkout App Repo") {
            steps {
                git branch: 'main', url: 'https://github.com/Md-Khursheed/Springboot-BankApp.git'
            }
        }

        stage("Build Application") {
            steps {
                sh "mvn clean package -DskipTests"
            }
        }

        stage("SonarQube Scan") {
            steps {
                withSonarQubeEnv("Sonar") {
                    sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=bankapp \
                    -Dsonar.projectName=bankapp
                    '''
                }
            }
        }

        stage("Docker Build") {
            steps {
                sh "docker build -t $DOCKER_REPO:$BUILD_NUMBER ."
            }
        }

        stage("Trivy Scan") {
            steps {
                sh "trivy image --timeout 15m $DOCKER_REPO:$BUILD_NUMBER || true"
            }
        }

        stage("Push Image") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhubID',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push $DOCKER_REPO:$BUILD_NUMBER
                    '''
                }
            }
        }

        stage("Update GitOps Repo") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "githubID",
                    usernameVariable: "GIT_USER",
                    passwordVariable: "GIT_PASS"
                )]) {

                    sh '''
                    git clone https://$GIT_USER:$GIT_PASS@github.com/Md-Khursheed/Springboot-BankApp-GitOps.git
                    
                    cd Springboot-BankApp-GitOps/kubernetes/base
                    
                    sed -i "s|image: mdkhursheed/bank-app:.*|image: $DOCKER_REPO:$BUILD_NUMBER|" bankapp-deployment.yml
                    
                    git config user.name "Md-Khursheed"
                    git config user.email "2mdkhursheed@gmail.com"
                    
                    git add .
                    git commit -m "Update image to $BUILD_NUMBER" || echo "No changes"
                    
                    git push origin main
                    '''
                }
            }
        }
    }
}

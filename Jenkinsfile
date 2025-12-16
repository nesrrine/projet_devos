pipeline {
    agent any

    environment {
        IMAGE_NAME = "nesrineromd/projet_devos"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl get ns devops || kubectl create namespace devops

                kubectl apply -f mysql-deployment.yaml -n devops
                kubectl apply -f mysql-service.yaml -n devops

                kubectl apply -f springboot-deployment.yaml -n devops
                kubectl apply -f springboot-service.yaml -n devops
                '''
            }
        }

        stage('Wait for Pods Ready') {
            steps {
                sh 'kubectl wait --for=condition=ready pod -l app=springboot -n devops --timeout=180s'
            }
        }

        stage('Test API') {
            steps {
                sh '''
                echo "Application déployée avec succès 🎉"
                echo "Services disponibles :"
                kubectl get svc -n devops
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline CI/CD terminé avec succès'
        }
        failure {
            echo '❌ Pipeline échoué'
        }
    }
}

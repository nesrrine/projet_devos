pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/studentsapp"
        DOCKER_CREDENTIALS_ID = "dockerhub"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Récupération du code depuis Git"
                git branch: 'main', url: 'https://github.com/nesrrine/projet_devos.git'
            }
        }

        stage('Clean & Build') {
            steps {
                echo "Nettoyage et compilation du projet Maven"
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Construction de l'image Docker"
                    // Vérifie si Docker est disponible
                    sh 'docker --version'
                    // Build de l'image Docker avec tag
                    sh "docker build -t ${DOCKER_IMAGE}:latest ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Push de l'image Docker sur Docker Hub"
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", 
                                                     usernameVariable: 'DOCKER_USER', 
                                                     passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline terminée"
        }
        success {
            echo "Pipeline exécutée avec succès"
        }
        failure {
            echo "Pipeline échouée, vérifier les logs"
        }
    }
}

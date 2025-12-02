pipeline {
    agent any

    environment {
        // Nom de l'image Docker sur Docker Hub
        DOCKER_IMAGE = "nesrineromd/studentsapp"
        // Identifiant du credentials Docker Hub configuré dans Jenkins
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
                sh 'mvn clean install -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Construction de l'image Docker"
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Push de l'image Docker sur Docker Hub"
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        docker.image("${DOCKER_IMAGE}:latest").push()
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

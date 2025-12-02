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
                sh 'mvn clean package -DskipTests -B'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Vérification de Docker"
                    def dockerAvailable = sh(script: 'docker --version', returnStatus: true)
                    if (dockerAvailable != 0) {
                        error "Docker n'est pas installé ou n'est pas accessible par Jenkins."
                    }

                    echo "Construction de l'image Docker ${DOCKER_IMAGE}:latest"
                    def buildStatus = sh(script: "docker build -t ${DOCKER_IMAGE}:latest .", returnStatus: true)
                    if (buildStatus != 0) {
                        error "Erreur lors de la construction de l'image Docker."
                    }
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
                        def loginStatus = sh(script: "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin", returnStatus: true)
                        if (loginStatus != 0) {
                            error "Échec de la connexion à Docker Hub."
                        }

                        def pushStatus = sh(script: "docker push ${DOCKER_IMAGE}:latest", returnStatus: true)
                        if (pushStatus != 0) {
                            error "Erreur lors du push de l'image Docker."
                        }
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

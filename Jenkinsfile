pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<ton_utilisateur>/<ton_projet>.git'
            }
        }

        stage('Clean & Build') {
            steps {
                sh 'mvn clean install'  // ou gradle selon ton projet
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("ton_dockerhub_utilisateur/<nom_image>:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                        docker.image("ton_dockerhub_utilisateur/<nom_image>:latest").push()
                    }
                }
            }
        }
    }
}

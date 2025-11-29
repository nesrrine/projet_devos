pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/nesrrine/projet_devos.git'
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
                    docker.build("nesrineromd/projet_devos:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials-id') {
                        docker.image("nesrineromd/projet_devos:latest").push()
                    }
                }
            }
        }
    }
}

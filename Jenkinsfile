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
                sh 'mvn clean install -DskipTests'  // Compile le projet sans exécuter les tests
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("nesrineromd/studentsapp:latest")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                        docker.image("nesrineromd/studentsapp:latest").push()
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline terminée"
        }
    }
}

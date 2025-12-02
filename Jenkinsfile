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
                sh 'mvn clean install -DskipTests -B'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t nesrineromd/projet_devos:latest ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push nesrineromd/projet_devos:latest
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
    }
}

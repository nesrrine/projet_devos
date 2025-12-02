pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/projet_devos:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/nesrrine/projet_devos.git',
                    changelog: false, 
                    poll: false, 
                    shallow: true
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo \\$DOCKER_PASS | docker login -u \\$DOCKER_USER --password-stdin && docker push $DOCKER_IMAGE"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline terminée ✅"
        }
    }
}

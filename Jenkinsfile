pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/projet_devos"
        DOCKER_TAG = "latest"
    }

    stages {
        stage('Check Docker Image') {
            steps {
                script {
                    // Vérifie si l'image existe sur Docker Hub
                    def imageExists = sh(
                        script: "docker pull ${DOCKER_IMAGE}:${DOCKER_TAG} >/dev/null 2>&1 && echo 'true' || echo 'false'",
                        returnStdout: true
                    ).trim()

                    if (imageExists == "true") {
                        echo "Image Docker déjà existante, on ne rebuild pas."
                        currentBuild.result = 'SUCCESS'
                        // Définit une variable pour sauter les builds
                        env.SKIP_BUILD = "true"
                    } else {
                        echo "Image Docker non trouvée, build nécessaire."
                        env.SKIP_BUILD = "false"
                    }
                }
            }
        }

        stage('Clean & Build Maven') {
            when {
                expression { env.SKIP_BUILD != "true" }
            }
            steps {
                sh 'mvn clean install -DskipTests -B'
            }
        }

        stage('Build Docker Image') {
            when {
                expression { env.SKIP_BUILD != "true" }
            }
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo \\$DOCKER_PASS | docker login -u \\$DOCKER_USER --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """
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

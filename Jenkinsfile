pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/projet_devos"
    }

    stages {
        stage('Checkout') {
            steps {
                // Clone rapide, shallow clone pour gagner du temps
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: 'https://github.com/nesrrine/projet_devos.git']],
                          extensions: [[$class: 'CloneOption', shallow: true, depth: 1, noTags: false, reference: '', timeout: 10]]
                ])
            }
        }

        stage('Clean & Build') {
            steps {
                // Build Maven
                sh 'mvn clean install -DskipTests -B'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker avec tag unique par build
                    sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} ."
                    sh "docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    // Utilisation sécurisée des credentials Jenkins
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            # Login Docker de manière sécurisée
                            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                            
                            # Push image versionnée
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            
                            # Push latest
                            docker push ${DOCKER_IMAGE}:latest
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

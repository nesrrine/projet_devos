pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/projet_devos"
        DOCKER_TAG = "latest"
        KUBE_NAMESPACE = "devops"
        DEPLOYMENT_FILE = "springboot-deployment.yaml"
        SERVICE_NAME = "springboot-service"
        NODE_PORT = "32035" // remplacer par le port NodePort exposé dans ton YAML
        SERVER_IP = "192.168.49.2" // IP de ton Minikube ou serveur
    }

    stages {

        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: 'https://github.com/nesrrine/projet_devos.git']],
                          extensions: [[$class: 'CloneOption', shallow: true, depth: 1, noTags: false, timeout: 10]]
                ])
            }
        }

        stage('Check Docker Image') {
            steps {
                script {
                    def imageExists = sh(script: "docker image inspect ${DOCKER_IMAGE}:${DOCKER_TAG} > /dev/null 2>&1 || echo 'no'", returnStdout: true).trim()
                    env.BUILD_MAVEN = (imageExists == "no") ? "true" : "false"
                    echo "Build Maven needed? ${env.BUILD_MAVEN}"
                }
            }
        }

        stage('Build Maven Project') {
            when {
                expression { env.BUILD_MAVEN == "true" }
            }
            steps {
                sh 'mvn clean install -DskipTests -B'
            }
        }

        stage('Build Docker Image') {
            when {
                expression { env.BUILD_MAVEN == "true" }
            }
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                            docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        '''
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Vérifier si le namespace existe
                    def nsExists = sh(script: "kubectl get ns ${KUBE_NAMESPACE} > /dev/null 2>&1 && echo 'yes' || echo 'no'", returnStdout: true).trim()
                    if (nsExists == "no") {
                        echo "Création du namespace ${KUBE_NAMESPACE}"
                        sh "kubectl create namespace ${KUBE_NAMESPACE}"
                    } else {
                        echo "Namespace ${KUBE_NAMESPACE} déjà existant"
                    }

                    // Déployer le YAML
                    sh "kubectl apply -f ${DEPLOYMENT_FILE} -n ${KUBE_NAMESPACE}"

                    // Vérifier si le service existe déjà
                    def svcExists = sh(script: "kubectl get svc ${SERVICE_NAME} -n ${KUBE_NAMESPACE} > /dev/null 2>&1 && echo 'yes' || echo 'no'", returnStdout: true).trim()
                    if (svcExists == "yes") {
                        echo "Service ${SERVICE_NAME} déjà existant"
                    } else {
                        echo "Service ${SERVICE_NAME} créé automatiquement"
                    }

                    // Vérifier les pods
                    sh "kubectl get pods -n ${KUBE_NAMESPACE}"
                }
            }
        }

        stage('Wait for Pod Ready') {
            steps {
                script {
                    echo "Attente que le pod soit en Running..."
                    sh "kubectl wait --for=condition=ready pod -l app=springboot -n ${KUBE_NAMESPACE} --timeout=180s"
                }
            }
        }

        stage('Test API') {
            steps {
                script {
                    def serviceURL = "http://${SERVER_IP}:${NODE_PORT}"
                    echo "URL du service : ${serviceURL}"

                    def response = sh(script: "curl -s ${serviceURL}/student/Depatment/getAllDepartment", returnStdout: true).trim()
                    echo "Réponse API : ${response}"
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

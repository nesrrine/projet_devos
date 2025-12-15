pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/projet_devos"
        DOCKER_TAG = "latest"
        KUBE_NAMESPACE = "devops"
        DEPLOYMENT_FILE = "springboot-deployment.yaml"
        SERVICE_NAME = "springboot-service"
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
            when { expression { env.BUILD_MAVEN == "true" } }
            steps {
                sh 'mvn clean install -DskipTests -B'
            }
        }

        stage('Build Docker Image') {
            when { expression { env.BUILD_MAVEN == "true" } }
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
                    def nsExists = sh(script: "kubectl get ns ${KUBE_NAMESPACE} > /dev/null 2>&1 && echo 'yes' || echo 'no'", returnStdout: true).trim()
                    if (nsExists == "no") {
                        echo "Création du namespace ${KUBE_NAMESPACE}"
                        sh "kubectl create namespace ${KUBE_NAMESPACE}"
                    } else {
                        echo "Namespace ${KUBE_NAMESPACE} déjà existant"
                    }
                    sh "kubectl apply -f ${DEPLOYMENT_FILE} -n ${KUBE_NAMESPACE}"
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
                    def minikubeIP = sh(script: "minikube ip", returnStdout: true).trim()
                    def nodePort = sh(script: "kubectl get svc ${SERVICE_NAME} -n ${KUBE_NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}'", returnStdout: true).trim()
                    def serviceURL = "http://${minikubeIP}:${nodePort}/student/Depatment/getAllDepartment"
                    echo "URL du service : ${serviceURL}"

                    retry(3) {
                        sleep(time: 5, unit: 'SECONDS')
                        sh "curl -s --fail ${serviceURL}"
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

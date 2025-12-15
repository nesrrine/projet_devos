pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/projet_devos"
        DOCKER_TAG = "latest"
        KUBE_NAMESPACE = "devops"
        DEPLOYMENT_FILE = "springboot-deployment.yaml"
        SERVICE_NAME = "springboot-service"

        // SonarQube
        SONARQUBE_SERVER = "SonarQube"
        SONAR_PROJECT_KEY = "projet_devos"
        SONAR_HOST_URL = "http://sonarqube:9000" // ⚠️ PAS localhost
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir() // 🔥 nettoie le workspace
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/nesrrine/projet_devos.git']],
                    extensions: [
                        [$class: 'CloneOption', shallow: false, timeout: 20]
                    ]
                ])
            }
        }

        stage('Build Maven Project') {
            steps {
                sh 'mvn clean verify -B'
            }
        }

        // ✅ SonarQube – création automatique du projet
        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_AUTH_TOKEN')]) {
                    withSonarQubeEnv("${SONARQUBE_SERVER}") {
                        sh """
                        mvn sonar:sonar \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.projectName=${SONAR_PROJECT_KEY} \
                        -Dsonar.login=${SONAR_AUTH_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "kubectl get ns ${KUBE_NAMESPACE} || kubectl create ns ${KUBE_NAMESPACE}"
                    sh "kubectl apply -f ${DEPLOYMENT_FILE} -n ${KUBE_NAMESPACE}"
                }
            }
        }

        stage('Wait for Pod Ready') {
            steps {
                sh "kubectl wait --for=condition=ready pod -l app=springboot -n ${KUBE_NAMESPACE} --timeout=180s"
            }
        }

        stage('Test API') {
            steps {
                script {
                    def ip = sh(script: "minikube ip", returnStdout: true).trim()
                    def port = sh(
                        script: "kubectl get svc ${SERVICE_NAME} -n ${KUBE_NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}'",
                        returnStdout: true
                    ).trim()

                    sh "curl -f http://${ip}:${port}/student/Depatment/getAllDepartment"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline réussie"
        }
        failure {
            echo "❌ Pipeline échouée"
        }
    }
}

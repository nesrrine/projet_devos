pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "nesrineromd/projet_devos"
        DOCKER_TAG = "latest"
        KUBE_NAMESPACE = "devops"
        SERVICE_NAME = "springboot-service"
        DEPLOYMENT_FILE = "springboot-deployment.yaml"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[url: 'https://github.com/nesrrine/projet_devos.git']],
                          extensions: [[$class: 'CloneOption', shallow: true, depth: 1]]
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

        stage('Generate Kubernetes YAML') {
            steps {
                script {
                    echo "Création dynamique du YAML de déploiement..."
                    writeFile file: "${DEPLOYMENT_FILE}", text: """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: springboot-deployment
  namespace: ${KUBE_NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: springboot
  template:
    metadata:
      labels:
        app: springboot
    spec:
      containers:
      - name: springboot
        image: ${DOCKER_IMAGE}:${DOCKER_TAG}
        ports:
        - containerPort: 8089
        env:
        - name: SPRING_DATASOURCE_URL
          value: "jdbc:mysql://mysql-service:3306/mydb?createDatabaseIfNotExist=true"
        - name: SPRING_DATASOURCE_USERNAME
          value: "root"
        - name: SPRING_DATASOURCE_PASSWORD
          value: "root"
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${KUBE_NAMESPACE}
spec:
  selector:
    app: springboot
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8089
  type: NodePort
"""
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "kubectl apply -f ${DEPLOYMENT_FILE} -n ${KUBE_NAMESPACE}"
                    sh "kubectl get pods -n ${KUBE_NAMESPACE}"
                }
            }
        }

        stage('Wait for Pod Ready') {
            steps {
                script {
                    sh "kubectl wait --for=condition=ready pod -l app=springboot -n ${KUBE_NAMESPACE} --timeout=120s"
                }
            }
        }

        stage('Test API') {
            steps {
                script {
                    def serviceURL = sh(script: "minikube service ${SERVICE_NAME} -n ${KUBE_NAMESPACE} --url", returnStdout: true).trim()
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

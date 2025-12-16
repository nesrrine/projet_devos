pipeline {
    agent any
    environment {
        DOCKER_IMAGE   = "nesrineromd/projet_devos"
        DOCKER_TAG     = "latest"
        KUBE_NAMESPACE = "devops"
        APP_NAME       = "springboot"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/nesrrine/projet_devos.git'
            }
        }

        stage('Check Docker Image') {
            steps {
                script {
                    def imageExists = sh(
                        script: "docker image inspect ${DOCKER_IMAGE}:${DOCKER_TAG} > /dev/null 2>&1 || echo 'no'",
                        returnStdout: true
                    ).trim()
                    env.BUILD_MAVEN = (imageExists == "no") ? "true" : "false"
                    echo "Build Maven needed? ${env.BUILD_MAVEN}"
                }
            }
        }

        stage('Build Maven Project') {
            when { expression { env.BUILD_MAVEN == "true" } }
            steps { sh 'mvn clean install -DskipTests -B' }
        }

        stage('Build Docker Image') {
            when { expression { env.BUILD_MAVEN == "true" } }
            steps { sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ." }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def nsExists = sh(
                        script: "kubectl get ns ${KUBE_NAMESPACE} > /dev/null 2>&1 && echo yes || echo no",
                        returnStdout: true
                    ).trim()

                    if (nsExists == "no") {
                        echo "Création du namespace ${KUBE_NAMESPACE}"
                        sh "kubectl create namespace ${KUBE_NAMESPACE}"
                    } else {
                        echo "Namespace ${KUBE_NAMESPACE} déjà existant"
                    }

                    // Déploiement
                    sh """
                    kubectl apply -n ${KUBE_NAMESPACE} -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: ${DOCKER_IMAGE}:${DOCKER_TAG}
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}-service
spec:
  type: ClusterIP
  selector:
    app: ${APP_NAME}
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF
                    """
                }
            }
        }

        stage('Wait for Pod Ready') {
            steps {
                sh "kubectl wait --for=condition=ready pod -l app=${APP_NAME} -n ${KUBE_NAMESPACE} --timeout=180s"
            }
        }

        stage('Test API from Pod') {
            steps {
                script {
                    // Récupérer le nom du pod
                    def podName = sh(
                        script: "kubectl get pod -n ${KUBE_NAMESPACE} -l app=${APP_NAME} -o jsonpath='{.items[0].metadata.name}'",
                        returnStdout: true
                    ).trim()

                    // URL interne Kubernetes (ClusterIP)
                    def serviceURL = "http://${APP_NAME}-service:80/Depatment/getAllDepartment"
                    echo "Test API depuis le pod : ${podName} via URL interne Kubernetes ${serviceURL}"

                    // Test API depuis le pod
                    sh "kubectl exec -n ${KUBE_NAMESPACE} ${podName} -- curl -s --fail ${serviceURL}"
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

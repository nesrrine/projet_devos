# Utiliser Alpine comme base
FROM alpine:3.18

# Installer Java 17 et bash
RUN apk add --no-cache openjdk17 bash

# Définir le dossier de travail dans le conteneur
WORKDIR /app

# Copier le jar compilé dans le conteneur
COPY target/*.jar app.jar

# Exposer le port de l'application
EXPOSE 8080

# Commande pour démarrer Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]

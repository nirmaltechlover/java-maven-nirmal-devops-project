pipeline {

    agent any

    tools {
          
        maven 'maven3'
    }


    environment {
      image_name = "nirmaldocker1987/java-maven-project-dev"

    }


    stages {

        stage('Checkout the code') {
            steps {
                sh 'echo "Checking out the code from Github repository..."'
                git branch: 'main', url: 'https://github.com/nirmaltechlover/java-maven-nirmal-devops-project.git'
    }
}


        stage('Build the code') {
            steps {
                sh 'echo "Building the java code using maven..."'
                sh 'mvn clean compile'
    }
}

        stage('Unit testing the code') {
            steps {
                sh 'echo "Performing unit tests on the java code..."'
                sh 'mvn test'
    }
}
         stage('Code analysis using Sonarqube') {
            steps {
                sh 'echo "Performing the code analysis using Sonarqube..."'
                withSonarQubeEnv('sonarqube-server') {
                
                sh 'mvn sonar:sonar -Dsonar.projectKey=java-maven-nirmal-devops-project'

                }

         }

         }
            stage('Quality gate check') {
            steps {
                sh 'echo "Performing the quality gate check..."'

                timeout(time: 15, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                
            }
                
            }  
            
            stage('Building the artifact') {
            steps {
                sh 'echo "Building the artifact..."'

                sh 'mvn clean package'

                }
                
            }
            
            stage ('Building the image') {
                steps {
                    
                    
                    sh 'echo "Building the docker image........."'
                    sh "docker build -t ${image_name}:${BUILD_ID} ."
                    
                }
            }
            stage ('Image push to dockerhub') {
                steps {
                    
                    sh 'echo "Pushing the docker image to dockerhub........."'
                    withCredentials([usernamePassword(credentialsId: 'docker_cred', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                        sh 'echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin'
                        sh "docker push ${image_name}:${BUILD_ID}"
                        }
                    
                }
            }

            }

    }



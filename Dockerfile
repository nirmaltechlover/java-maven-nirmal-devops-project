#### Base image tomcat with openjdk

FROM tomcat:11-jdk17-temurin

#### cleaning of old webapps directory

RUN rm -rf /usr/local/tomcat/webapps/*


#### Then copy war directory to tomcat server
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war


#### open port 8080
EXPOSE 8080

####

CMD ["catalina.sh", "run"]

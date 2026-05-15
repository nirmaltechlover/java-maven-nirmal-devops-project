#### Base image tomcat with openjdk

FROM tomcat:9.0.118-jdk21

#### cleaning of old webapps directory




#### Then copy war directory to tomcat server
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war


#### open port 8080
EXPOSE 8080

####

CMD ["catalina.sh", "run"]

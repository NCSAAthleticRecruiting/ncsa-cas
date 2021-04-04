FROM tomcat:8.5.57-jdk11-openjdk

# set WORKDIR
WORKDIR /usr/local/tomcat/


#Cutomizing fasttrack deploy
RUN mkdir /usr/local/tomcat/webapps/cas
COPY cas.war /usr/local/tomcat/webapps/cas.war
RUN cd webapps/cas && jar -xf /usr/local/tomcat/webapps/cas.war
COPY .keystore /root/.keystore
COPY application.properties /usr/local/tomcat/webapps/cas/WEB-INF/classes/application.properties
COPY fasttrack-1.json /usr/local/tomcat/webapps/cas/WEB-INF/classes/fasttrack-1.json
COPY fasttrack-okta-metadata.xml /usr/local/tomcat/webapps/cas/WEB-INF/classes/fasttrack-okta-metadata.xml

RUN rm -rf /usr/local/tomcat/conf/server.xml
COPY server.xml /usr/local/tomcat/conf/server.xml

EXPOSE 8443
EXPOSE 8080
EXPOSE 443

CMD ["/usr/local/tomcat/bin/catalina.sh", "run"]

FROM tomcat:7-jre8-alpine

ENV RELEASE_VERSION 1.0
ENV DOCKERIZE_VERSION v0.6.0

ADD openmrs-runtime.properties /usr/local/tomcat/openmrs-runtime.properties
ADD setenv.sh /usr/local/tomcat/bin/setenv.sh
ADD logging.properties /usr/local/tomcat/conf/logging.properties
ADD catalina.properties /usr/local/tomcat/conf/catalina.properties
ADD server.xml /usr/local/tomcat/conf/server.xml
ADD localtime /etc/localtime

RUN apk --update add curl unzip; \
    rm -rf /usr/local/tomcat/webapps/*; \
#    curl -k -L https://bintray.com/isanteplus/clean-database/download_file?file_path=openmrs.war \
#    curl -k -L https://www.dropbox.com/s/2hko9ugxqqvv2rv/openmrs-2.0.5.war?dl=1 \
     curl -k -L https://www.dropbox.com/s/4tyt920fvpd7nwc/openmrs-2.0.5.war?dl=1 \
         -o /usr/local/tomcat/webapps/openmrs.war;


# RUN curl -k -L https://bintray.com/isanteplus/clean-database/download_file?file_path=modules.zip \
# RUN curl -k -L https://www.dropbox.com/s/w7qxda2c4aniqm7/modules.zip?dl=1 \
RUN curl -k -L https://www.dropbox.com/s/h6ngkw9bzatrlnd/modules.zip?dl=1 \
         -o /tmp/modules.zip; \
    unzip /tmp/modules.zip -d /root/.OpenMRS; \
    rm /tmp/modules.zip; \
    curl -k -L https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
         -o /tmp/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz; \
    tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz; \
    rm /tmp/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz; \
    apk del curl unzip && rm -f /var/cache/apk/*;

VOLUME /opt/isanteplus/data

CMD dockerize -wait tcp://isanteplus-platform-mysql:3306 -timeout 300s /usr/local/tomcat/bin/catalina.sh run

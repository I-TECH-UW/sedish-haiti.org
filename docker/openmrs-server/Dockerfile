FROM tomcat:7-jre8

# Take some initial steps to improve overall security, size, and functionality of the container
# This includes updating packages and removing all of the default Tomcat webapps

RUN apt-get update && apt-get install -y \
       zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/local/tomcat/webapps/*

RUN sed -i '/Connector port="8080"/a URIEncoding="UTF-8" relaxedPathChars="[]|" relaxedQueryChars="[]|{}^&#x5c;&#x60;&quot;&lt;&gt;"' /usr/local/tomcat/conf/server.xml

# All environment variables that are available to configure on this container are listed here
# for clarity.  These list the variables supported, and the default values if not overridden

# These environment variables are appended to configure the Tomcat JAVA_OPTS
ENV OMRS_JAVA_MEMORY_OPTS="-Xmx2048m -Xms1024m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:NewSize=128m"
ENV OMRS_JAVA_SERVER_OPTS="-Dfile.encoding=UTF-8 -server -Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -Djava.awt.headlesslib=true"

# These environment variables are used to create the openmrs-server.properties file, which controls how OpenMRS initializes
ENV OMRS_CONFIG_ADD_DEMO_DATA="false"
ENV OMRS_CONFIG_ADMIN_USER_PASSWORD="Admin123"
ENV OMRS_CONFIG_AUTO_UPDATE_DATABASE="false"
ENV OMRS_CONFIG_CONNECTION_DRIVER_CLASS="com.mysql.jdbc.Driver"
ENV OMRS_CONFIG_CONNECTION_USERNAME="openmrs"
ENV OMRS_CONFIG_CONNECTION_PASSWORD="openmrs"
ENV OMRS_CONFIG_CONNECTION_SERVER="db"
ENV OMRS_CONFIG_CONNECTION_PORT="3306"
ENV OMRS_CONFIG_CONNECTION_NAME="openmrs"
ENV OMRS_CONFIG_CONNECTION_ARGS="autoReconnect=true&sessionVariables=storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8"
ENV OMRS_CONFIG_CONNECTION_EXTRA_ARGS=""
ENV OMRS_CONFIG_CONNECTION_URL="jdbc:mysql://${OMRS_CONFIG_CONNECTION_SERVER}:${OMRS_CONFIG_CONNECTION_PORT}/${OMRS_CONFIG_CONNECTION_NAME}?${OMRS_CONFIG_CONNECTION_ARGS}${OMRS_CONFIG_CONNECTION_EXTRA_ARGS}"
ENV OMRS_CONFIG_CREATE_DATABASE_USER="false"
ENV OMRS_CONFIG_CREATE_TABLES="false"
ENV OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE="true"
ENV OMRS_CONFIG_INSTALL_METHOD="auto"
ENV OMRS_CONFIG_MODULE_WEB_ADMIN="true"

# These environment variables are meant to enable developer settings
ENV OMRS_DEV_DEBUG_PORT="1044"

# Additional environment variables as needed.  This should match the name of the distribution supplied OpenMRS war file
ENV OMRS_WEBAPP_NAME="openmrs"

# Set up volumes.
# /openmrs/distribution is expected to be mounted into the container with the artifacts making up the distribution
# /openmrs/data represents the data persisted inside the container to the filesystem for OpenMRS
VOLUME ["/openmrs/distribution", "/openmrs/data"]

# Copy in the start-up scripts
COPY wait-for-it.sh /usr/local/tomcat/wait-for-it.sh
COPY startup.sh /usr/local/tomcat/startup.sh
RUN chmod +x /usr/local/tomcat/wait-for-it.sh
RUN chmod +x /usr/local/tomcat/startup.sh

# Add Dockerfile and commit info for documentation
ADD Dockerfile /openmrs/docker

EXPOSE 8080

CMD ["/usr/local/tomcat/startup.sh"]

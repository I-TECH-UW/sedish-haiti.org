#!/bin/bash -eux

echo "Initiating OpenMRS startup"

# This startup script is responsible for fully preparing the OpenMRS Tomcat environment.

OMRS_HOME="/openmrs"

# A volume mount is expected that contains distribution artifacts.  The expected format is shown in these environment vars.

OMRS_DISTRO_DIR="$OMRS_HOME/distribution"
OMRS_DISTRO_WEBAPPS="$OMRS_DISTRO_DIR/openmrs_webapps"
OMRS_DISTRO_MODULES="$OMRS_DISTRO_DIR/openmrs_modules"
OMRS_DISTRO_OWAS="$OMRS_DISTRO_DIR/openmrs_owas"
OMRS_DISTRO_CONFIG="$OMRS_DISTRO_DIR/openmrs_config"

# Each of these mounted directories are used to populate expected configurations on the server, defined here

OMRS_DATA_DIR="$OMRS_HOME/data"
OMRS_MODULES_DIR="$OMRS_DATA_DIR/modules"
OMRS_OWA_DIR="$OMRS_DATA_DIR/owa"
OMRS_CONFIG_DIR="$OMRS_DATA_DIR/configuration"

OMRS_SERVER_PROPERTIES_FILE="$OMRS_HOME/openmrs-server.properties"

TOMCAT_DIR="/usr/local/tomcat"
TOMCAT_WEBAPPS_DIR="$TOMCAT_DIR/webapps"
TOMCAT_WORK_DIR="$TOMCAT_DIR/work"
TOMCAT_TEMP_DIR="$TOMCAT_DIR/temp"
TOMCAT_SETENV_FILE="$TOMCAT_DIR/bin/setenv.sh"

echo "Clearing out existing directories of any previous artifacts"

rm -fR $TOMCAT_WEBAPPS_DIR;
rm -fR $OMRS_MODULES_DIR;
rm -fR $OMRS_OWA_DIR
rm -fR $OMRS_CONFIG_DIR
rm -fR $TOMCAT_WORK_DIR
rm -fR $TOMCAT_TEMP_DIR

echo "Loading artifacts into appropriate locations"

cp -r $OMRS_DISTRO_WEBAPPS $TOMCAT_WEBAPPS_DIR
[ -d "$OMRS_DISTRO_MODULES" ] && cp -r $OMRS_DISTRO_MODULES $OMRS_MODULES_DIR
[ -d "$OMRS_DISTRO_OWAS" ] && cp -r $OMRS_DISTRO_OWAS $OMRS_OWA_DIR
[ -d "$OMRS_DISTRO_CONFIG" ] && cp -r $OMRS_DISTRO_CONFIG $OMRS_CONFIG_DIR

echo "Writing out $OMRS_SERVER_PROPERTIES_FILE"

cat > $OMRS_SERVER_PROPERTIES_FILE << EOF
add_demo_data=${OMRS_CONFIG_ADD_DEMO_DATA}
admin_user_password=${OMRS_CONFIG_ADMIN_USER_PASSWORD}
auto_update_database=${OMRS_CONFIG_AUTO_UPDATE_DATABASE}
connection.driver_class=${OMRS_CONFIG_CONNECTION_DRIVER_CLASS}
connection.username=${OMRS_CONFIG_CONNECTION_USERNAME}
connection.password=${OMRS_CONFIG_CONNECTION_PASSWORD}
connection.url=${OMRS_CONFIG_CONNECTION_URL}
create_database_user=${OMRS_CONFIG_CREATE_DATABASE_USER}
create_tables=${OMRS_CONFIG_CREATE_TABLES}
has_current_openmrs_database=${OMRS_CONFIG_HAS_CURRENT_OPENMRS_DATABASE}
install_method=${OMRS_CONFIG_INSTALL_METHOD}
module_web_admin=${OMRS_CONFIG_MODULE_WEB_ADMIN}
EOF

echo "Writing out $TOMCAT_SETENV_FILE file"

JAVA_OPTS="$OMRS_JAVA_SERVER_OPTS $OMRS_JAVA_MEMORY_OPTS"
CATALINA_OPTS="-DOPENMRS_INSTALLATION_SCRIPT=$OMRS_SERVER_PROPERTIES_FILE -DOPENMRS_APPLICATION_DATA_DIRECTORY=$OMRS_DATA_DIR/"

if [ ! -z "$OMRS_DEV_DEBUG_PORT" ]; then
  echo "Enabling debugging on port $OMRS_DEV_DEBUG_PORT"
  CATALINA_OPTS="$CATALINA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$OMRS_DEV_DEBUG_PORT"
fi

cat > $TOMCAT_SETENV_FILE << EOF
export JAVA_OPTS="$JAVA_OPTS"
export CATALINA_OPTS="$CATALINA_OPTS"
EOF

echo "Waiting for MySQL to initialize..."

/usr/local/tomcat/wait-for-it.sh --timeout=3600 ${OMRS_CONFIG_CONNECTION_SERVER}:3306

echo "Starting up OpenMRS..."

/usr/local/tomcat/bin/catalina.sh run &

# Trigger first filter to start data importation
sleep 15
curl -sL http://localhost:8080/$OMRS_WEBAPP_NAME/ > /dev/null
sleep 15

# bring tomcat process to foreground again
wait ${!}

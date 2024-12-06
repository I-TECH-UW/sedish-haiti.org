#!/bin/bash
set -e

# This script runs during the MySQL initialization phase, thanks to docker-entrypoint.sh.
# It uses the following ENV variables:
#   - OPENMRS_DB_COUNT 
#   - INITIAL_SQL_FILE
#   - MYSQL_ROOT_PASSWORD
#   - OMRS_CONFIG_CONNECTION_USERNAME_1
#   - OMRS_CONFIG_CONNECTION_PASSWORD_1

# For each database "openmrsN":
# 1. CREATE DATABASE openmrsN
# 2. CREATE USER 'openmrsN'@'%' IDENTIFIED BY 'dev_password_only'
# 3. GRANT ALL PRIVILEGES ON openmrsN.* TO 'openmrsN'@'%'
# 4. Load INITIAL_SQL_FILE into openmrsN
# 5. FLUSH PRIVILEGES

if [ -z "$OPENMRS_DB_COUNT" ]; then
  # set default
  OPENMRS_DB_COUNT=1
fi

if [ -z "$INITIAL_SQL_FILE" ]; then

  echo "INITIAL_SQL_FILE not set. Please provide the path to the SQL dump file."
  exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "MYSQL_ROOT_PASSWORD is not set."
  exit 1
fi

for i in $(seq 1 "$OPENMRS_DB_COUNT"); do


  if [ "$i" -eq 1 ]; then
    db="openmrs"
  else
    db="openmrs$i"
  fi
  
  # Check if user variable is set
  if [ -z "$OMRS_CONFIG_CONNECTION_USERNAME_1" ]; then
    user="$OMRS_CONFIG_CONNECTION_USERNAME_1"
  else
    user="$db"
  fi

  if [ -z "$OMRS_CONFIG_CONNECTION_PASSWORD_1" ]; then
    password="$OMRS_CONFIG_CONNECTION_PASSWORD_1"
  else
    password="dev_password_only"
  fi

  echo "Creating database: $db"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$db\`;"

  echo "Creating user '$user' with password '$password'"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$user'@'%' IDENTIFIED BY '$password';"

  echo "Granting privileges to '$user' on $db"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON \`$db\`.* TO '$user'@'%'; FLUSH PRIVILEGES;"

  echo "Loading initial dump into $db from $INITIAL_SQL_FILE"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$db" < "$INITIAL_SQL_FILE"
done

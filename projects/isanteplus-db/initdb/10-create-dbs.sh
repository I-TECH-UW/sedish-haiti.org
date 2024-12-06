#!/bin/bash
set -e

# This script runs during the MySQL initialization phase, thanks to docker-entrypoint.sh.
# It uses OPENMRS_DB_COUNT and INITIAL_SQL_FILE from environment variables.
# For each database "openmrsN":
# 1. CREATE DATABASE openmrsN
# 2. CREATE USER 'openmrsN'@'%' IDENTIFIED BY 'dev_password_only'
# 3. GRANT ALL PRIVILEGES ON openmrsN.* TO 'openmrsN'@'%'
# 4. Load INITIAL_SQL_FILE into openmrsN
# 5. FLUSH PRIVILEGES

if [ -z "$OPENMRS_DB_COUNT" ]; then
  # set default
  OPENMRS_DB_COUNT=10
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
  
  user="$db"
  password="dev_password_only"

  echo "Creating database: $db"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$db\`;"

  echo "Creating user '$user' with password '$password'"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$user'@'%' IDENTIFIED BY '$password';"

  echo "Granting privileges to '$user' on $db"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL ON \`$db\`.* TO '$user'@'%'; FLUSH PRIVILEGES;"

  echo "Loading initial dump into $db from $INITIAL_SQL_FILE"
  mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$db" < "$INITIAL_SQL_FILE"
done

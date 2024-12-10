FROM mysql:5.7.44

# Set working directory for initialization scripts
WORKDIR /docker-entrypoint-initdb.d

# Copy initialization files into the container
COPY ./initdb/isanteplus-db.sql /docker-entrypoint-initdb.d/initial.dump
COPY ./initdb/10-create-dbs.sh /docker-entrypoint-initdb.d/10-initdb.sh

# Set permissions to ensure scripts and dumps are executable/readable
RUN chmod 644 /docker-entrypoint-initdb.d/initial.dump && \
    chmod +x /docker-entrypoint-initdb.d/10-initdb.sh

# Expose MySQL ports
EXPOSE 3306 33060

# Use the base image entrypoint and command
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]

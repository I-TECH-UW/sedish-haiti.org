FROM mysql:5.6

ENV MYSQL_ROOT_PASSWORD=1nT31i2o
ENV MYSQL_DATABASE=openmrs
ENV MYSQL_USER=isanteplus
ENV MYSQL_PASSWORD=Admin123
ENV MYSQL_DATA_DIRECTORY=/opt/isanteplus/data/system/mysql

ADD isanteplus-mysql.cnf /root/.my.cnf
ADD backup /usr/bin/backup
ADD localtime /etc/localtime

RUN chmod 0444 /root/.my.cnf

RUN apt-get update && apt-get install -y \
    curl \
    zip \
    unzip \
# && curl -L https://bintray.com/isanteplus/clean-database/download_file?file_path=Dump20190331.sql.zip \
&& curl -L https://www.dropbox.com/s/v0608qqtw1u1lk2/isante_db_dev_20200504.zip?dl=1  \
    -o /tmp/isante_db_dump.sql.zip \
&& apt-get remove -y \
   curl 

COPY run.sh /run.sh

VOLUME /opt/isanteplus/data

EXPOSE 3306

CMD ["/run.sh"]

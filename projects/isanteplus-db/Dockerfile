FROM debian:buster-slim

# Add our user and group first to make sure their IDs get assigned consistently
RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update && apt-get install -y --no-install-recommends gnupg dirmngr && rm -rf /var/lib/apt/lists/*

# Install gosu for easy step-down from root
ENV GOSU_VERSION 1.14
RUN set -eux; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates wget; \
    rm -rf /var/lib/apt/lists/*; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    chmod +x /usr/local/bin/gosu; \
    gosu --version; \
    gosu nobody true

RUN mkdir /docker-entrypoint-initdb.d

# Install required packages for MySQL and initialization
RUN apt-get update && apt-get install -y --no-install-recommends \
    pwgen \
    openssl \
    perl \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Add MySQL APT repository and import GPG key
ENV MYSQL_MAJOR 5.7
ENV MYSQL_VERSION 5.7.42-1debian10
RUN set -ex; \
    key='859BE8D7C586F538430B19C2467B942D3A79BD29'; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
    gpg --batch --export "$key" > /etc/apt/trusted.gpg.d/mysql.gpg; \
    gpgconf --kill all; \
    rm -rf "$GNUPGHOME"; \
    apt-key list > /dev/null; \
    echo 'deb http://repo.mysql.com/apt/debian/ buster mysql-5.7' > /etc/apt/sources.list.d/mysql.list

# Install MySQL server
RUN { \
        echo mysql-community-server mysql-community-server/data-dir select ''; \
        echo mysql-community-server mysql-community-server/root-pass password ''; \
        echo mysql-community-server mysql-community-server/re-root-pass password ''; \
        echo mysql-community-server mysql-community-server/remove-test-db select false; \
    } | debconf-set-selections \
    && apt-get update \
    && apt-get install -y mysql-server="${MYSQL_VERSION}" \
    && find /etc/mysql/ -name '*.cnf' -print0 \
        | xargs -0 grep -lZE '^(bind-address|log)' \
        | xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/' \
    && echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    && chmod 1777 /var/run/mysqld /var/lib/mysql

VOLUME /var/lib/mysql

# Copy your docker-entrypoint.sh script (adjust path as needed)
COPY ./resources/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

EXPOSE 3306 33060

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]

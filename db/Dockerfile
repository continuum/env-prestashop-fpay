FROM mysql:5.7.15

ENV MYSQL_DATABASE=prestashop \
    MYSQL_ROOT_PASSWORD=admin

ADD script.sql /docker-entrypoint-initdb.d

EXPOSE 3306

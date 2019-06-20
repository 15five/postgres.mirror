FROM postgres:11-alpine

COPY init.sh /docker-entrypoint-initdb.d/init.sh

CMD ["postgres", "-D", "/var/lib/postgresql/data/datarep"]


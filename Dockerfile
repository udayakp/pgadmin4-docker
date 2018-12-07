#FROM python:2-alpine3.7

#ENV PGADMIN_VERSION=3.0 \
#    PYTHONDONTWRITEBYTECODE=1

## Install postgresql tools for backup/restore
#RUN apk add --no-cache postgresql \
# && cp /usr/bin/psql /usr/bin/pg_dump /usr/bin/pg_dumpall /usr/bin/pg_restore /usr/local/bin/ \
# && apk del postgresql

#RUN apk add --no-cache alpine-sdk postgresql-dev \
# && pip install --upgrade pip \
# && echo "https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN_VERSION}/pip/pgadmin4-${PGADMIN_VERSION}-py2.py3-none-any.whl" | pip install --no-cache-dir -r /dev/stdin \
# && apk del alpine-sdk \
# && addgroup -g 50 -S pgadmin \
# && adduser -D -S -h /pgadmin -s /sbin/nologin -u 1000 -G pgadmin pgadmin \
# && mkdir -p /pgadmin/config /pgadmin/storage \
# && chown -R 1000:50 /pgadmin

#EXPOSE 5050

#COPY LICENSE config_distro.py /usr/local/lib/python2.7/site-packages/pgadmin4/

#USER pgadmin:pgadmin
#CMD ["python", "./usr/local/lib/python2.7/site-packages/pgadmin4/pgAdmin4.py"]
#VOLUME /pgadmin/
##############

FROM python:3.6-alpine

# runtime dependencies
RUN set -ex \
	&& apk add --no-cache --virtual .pgadmin4-rundeps \
		bash \
		postgresql

ENV PGADMIN4_VERSION 3.0
ENV PGADMIN4_DOWNLOAD_URL https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v3.0/pip/pgadmin4-3.0-py2.py3-none-any.whl

# Metadata
LABEL org.label-schema.name="pgAdmin4" \
      org.label-schema.version="$PGADMIN4_VERSION" \
      org.label-schema.license="PostgreSQL" \
      org.label-schema.url="https://www.pgadmin.org" \
      org.label-schema.vcs-url="https://github.com/fenglc/dockercloud-pgAdmin4"

RUN set -ex \
	&& apk add --no-cache --virtual .build-deps \
		gcc \
		musl-dev \
		postgresql-dev \
	&& pip --no-cache-dir install \
		$PGADMIN4_DOWNLOAD_URL \
	&& apk del .build-deps

VOLUME /var/lib/pgadmin

COPY docker-entrypoint.sh /usr/local/bin/
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5050
CMD ["pgadmin4"]

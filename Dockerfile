# Dockerfile for Grafana
# Grafana latest (4.x)

# Build with:
# docker build -t "grafana" .

# Alpine OS 3.4
# http://dl-cdn.alpinelinux.org/alpine/v3.4/community/x86_64/
FROM alpine:3.4

MAINTAINER Tuan Vo <vohungtuan@gmail.com>

###############################################################################
#                                INSTALLATION
###############################################################################

### install gosu 1.9 for easy step-down from root
ENV GOSU_VERSION 1.9

RUN set -x \
  && apk --no-cache add openssl \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true
 
### install Grafana

ENV GRAFANA_URL https://grafanarel.s3.amazonaws.com/builds/grafana-latest.linux-x64.tar.gz
ENV GRAFANA_HOME /opt/grafana
ENV GRAFANA_PACKAGE grafana-latest.linux-x64.tar.gz

RUN set -x \
 && mkdir -p /opt/tmp/ \
 && mkdir -p ${GRAFANA_HOME}/ \
 && wget -O /opt/tmp/$GRAFANA_PACKAGE $GRAFANA_URL \
 && apk --no-cache --update add tar \
 && tar xfz /opt/tmp/$GRAFANA_PACKAGE --strip-components=1 -C $GRAFANA_HOME \
 && rm /opt/tmp/$GRAFANA_PACKAGE \
 && addgroup grafana \
 && adduser -D -S grafana -s /bin/bash -h ${GRAFANA_HOME} -g "Grafana service user" -G grafana \
 && mkdir -p /var/log/grafana \
 && mkdir -p /var/lib/grafana \
 && chown -R grafana:grafana ${GRAFANA_HOME} /var/log/grafana /var/lib/grafana

###############################################################################
#                                   START
###############################################################################

# 3000 (Grafana web interface).
EXPOSE 3000

VOLUME /var/lib/grafana

ENV PATH ${GRAFANA_HOME}/bin:$PATH
WORKDIR ${GRAFANA_HOME}

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
 && ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["grafana-server", "web"]

# Remove tmp
RUN find /opt/tmp/ -type f | xargs rm -f

# Run with:
# docker run -p 3000:3000 -d --name grafanaContainer grafana
# docker logs -f $(docker run -p 3000:3000 -d --name grafanaContainer grafana)
# docker run -p 3000:3000 -d --link elasticsearchContainer:elasticsearch --name grafanaContainer grafana

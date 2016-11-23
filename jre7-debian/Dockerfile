#
# Base image for ceylon/ceylon images
#
FROM java:7-jre

MAINTAINER Tako Schotanus <tako@ceylon-lang.org>

ENV LANG=en_US.utf8 \
    HOME=/app \
    JAVA_OPTS=-Duser.home=/app

LABEL org.ceylon-lang.dockerfile.description="Base image for ceylon/ceylon images" \
    org.ceylon-lang.dockerfile.vendor="RedHat" \
    org.ceylon-lang.dockerfile.version="1.2"

USER root

RUN apt-get -y update && \
    apt-get -y install apt-transport-https less vim nodejs sudo && \
    wget -O - https://downloads.ceylon-lang.org/apt/ceylon-debian-repo.gpg.key | apt-key add - && \
    echo "deb https://downloads.ceylon-lang.org/apt/ unstable main" > /etc/apt/sources.list.d/ceylon.list && \
    apt-get clean && \
    useradd -u 1000 -r -g 0 -d ${HOME} -s /usr/sbin/nologin -c "Ceylon Application User" ceylon && \
    mkdir -p ${HOME}/.ceylon/cache && \
    chown -R 1000:0 ${HOME} && \
    chmod -R ug+rwx ${HOME}

USER 1000

WORKDIR /app


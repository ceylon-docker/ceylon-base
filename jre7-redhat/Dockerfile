#
# Base image for ceylon/ceylon images
#
FROM jboss/base-jdk:7

MAINTAINER Tako Schotanus <tako@ceylon-lang.org>

ENV LANG=en_US.utf8 \
    HOME=/app \
    JAVA_OPTS=-Duser.home=/app

LABEL org.ceylon-lang.dockerfile.description="Base image for ceylon/ceylon images" \
    org.ceylon-lang.dockerfile.vendor="RedHat" \
    org.ceylon-lang.dockerfile.version="1.2"

USER root

RUN yum install -y yum-utils wget less vim nodejs sudo && \
    wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-ceylon https://downloads.ceylon-lang.org/rpm/ceylon-rpm-repo.gpg.key && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-ceylon && \
    yum-config-manager --add-repo https://downloads.ceylon-lang.org/rpm/ceylon.repo && \
    yum clean all && \
    userdel -rf jboss && \
    useradd -u 1000 -r -g 0 -d ${HOME} -s /usr/sbin/nologin -c "Ceylon Application User" ceylon && \
    mkdir -p ${HOME}/.ceylon/cache && \
    chown -R 1000:0 ${HOME} && \
    chmod -R ug+rwx ${HOME}

USER 1000

WORKDIR /app


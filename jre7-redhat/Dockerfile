#
# Base image for ceylon/ceylon images
#
FROM jboss/base-jdk:7

MAINTAINER Tako Schotanus <tako@ceylon-lang.org>

ENV LANG=en_US.utf8

LABEL org.ceylon-lang.dockerfile.description="Base image for ceylon/ceylon images" \
    org.ceylon-lang.dockerfile.vendor="RedHat" \
    org.ceylon-lang.dockerfile.version="1.0"

USER root

RUN yum install -y yum-utils wget less vim nodejs && \
    wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-ceylon https://downloads.ceylon-lang.org/rpm/ceylon-rpm-repo.gpg.key && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-ceylon && \
    yum-config-manager --add-repo https://downloads.ceylon-lang.org/rpm/ceylon.repo && \
    yum clean all && \
    userdel -rf jboss && \
    groupadd -r ceylon -g 1000 && \
    useradd -u 1000 -m -s /usr/sbin/nologin -g ceylon -d /app ceylon && \
    mkdir -p /app/.ceylon/cache && \
    chown -R ceylon:ceylon /app && \
    chmod -R 755 /app

USER ceylon

WORKDIR /app

#!/bin/bash

set -e

# Define which JRE versions to generate for
JRES=(7 8)

# Define the default JRE
DEFAULT_JRE=8

# Define default platform
DEFAULT_PLATFORM="debian"

# The base name of the images to create
IMAGE=docker.io/ceylon/ceylon-base

BUILD=0
PULL=0
PUSH=0
CLEAN=0
VERBOSE=0
QUIET=-q
for arg in "$@"; do
    case "$arg" in
        --help)
            echo "Usage: $0 [--help] [--pull] [--build] [--push] [--clean] [--verbose]"
            echo ""
            echo "   --help    : shows this help text"
            echo "   --pull    : pulls any previously existing images from Docker Hub"
            echo "   --build   : runs 'docker build' for each image"
            echo "   --push    : pushes each image to Docker Hub"
            echo "   --clean   : removes local images"
            echo "   --verbose : show more information while running docker commands"
            echo ""
            exit
            ;;
        --build)
            BUILD=1
            ;;
        --pull)
            PULL=1
            ;;
        --push)
            PUSH=1
            ;;
        --clean)
            CLEAN=1
            ;;
        --verbose)
            VERBOSE=1
            QUIET=
            ;;
    esac
done

function error() {
    local MSG=$1
    [[ ! -z $MSG ]] && echo $MSG
    exit 1
}

function build_dir() {
    local VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_dir()"
    local FROM=$2
    [[ -z $FROM ]] && error "Missing 'from' parameter for build_dir()"
    local NAME=$3
    [[ -z $NAME ]] && error "Missing 'name' parameter for build_dir()"
    local DOCKERFILE=$4
    [[ -z $DOCKERFILE ]] && error "Missing 'dockerfile' parameter for build_dir()"
    shift 4
    local TAGS=("$@")

    echo "Building image $NAME with tags ${TAGS[@]} ..."
    rm -rf /tmp/docker-ceylon-build-templates
    mkdir /tmp/docker-ceylon-build-templates
    cp templates/$DOCKERFILE /tmp/docker-ceylon-build-templates/Dockerfile
    sed -i "s/@@FROM@@/${FROM//\//\\/}/g" /tmp/docker-ceylon-build-templates/Dockerfile
    sed -i "s/@@VERSION@@/$VERSION/g" /tmp/docker-ceylon-build-templates/Dockerfile
    mkdir -p "$NAME"
    pushd "$NAME" > /dev/null
    cp /tmp/docker-ceylon-build-templates/* .
    rm -rf /tmp/docker-ceylon-build-templates
    if [[ $PULL -eq 1 ]]; then
        echo "Pulling existing image from Docker Hub (if any)..."
        if [[ $VERBOSE -eq 1 ]]; then
            docker pull "$FROM" || true
            docker pull "${IMAGE}:$NAME" || true
        else
            docker pull "$FROM" > /dev/null || true
            docker pull "${IMAGE}:$NAME" > /dev/null || true
        fi
    fi
    if [[ $BUILD -eq 1 ]]; then
        echo "Building image..."
        docker build -t "${IMAGE}:$NAME" $QUIET .
    fi
    for t in ${TAGS[@]}; do
        [[ $BUILD -eq 1 ]] && docker tag "${IMAGE}:$NAME" "${IMAGE}:$t"
    done
    if [[ $CLEAN -eq 1 ]]; then
        echo "Removing image..."
        docker rmi "${IMAGE}:$NAME"
        for t in ${TAGS[@]}; do
            docker rmi "${IMAGE}:$t"
        done
    fi
    popd > /dev/null
}

function build_normal() {
    local VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_normal_onbuild()"
    local FROM=$2
    [[ -z $FROM ]] && error "Missing 'from' parameter for build_normal_onbuild()"
    local JRE=$3
    [[ -z $JRE ]] && error "Missing 'jre' parameter for build_normal_onbuild()"
    local PLATFORM=$4
    [[ -z $PLATFORM ]] && error "Missing 'platform' parameter for build_normal_onbuild()"
    shift 4
    local TAGS=("$@")

    echo "Building for JRE $JRE with tags ${TAGS[@]} ..."

    local NAME="$JRE-$PLATFORM"
    build_dir $VERSION $FROM $NAME "Dockerfile.$PLATFORM" "${TAGS[@]}"
}

function build_jres() {
    local VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build_jres()"
    local FROM_TEMPLATE=$2
    [[ -z $FROM_TEMPLATE ]] && error "Missing 'from_template' parameter for build_jres()"
    local JRE_TEMPLATE=$3
    [[ -z $JRE_TEMPLATE ]] && error "Missing 'jre_template' parameter for build_jres()"
    local PLATFORM=$4
    [[ -z $PLATFORM ]] && error "Missing 'platform' parameter for build_jres()"

    echo "Building for platform $PLATFORM ..."

    for t in ${JRES[@]}; do
        local FROM=${FROM_TEMPLATE/@/$t}
        local JRE=${JRE_TEMPLATE/@/$t}
        local TAGS=()
        build_normal $VERSION $FROM $JRE $PLATFORM "${TAGS[@]}"
    done
}

function build() {
    local VERSION=$1
    [[ -z $VERSION ]] && error "Missing 'version' parameter for build()"

    echo "Building version $VERSION ..."

    build_jres $VERSION "java:@-jre" "jre@" "debian"
    build_jres $VERSION "jboss/base-jdk:@" "jre@" "redhat"
}

build "dummy"

[[ $PUSH -eq 1 ]] && echo "Pushing image to Docker Hub..." && docker push "${IMAGE}"


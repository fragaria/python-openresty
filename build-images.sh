#!/bin/bash

# kudos https://dev.to/zeerorg/build-multi-arch-docker-images-on-travis-5428

echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

# Build for amd64 and push
buildctl build --frontend dockerfile.v0 \
            --local dockerfile=. \
            --local context=. \
            --output type=image,name=docker.io/fragaria/python-openresty:test-build-amd64,push=true \
            --opt platform=linux/amd64 \
            --opt filename=./Dockerfile


# Build for armhf and push
buildctl build --frontend dockerfile.v0 \
            --local dockerfile=. \
            --local context=. \
            --output type=image,name=docker.io/fragaria/python-openresty:test-build-armhf,push=true \
            --opt platform=linux/armhf \
            --opt filename=./Dockerfile


export DOCKER_CLI_EXPERIMENTAL=enabled

# Create manifest list and push that
docker manifest create fragaria/python-openresty:test-build \
            fragaria/python-openresty:test-build-amd64 \
            fragaria/python-openresty:test-build-armhf

docker manifest annotate fragaria/python-openresty:test-build fragaria/python-openresty:test-build-armhf --arch arm
docker manifest annotate fragaria/python-openresty:test-build fragaria/python-openresty:test-build-amd64 --arch amd64

docker manifest push fragaria/python-openresty:test-build

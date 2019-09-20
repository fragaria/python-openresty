#!/bin/bash

# kudos https://dev.to/zeerorg/build-multi-arch-docker-images-on-travis-5428

echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USER" --password-stdin

# Build for amd64 and push
buildctl build --frontend dockerfile.v0 \
            --local dockerfile=. \
            --local context=. \
            --output type=image,name=docker.io/fragaria/python-openresty:1.15.8-amd64,push=true \
            --opt platform=linux/amd64 \
            --opt filename=./Dockerfile


# Build for armhf and push
buildctl build --frontend dockerfile.v0 \
            --local dockerfile=. \
            --local context=. \
            --output type=image,name=docker.io/fragaria/python-openresty:1.15.8-armhf,push=true \
            --opt platform=linux/armhf \
            --opt filename=./Dockerfile


export DOCKER_CLI_EXPERIMENTAL=enabled

# Create manifest list and push that
# 1.15.8
docker manifest create fragaria/python-openresty:1.15.8 \
            fragaria/python-openresty:1.15.8-amd64 \
            fragaria/python-openresty:1.15.8-armhf

docker manifest annotate fragaria/python-openresty:1.15.8 fragaria/python-openresty:1.15.8-armhf --arch arm
docker manifest annotate fragaria/python-openresty:1.15.8 fragaria/python-openresty:1.15.8-amd64 --arch amd64

docker manifest push fragaria/python-openresty:1.15.8

# latest

docker tag fragaria/python-openresty:1.15.8 fragaria/python-openresty:latest
docker tag fragaria/python-openresty:1.15.8-armhf fragaria/python-openresty:latest-armhf
docker tag fragaria/python-openresty:1.15.8-amd64 fragaria/python-openresty:latest-amd64

docker push fragaria/python-openresty:latest
docker push fragaria/python-openresty:latest-armhf
docker push fragaria/python-openresty:latest-amd64

docker manifest create fragaria/python-openresty:latest \
            fragaria/python-openresty:latest-amd64 \
            fragaria/python-openresty:latest-armhf

docker manifest annotate fragaria/python-openresty:latest fragaria/python-openresty:latest-armhf --arch arm
docker manifest annotate fragaria/python-openresty:latest fragaria/python-openresty:latest-amd64 --arch amd64

docker manifest push fragaria/python-openresty:latest

# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM ruby:slim

WORKDIR /app

RUN  apt-get -y -qq update \
  && apt-get -y -qq upgrade \
  && apt-get -y install curl \
  && apt-get -y install python-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# docker
RUN  curl -fsSL get.docker.com | sh

# aws-cli, aws-sam-cli
RUN  pip install awscli \
  && pip install aws-sam-cli

# aws-cli 用にダミーファイル作っておく
RUN  mkdir /root/.aws \
  && echo '[default]\n' > /root/.aws/config \
  && echo '[default]\n' > /root/.aws/credentials

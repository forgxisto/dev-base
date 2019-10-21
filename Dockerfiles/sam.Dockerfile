# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM ruby:slim

WORKDIR /app

RUN  apt -y update \
  && apt -y full-upgrade \
  && apt -y install curl \
  && apt -y install python-pip \
  && apt -y autoremove \
  && apt -y clean \
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

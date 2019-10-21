# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM node:slim

WORKDIR /app

RUN  apt -y update \
  && apt -y full-upgrade \
  && apt -y install build-essential \
  && apt -y install git \
  && apt -y install libpng-dev \
  && apt -y install python-pip \
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# aws-cli
RUN  pip install awscli

# aws-cli 用にダミーファイル作っておく
RUN  mkdir /root/.aws \
  && echo '[default]\n' > /root/.aws/config \
  && echo '[default]\n' > /root/.aws/credentials

# グローバルに置いておきたいパッケージ
RUN  npm -g config set user root \
  && npm -g install gatsby-cli \
  && npm -g install @aws-amplify/cli

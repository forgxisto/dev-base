# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM node:slim

WORKDIR /app

ENV GOPATH=/go
ENV PATH="${PATH}:${GOPATH}/bin"

RUN  apt -y update \
  && apt -y full-upgrade \
  && apt -y install build-essential \
  && apt -y install git \
  && apt -y install libpng-dev \
  && apt -y install vim \
  && apt -y install tmux \
  && apt -y install golang \
  && apt -y install python-pip \
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# aws-cli
RUN  pip install awscli

# aws-cli 用にダミーファイル作っておく
RUN  mkdir ~/.aws \
  && echo '[default]\n' > ~/.aws/config \
  && echo '[default]\n' > ~/.aws/credentials

# overmind
RUN go get golang.org/dl/go1.15 \
  && go1.15 download \
  && GO111MODULE=on go1.15 get -u github.com/DarthSim/overmind/v2

# グローバルに置いておきたいパッケージ
RUN  yarn global add gatsby-cli \
  && yarn global add typesync \
  && yarn global upgrade --latest

# amplify cli は npm でインストールしないと問題がある・・・
# Refs https://github.com/aws-amplify/amplify-cli/issues/3439
RUN  npm -g config set user root \
  && npm install -g @aws-amplify/cli

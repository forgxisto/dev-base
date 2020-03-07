# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM ruby:2.7-slim

WORKDIR /app

RUN  apt -y update \
  && apt -y full-upgrade \
  && apt -y install locales locales-all \
  && apt -y install build-essential \
  && apt -y install curl \
  && apt -y install file \
  && apt -y install git \
  && apt -y install python-pip \
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# docker
RUN curl -fsSL get.docker.com | sh

# linuxbrew
RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
RUN mkdir ~/.linuxbrew/bin
RUN ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin

ENV PATH $PATH:/root/.linuxbrew/bin:/root/.linuxbrew/sbin${PATH}

# aws-cli
RUN pip install awscli

# aws-sam-cli
RUN brew tap aws/tap \
  && brew install aws-sam-cli

# aws-cli 用にダミーファイル作っておく
RUN  mkdir ~/.aws \
  && echo '[default]\n' > ~/.aws/config \
  && echo '[default]\n' > ~/.aws/credentials

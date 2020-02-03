# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM ruby:slim

WORKDIR /app

RUN  apt -y update \
  && apt -y full-upgrade \
  && apt -y install locales locales-all \
  && apt -y install build-essential \
  && apt -y install curl \
  && apt -y install file \
  && apt -y install git \
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
RUN echo 'export PATH="/root/.linuxbrew/bin:/root/.linuxbrew/sbin${PATH+:$PATH}"' >> ~/.bashrc

# aws-cli, aws-sam-cli
RUN ~/.linuxbrew/bin/brew tap aws/tap \
  && ~/.linuxbrew/bin/brew install awscli \
  && ~/.linuxbrew/bin/brew install aws-sam-cli

# aws-cli 用にダミーファイル作っておく
RUN  mkdir ~/.aws \
  && echo '[default]\n' > ~/.aws/config \
  && echo '[default]\n' > ~/.aws/credentials

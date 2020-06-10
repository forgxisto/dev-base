# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

FROM ruby:slim

WORKDIR /app

ENV GOPATH=/go
ENV PATH="${PATH}:${GOPATH}/bin"

RUN apt -y update \
  && apt -y full-upgrade \
  && apt -y install locales locales-all \
  && apt -y install build-essential \
  && apt -y install curl \
  && apt -y install file \
  && apt -y install git \
  && apt -y install libsqlite3-dev \
  && apt -y install libpq-dev \
  && apt -y install default-mysql-client \
  && apt -y install vim \
  && apt -y install tmux \
  && apt -y install golang \
  && apt -y install python-pip \
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# linuxbrew
RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
RUN mkdir ~/.linuxbrew/bin
RUN ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
ENV PATH $PATH:/root/.linuxbrew/bin:/root/.linuxbrew/sbin${PATH}

# aws-cli
RUN pip install awscli

# aws-cli 用にダミーファイル作っておく
RUN  mkdir ~/.aws \
  && echo '[default]\n' > ~/.aws/config \
  && echo '[default]\n' > ~/.aws/credentials

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt -y install nodejs

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt -y update \
  && apt -y install yarn

# overmind
# RUN GO111MODULE=on go get -u github.com/DarthSim/overmind/v2

# エイリアスの代わり
RUN echo '#!/bin/bash\nbundle exec $*' >> /usr/bin/bex \
  && chmod +x /usr/bin/bex

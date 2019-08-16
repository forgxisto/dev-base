# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

FROM ruby:slim

WORKDIR /app

ENV GOPATH=/go
ENV PATH="${PATH}:${GOPATH}/bin"

RUN apt-get -y -qq update \
  && apt-get -y -qq upgrade \
  && apt-get -y install curl \
  && apt-get -y install build-essential \
  && apt-get -y install git \
  && apt-get -y install libsqlite3-dev \
  && apt-get -y install libpq-dev \
  && apt-get -y install mysql-client \
  && apt-get -y install vim \
  && apt-get -y install tmux \
  && apt-get -y install golang \
  && apt-get -y install python-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# aws-cli
RUN  pip install awscli

# aws-cli 用にダミーファイル作っておく
RUN mkdir /root/.aws \
  && echo '[default]\n' > /root/.aws/config \
  && echo '[default]\n' > /root/.aws/credentials

# node
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get -y install nodejs

# overmind
RUN go get -u -f github.com/DarthSim/overmind

# エイリアスの代わり
RUN echo '#!/bin/bash\nbundle exec $*' >> /usr/bin/bex \
  && chmod +x /usr/bin/bex

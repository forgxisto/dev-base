# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

FROM ruby:slim

WORKDIR /app

ENV GOPATH=/go
ENV PATH="${PATH}:${GOPATH}/bin"

RUN apt -y update \
  && apt -y full-upgrade \
  && apt -y install build-essential \
  && apt -y install git \
  && apt -y install curl \
  && apt -y install libsqlite3-dev \
  && apt -y install libpq-dev \
  && apt -y install mysql-client \
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
RUN mkdir /root/.aws \
  && echo '[default]\n' > /root/.aws/config \
  && echo '[default]\n' > /root/.aws/credentials

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt -y install nodejs

# overmind
RUN go get -u -f github.com/DarthSim/overmind

# エイリアスの代わり
RUN echo '#!/bin/bash\nbundle exec $*' >> /usr/bin/bex \
  && chmod +x /usr/bin/bex

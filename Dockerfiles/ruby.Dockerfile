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
  && apt-get -y install nodejs \
  && apt-get -y install vim \
  && apt-get -y install tmux \
  && apt-get -y install golang \
  && apt-get -y install python3

# aws-cli
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip3 install awscli

# overmind
RUN go get -u -f github.com/DarthSim/overmind

# エイリアスの代わり
RUN echo '#!/bin/bash\nbundle exec $*' >> /usr/bin/bex \
  && chmod +x /usr/bin/bex

# aws-cli 用にダミーファイル作っておく
RUN mkdir /root/.aws \
  && echo '[default]\n' > /root/.aws/config \
  && echo '[default]\n' > /root/.aws/credentials

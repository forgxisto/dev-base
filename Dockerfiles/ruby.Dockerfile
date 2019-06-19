# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

FROM ruby:slim

WORKDIR /app

ENV GOPATH=/go

RUN apt-get -y -qq update \
  && apt-get -y -qq upgrade \
  && apt-get -y install build-essential \
  && apt-get -y install git \
  && apt-get -y install libsqlite3-dev \
  && apt-get -y install libpq-dev \
  && apt-get -y install mysql-client \
  && apt-get -y install nodejs \
  && apt-get -y install vim \
  && apt-get -y install tmux \
  && apt-get -y install golang

# overmind
RUN go get -u -f github.com/DarthSim/overmind

# エイリアス
RUN echo 'alias bex="bundle exec"' >> ~/.bashrc

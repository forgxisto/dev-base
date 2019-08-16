# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

FROM ruby:slim

WORKDIR /app

ENV GOPATH=/go
ENV PATH="${PATH}:${GOPATH}/bin"

RUN apt-get -y -qq update \
  && apt-get -y -qq upgrade \
  && apt-get -y install curl \
  && apt-get -y install python-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# aws-cli
RUN  pip install awscli \
  && pip install boto3

# aws-cli 用にダミーファイル作っておく
RUN mkdir /root/.aws \
  && echo '[default]\n' > /root/.aws/config \
  && echo '[default]\n' > /root/.aws/credentials

# nodeとグローバルインストールするパッケージ
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get -y install nodejs \
  && npm -g config set user root \
  && npm -g install serverless

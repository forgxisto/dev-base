# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

FROM ruby:slim

WORKDIR /app

ENV GOPATH=/go
ENV PATH="${PATH}:${GOPATH}/bin"

RUN apt -y update \
  && apt -y full-upgrade \
  && apt -y install curl \
  && apt -y install python-pip \
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# aws-cli
RUN  pip install awscli \
  && pip install boto3

# aws-cli 用にダミーファイル作っておく
RUN mkdir ~/.aws \
  && echo '[default]\n' > ~/.aws/config \
  && echo '[default]\n' > ~/.aws/credentials

# Node.js
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt -y install nodejs

# nodeとグローバルインストールするパッケージ
RUN npm -g config set user root \
  && npm -g install serverless

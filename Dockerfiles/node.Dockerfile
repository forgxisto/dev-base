# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM node:slim

WORKDIR /app

RUN apt-get -y -qq update \
  && apt-get -y -qq upgrade \
  && apt-get -y install build-essential \
  && apt-get -y install git \
  && apt-get -y install libpng-dev \
  && apt-get -y install python3

# aws-cli
RUN curl -kL https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip3 install awscli

# aws-cli 用にダミーファイル作っておく
RUN mkdir /root/.aws \
  && echo '[default]\n' > /root/.aws/config \
  && echo '[default]\n' > /root/.aws/credentials

# グローバルに置いておきたいパッケージ
RUN npm install --global gatsby-cli \
  && npm install --global @aws-amplify/cli \
  && npm install --global serverless

# https://github.com/nodejs/docker-node/blob/master/README.md#how-to-use-this-image
# https://hub.docker.com/_/node/

FROM node:alpine

RUN npm install -g dynamodb-admin

# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

ARG RUBY_VERSION
ARG DISTRO_NAME=bullseye

FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME AS base

ARG DISTRO_NAME

# Common dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=tmpfs,target=/var/log \
  apt -y update \
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
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* && \
  truncate -s 0 /var/log/*log

# Install NodeJS and Yarn
ARG NODE_MAJOR
ARG YARN_VERSION
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=tmpfs,target=/var/log \
  curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash - \
  && apt -y install nodejs
RUN npm install -g yarn@$YARN_VERSION

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

# Store Bundler settings in the project's root
ENV BUNDLE_APP_CONFIG=.bundle

WORKDIR /app

EXPOSE 3000
CMD ["/usr/bin/bash"]

# ================================================= For development
FROM base AS development

ENV RAILS_ENV=development

# ================================================= For production
FROM base AS production

ENV RAILS_ENV=production

COPY ../App/ruby/ ./
RUN bundle install --quiet --jobs=${BUNDLE_JOBS}
RUN yarn --check-files --silent && yarn cache clean

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
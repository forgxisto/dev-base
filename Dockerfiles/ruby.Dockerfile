# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

ARG RUBY_VERSION
ARG DISTRO_NAME=bookworm

FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME AS base

ARG DISTRO_NAME

# Common dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=tmpfs,target=/var/log \
  apt -y update \
  && apt -y full-upgrade \
  && apt -y install build-essential \
    locales locales-all \
    build-essential \
    curl \
    file \
    git \
    libsqlite3-dev \
    libpq-dev \
    default-mysql-client \
    vim \
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
FROM base AS production-builder

ENV RAILS_ENV=production

# Copy source
COPY ../App/ruby/ ./
# Build source
RUN bundle install --quiet --jobs=${BUNDLE_JOBS}
RUN yarn --check-files --silent && yarn cache clean
RUN bundle exec rails assets:precompile

FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME AS production

# Production-only dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  --mount=type=tmpfs,target=/var/log \
  apt -y update \
  && apt -y full-upgrade \
  && apt -y install build-essential \
    curl \
    tzdata \
    time \
    locales \
  && update-locale LANG=C.UTF-8 LC_ALL=C.UTF-8

# Upgrade RubyGems and install the latest Bundler version
RUN gem update --system && \
    gem install bundler

ENV RAILS_ENV=production

EXPOSE 3000

# Copy source
COPY ../App/ruby/ ./
# Copy artifacts
COPY --from=production-builder $BUNDLE_PATH $BUNDLE_PATH

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# http://docs.docker.jp/compose/rails.html
# https://hub.docker.com/r/library/ruby/

ARG RUBY_VERSION
ARG DISTRO_NAME=bookworm

FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME AS base

WORKDIR /app

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  BUNDLE_APP_CONFIG=.bundle

# Common dependencies
RUN apt -y update \
  && apt -y full-upgrade \
  && apt -y install build-essential \
    curl \
    git \
    libsqlite3-dev \
    libpq-dev \
    default-mysql-client \
    locales \
    vim \
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* \
  && truncate -s 0 /var/log/*log

# Install NodeJS and Yarn
ARG NODE_MAJOR
ARG YARN_VERSION
RUN curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash - \
  && apt -y install nodejs \
  && npm install -g yarn@$YARN_VERSION

EXPOSE 3000
CMD ["/bin/bash"]

# ================================================= For development
FROM base AS development

ENV RAILS_ENV=development

# ================================================= For production
FROM base AS production-builder

WORKDIR /app

ENV RAILS_ENV=production

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  BUNDLE_PATH=/app/vendor/bundle

# Copy source
COPY ../App/ruby/ .
# Build source
RUN bundle install --quiet --jobs=${BUNDLE_JOBS}
RUN yarn --check-files --silent && yarn cache clean
RUN bundle exec rails assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

FROM ruby:$RUBY_VERSION-slim-$DISTRO_NAME AS production

WORKDIR /app

ENV RAILS_ENV=production

# Configure bundler
ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  BUNDLE_PATH=/app/vendor/bundle

# Production-only dependencies
RUN apt -y update \
  && apt -y full-upgrade \
  && apt -y install tzdata \
    locales \
  && apt -y autoremove \
  && apt -y clean \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* \
  && truncate -s 0 /var/log/*log \
  && update-locale LANG=C.UTF-8 LC_ALL=C.UTF-8

# Upgrade RubyGems and install the latest Bundler version
RUN gem update --system && \
    gem install bundler

# Copy source
COPY ../App/ruby .
# Copy artifacts
COPY --from=production-builder $BUNDLE_PATH $BUNDLE_PATH
COPY --from=production-builder /app/public /app/public

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

#################################
#          Build Stage          #
#################################

FROM ruby:2.7 AS build

ARG BUILD_PACKAGES="git libicu-dev libpq-dev nodejs npm"
ARG BUILD_SCRIPT="npm install -g npm && \
                  npm install -g yarn && \
                  yarn set version 1.22.10"
ARG BUNDLE_WITHOUT="development:metrics:test"
ARG BUNDLER_VERSION="2.2.17"
ARG POST_BUILD_SCRIPT="bin/rails assets:precompile"
ARG SKIP_MEMCACHE_CHECK="true"
ARG RAILS_ENV="production"
ARG SECRET_KEY_BASE="thisneedstobeset"

# Set build shell
SHELL ["/bin/bash", "-c"]

# Use root user
USER root

# Install dependencies
RUN    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y ${BUILD_PACKAGES}

RUN [[ ${BUILD_SCRIPT} ]] && bash -c "${BUILD_SCRIPT}"

# Install specific versions of dependencies
RUN gem install bundler:${BUNDLER_VERSION} --no-document

# TODO: Load artifacts

COPY ./Gemfile ./Gemfile.lock /app-src/
WORKDIR /app-src

# Run deployment
RUN    bundle config set --local deployment 'true' \
    && bundle config set --local without ${BUNDLE_WITHOUT} \
    && bundle package \
    && bundle install \
    && bundle clean

# set up app-src directory
COPY . /app-src

RUN [[ ${POST_BUILD_SCRIPT} ]] && bash -c "${POST_BUILD_SCRIPT}"

# TODO: Save artifacts

RUN rm -rf vendor/cache/ .git

#################################
#           Run Stage           #
#################################

# This image will be replaced by Openshift
FROM ruby:2.7-slim AS app

# Set runtime shell
SHELL ["/bin/bash", "-c"]

# Add user
RUN adduser --disabled-password --uid 1001 --gid 0 --gecos "" app
RUN adduser --disabled-password --uid 1002 --gid 0 --gecos "" clamav

ARG BUNDLE_WITHOUT='development:metrics:test'
ARG BUNDLER_VERSION=2.2.17
ARG RUN_PACKAGES="clamav clamav-daemon git graphicsmagick libicu-dev libpq5 nodejs poppler-utils"
ARG PS1="\\h:\\w\\$"
ENV PS1=$PS1
ARG TZ="Europe/Zurich"
ENV TZ=$TZ

# Install dependencies, remove apt!
RUN    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y ${RUN_PACKAGES} \
       vim-tiny curl

# Copy deployment ready source code from build
COPY --from=build /app-src /app-src
COPY docker/ /
WORKDIR /app-src

# Set group permissions to app folder
RUN    mkdir /var/run/clamav \
    && chgrp -R 0 /app-src \
                  /var/log/clamav \
                  /var/lib/clamav \
                  /var/run/clamav \
                  /run/clamav \
    && chmod -R u+w,g=u /app-src \
                        /var/log/clamav \
                        /var/lib/clamav \
                        /var/run/clamav \
                        /run/clamav \
    && freshclam


ENV HOME=/app-src

# Use cached gems
RUN    bundle config set --local deployment 'true' \
    && bundle config set --local without ${BUNDLE_WITHOUT} \
    && bundle

USER 1000

CMD ["bundle", "exec", "puma", "-t", "8"]

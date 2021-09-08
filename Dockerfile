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
RUN adduser --disabled-password --uid 1001 --gid 0 --gecos "" --shell /bin/bash app
# RUN adduser --disabled-password --uid 1002 --gid 0 --gecos "" clamav

ARG BUNDLE_WITHOUT='development:metrics:test'
ARG BUNDLER_VERSION=2.2.17
# ARG RUN_PACKAGES="clamav clamav-daemon git graphicsmagick libicu-dev libpq5 nodejs poppler-utils"
ARG PS1="\\h:\\w\\$"
ENV PS1=$PS1
ARG TZ="Europe/Zurich"
ENV TZ=$TZ

# Install dependencies, remove apt!
RUN    echo "a4" > /etc/papersize
RUN    touch /etc/papersize.dpkg-inst
RUN    chmod a+rw /etc/papersize.dpkg-inst
RUN    chmod a+x /etc
RUN    export DEBIAN_FRONTEND=noninteractive
RUN    apt-get update
RUN    apt-get upgrade -y
RUN    apt-get -y install clamav
RUN    apt-get -y install clamav-daemon
RUN    apt-get -y install git
RUN    apt-get download libpaper1
RUN    dpkg --unpack libpaper1*.deb
RUN    rm /var/lib/dpkg/info/libpaper1\:amd64.postinst
RUN    dpkg --configure libpaper1
RUN    apt-get install -yf
RUN    rm libpaper1*.deb
RUN    apt-get -y install graphicsmagick
RUN    apt-get -y install libicu-dev
RUN    apt-get -y install libpq5
RUN    apt-get -y install nodejs
RUN    apt-get -y install poppler-utils
# && apt-get -y \
#            -o Dpkg::Options::="--force-overwrite" \
#            -o Dpkg::Options::="--force-confdef" \
#            -o Dpkg::Options::="--force-confold" \
#            install ${RUN_PACKAGES} vim-tiny curl \
RUN usermod -a -G 0 clamav

# Copy deployment ready source code from build
COPY --from=build /app-src /app-src
COPY docker/ /
WORKDIR /app-src

# Set group permissions to app folder and help clamav to start
RUN    mkdir /var/run/clamav \
    && chown clamav /run/clamav \
    && sed -i 's/^chown/# chown/' /etc/init.d/clamav-daemon \
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

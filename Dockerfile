FROM ruby:2.5.1-slim
MAINTAINER Valter Nepomuceno <valter.nep@gmail.com>

ENV APP_HOME /usr/src/app
ENV LANG=C.UTF-8
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
ARG BUNDLE_GITHUB__COM

RUN set -x \
    && BUILD_DEPENDENCIES='build-essential git' \
    && RUNTIME_DEPENDENCIES='curl libpq-dev' \
    && NPROC=$(nproc --all) \
    && apt-get update \
    && apt-get install -y --force-yes ${BUILD_DEPENDENCIES} ${RUNTIME_DEPENDENCIES} \
    && gem install bundler \
    && bundle install -j${NPROC} \
    && apt-get purge -y --force-yes ${BUILD_DEPENDENCIES} \
    && apt-get autoremove -y --force-yes \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ENV DOCKERIZE_VERSION v0.2.0
RUN curl -L -X GET https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar xz -C /usr/local/bin/
RUN cp Gemfile.lock Gemfile.lock.tmp

COPY . $APP_HOME

RUN cp Gemfile.lock.tmp Gemfile.lock

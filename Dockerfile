FROM ruby:2.5.9-slim-buster AS base

ENV BUNDLER_VERSION=2.1.4
ENV RAILS_LOG_TO_STDOUT=true

RUN echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list && \
  apt-get -y update && \
  apt-get -y install --no-install-recommends apt-transport-https curl gnupg libpq5 shared-mime-info && \
  (curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null) && \
  (echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list) && \
  apt-get -y update && \
  apt-get -y install --no-install-recommends helm && \
  apt-get clean && \
  rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  gem install bundler -v "$BUNDLER_VERSION" && \
  rm -rvf /usr/local/bundle/cache/*.gem && \
  useradd -mU -d /app app
WORKDIR /app

ARG RAILS_ENV=production
ARG RACK_ENV=production
ENV RAILS_ENV=${RAILS_ENV}
ENV RACK_ENV=${RACK_ENV}

FROM base AS build

RUN apt-get -y update && \
  apt-get install -y --no-install-recommends build-essential libpq-dev nodejs make && \
  rm -rvf /var/lib/apt/lists/*
USER app

COPY --chown=app:app Gemfile* ./
RUN bundle config --local deployment 'true' && \
  bundle config --local without $(echo 'development test' | sed "s/\\s*$RAILS_ENV\\s*//g") && \
  bundle install -j4 --retry 3 && \
  rm -rvf /usr/local/bundle/ruby/*/cache/*.gem && \
  find /usr/local/bundle -name "*.c" -delete && \
  find /usr/local/bundle -name "*.o" -delete

ENV DB_NAME=barito_production
ARG NODE_ENV=${RAILS_ENV}
ENV NODE_ENV=${NODE_ENV}

COPY --chown=app:app . .
RUN mv config/application.yml.example config/application.yml && \
  mv config/database.yml.example config/database.yml && \
  mv config/tps_config.yml.example config/tps_config.yml && \
  SECRET_KEY_BASE=$(printf %128s | tr ' ' '0') bundle exec rails assets:precompile && \
  rm -rvf node_modules tmp/cache vendor/assets spec

FROM base
USER app

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=app:app --from=build /app .
ENTRYPOINT ["bundle", "exec"]
CMD ["puma", "--port", "8080"]

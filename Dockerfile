FROM ruby:3.1.2-alpine

ENV BUNDLER_VERSION=2.3.15

RUN apk add --update --no-cache \
      binutils-gold \
      build-base \
      curl \
      file \
      g++ \
      gcc \
      git \
      less \
      libstdc++ \
      libffi-dev \
      libc-dev \
      linux-headers \
      libxml2-dev \
      libxslt-dev \
      libgcrypt-dev \
      make \
      mariadb-dev \
      mysql-client \
      netcat-openbsd \
      nodejs \
      openssl \
      pkgconfig \
      python3 \
      tzdata \
      yarn

RUN gem install bundler -v 2.3.15

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle config build.nokogiri --use-system-libraries

RUN bundle check || bundle install

COPY . ./

ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]

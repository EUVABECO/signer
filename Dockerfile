FROM ruby:3.3.3-alpine as base
LABEL maintainer="developers@mesvaccins.net"
# === Install GEMS === #

RUN apk update && apk add --no-cache build-base
RUN gem update --system \
  && gem install bundler:2.3.3 --no-document

EXPOSE 3000
WORKDIR /app

COPY . /app

RUN bundle config set --local path '/vendor'
RUN bundle config set --local without 'development test'
RUN bundle install --jobs 4

ENV RUBYOPT '--yjit-disable --yjit-exec-mem-size=128'

CMD ["bundle", "exec", "falcon", "serve", "-c", "config.ru", "-b", "http://0.0.0.0", "--port", "3000", "-n", "1"]

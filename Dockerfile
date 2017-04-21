FROM ruby:2.4-slim
RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends curl git make gcc ruby-dev && \
  apt-get clean autoclean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

ENV APP_ROOT /var/www/tree-planter
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
ADD Gemfile* $APP_ROOT/
RUN bundle install --jobs=3 --without development
ADD . $APP_ROOT
COPY config-example.json $APP_ROOT/config.json

EXPOSE 80
CMD ["bundle", "exec", "passenger", "start", "--port", "80"]

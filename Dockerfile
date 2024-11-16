FROM ruby:3.3

ENV APP_HOME /app
ENV UPSTREAM_BASE_URL http://host.docker.internal:3456

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY Gemfile Gemfile.lock $APP_HOME/

RUN bundle install

COPY . $APP_HOME

EXPOSE 4567
# Start the Sinatra app
CMD ["ruby", "proxy.rb"]

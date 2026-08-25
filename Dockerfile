FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    git \
    curl \
  && rm -rf /var/lib/apt/lists/*

ARG UID=1000
ARG GID=1000
RUN groupadd --gid "$GID" app \
  && useradd --uid "$UID" --gid "$GID" --create-home --shell /bin/bash app \
  && mkdir -p /usr/local/bundle \
  && chown -R "$UID:$GID" /usr/local/bundle

WORKDIR /app

COPY --chown=app:app Gemfile Gemfile.lock ./
USER app
RUN bundle install

COPY --chown=app:app . .

COPY entrypoint.sh /usr/bin/
USER root
RUN chmod +x /usr/bin/entrypoint.sh
USER app
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]

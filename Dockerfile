# syntax=docker/dockerfile:1

FROM node:22-bookworm-slim AS assets
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json ./frontend/
WORKDIR /app/frontend
RUN npm ci
COPY frontend/ ./
WORKDIR /app
COPY priv ./priv
WORKDIR /app/frontend
RUN npm run build

FROM elixir:1.18-otp-27 AS build
RUN apt-get update && apt-get install -y --no-install-recommends build-essential git \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /app
ENV MIX_ENV=prod LANG=C.UTF-8
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
COPY config config
COPY lib lib
COPY priv priv
COPY --from=assets /app/priv/static ./priv/static
RUN mix compile && mix release

FROM debian:bookworm-slim AS app
RUN apt-get update && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses6 ca-certificates \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN useradd --create-home app
COPY --from=build --chown=app:app /app/_build/prod/rel/doski ./
COPY rel/docker-entrypoint.sh /app/bin/server
RUN chmod +x /app/bin/server
USER app
ENV PHX_SERVER=true LANG=C.UTF-8
EXPOSE 4000
ENTRYPOINT ["/app/bin/server"]

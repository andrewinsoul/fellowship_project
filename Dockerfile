# Build the umbrella release with matching Elixir and Erlang versions.
ARG ELIXIR_VERSION=1.20.4
ARG OTP_VERSION=29.0.6
ARG DEBIAN_VERSION=bookworm-20261005-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

RUN apt-get update -y && \
    apt-get install -y build-essential git && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"

# Copy the umbrella project, including each child application's source,
# dependencies, static files, and release overlays.
COPY . .

RUN mix deps.get --only "$MIX_ENV" && \
    mix deps.compile && \
    mix compile && \
    mix release fellowship_api

FROM ${RUNNER_IMAGE} AS runner

RUN apt-get update -y && \
    apt-get install -y \
        libstdc++6 \
        openssl \
        libncurses6 \
        locales \
        ca-certificates && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US:en"
ENV LC_ALL="en_US.UTF-8"
ENV MIX_ENV="prod"

WORKDIR /app
RUN chown nobody /app

COPY --from=builder --chown=nobody:root \
    /app/_build/prod/rel/fellowship_api ./

USER nobody

CMD ["/app/bin/server"]

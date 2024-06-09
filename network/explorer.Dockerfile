FROM hexpm/elixir:1.14.5-erlang-24.2.2-alpine-3.18.2 AS builder

WORKDIR /app

ENV MIX_ENV="prod"

RUN apk --no-cache --update add alpine-sdk gmp-dev automake libtool inotify-tools autoconf python3 file gcompat

RUN set -ex && apk --update add libstdc++ curl ca-certificates gcompat

ARG CACHE_EXCHANGE_RATES_PERIOD
ARG API_V1_READ_METHODS_DISABLED
ARG DISABLE_WEBAPP
ARG API_V1_WRITE_METHODS_DISABLED
ARG CACHE_TOTAL_GAS_USAGE_COUNTER_ENABLED
ARG ADMIN_PANEL_ENABLED
ARG CACHE_ADDRESS_WITH_BALANCES_UPDATE_INTERVAL
ARG SESSION_COOKIE_DOMAIN
ARG MIXPANEL_TOKEN
ARG MIXPANEL_URL
ARG AMPLITUDE_API_KEY
ARG AMPLITUDE_URL
ARG CHAIN_TYPE
ENV CHAIN_TYPE=${CHAIN_TYPE}
ARG BRIDGED_TOKENS_ENABLED
ENV BRIDGED_TOKENS_ENABLED=${BRIDGED_TOKENS_ENABLED}
ARG MUD_INDEXER_ENABLED
ENV MUD_INDEXER_ENABLED=${MUD_INDEXER_ENABLED}

# Cache elixir deps
RUN git clone --depth 1 --branch=master --single-branch https://github.com/blockscout/blockscout.git /app
RUN mix local.hex --force
RUN mix do deps.get, local.rebar --force, deps.compile

RUN apk add --update nodejs npm

# Run forderground build and phoenix digest
RUN mix compile && npm install npm@latest

# Add blockscout npm deps
RUN cd apps/block_scout_web/assets/ && \
    npm install && \
    npm run deploy && \
    cd /app/apps/explorer/ && \
    npm install && \
    apk update && \
    apk del --force-broken-world alpine-sdk gmp-dev automake libtool inotify-tools autoconf python3

RUN apk add --update git make

RUN mix phx.digest

RUN mkdir -p /opt/release \
  && mix release blockscout \
  && mv _build/${MIX_ENV}/rel/blockscout /opt/release

# ##############################################################
FROM hexpm/elixir:1.14.5-erlang-24.2.2-alpine-3.18.2

ARG RELEASE_VERSION
ENV RELEASE_VERSION=${RELEASE_VERSION}
ARG CHAIN_TYPE
ENV CHAIN_TYPE=${CHAIN_TYPE}
ARG BRIDGED_TOKENS_ENABLED
ENV BRIDGED_TOKENS_ENABLED=${BRIDGED_TOKENS_ENABLED}
ARG BLOCKSCOUT_VERSION
ENV BLOCKSCOUT_VERSION=${BLOCKSCOUT_VERSION}

RUN apk --no-cache --update add jq curl

WORKDIR /app

COPY --from=builder /opt/release/blockscout .
COPY --from=builder /app/apps/explorer/node_modules ./node_modules
COPY --from=builder /app/config/config_helper.exs ./config/config_helper.exs
COPY --from=builder /app/config/config_helper.exs /app/releases/${RELEASE_VERSION}/config_helper.exs
COPY --from=builder /app/config/assets/precompiles-arbitrum.json ./config/assets/precompiles-arbitrum.json
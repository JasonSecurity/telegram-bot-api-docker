# syntax=docker/dockerfile:1

# Build the official Telegram Bot API server from a pinned upstream commit.
# Update both version and commit together when preparing a new release.
ARG TELEGRAM_BOT_API_VERSION=10.4
ARG TELEGRAM_BOT_API_COMMIT=7232881b39dfcd048a0d569f1983c5184249ee05

FROM debian:bookworm-slim AS builder

ARG TELEGRAM_BOT_API_VERSION
ARG TELEGRAM_BOT_API_COMMIT

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        cmake \
        g++ \
        git \
        gperf \
        make \
        libssl-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone --recurse-submodules https://github.com/tdlib/telegram-bot-api.git \
    && git -C telegram-bot-api checkout --detach "${TELEGRAM_BOT_API_COMMIT}" \
    && git -C telegram-bot-api submodule update --init --recursive \
    && actual_version="$(sed -nE 's/^project\(TelegramBotApi VERSION ([^ ]+) LANGUAGES CXX\)/\1/p' telegram-bot-api/CMakeLists.txt)" \
    && test "${actual_version}" = "${TELEGRAM_BOT_API_VERSION}" \
    && cmake -S telegram-bot-api -B telegram-bot-api/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build telegram-bot-api/build --target install --parallel "$(nproc)"

FROM debian:bookworm-slim AS runtime

ARG TELEGRAM_BOT_API_VERSION
ARG TELEGRAM_BOT_API_COMMIT

LABEL org.opencontainers.image.title="Telegram Bot API Server" \
      org.opencontainers.image.description="Official Telegram Bot API server built from upstream source" \
      org.opencontainers.image.source="https://github.com/JasonSecurity/telegram-bot-api-docker" \
      org.opencontainers.image.url="https://github.com/tdlib/telegram-bot-api" \
      org.opencontainers.image.version="${TELEGRAM_BOT_API_VERSION}" \
      org.opencontainers.image.revision="${TELEGRAM_BOT_API_COMMIT}" \
      org.opencontainers.image.licenses="BSL-1.0"

ENV TELEGRAM_API_ID="" \
    TELEGRAM_API_HASH="" \
    TELEGRAM_WORK_DIR="/var/lib/telegram-bot-api" \
    TELEGRAM_TEMP_DIR="/tmp/telegram-bot-api"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libssl3 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p "${TELEGRAM_WORK_DIR}" "${TELEGRAM_TEMP_DIR}"

COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/lib/telegram-bot-api

EXPOSE 8081

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

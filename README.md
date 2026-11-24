# Telegram Bot API

Docker images for the official [Telegram Bot API server](https://github.com/tdlib/telegram-bot-api), built from the upstream C++ source.

![Docker Image Version](https://img.shields.io/docker/v/djasonx/telegram-bot-api?sort=semver&label=latest%20version)
![Docker Image Size](https://img.shields.io/docker/image-size/djasonx/telegram-bot-api/latest)

## Images

The same multi-architecture image is published to both registries:

| Registry | Image |
|---|---|
| Docker Hub | `djasonx/telegram-bot-api` |
| GitHub Container Registry | `ghcr.io/jasonsecurity/telegram-bot-api` |

The version badge above tracks the newest version tag published to Docker Hub. Available tags can be viewed in the [Docker Hub tags list](https://hub.docker.com/r/djasonx/telegram-bot-api/tags) and the [GHCR package](https://github.com/JasonSecurity/telegram-bot-api-docker/pkgs/container/telegram-bot-api).

Every release is published with two tags:

- `latest`: the newest version published by this repository.
- `X.Y` (or `X.Y.Z`, when applicable): a version-specific tag.

Both tags support `linux/amd64` and `linux/arm64`. Docker selects the appropriate image for the host architecture.

**Using `latest` does not automatically update a running container.** It only moves the image tag when a new release is published. You remain in control of deployment: pull the image and recreate the container when you choose.

## Quick start

Create an application at [my.telegram.org/apps](https://my.telegram.org/apps) and note its API ID and API hash.

Create a directory for the server's persistent data:

```sh
mkdir -p ./data
```

Start the container with the newest published version:

```sh
docker run -d \
  --name telegram-bot-api \
  --restart unless-stopped \
  -p 8081:8081 \
  -e TELEGRAM_API_ID="your_api_id" \
  -e TELEGRAM_API_HASH="your_api_hash" \
  -v "$(pwd)/data:/var/lib/telegram-bot-api" \
  djasonx/telegram-bot-api:latest
```

To pull the same image from GHCR:

```sh
docker pull ghcr.io/jasonsecurity/telegram-bot-api:latest
```

The server listens on port `8081`. The example maps it to port `8081` on the host. Make the endpoint accessible only to the applications and clients that need it; use a firewall or reverse proxy when appropriate.

To deploy a specific release instead of following `latest`, replace `latest` with the desired version tag (for example, `X.Y`). See the registry tag lists linked above for published versions.

## Docker Compose

Save the following as `compose.yaml`:

```yaml
services:
  telegram-bot-api:
    image: djasonx/telegram-bot-api:latest
    container_name: telegram-bot-api
    restart: unless-stopped
    ports:
      - "8081:8081"
    environment:
      TELEGRAM_API_ID: ${TELEGRAM_API_ID}
      TELEGRAM_API_HASH: ${TELEGRAM_API_HASH}
    volumes:
      - ./data:/var/lib/telegram-bot-api
```

Create a `.env` file in the same directory:

```dotenv
TELEGRAM_API_ID=your_api_id
TELEGRAM_API_HASH=your_api_hash
```

Start the service:

```sh
docker compose up -d
```

When you decide to deploy a newer release:

```sh
docker compose pull
docker compose up -d
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `TELEGRAM_API_ID` | Required | Telegram application API ID |
| `TELEGRAM_API_HASH` | Required | Telegram application API hash |
| `TELEGRAM_WORK_DIR` | `/var/lib/telegram-bot-api` | Persistent data directory |
| `TELEGRAM_TEMP_DIR` | `/tmp/telegram-bot-api` | Temporary files directory |
| `TELEGRAM_HTTP_PORT` | `8081` | HTTP listening port |

The container starts the server with `--local` enabled. The directory and port variables are passed to the corresponding server options. Additional command-line options can be supplied after the image name.

Local mode supports uploads up to 2000 MB and access to files using local paths. See Telegram's [instructions for moving a bot to a local server](https://github.com/tdlib/telegram-bot-api#moving-a-bot-to-a-local-server) before switching an existing bot.

## Versions and source

Each version-specific image is built from the corresponding verified commit in the official upstream repository. The source version and commit are included in the image's OCI labels.

The release workflow checks the [official Bot API changelog](https://core.telegram.org/bots/api-changelog) daily. When a new stable version is announced and its matching upstream source revision is available and verified, the workflow builds and publishes that version to both registries, including the `latest` tag. See [the release procedure](docs/RELEASING.md) for details.

## License

The Telegram Bot API server is maintained by [TDLib](https://github.com/tdlib/telegram-bot-api) and is distributed under the [Boost Software License 1.0](https://github.com/tdlib/telegram-bot-api/blob/master/LICENSE_1_0.txt).

This repository contains the Docker packaging and build configuration. Telegram names and marks belong to their respective owners.

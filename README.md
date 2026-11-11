# Telegram Bot API

Docker images for the official [Telegram Bot API server](https://github.com/tdlib/telegram-bot-api), built from the upstream C++ source.

## Images

The images are available from both registries:

| Registry | Image |
|---|---|
| Docker Hub | `djasonx/telegram-bot-api` |
| GitHub Container Registry | `ghcr.io/jasonsecurity/telegram-bot-api` |

Available tags:

- `10.4`: Telegram Bot API 10.4.
- `latest`: most recently published version.

Both tags support `linux/amd64` and `linux/arm64`. Docker selects the appropriate image for the host architecture.

## Quick start

Create an application at [my.telegram.org/apps](https://my.telegram.org/apps) and note its API ID and API hash.

Create a directory for the server's persistent data:

```sh
mkdir -p ./data
```

Start the container:

```sh
docker run -d \
  --name telegram-bot-api \
  --restart unless-stopped \
  -p 8081:8081 \
  -e TELEGRAM_API_ID="your_api_id" \
  -e TELEGRAM_API_HASH="your_api_hash" \
  -v "$(pwd)/data:/var/lib/telegram-bot-api" \
  djasonx/telegram-bot-api:10.4
```

To pull the same image from GHCR, use:

```sh
docker pull ghcr.io/jasonsecurity/telegram-bot-api:10.4
```

The server listens on port `8081`. The example maps it to port `8081` on the host. Make the endpoint accessible only to the applications and clients that need it; use a firewall or reverse proxy when appropriate.

## Docker Compose

Save the following as `compose.yaml`:

```yaml
services:
  telegram-bot-api:
    image: djasonx/telegram-bot-api:10.4
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

Each versioned image is built from a specific commit in the official upstream repository. The source version and commit are included in the image labels.

The initial image release is based on:

| Item | Value |
|---|---|
| Telegram Bot API | `10.4` |
| Upstream commit | [`7232881b39dfcd048a0d569f1983c5184249ee05`](https://github.com/tdlib/telegram-bot-api/commit/7232881b39dfcd048a0d569f1983c5184249ee05) |
| Build image | Debian Bookworm Slim |
| Architectures | `linux/amd64`, `linux/arm64` |

The release workflow checks the [official Bot API changelog](https://core.telegram.org/bots/api-changelog) daily and publishes a new version when the corresponding upstream source revision is available and verified. See [the release procedure](docs/RELEASING.md) for details.

## License

The Telegram Bot API server is maintained by [TDLib](https://github.com/tdlib/telegram-bot-api) and is distributed under the [Boost Software License 1.0](https://github.com/tdlib/telegram-bot-api/blob/master/LICENSE_1_0.txt).

This repository contains the Docker packaging and build configuration. Telegram names and marks belong to their respective owners.

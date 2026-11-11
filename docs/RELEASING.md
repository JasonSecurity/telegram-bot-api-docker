# Release procedure

This repository builds and publishes versioned Docker images of the official Telegram Bot API server.

## Automatic releases

The `.github/workflows/check-upstream-release.yml` workflow checks the [official Bot API changelog](https://core.telegram.org/bots/api-changelog) once a day at 12:00 UTC.

A release is published only when all of the following conditions are met:

1. The changelog lists a stable Bot API version newer than the highest version tag in this repository.
2. The upstream repository contains the matching version update commit.
3. The commit's `CMakeLists.txt` declares the same version.

The workflow passes that commit to the image build. If any check fails, it stops without publishing an image. Changes to the upstream development branch do not, by themselves, trigger a release.

To check for a release without publishing, run **Check Telegram Bot API stable release** in GitHub Actions with `dry_run=true`. Set `dry_run=false` only when a manual check should also publish a detected release.

## Manual releases

To publish a specific stable version, run **Build and publish Docker image** in GitHub Actions and enter the version, for example `10.4`.

The workflow locates the upstream version update commit and verifies the version declared in `CMakeLists.txt`. It then builds from that exact commit rather than from the moving `master` branch.

## Images

Each successful release publishes `linux/amd64` and `linux/arm64` images to both registries:

- `djasonx/telegram-bot-api:X.Y`
- `djasonx/telegram-bot-api:latest`
- `ghcr.io/jasonsecurity/telegram-bot-api:X.Y`
- `ghcr.io/jasonsecurity/telegram-bot-api:latest`

The version tag is not overwritten if it already exists. The `latest` tag is updated with each release.

## Verify a release

Replace `X.Y` with the released version:

```sh
docker buildx imagetools inspect djasonx/telegram-bot-api:X.Y
docker buildx imagetools inspect ghcr.io/jasonsecurity/telegram-bot-api:X.Y
docker pull djasonx/telegram-bot-api:X.Y
```

Check the image's version and revision labels, then test the container with a Telegram application API ID and API hash.

## Rollback

Change the image reference in the deployment configuration to the previous version tag and recreate the container. Keep the existing data volume so the server retains its files and state.

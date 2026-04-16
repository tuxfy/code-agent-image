## Run from Docker Hub with shared token:

### Docker

```
docker run --rm -it \
  --network bridge \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents,target=/home/agent \
  tuxfy/ai-agents:latest
```

### Podman

```
podman run --rm -it \
  --network bridge \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents,target=/home/agent \
  tuxfy/ai-agents:latest
```

## Use run script within your project (docker)

1. copy run-ai-agent.sh to your project
2. bash run-ai-agent.sh

Excludes

-   existing .env\* files from docker container
-   symfony secrets

Mounts

-   volume ai-agents for shared tokens

## Run from Docker Hub with masking symfony secrets:

### Docker

```
docker run --rm -it \
  --network bridge \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents,target=/home/agent \
  --mount type=bind,source=/dev/null,target=/workspace/.env,ro \
  --mount type=bind,source=/dev/null,target=/workspace/.env.local,ro \
  --mount type=tmpfs,target=/workspace/config/secrets \
  tuxfy/ai-agents:latest
```

### Podman

```
podman run --rm -it \
  --network bridge \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents,target=/home/agent \
  --mount type=bind,source=/dev/null,target=/workspace/.env,ro \
  --mount type=bind,source=/dev/null,target=/workspace/.env.local,ro \
  --mount type=tmpfs,target=/workspace/config/secrets \
  tuxfy/ai-agents:latest
```

## Secret masking checklist (common patterns to consider):

-   `.env`, `.env.*`, `.env.local`
-   `config/secrets`, `config/secrets/*`
-   `secrets`, `secrets/*`
-   `*.pem`, `*.key`, `*.p12`
-   `*.json` if it contains credentials (service accounts, cloud keys)

## Build from Docker Hub:

```
docker pull tuxfy/ai-agents:latest
podman pull tuxfy/ai-agents:latest
```

Build:

```
podman build -t ai-agents .

podman login docker.io

podman tag ai-agents tuxfy/ai-agents:1.2.0 &&
podman tag ai-agents tuxfy/ai-agents:latest &&
podman push tuxfy/ai-agents:1.2.0 &&
podman push tuxfy/ai-agents:latest
```

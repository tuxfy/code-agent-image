## Run from Docker Hub with shared token:

### Docker

```
docker run --rm -it \
  --network bridge \
  --user "$(id -u)":"$(id -g)" \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents-codex,target=/home/agent/.codex \
  --mount type=volume,source=ai-agents-vibe,target=/home/agent/.vibe \
  tuxfy/ai-agents:latest
```

### Podman

```
podman run --rm -it \
  --network bridge \
  --userns=keep-id \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents-codex,target=/home/agent/.codex \
  --mount type=volume,source=ai-agents-vibe,target=/home/agent/.vibe \
  tuxfy/ai-agents:latest
```

## Run from Docker Hub with masking symfony secrets:

### Docker

```
docker run --rm -it \
  --network bridge \
  --user "$(id -u)":"$(id -g)" \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents-codex,target=/home/agent/.codex \
  --mount type=volume,source=ai-agents-vibe,target=/home/agent/.vibe \
  --mount type=bind,source=/dev/null,target=/workspace/.env,ro \
  --mount type=bind,source=/dev/null,target=/workspace/.env.local,ro \
  --mount type=tmpfs,target=/workspace/config/secrets \
  tuxfy/ai-agents:latest
```

### Podman

```
podman run --rm -it \
  --network bridge \
  --userns=keep-id \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=volume,source=ai-agents-codex,target=/home/agent/.codex \
  --mount type=volume,source=ai-agents-vibe,target=/home/agent/.vibe \
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
podman build -t code-agents .

podman login docker.io

podman tag code-agents tuxfy/ai-agents:1.0.2 &&
podman tag code-agents tuxfy/ai-agents:latest &&
podman push tuxfy/ai-agents:1.0.2 &&
podman push tuxfy/ai-agents:latest
```

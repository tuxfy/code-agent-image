## Run from Docker Hub:

### Docker

```
docker run --rm -it \
  --network bridge \
  --user "$(id -u)":"$(id -g)" \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount target=/workspace/.env \
  --mount target=/workspace/.env.local \
  --mount type=tmpfs,target=/workspace/config/secrets \
  tuxfy/ai-agents:latest
```

### Podman

```
podman run --rm -it \
  --network bridge \
  --userns=keep-id \
  --mount type=bind,source="$PWD",target=/workspace \
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

podman tag code-agents tuxfy/ai-agents:1.0.1 &&
podman tag code-agents tuxfy/ai-agents:latest &&
podman push tuxfy/ai-agents:1.0.1 &&
podman push tuxfy/ai-agents:latest
```

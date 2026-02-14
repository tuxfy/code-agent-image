Build:

```
podman build -t code-agents .
```

Run (Podman, rootless, bridge network, project mounted at /workspace):

```
ich
```

Run (Docker, bridge network, project mounted at /workspace):

```
docker run --rm -it \
  --network bridge \
  --user "$(id -u)":"$(id -g)" \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=tmpfs,target=/workspace/.env \
  --mount type=tmpfs,target=/workspace/.env.local \
  --mount type=tmpfs,target=/workspace/config/secrets \
  code-agents
```

Mask sensitive files inside the container (examples):

```
podman run --rm -it \
  --network bridge \
  --userns=keep-id \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=bind,source=/dev/null,target=/workspace/.env,ro \
  --mount type=bind,source=/dev/null,target=/workspace/.env.local,ro \
  --mount type=tmpfs,target=/workspace/config/secrets \
  code-agents
```

Run Codex in interactive approval mode (confirm commands manually):

```
codex
```

Pull from Docker Hub:

```
podman pull <DOCKERHUB_USER>/<REPO_NAME>:<TAG>
```

Run from Docker Hub:

```
podman run --rm -it \
  --network bridge \
  --userns=keep-id \
  --mount type=bind,source="$PWD",target=/workspace \
  --mount type=tmpfs,target=/workspace/.env \
  --mount type=tmpfs,target=/workspace/.env.local \
  --mount type=tmpfs,target=/workspace/config/secrets \
  <DOCKERHUB_USER>/<REPO_NAME>:<TAG>
```

Secret masking checklist (common patterns to consider):

-   `.env`, `.env.*`, `.env.local`
-   `config/secrets`, `config/secrets/*`
-   `secrets`, `secrets/*`
-   `*.pem`, `*.key`, `*.p12`
-   `*.json` if it contains credentials (service accounts, cloud keys)

#!/usr/bin/env bash
set -Eeuo pipefail

IMAGE="${IMAGE:-tuxfy/ai-agents:latest}"
WORKSPACE_DIR="${WORKSPACE_DIR:-$PWD}"
HOME_VOLUME="${HOME_VOLUME:-ai-agents}"

mounts=(
  --mount "type=bind,source=$WORKSPACE_DIR,target=/workspace"
  --mount "type=volume,source=$HOME_VOLUME,target=/home/agent"
  --mount "type=tmpfs,target=/workspace/config/secrets"
)

while IFS= read -r -d '' file; do
  filename="$(basename "$file")"
  mounts+=(
    --mount "type=bind,source=/dev/null,target=/workspace/$filename,ro"
  )
done < <(find "$WORKSPACE_DIR" -maxdepth 1 -type f -name '.env*' -print0)

exec docker run --rm -it \
  --network bridge \
  "${mounts[@]}" \
  "$IMAGE"

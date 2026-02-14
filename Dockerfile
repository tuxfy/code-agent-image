FROM debian:trixie-slim

# --- Base tools ---
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    pipx \
 && rm -rf /var/lib/apt/lists/*

# --- Install Node (Codex runtime) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y nodejs

# --- Install Codex CLI + Claude Code ---
RUN npm install -g @openai/codex @anthropic-ai/claude-code \
 && rm -rf /usr/lib/node_modules/npm \
 && rm -f /usr/bin/npm \
 && rm -f /usr/bin/npx

# --- Install Vibe ---
ENV PIPX_HOME=/opt/pipx
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install mistral-vibe

# --- Git safe directory for bind mounts ---
RUN git config --system --add safe.directory /workspace

RUN useradd -m -u 1000 -s /bin/bash agent \
 && mkdir -p /workspace /home/agent/.codex /home/agent/.vibe /home/agent/.claude \
 && chown -R agent:agent /workspace /home/agent/.codex /home/agent/.vibe /home/agent/.claude

RUN mkdir -p /etc/claude-code
COPY .claude/managed-settings.json /etc/claude-code/managed-settings.json
RUN chmod 0644 /etc/claude-code/managed-settings.json

# --- Seed default configs in the agent home ---
COPY --chown=agent:agent .codex/config.toml /home/agent/.codex/config.toml
COPY --chown=agent:agent .vibe/config.toml /home/agent/.vibe/config.toml

RUN cat <<'EOF' > /usr/local/bin/entrypoint.sh
#!/bin/sh
set -eu

SENSITIVE_GLOBS="/workspace/.env /workspace/.env.local /workspace/.env.* /workspace/config/secrets"

warned=0
for glob in $SENSITIVE_GLOBS; do
  for path in $glob; do
    if [ -e "$path" ]; then
      if [ -d "$path" ]; then
        if [ -n "$(ls -A "$path" 2>/dev/null)" ]; then
          echo "warning: sensitive directory is readable and non-empty: $path" >&2
          warned=1
        fi
      elif [ -f "$path" ]; then
        if [ -s "$path" ]; then
          echo "warning: sensitive file is readable and non-empty: $path" >&2
          warned=1
        fi
      elif [ -r "$path" ] && [ ! -c "$path" ] && [ ! -b "$path" ]; then
        echo "warning: sensitive path is readable: $path" >&2
        warned=1
      fi
    fi
  done
done

if [ "$warned" -eq 1 ]; then
  echo "hint: mask secrets with --mount type=bind,source=/dev/null,target=/workspace/.env,ro" >&2
  echo "hint: mask directories with --mount type=tmpfs,target=/workspace/config/secrets" >&2
fi

exec "$@"
EOF

RUN chmod 0755 /usr/local/bin/entrypoint.sh

WORKDIR /workspace

USER agent

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["/bin/bash"]

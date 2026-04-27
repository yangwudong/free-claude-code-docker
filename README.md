# free-claude-code-docker

Docker packaging for [free-claude-code](https://github.com/Alishahryar1/free-claude-code) — a lightweight proxy that routes Claude Code's Anthropic API calls to alternative LLM providers.

## Quick Start

### 1. Clone & Configure

```bash
git clone https://github.com/yangwudong/free-claude-code-docker.git
cd free-claude-code-docker
cp .env.example .env
```

Edit `.env` — at minimum set your API key:

```dotenv
NVIDIA_NIM_API_KEY="nvapi-your-key-here"
ANTHROPIC_AUTH_TOKEN="your-secret-token"
```

### 2. Build & Run

```bash
docker compose up -d
```

### 3. Connect Claude Code

From any machine on your LAN:

```bash
ANTHROPIC_AUTH_TOKEN="your-secret-token" \
ANTHROPIC_BASE_URL="http://<server-ip>:8082" \
claude
```

## Configuration

All configuration is via `.env` file (see `.env.example` for full reference).

| Variable | Required | Description |
|----------|----------|-------------|
| `NVIDIA_NIM_API_KEY` | Yes | NVIDIA NIM API key ([get one](https://build.nvidia.com/settings/api-keys)) |
| `ANTHROPIC_AUTH_TOKEN` | Recommended | Auth token for LAN access. **Set this before exposing on a network.** |
| `MODEL` | No | Default model (format: `provider/model/name`) |
| `MODEL_OPUS` / `MODEL_SONNET` / `MODEL_HAIKU` | No | Per-Claude-model overrides |

### Providers

| Provider | `MODEL` prefix | API Key Variable |
|----------|---------------|-----------------|
| NVIDIA NIM | `nvidia_nim/...` | `NVIDIA_NIM_API_KEY` |
| OpenRouter | `open_router/...` | `OPENROUTER_API_KEY` |
| DeepSeek | `deepseek/...` | `DEEPSEEK_API_KEY` |

> Local providers (LM Studio, llama.cpp, Ollama) require the service to be accessible from the container. Use `host.docker.internal` instead of `localhost` in the base URL.

## Commands

```bash
docker compose up -d          # Start
docker compose logs -f        # View logs
docker compose down           # Stop
docker compose build --no-cache  # Rebuild (e.g., after upstream update)
docker compose up -d --build  # Rebuild and restart
```

## Updating

The image installs from the upstream `main` branch. To update:

```bash
docker compose build --no-cache
docker compose up -d
```

A weekly CI build runs every Monday to catch upstream breakage.

## Architecture

```
┌─────────────────┐        ┌─────────────────────────┐        ┌──────────────────┐
│  Claude Code    │        │  Docker Container        │        ┌──────────────────┤
│  CLI / VSCode   │───────>│  free-claude-code        │───────>│  NVIDIA NIM      │
│  (LAN client)   │<───────│  proxy (:8082)           │<───────│  API             │
└─────────────────┘        └─────────────────────────┘        └──────────────────┘
```

See [PLAN.md](PLAN.md) for detailed design decisions.

## License

- This repo: [Apache License 2.0](LICENSE)
- Upstream [free-claude-code](https://github.com/Alishahryar1/free-claude-code): [MIT License](https://github.com/Alishahryar1/free-claude-code/blob/main/LICENSE)

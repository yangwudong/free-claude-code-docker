# Architecture & Design Decisions

## Purpose

Docker packaging for [free-claude-code](https://github.com/Alishahryar1/free-claude-code) — a lightweight proxy that routes Claude Code's Anthropic API calls to alternative LLM providers (NVIDIA NIM, OpenRouter, DeepSeek, LM Studio, llama.cpp, Ollama).

## Why a Separate Repo

The upstream project [explicitly states](https://github.com/Alishahryar1/free-claude-code/blob/main/README.md): "Not accepting Docker integration PRs for now." This repo is an independent Docker wrapper maintained separately.

## Install Method: `uv tool install` from Git

The upstream project publishes itself as an installable Python package with CLI entrypoints (`free-claude-code`, `fcc-init`). We use `uv tool install` to install directly from the upstream git repo at build time.

**Why not other approaches:**

| Approach | Rejected because |
|----------|-----------------|
| Copy source into image | Duplicates code, harder to update, license maintenance |
| Git submodule | Submodule management overhead, complex for a wrapper repo |
| PyPI install | Upstream may not publish to PyPI; git install always has latest |

**How it works:**

```
uv tool install "free-claude-code @ git+https://github.com/Alishahryar1/free-claude-code.git"
```

This installs the package globally in the container, making the `free-claude-code` CLI available as the entrypoint.

## Base Image: `python:3.14-slim-bookworm`

| Choice | Rationale |
|--------|-----------|
| `python:3.14` | Upstream requires `>=3.14` in pyproject.toml |
| `slim` | No apt packages needed. All deps via pip/uv. ~150MB vs ~1GB+ full image |
| `bookworm` (Debian 12) | Stable release. Trixie is testing — unnecessary risk for a proxy |
| `uv` binary | Copied from `ghcr.io/astral-sh/uv:latest` in a single COPY step |

## No Voice Extras

Voice transcription requires either:
- `voice_local`: torch + transformers + accelerate (~3-5GB added)
- `voice`: grpcio + nvidia-riva-client (~200MB added)

For a LAN proxy, voice is unnecessary. The image stays ~300-400MB without it.

## Version Strategy: Track `main`, Weekly CI Rebuild

- Dockerfile installs from upstream `main` branch (no pinned version)
- GitHub Actions workflow runs `docker build` every Monday at 2am UTC
- Catches upstream breakage within a week
- Manual `workflow_dispatch` trigger available for immediate rebuilds
- Build-only for now (no push to registry); add registry push when ready

## Runtime Configuration

| Aspect | Design |
|--------|--------|
| Config method | `.env` file mounted at runtime via `env_file` in compose |
| Port | 8082 (matches upstream default) |
| Binding | `0.0.0.0` inside container (upstream default in `config/settings.py`) |
| Auth | `ANTHROPIC_AUTH_TOKEN` in `.env` — strongly recommended for LAN exposure |
| Messaging | `MESSAGING_PLATFORM=none` override in compose — no bots needed in container |
| Healthcheck | `GET /v1/models` — lightweight probe endpoint already provided by upstream |

## Security Considerations

- `.env` is `.gitignored` and `.dockerignore`d — never committed or sent to build context
- `ANTHROPIC_AUTH_TOKEN` gates all API access — set it before exposing on LAN
- Container runs as root by default — add `USER` directive if hardening is needed
- No local model providers (Ollama, LM Studio) expected inside container — those run on the host

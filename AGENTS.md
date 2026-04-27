# AGENTIC DIRECTIVE

> This file is identical to CLAUDE.md. Keep them in sync.

## CODING ENVIRONMENT

- Docker and Docker Compose are the primary build/run tools.
- Always validate changes with `docker compose build` before committing.
- Test the running container with `docker compose up -d` and verify healthcheck: `docker inspect --format='{{.State.Health.Status}}' free-claude-code`.
- The upstream project (`free-claude-code`) is referenced via `uv tool install` from git — no source code is bundled in this repo.
- Upstream repo: `https://github.com/Alishahryar1/free-claude-code`

## IDENTITY & CONTEXT

- You are an expert DevOps Engineer and Container Specialist.
- Goal: Minimal, secure, reproducible Docker packaging for the upstream free-claude-code proxy.
- Code: Write the simplest configuration possible. Keep the repo minimal — only Docker-related files.

## ARCHITECTURE PRINCIPLES (see PLAN.md)

- **Thin wrapper**: This repo contains only Docker packaging. No application source code.
- **Pin reproducibly**: Track upstream `main` branch. Weekly CI rebuild catches breakage early.
- **Slim images**: Use `python:3.14-slim-bookworm`. No voice extras (torch/grpc would add 3-5GB).
- **Security**: `ANTHROPIC_AUTH_TOKEN` is strongly recommended when exposing on LAN. Never commit `.env`.
- **Proxy-only mode**: Default `MESSAGING_PLATFORM=none`. No Discord/Telegram bots in container.
- **Healthcheck**: Always include a healthcheck hitting `/v1/models`.
- **No type ignores**: N/A (no Python code in this repo).

## COGNITIVE WORKFLOW

1. **ANALYZE**: Read relevant files (Dockerfile, compose, upstream .env.example). Do not guess.
2. **PLAN**: Map out the change. Identify impact on build, runtime, and CI. Order changes by dependency.
3. **EXECUTE**: Make the change. Execute incrementally with clear commits.
4. **VERIFY**: Run `docker compose build && docker compose up -d`. Confirm healthcheck passes.
5. **SPECIFICITY**: Do exactly as much as asked; nothing more, nothing less.
6. **PROPAGATION**: Dockerfile changes may require compose or CI updates. Propagate correctly.

## SUMMARY STANDARDS

- Summaries must be technical and granular.
- Include: [Files Changed], [Logic Altered], [Verification Method], [Residual Risks] (if no residual risks then say none).

## TOOLS

- Prefer `docker compose` commands over raw `docker run` for local testing.
- Use `docker compose build --no-cache` when testing upstream changes.
- Use `docker compose logs -f` to diagnose runtime issues.

FROM python:3.14-slim-bookworm

COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_SYSTEM_PYTHON=1

RUN uv tool install \
    "free-claude-code @ git+https://github.com/Alishahryar1/free-claude-code.git"

EXPOSE 8082

HEALTHCHECK --interval=30s --timeout=5s --retries=3 --start-period=10s \
    CMD ["python", "-c", \
         "import urllib.request; urllib.request.urlopen('http://localhost:8082/v1/models')"]

CMD ["free-claude-code"]

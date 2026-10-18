# openrouter-proxy

A pass-through proxy to `https://openrouter.ai`, for servers OpenRouter refuses by region (it answers
403 to every request from Iran). It runs on a host OpenRouter accepts and forwards the request with
the caller's IP headers removed.

```
https://<host>/<PROXY_SECRET>/api/v1/...  ->  https://openrouter.ai/api/v1/...
```

Everything else is a 404, and `/healthz` answers `ok`.

- **No key is stored here.** The caller's `Authorization: Bearer sk-or-...` header is passed through
  unchanged, so each client spends its own OpenRouter key.
- **`PROXY_SECRET`** is a random path segment that stops the proxy being used as an open relay. Set it
  in the deployment environment; it is required and never committed.
- The request line (which holds the secret) is not written to the access log.

## Deploy (ci-agent)

Compose mode, this repo, HTTP port `8120`, environment `PROXY_SECRET=<random>`. Pre-pull the base
image on the host, since ci-agent does not pull: `docker pull nginx:1.29-alpine`.

## Use

Set the OpenAI-compatible client's base URL to `https://<host>/<PROXY_SECRET>/api/v1`.

## Test locally

```bash
PROXY_SECRET=test docker compose up -d --build
curl -s localhost:8120/test/api/v1/models | head -c 200
curl -s -o /dev/null -w '%{http_code}\n' localhost:8120/api/v1/models   # 404
```

## License

[MIT](LICENSE)

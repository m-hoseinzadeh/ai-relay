# openrouter-proxy

A pass-through proxy to `https://openrouter.ai`, and a relay to a few AI APIs, for servers they refuse
by region (OpenRouter answers 403 to every request from Iran). It runs on a host they accept and
forwards the request with the caller's IP headers removed.

```
https://<host>/<PROXY_SECRET>/api/v1/...                      ->  https://openrouter.ai/api/v1/...
https://<host>/<PROXY_SECRET>/relay/api.openai.com/...         ->  https://api.openai.com/...
https://<host>/<PROXY_SECRET>/relay/api.anthropic.com/...      ->  https://api.anthropic.com/...
https://<host>/<PROXY_SECRET>/relay/generativelanguage.googleapis.com/...
                                                                ->  https://generativelanguage.googleapis.com/...
```

Everything else is a 404 (any other host after `/relay/` too), and `/healthz` answers `ok`. To allow
another host, add it to the relay `location` in `templates/default.conf.template`.

- **No key is stored here.** The caller's `Authorization` (or Anthropic's `x-api-key`) header is passed
  through unchanged, so each client spends its own key.
- **`PROXY_SECRET`** is a random path segment that stops the proxy being used as an open relay. Set it
  in the deployment environment; it is required and never committed. Letters, digits, `-` and `_`
  only: it is part of a regular expression in the relay route.
- The request line (which holds the secret) is not written to the access log.

## Deploy (ci-agent)

Compose mode, this repo, HTTP port `8120`, environment `PROXY_SECRET=<random>`. Pre-pull the base
image on the host, since ci-agent does not pull: `docker pull nginx:1.29-alpine`.

## Use

Set the OpenAI-compatible client's base URL to `https://<host>/<PROXY_SECRET>/api/v1`.

As the Siteoseo AI service's relay (its providers marked "via relay"): `AI_RELAY_URL=https://<host>/<PROXY_SECRET>/relay`.
It calls `{AI_RELAY_URL}/{provider host}/...`; the `X-Relay-Key` header it sends is dropped here.

## Test locally

```bash
PROXY_SECRET=test docker compose up -d --build
curl -s localhost:8120/test/api/v1/models | head -c 200
curl -s -o /dev/null -w '%{http_code}\n' localhost:8120/api/v1/models   # 404
curl -s -o /dev/null -w '%{http_code}\n' localhost:8120/test/relay/api.openai.com/v1/models   # 401: OpenAI wants a key
curl -s -o /dev/null -w '%{http_code}\n' localhost:8120/test/relay/example.com/   # 404
```

## License

[MIT](LICENSE)

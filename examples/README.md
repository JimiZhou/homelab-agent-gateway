# Examples

Run from the project root:

```sh
curl http://localhost:8088/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d @examples/chat.json
```

URL context:

```sh
curl http://localhost:8088/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d @examples/url-summary.json
```

Vision fusion:

```sh
curl http://localhost:8088/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d @examples/vision.json
```

# Best Practices / 最佳实践

## Local First, Paid Last

Use the local model for most work:

- normal chat
- summarization
- URL reading
- image description through local vision
- simple tool use

Enable commercial fallback only when:

- local model errors
- local model returns empty content
- local model explicitly says it cannot determine the answer
- you need a high-confidence final answer

Recommended fallback policy:

```text
error_or_empty
```

Use `low_confidence` for important tasks and `always` only for evaluation.

## Keep the Public Surface Small

Expose one model to clients:

```text
homelab-agent
```

Keep component models hidden unless you are debugging.

## Prefer Deterministic Routing

Do not rely only on model autonomy. Deterministic gateway routing is cheaper and more stable:

- URL detected -> fetch before generation
- image/video detected -> vision preprocessing
- timely query detected -> search before generation

## Secure Fetching

The gateway blocks local/private/reserved addresses for URL and media fetches. Keep this enabled if the gateway is reachable by untrusted clients.

Recommended limits:

```text
MAX_FETCH_BYTES=262144
MAX_VISION_MEDIA_BYTES=4194304
TOOL_HTTP_TIMEOUT=8
MAX_AUTO_URLS=3
```

## Observe Before Tuning

Use the request log panel before changing models or prompts. Check:

- route model
- tools called
- auto context
- vision fusion
- fallback usage
- duration

## Suggested Model Layout

Budget homelab:

```text
7B-9B text instruct model
0.5B-2B vision model
commercial fallback off by default
```

Balanced homelab:

```text
14B text instruct model
2B-8B vision model
commercial fallback error_or_empty
```

High quality:

```text
local model for context/tools
commercial fallback low_confidence
```

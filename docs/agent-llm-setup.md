# Agent LLM Setup / Agent 模型部署说明

Homelab Agent Gateway works best when the upstream text model can follow instructions and produce function calls. It does not need to be huge; a strong 7B-14B instruct model is often enough for homelab automation.

## Model Selection

Recommended text model traits:

- instruct/chat tuned
- good JSON discipline
- tool/function calling support, or at least reliable structured output
- 8k+ context if possible
- low hallucination under `temperature=0`

Recommended vision model traits:

- OpenAI-style image input support
- good OCR and scene description
- concise image/video summarization

## llama.cpp Example

Text model:

```sh
llama-server \
  --model /models/text-model.gguf \
  --host 0.0.0.0 \
  --port 8001 \
  --ctx-size 8192 \
  --jinja \
  --alias text-model
```

Vision model:

```sh
llama-server \
  --model /models/vision-model.gguf \
  --mmproj /models/vision-mmproj.gguf \
  --host 0.0.0.0 \
  --port 8002 \
  --ctx-size 4096 \
  --jinja \
  --alias vision-model
```

Your exact flags depend on the model family and llama.cpp build. Verify with:

```sh
curl http://localhost:8001/v1/models
curl http://localhost:8002/v1/models
```

## Gateway Mapping

The gateway has two layers of names:

- public model name: what clients call, usually `homelab-agent`
- component model name: what the gateway routes internally
- upstream model name: what the inference server expects

Example:

```json
{
  "public_model": "homelab-agent",
  "default_text_model": "local-text",
  "vision_model": "local-vision",
  "model_upstreams": {
    "local-text": "http://host.docker.internal:8001/v1",
    "local-vision": "http://host.docker.internal:8002/v1"
  },
  "upstream_models": {
    "local-text": "text-model",
    "local-vision": "vision-model"
  }
}
```

## Tool Calling Notes

Some local models emit native OpenAI `tool_calls`; others follow XML or plain JSON conventions. The gateway already provides deterministic context injection for common cases:

- URL in prompt -> `fetch_url`
- timely query words -> `web_search`
- image/video in prompt -> vision preprocessing

This reduces reliance on the local model's autonomous tool choice and improves reliability.

## Suggested Generation Defaults

For agent workloads:

```text
temperature = 0
top_p = 0.8
max_tokens = 1024
```

Use higher temperature only for creative writing models.

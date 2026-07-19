# Deployment Guide / 部署指南

## 1. Prerequisites / 前置条件

- Docker and Docker Compose
- One OpenAI-compatible text model endpoint
- Optional: one OpenAI-compatible vision model endpoint
- Optional: a commercial OpenAI-compatible API for fallback

The gateway itself does not require GPU. GPUs are only needed by your model servers.

网关本身不需要 GPU，GPU 只用于你的模型推理服务。

## 2. Recommended Homelab Topology

```mermaid
flowchart TB
  subgraph Host[Homelab Host]
    Gateway[homelab-agent-gateway :8088]
    Text[Text LLM :8001]
    Vision[Vision LLM :8002]
    Data[(./data)]
  end
  Apps[Apps / Agents / Chat UIs] --> Gateway
  Gateway --> Text
  Gateway --> Vision
  Gateway --> Data
  Gateway -. optional .-> Paid[Commercial fallback API]
```

## 3. Start Local Model Servers

Start any OpenAI-compatible server. Common choices:

- llama.cpp server
- vLLM
- Ollama with OpenAI-compatible proxy
- LM Studio server

Example endpoints used by the default Compose file:

```text
Text model:   http://localhost:8001/v1
Vision model: http://localhost:8002/v1
```

## 4. Configure Gateway

```sh
cp .env.example .env
```

Edit `.env`:

```sh
PUBLIC_MODEL=homelab-agent
LLM_MODEL=local-text
VISION_MODEL=local-vision
MODEL_UPSTREAMS=local-text=http://host.docker.internal:8001/v1,local-vision=http://host.docker.internal:8002/v1
```

`host.docker.internal` is mapped through Docker `extra_hosts` and points back to the host machine on Linux.

## 5. Start

```sh
docker compose up -d --build
```

Open:

```text
http://localhost:8088/
```

## 6. Verify

```sh
curl http://localhost:8088/health
curl http://localhost:8088/v1/models
```

Chat completion:

```sh
curl http://localhost:8088/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"homelab-agent","stream":false,"messages":[{"role":"user","content":"hello"}]}'
```

## 7. Enable API Key

For LAN or public access, set:

```sh
GATEWAY_API_KEY=change-me-to-a-long-random-secret
```

Then call:

```sh
curl http://localhost:8088/v1/chat/completions \
  -H 'Authorization: Bearer change-me-to-a-long-random-secret' \
  -H 'Content-Type: application/json' \
  -d '{"model":"homelab-agent","stream":false,"messages":[{"role":"user","content":"hello"}]}'
```

## 8. Upgrade

```sh
git pull
docker compose up -d --build
```

Configuration and request logs are persisted under `./data`.

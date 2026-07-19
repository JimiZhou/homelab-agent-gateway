# Architecture / 架构

## Request Flow

```mermaid
sequenceDiagram
  participant C as Client
  participant G as Gateway
  participant V as Vision LLM
  participant T as Text LLM
  participant W as Web Tools
  participant P as Paid Fallback

  C->>G: /v1/chat/completions model=homelab-agent
  G->>G: load config and route model
  opt image/video input
    G->>V: visual understanding
    V-->>G: visual summary
  end
  opt URL or timely query
    G->>W: fetch_url / web_search
    W-->>G: structured context
  end
  G->>T: final local text generation
  T-->>G: answer or tool calls
  opt tool calls
    G->>W: execute built-in tool
    W-->>G: tool result
    G->>T: continue
  end
  opt fallback policy triggers
    G->>P: paid-model fallback
    P-->>G: final answer
  end
  G-->>C: OpenAI-compatible response
```

## Components

```mermaid
flowchart TB
  subgraph Gateway[Homelab Agent Gateway]
    Router[Model Router]
    Config[Web Config UI]
    Logs[Request Logs]
    Tools[Tool Executor]
    Guard[Fetch Guardrails]
    Fusion[Vision Fusion]
    Fallback[Fallback Policy]
  end

  Client[OpenAI-compatible Apps] --> Router
  Config --> Router
  Router --> Fusion
  Router --> Tools
  Router --> Fallback
  Router --> Logs
  Tools --> Guard
  Fusion --> Vision[Vision LLM]
  Router --> Text[Text LLM]
  Fallback -. optional .-> Paid[Commercial API]
```

## API Surface

Main endpoints:

- `GET /`
- `GET /health`
- `GET /admin/config`
- `POST /admin/config`
- `GET /admin/logs`
- `GET /v1/models`
- `GET /v1/tools`
- `POST /v1/tools/call`
- `POST /v1/chat/completions`

`/v1/chat/completions` intentionally returns OpenAI-compatible responses so most existing clients can use the gateway by changing only `base_url` and `model`.

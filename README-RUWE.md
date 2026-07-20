# CES Twilio Adapter — Configuration Notes

Companion notes for [`script/values.sh`](script/values.sh) (the deploy-time config sourced by `script/deploy.sh`). The comments that used to live inline in `values.sh` have been moved here to keep that file minimal.

## Where Twilio fits vs. where GCP fits

```
Caller ─phone─▶ Twilio ─webhook/WebSocket─▶ THIS ADAPTER ─Bearer─▶ GCP CES agent
                (carrier)                    (ces-twilio-adapter)   (ces.googleapis.com)
```

- **Twilio** = the telephony/SMS layer that receives the call and streams audio in. The `ces-twilio-auth-token` verifies **that** side.
- **GCP CES agent** = the conversational AI brain the adapter talks **to**. The `ces-twilio-adapter-token` (or ADC) authenticates **that** side.

The whole point of this "adapter" is to sit in the middle and translate between Twilio and the GCP CES agent. That is why it needs credentials for **both** worlds — Twilio's Auth Token inbound, a Google token outbound. The agent itself is a **GCP (Google Cloud CES)** agent, not a Twilio one.

## Two different tokens (despite the similar names)

These are opposite things — don't confuse them:

| Secret | Config var | Direction | Purpose |
|---|---|---|---|
| `ces-twilio-auth-token` | `TWILIO_AUTH_TOKEN_PATH` | **Inbound** | Twilio's account Auth Token. Verifies incoming webhook/WebSocket requests genuinely come from Twilio (HMAC signature check). **Always required. Nothing to do with ADC.** |
| `ces-twilio-adapter-token` | `AUTH_TOKEN_SECRET_PATH` | **Outbound** | A Google OAuth2 access token this adapter uses to authenticate **to** the GCP CES agent (sent as a Bearer token). The ADC-related one. |

### `ces-twilio-auth-token` (inbound — Twilio verification)

Get it from the Twilio Console:

> Settings → Account Settings → API Keys & auth → **Auth tokens** tab → **Primary auth token**

This is always required. It is mounted into the Cloud Run service as the `TWILIO_AUTH_TOKEN` env var via `--set-secrets`.

### `ces-twilio-adapter-token` (outbound — agent auth)

This is the manual alternative to letting **Application Default Credentials (ADC)** mint the agent token automatically.

- **Default (recommended): ADC.** On Cloud Run the service runs as its service account identity, so `AUTH_TOKEN_SECRET_PATH` is intentionally left **unset** and the agent token is minted/refreshed automatically. Requires an IAM role on the service account granting agent access (e.g. `roles/ces.client`).
- **Override: Secret Manager.** Set `AUTH_TOKEN_SECRET_PATH` to the full secret path below. You are then responsible for rotating the token yourself — it expires after ~1 hour and nothing refreshes it.

```bash
AUTH_TOKEN_SECRET_PATH="projects/${PROJECT_ID}/secrets/ces-twilio-adapter-token"
```

Setting `AUTH_TOKEN_SECRET_PATH` is the switch that turns ADC **off**; leaving it unset keeps ADC active. You can't meaningfully have both.

## Phone number → agent mapping

Choose **one** method (see the "Phone Number to Agent Mapping" section in [`README.md`](README.md)):

1. **Firestore** (recommended for production): set `NUMBERS_COLLECTION_ID`, e.g. `ces-twilio-adapter-mappings`.
2. **Local JSON file** (for development/testing): set `NUMBERS_CONFIG_FILE`, e.g. `number_mappings.json`.

## `values.sh` vs. `.env`

Two files, two tools, two lifecycles — keep them separate:

- **`script/values.sh`** = deploy-time config sourced by `script/deploy.sh` → passed to `gcloud run deploy`. Holds infra settings (`PROJECT_ID`, `LOCATION`, `SERVICE_ACCOUNT`, …) plus which secrets to mount. The Python app never reads most of these.
- **`.env`** = local runtime config loaded by `main.py` via `load_dotenv()` when you run `python main.py`. Holds the real `TWILIO_AUTH_TOKEN` for local testing (in prod that comes from Secret Manager instead).

`PUBLIC_SERVER_HOSTNAME` deliberately **differs** between the two (your ngrok hostname locally vs. the `run.app` URL in prod), which is one reason not to merge them.

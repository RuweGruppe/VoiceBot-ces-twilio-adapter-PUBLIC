#!/bin/bash

# Copyright 2025 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Deploy-time config sourced by deploy.sh. See README-RUWE.md for the full
# explanation of the architecture and the two different tokens.

PROJECT_ID=voicebot-503007
SERVICE_NAME=ces-twilio-adapter
SERVICE_ACCOUNT=ces-twilio-adapter@${PROJECT_ID}.iam.gserviceaccount.com
TIMEOUT=60m
CONCURRENCY=3
LOCATION=europe-west1
PUBLIC_SERVER_HOSTNAME="ces-twilio-adapter-738478701190.europe-west1.run.app"
TWILIO_ACCOUNT_SID="AC2..."

# Outbound agent auth. Unset = use ADC (recommended). To use the Secret Manager
# override, set the full path (see README-RUWE.md):
#   AUTH_TOKEN_SECRET_PATH="projects/${PROJECT_ID}/secrets/ces-twilio-adapter-token"

# Inbound Twilio verification secret, mounted as the TWILIO_AUTH_TOKEN env var.
TWILIO_AUTH_TOKEN_PATH="ces-twilio-auth-token:latest"

# Phone number -> agent mapping: choose ONE (see README-RUWE.md / README.md).
# NUMBERS_COLLECTION_ID="ces-twilio-adapter-mappings"   # Firestore (production)
NUMBERS_CONFIG_FILE="number_mappings.json"              # Local JSON (dev/test)

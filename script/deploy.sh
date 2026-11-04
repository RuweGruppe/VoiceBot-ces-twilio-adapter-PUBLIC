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

ENV=${1:?"Usage: deploy.sh [prod|stage]"}

SCRIPT_DIR=$(dirname "$0")
VALUES_FILE="$SCRIPT_DIR/values.${ENV}.sh"

if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: $VALUES_FILE not found. Valid environments: prod, stage"
    exit 1
fi

source "$VALUES_FILE"

REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
MAPPINGS_FILE="$REPO_ROOT/number_mappings.${ENV}.json"

if [ ! -f "$MAPPINGS_FILE" ]; then
    echo "Error: $MAPPINGS_FILE not found."
    exit 1
fi

cp "$MAPPINGS_FILE" "$REPO_ROOT/number_mappings.json"
echo "Deploying $ENV (service: $SERVICE_NAME) with number_mappings.${ENV}.json"

BUILD_SERVICE_ACCOUNT="voicebot-cloudbuild@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud run deploy $SERVICE_NAME \
    --source="$REPO_ROOT" \
    --platform=managed \
    --region=$LOCATION \
    --cpu=1 \
    --memory=1Gi \
    --min-instances=1 \
    --max-instances=10 \
    --service-account=$SERVICE_ACCOUNT \
    --build-service-account=projects/$PROJECT_ID/serviceAccounts/$BUILD_SERVICE_ACCOUNT \
    --allow-unauthenticated \
    --project=$PROJECT_ID  \
    --timeout=$TIMEOUT \
    --concurrency=$CONCURRENCY \
    --set-env-vars=PUBLIC_SERVER_HOSTNAME="$PUBLIC_SERVER_HOSTNAME",TWILIO_ACCOUNT_SID="$TWILIO_ACCOUNT_SID",NUMBERS_COLLECTION_ID="$NUMBERS_COLLECTION_ID",NUMBERS_CONFIG_FILE="$NUMBERS_CONFIG_FILE" \
    --set-secrets=TWILIO_AUTH_TOKEN="$TWILIO_AUTH_TOKEN_PATH"

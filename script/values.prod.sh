#!/bin/bash

PROJECT_ID=voicebot-503007
SERVICE_NAME=ces-twilio-adapter
SERVICE_ACCOUNT=ces-twilio-adapter@${PROJECT_ID}.iam.gserviceaccount.com
TIMEOUT=60m
CONCURRENCY=6
LOCATION=europe-west1
PUBLIC_SERVER_HOSTNAME="ces-twilio-adapter-738478701190.europe-west1.run.app"
TWILIO_ACCOUNT_SID=${TWILIO_ACCOUNT_SID:?"Set TWILIO_ACCOUNT_SID env var before deploying"}
TWILIO_AUTH_TOKEN_PATH="ces-twilio-auth-token:latest"
NUMBERS_CONFIG_FILE="number_mappings.json"

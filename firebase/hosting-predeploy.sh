#!/bin/sh

# This script is run by the firebase predeploy hook
# See firebase.json

SCRIPT_DIR=$(dirname $(readlink -f "$0"))

FIREBASERC_PATH="${SCRIPT_DIR}/.firebaserc"

project_to_alias() {
  PROJECT_NAME=$1
  ALIAS_NAME=$(jq -r ".projects | to_entries[] | select(.value == \"$PROJECT_NAME\").key" $FIREBASERC_PATH)

  if [ -z "$ALIAS_NAME" ]; then
    exit 1
  else
    echo "$ALIAS_NAME"
    exit 0
  fi
}

if [ -z "$GCLOUD_PROJECT" ] || [ -z "$RESOURCE_DIR" ]; then
  echo "Error: Required environment variables are not set."
  exit 1
fi

rm -rf $RESOURCE_DIR

cd ../flutter
ALIAS=$(project_to_alias $GCLOUD_PROJECT)
JSON_PATH="dart_defines/$ALIAS.json"

if [ ! -f "$JSON_PATH" ]; then
  echo "Error: $JSON_PATH does not exist."
  exit 1
fi

fvm flutter build web --release --dart-define-from-file=$JSON_PATH

cd ../firebase
mkdir -p hosting/dist
cp -r ../flutter/build/web/* hosting/dist/

#!/bin/sh

WORKSPACE_ROOT="/workspaces/flutter_firebse"

# Install Flutter
fvm install

# Install npm dependencies for Firebase Functions
npm --prefix "$WORKSPACE_ROOT/functions" install

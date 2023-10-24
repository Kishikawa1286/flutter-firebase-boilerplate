FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04

ARG WORKSPACE_NAME=flutter_firebse
ARG WORKSPACE_PATH=/workspaces/flutter_firebse

# Also Specified in devcontainer.json
ARG USERNAME=vscode
ARG NODE_VERSION=18

RUN apt-get update && \
    # Install npm with apt to use n
    apt-get install -y --no-install-recommends \
    nodejs npm

# Grant access for the devcontainer user
RUN mkdir -p /usr/local/share/npm-global/lib \
    && chown -R vscode /usr/local/share/npm-global/lib
RUN mkdir -p ${WORKSPACE_PATH}/firebase/functions/node_modules \
    && chown -R vscode ${WORKSPACE_PATH}

# Install Node
RUN npm install -g n
RUN n ${NODE_VERSION}
# Install Firebase CLI
RUN npm install -g firebase-tools

# Install Dart
# See: https://dart.dev/get-dart
RUN apt-get install -y apt-transport-https && \
    wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg && \
    echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | tee /etc/apt/sources.list.d/dart_stable.list && \
    apt-get update && \
    apt-get install -y dart
ENV PATH $PATH:/usr/lib/dart/bin

USER ${USERNAME}

# Install fvm and flutterfire_cli
# See: https://fvm.app/docs/getting_started/installation
# See: https://firebase.flutter.dev/docs/cli/
RUN dart pub global activate fvm && \
    dart pub global activate flutterfire_cli
ENV PATH $PATH:/home/${USERNAME}/.pub-cache/bin

RUN mkdir -p ${WORKSPACE_PATH}
WORKDIR ${WORKSPACE_PATH}

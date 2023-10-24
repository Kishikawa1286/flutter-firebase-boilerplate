FROM ubuntu:jammy

# Also Specified in devcontainer.json
ARG USERNAME=vscode
ARG NODE_VERSION=18

ENV DEBIAN_FRONTEND noninteractive

RUN useradd ${USERNAME}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Install npm with apt to use n
    nodejs npm \
    # Install utils
    wget curl gpg git

# Install Node
RUN npm install -g n
RUN n ${NODE_VERSION}
# Install Firebase CLI
RUN npm install -g firebase-tools

RUN mkdir -p /usr/local/share/npm-global/lib && \
    chown -R ${USERNAME} /usr/local/share/npm-global/lib
RUN mkdir -p /home/${USERNAME} && \
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}

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

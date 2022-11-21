ARG BASE_IMAGE_TAG=null
FROM mcr.microsoft.com/vscode/devcontainers/go:0-${BASE_IMAGE_TAG}

ARG SKAFFOLD_VERSION=null
ARG NODEJS_VERSION=null
ARG YQ_VERSION=null
ARG DIVE_VERSION=null

RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin/

RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-amd64 && \
    sudo install skaffold /usr/local/bin/

RUN sudo apt -y update && sudo apt -y upgrade
RUN sudo apt -y install podman
RUN sudo apt-get -y install python3-pip
RUN sudo pip3 install cruft

RUN curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION} | sudo -E bash - && \
    apt install -y nodejs && \
    npm install -g "@vscode/dev-container-cli"

RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq

RUN wget https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.deb && \
    apt install ./dive_${DIVE_VERSION}_linux_amd64.deb

COPY *.cache .cache
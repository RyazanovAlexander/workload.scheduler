ARG VARIANT="1.18-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/go:0-${VARIANT}

RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin/

RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
    sudo install skaffold /usr/local/bin/

RUN apt update && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && \
    apt install -y nodejs && \
    npm install -g "@vscode/dev-container-cli"
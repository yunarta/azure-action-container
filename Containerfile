FROM ubuntu:jammy

RUN export DEBIAN_FRONTEND="noninteractive"\
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    gpg lsb-release \
    git wget curl \
    zip unzip \
    libicu-dev python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

RUN mkdir -p /etc/apt/keyrings \
    && curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg \
    && chmod go+r /etc/apt/keyrings/microsoft.gpg

RUN AZ_DIST=$(lsb_release -cs) \
    && echo "Types: deb\n\
URIs: https://packages.microsoft.com/repos/azure-cli/\n\
Suites: ${AZ_DIST}\n\
Components: main\n\
Architectures: $(dpkg --print-architecture)\n\
Signed-by: /etc/apt/keyrings/microsoft.gpg" | tee /etc/apt/sources.list.d/azure-cli.sources


RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN export DEBIAN_FRONTEND="noninteractive"\
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    azure-cli terraform \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /venv \
    && . /venv/bin/activate \
    && pip install azure-identity azure-mgmt-resource jinja2

SHELL [ "/bin/bash", "-lc" ]

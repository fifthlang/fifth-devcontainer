FROM ubuntu:22.04

ARG FIFTH_VERSION=0.1.0
ARG FIFTH_RUNTIME=linux-x64
ARG FIFTH_FRAMEWORK=net8.0

LABEL maintainer="Fifth Language Project"
LABEL description="Container for building and running Fifth language programs"
LABEL fifth.version="${FIFTH_VERSION}"
LABEL fifth.framework="${FIFTH_FRAMEWORK}"

# Install essential build tools + libicu for .NET globalization
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        build-essential \
        make \
        git \
        curl \
        ca-certificates \
        libicu70 \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Extract .NET version from FIFTH_FRAMEWORK (e.g., net8.0 -> 8.0, net10.0 -> 10.0)
# Install corresponding .NET Runtime
RUN DOTNET_VERSION=$(echo "${FIFTH_FRAMEWORK}" | sed 's/net//') \
    && echo "Installing .NET Runtime ${DOTNET_VERSION} for framework ${FIFTH_FRAMEWORK}" \
    && wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends dotnet-runtime-${DOTNET_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Fifth compiler
RUN mkdir -p /opt/fifth \
    && curl -fsSL "https://github.com/aabs/fifthlang/releases/download/v${FIFTH_VERSION}/fifth-${FIFTH_VERSION}-${FIFTH_RUNTIME}-${FIFTH_FRAMEWORK}.tar.gz" \
        -o /tmp/fifth.tar.gz \
    && tar -xzf /tmp/fifth.tar.gz -C /opt/fifth \
    && rm /tmp/fifth.tar.gz \
    && chmod +x /opt/fifth/fifth-${FIFTH_VERSION}/bin/fifth

ENV PATH="/opt/fifth/fifth-${FIFTH_VERSION}/bin:${PATH}"

WORKDIR /workspace

CMD ["bash"]

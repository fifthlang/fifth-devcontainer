FROM ubuntu:22.04

ARG FIFTH_VERSION=0.10.0
ARG FIFTH_SDK_VERSION=0.10.0

LABEL maintainer="Fifth Language Project"
LABEL description="Container for building and running Fifth language programs"
LABEL fifth.version="${FIFTH_VERSION}"
LABEL fifth.sdk.version="${FIFTH_SDK_VERSION}"

# Install essential build tools + libicu for .NET globalization
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        ca-certificates \
        libicu70 \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install .NET 10 SDK (required for .5thproj + MSBuild SDK resolution)
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet \
    && rm /tmp/dotnet-install.sh

ENV DOTNET_ROOT="/usr/share/dotnet"
ENV PATH="${DOTNET_ROOT}:${PATH}"

# Install Fifth compiler tool from NuGet
RUN dotnet tool install --tool-path /usr/local/bin Fifth.Compiler.Tool --version "${FIFTH_VERSION}"

WORKDIR /workspace

CMD ["bash"]

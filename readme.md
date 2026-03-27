# Fifth Language DevContainer

A Docker container image for building and running [Fifth](https://github.com/aabs/fifthlang) language programs.

## What's Included

- Ubuntu 22.04 base image
- Fifth compiler tool from NuGet (`Fifth.Compiler.Tool` v0.10.0)
- Fifth MSBuild SDK from NuGet (`Fifth.Sdk` v0.10.0)
- .NET SDK 10.0
- Build tools: `gcc`, `git`, `curl`

## Quick Start

### Build the Image Locally

```bash
docker build --build-arg FIFTH_VERSION=0.10.0 --build-arg FIFTH_SDK_VERSION=0.10.0 -t fifth:0.10.0 .
```

### Test the Image

```bash
docker run --rm fifth:0.10.0 fifthc --version
docker run --rm -v "$(pwd):/workspace" fifth:0.10.0 sh -lc "dotnet tool restore && dotnet build src/Hello/Hello.5thproj"
```

### Run an Interactive Shell

```bash
docker run --rm -it -v "$(pwd):/workspace" fifth:0.10.0 bash
```

## Pushing to GitHub Container Registry (ghcr.io)

This repository also publishes automatically via GitHub Actions when a tag is pushed in the format `vX.Y.Z` (or pre-release variants such as `vX.Y.Z-rc.1`). The published image tag strips the `v` prefix (for example, `v0.10.0` publishes image tag `0.10.0`) and uses the same version for `FIFTH_VERSION` and `FIFTH_SDK_VERSION`.

### 1. Create a Personal Access Token (PAT)

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"**
3. Give it a name (e.g., `ghcr-fifth-push`)
4. Select these scopes:
   - ✅ `write:packages`
   - ✅ `read:packages`
5. Click **Generate token** and copy it immediately

### 2. Authenticate to ghcr.io

```bash
# Replace YOUR_GITHUB_USERNAME and YOUR_PAT with your values
echo "YOUR_PAT" | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
```

Example:
```bash
echo "ghp_xxxxxxxxxxxxxxxxxxxx" | docker login ghcr.io -u aabs --password-stdin
```

### 3. Build and Push

```bash
docker build --build-arg FIFTH_VERSION=0.10.0 --build-arg FIFTH_SDK_VERSION=0.10.0 -t ghcr.io/aabs/fifthlang/fifth:0.10.0 .
docker tag ghcr.io/aabs/fifthlang/fifth:0.10.0 ghcr.io/aabs/fifthlang/fifth:latest
docker push ghcr.io/aabs/fifthlang/fifth:0.10.0
docker push ghcr.io/aabs/fifthlang/fifth:latest
```

This will:
1. Build the image with the full registry name (`ghcr.io/aabs/fifthlang/fifth:0.10.0`)
2. Push both the versioned tag and `latest` tag to ghcr.io

### 4. View Published Images

Visit: https://github.com/aabs?tab=packages

## Configuration Options

Override defaults using Docker build args:

| Variable | Default | Description |
|----------|---------|-------------|
| `FIFTH_VERSION` | `0.10.0` | Fifth compiler tool version |
| `FIFTH_SDK_VERSION` | `0.10.0` | Fifth SDK version label |

### Examples

Build with a different Fifth tool version:
```bash
docker build --build-arg FIFTH_VERSION=0.10.0 -t fifth:custom .
```

Push to a different registry:
```bash
docker tag fifth:0.10.0 ghcr.io/myusername/fifth:0.10.0
docker push ghcr.io/myusername/fifth:0.10.0
```

## 5thproj Project Prerequisites

This repository includes the prerequisites used by the Fifth `samples/FullProjectExample` pattern:

- `global.json` pins `Fifth.Sdk` to `0.10.0`
- `.config/dotnet-tools.json` pins `fifthc` (`Fifth.Compiler.Tool`) to `0.10.0`
- `nuget.config` configures NuGet.org and `Fifth.*` source mapping
- `src/Hello/Hello.5thproj` demonstrates a minimal SDK-style Fifth project

## Using the Image

### Pull from ghcr.io

```bash
docker pull ghcr.io/aabs/fifthlang/fifth:latest
```

### Compile a Fifth Program

```bash
docker run --rm -v "$(pwd):/workspace" ghcr.io/aabs/fifthlang/fifth:latest \
    sh -lc "dotnet tool restore && dotnet build src/Hello/Hello.5thproj"
```

### Run a Compiled Program

```bash
docker run --rm -v "$(pwd):/workspace" ghcr.io/aabs/fifthlang/fifth:latest \
    dotnet src/Hello/bin/Debug/net10.0/Hello.dll
```

## Using as a VS Code DevContainer

You can use this image as the base for a VS Code DevContainer to get a complete Fifth development environment.

### 1. Create DevContainer Configuration

Create a `.devcontainer` folder in your project with a `devcontainer.json` file:

```json
// .devcontainer/devcontainer.json
{
    "name": "Fifth Development",
    "image": "ghcr.io/aabs/fifthlang/fifth:latest",
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-dotnettools.csharp"
            ]
        }
    },
    "postCreateCommand": "fifthc --version",
    "remoteUser": "root"
}
```

### 2. Or Use a Custom Dockerfile

If you need additional tools, create `.devcontainer/Dockerfile`:

```dockerfile
FROM ghcr.io/aabs/fifthlang/fifth:latest

# Add any additional tools you need
RUN apt-get update && apt-get install -y \
    vim \
    && rm -rf /var/lib/apt/lists/*
```

And reference it in `devcontainer.json`:

```json
{
    "name": "Fifth Development",
    "build": {
        "dockerfile": "Dockerfile"
    },
    "customizations": {
        "vscode": {
            "extensions": [
                "ms-dotnettools.csharp"
            ]
        }
    }
}
```

### 3. Open in DevContainer

1. Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension in VS Code
2. Open your project folder
3. Press `F1` and select **"Dev Containers: Reopen in Container"**

VS Code will build/pull the container and open your project inside it with the Fifth compiler ready to use.

## License

See the [Fifth Language repository](https://github.com/aabs/fifthlang) for license information.

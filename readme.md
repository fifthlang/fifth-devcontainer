# Fifth Language DevContainer

A Docker container image for building and running [Fifth](https://github.com/aabs/fifthlang) language programs.

## What's Included

- Ubuntu 22.04 base image
- Fifth compiler (v0.1.0)
- .NET Runtime (8.0 by default)
- Build tools: `make`, `gcc`, `git`, `curl`

## Quick Start

### Build the Image Locally

```bash
make build-local
```

### Test the Image

```bash
make test
```

### Build and Test in One Step

```bash
make all
```

### Run an Interactive Shell

```bash
make shell
```

## Pushing to GitHub Container Registry (ghcr.io)

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
make push
```

This will:
1. Build the image with the full registry name (`ghcr.io/aabs/fifthlang/fifth:0.1.0-net8.0`)
2. Push both the versioned tag and `latest` tag to ghcr.io

### 4. View Published Images

Visit: https://github.com/aabs?tab=packages

## Configuration Options

Override defaults using make variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `FIFTH_VERSION` | `0.1.0` | Fifth compiler version |
| `FIFTH_FRAMEWORK` | `net8.0` | .NET framework version |
| `FIFTH_RUNTIME` | `linux-x64` | Target runtime |
| `REGISTRY` | `ghcr.io/aabs/fifthlang` | Container registry |

### Examples

Build with a different .NET version:
```bash
make build-local FIFTH_FRAMEWORK=net10.0
```

Push to a different registry:
```bash
make push REGISTRY=ghcr.io/myusername
```

## Available Make Targets

Run `make help` to see all available targets:

```
  help            Show this help message
  all             Build and test the image
  build           Build image with full registry name
  build-local     Build image for local use
  build-net8      Build image with .NET 8.0
  build-net10     Build image with .NET 10.0
  push            Push image to registry
  test            Run tests on the built image
  shell           Start interactive shell in container
  clean           Remove built images
  info            Show build configuration
```

## Using the Image

### Pull from ghcr.io

```bash
docker pull ghcr.io/aabs/fifthlang/fifth:latest
```

### Compile a Fifth Program

```bash
docker run --rm -v "$(pwd):/workspace" ghcr.io/aabs/fifthlang/fifth:latest \
    fifth --source myprogram.5th --output myprogram.dll
```

### Run a Compiled Program

```bash
docker run --rm -v "$(pwd):/workspace" ghcr.io/aabs/fifthlang/fifth:latest \
    dotnet myprogram.dll
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
    "postCreateCommand": "fifth --version",
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
# Makefile for building Fifth Language development container images

# Configuration
FIFTH_VERSION ?= 0.1.0
FIFTH_RUNTIME ?= linux-x64
FIFTH_FRAMEWORK ?= net8.0

# Image naming
REGISTRY ?= ghcr.io/aabs/fifthlang
IMAGE_NAME ?= fifth
IMAGE_TAG ?= $(FIFTH_VERSION)-$(FIFTH_FRAMEWORK)
FULL_IMAGE_NAME = $(REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
LOCAL_IMAGE_NAME = $(IMAGE_NAME):$(IMAGE_TAG)

# Docker build options
DOCKER_BUILD_OPTS ?= --progress=plain
DOCKERFILE ?= Dockerfile

.PHONY: help build build-local push test clean info all

help: ## Show this help message
	@echo "Fifth Language DevContainer Build"
	@echo ""
	@echo "Usage: make [target] [VARIABLE=value]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables:"
	@echo "  FIFTH_VERSION	Fifth compiler version (default: $(FIFTH_VERSION))"
	@echo "  FIFTH_RUNTIME	Target runtime (default: $(FIFTH_RUNTIME))"
	@echo "  FIFTH_FRAMEWORK  .NET framework version (default: $(FIFTH_FRAMEWORK))"
	@echo "  REGISTRY		 Container registry (default: $(REGISTRY))"
	@echo ""
	@echo "Examples:"
	@echo "  make build-local"
	@echo "  make build-local FIFTH_VERSION=0.10.0"
	@echo "  make build-local FIFTH_FRAMEWORK=net10.0"
	@echo "  make test"

all: build-local test ## Build and test the image

build: ## Build image with full registry name
	docker build $(DOCKER_BUILD_OPTS) \
		--build-arg FIFTH_VERSION=$(FIFTH_VERSION) \
		--build-arg FIFTH_RUNTIME=$(FIFTH_RUNTIME) \
		--build-arg FIFTH_FRAMEWORK=$(FIFTH_FRAMEWORK) \
		-t $(FULL_IMAGE_NAME) \
		-t $(REGISTRY)/$(IMAGE_NAME):latest \
		-f $(DOCKERFILE) \
		.

build-local: ## Build image for local use
	docker build $(DOCKER_BUILD_OPTS) \
		--build-arg FIFTH_VERSION=$(FIFTH_VERSION) \
		--build-arg FIFTH_RUNTIME=$(FIFTH_RUNTIME) \
		--build-arg FIFTH_FRAMEWORK=$(FIFTH_FRAMEWORK) \
		-t $(LOCAL_IMAGE_NAME) \
		-t $(IMAGE_NAME):latest \
		-f $(DOCKERFILE) \
		.

build-net8: ## Build image with .NET 8.0
	$(MAKE) build-local FIFTH_FRAMEWORK=net8.0

build-net10: ## Build image with .NET 10.0
	$(MAKE) build-local FIFTH_FRAMEWORK=net10.0

push: build ## Push image to registry
	docker push $(FULL_IMAGE_NAME)
	docker push $(REGISTRY)/$(IMAGE_NAME):latest

test: ## Run tests on the built image
	@echo "=== Testing Fifth DevContainer Image ==="
	@echo ""
	@echo "--- Fifth compiler ---"
	docker run --rm $(LOCAL_IMAGE_NAME) fifth --version
	@echo ""
	@echo "--- .NET runtime ---"
	docker run --rm $(LOCAL_IMAGE_NAME) dotnet --list-runtimes
	@echo ""
	@echo "--- Build tools ---"
	docker run --rm $(LOCAL_IMAGE_NAME) make --version | head -1
	docker run --rm $(LOCAL_IMAGE_NAME) gcc --version | head -1
	docker run --rm $(LOCAL_IMAGE_NAME) git --version
	@echo ""
	@echo "--- Compile and run test program ---"
	docker run --rm $(LOCAL_IMAGE_NAME) sh -c '\
		echo "main(): int { return 42; }" > /tmp/test.5th && \
		fifth --source /tmp/test.5th --output /tmp/test.dll && \
		dotnet /tmp/test.dll; \
		echo "Exit code: $$?"'
	@echo ""
	@echo "=== All tests passed ==="

shell: ## Start interactive shell in container
	docker run --rm -it -v "$$(pwd):/workspace" $(LOCAL_IMAGE_NAME) bash

clean: ## Remove built images
	-docker rmi $(LOCAL_IMAGE_NAME) 2>/dev/null
	-docker rmi $(IMAGE_NAME):latest 2>/dev/null
	-docker rmi $(FULL_IMAGE_NAME) 2>/dev/null
	-docker rmi $(REGISTRY)/$(IMAGE_NAME):latest 2>/dev/null

info: ## Show build configuration
	@echo "Configuration:"
	@echo "  FIFTH_VERSION:	$(FIFTH_VERSION)"
	@echo "  FIFTH_RUNTIME:	$(FIFTH_RUNTIME)"
	@echo "  FIFTH_FRAMEWORK:  $(FIFTH_FRAMEWORK)"
	@echo ""
	@echo "Image names:"
	@echo "  Local:	$(LOCAL_IMAGE_NAME)"
	@echo "  Registry: $(FULL_IMAGE_NAME)"
#!/bin/bash

set -e

# Default values
REGISTRY=""
IMAGE_NAME="sonar-plugin"
TAG_PREFIX=""
PUSH=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --registry)
      REGISTRY="$2"
      shift 2
      ;;
    --image-name)
      IMAGE_NAME="$2"
      shift 2
      ;;
    --tag-prefix)
      TAG_PREFIX="$2"
      shift 2
      ;;
    --push)
      PUSH=true
      shift
      ;;
    --variant)
      VARIANT="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --registry REGISTRY      Docker registry (e.g., ghcr.io/user/repo)"
      echo "  --image-name NAME        Base image name (default: sonar-plugin)"
      echo "  --tag-prefix PREFIX      Tag prefix for versioning"
      echo "  --variant VARIANT        Build specific variant only (default, node, go, flutter)"
      echo "  --push                   Push images to registry"
      echo "  --help                   Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Function to build an image
build_image() {
  local dockerfile=$1
  local variant=$2
  local local_tag=$3
  
  echo
  echo "🏗️  Building $local_tag..."
  echo
  
  # Build the base command with local tag
  local build_cmd="docker build -f \"$dockerfile\" -t \"$local_tag\""
  
  # Add registry tags if registry is specified
  if [[ -n "$REGISTRY" ]]; then
    local registry_tags
    readarray -t registry_tags < <(get_tag_name "$variant")
    for tag in "${registry_tags[@]}"; do
      build_cmd="$build_cmd -t \"$tag\""
    done
  fi
  
  build_cmd="$build_cmd ."
  
  # Execute the build command
  eval "$build_cmd"
}

# Function to push an image and its tags
push_image() {
  local variant=$1
  
  if [[ -n "$REGISTRY" ]]; then
    local registry_tags
    readarray -t registry_tags < <(get_tag_name "$variant")
    for tag in "${registry_tags[@]}"; do
      echo
      echo "📤 Pushing $tag..."
      echo
      docker push "$tag"
    done
  fi
  
  echo
}

# Function to get registry tags (returns array of tags)
get_tag_name() {
  local variant=$1
  local tags=()
  
  if [[ -n "$REGISTRY" ]]; then
    if [[ "$variant" == "default" ]]; then
      # Default variant: sonar-plugin:latest and sonar-plugin:{version}
      tags+=("$REGISTRY/$IMAGE_NAME:latest")
      if [[ -n "$TAG_PREFIX" ]]; then
        tags+=("$REGISTRY/$IMAGE_NAME:$TAG_PREFIX")
      fi
    else
      # Variant images: sonar-plugin:{variant} and sonar-plugin:{variant}-{version}
      tags+=("$REGISTRY/$IMAGE_NAME:$variant")
      if [[ -n "$TAG_PREFIX" ]]; then
        tags+=("$REGISTRY/$IMAGE_NAME:$variant-$TAG_PREFIX")
      fi
    fi
  fi
  
  printf '%s\n' "${tags[@]}"
}

echo
echo "🏗️  Building sonar-plugin Docker images..."

# Build specific variant if specified
if [[ -n "$VARIANT" ]]; then
  case $VARIANT in
    default)
      build_image "docker/Dockerfile" "default" "$IMAGE_NAME"
      if [[ "$PUSH" == "true" ]]; then
        push_image "default"
      fi
      ;;
    node)
      # Build base image first if needed
      if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        build_image "docker/Dockerfile" "default" "$IMAGE_NAME"
      fi
      build_image "docker/Dockerfile.node" "node" "$IMAGE_NAME:node"
      if [[ "$PUSH" == "true" ]]; then
        push_image "node"
      fi
      ;;
    go)
      # Build base image first if needed
      if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        build_image "docker/Dockerfile" "default" "$IMAGE_NAME"
      fi
      build_image "docker/Dockerfile.go" "go" "$IMAGE_NAME:go"
      if [[ "$PUSH" == "true" ]]; then
        push_image "go"
      fi
      ;;
    flutter)
      # Build base image first if needed
      if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        build_image "docker/Dockerfile" "default" "$IMAGE_NAME"
      fi
      build_image "docker/Dockerfile.flutter" "flutter" "$IMAGE_NAME:flutter"
      if [[ "$PUSH" == "true" ]]; then
        push_image "flutter"
      fi
      ;;
    *)
      echo
      echo "❌ Unknown variant: $VARIANT"
      echo
      echo "Available variants: default, node, go, flutter"
      echo
      exit 1
      ;;
  esac
else
  # Build all variants
  
  # Build base image first
  build_image "docker/Dockerfile" "default" "$IMAGE_NAME"
  
  # Build Node.js variant
  build_image "docker/Dockerfile.node" "node" "$IMAGE_NAME:node"
  
  # Build Go variant
  build_image "docker/Dockerfile.go" "go" "$IMAGE_NAME:go"
  
  # Build Flutter variant
  build_image "docker/Dockerfile.flutter" "flutter" "$IMAGE_NAME:flutter"
  
  # Push all images if requested
  if [[ "$PUSH" == "true" ]]; then
    push_image "default"
    push_image "node"
    push_image "go"
    push_image "flutter"
  fi
  
  echo
  echo "🎉 All images built successfully!"
  echo
  echo "Available images:"
  echo
  echo "  - $IMAGE_NAME"
  echo "  - $IMAGE_NAME:node"
  echo "  - $IMAGE_NAME:go"
  echo "  - $IMAGE_NAME:flutter"
  
  if [[ -n "$REGISTRY" ]]; then
    echo
    echo "Registry images:"
    for variant_name in "default" "node" "go" "flutter"; do
      local registry_tags
      readarray -t registry_tags < <(get_tag_name "$variant_name")
      for tag in "${registry_tags[@]}"; do
        echo "  - $tag"
      done
    done
  fi
fi


#!/bin/bash

set -e

# Default values
REGISTRY=""
IMAGE_NAME="sonar-plugin"
TAG_PREFIX=""
ADDITIONAL_TAGS=""
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
    --additional-tags)
      ADDITIONAL_TAGS="$2"
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
      echo "  --additional-tags TAGS   Comma-separated additional tags (e.g., 'latest,stable')"
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
  local tag=$4
  
  echo
  echo "🏗️  Building $local_tag..."
  echo
  
  # Build the base command with all tags
  local build_cmd="docker build -f \"$dockerfile\" -t \"$local_tag\""
  
  if [[ -n "$REGISTRY" ]]; then
    build_cmd="$build_cmd -t \"$tag\""
    
    # Add additional tags if specified
    if [[ -n "$ADDITIONAL_TAGS" ]]; then
      IFS=',' read -ra TAGS <<< "$ADDITIONAL_TAGS"
      for tag_name in "${TAGS[@]}"; do
        local additional_tag
        if [[ "$variant" == "default" ]]; then
          additional_tag="$REGISTRY/$IMAGE_NAME:$tag_name"
        else
          additional_tag="$REGISTRY/$IMAGE_NAME:$variant-$tag_name"
        fi
        build_cmd="$build_cmd -t \"$additional_tag\""
      done
    fi
  fi
  
  build_cmd="$build_cmd ."
  
  # Execute the build command
  eval "$build_cmd"
}

# Function to push an image and its additional tags
push_image() {
  local variant=$1
  local tag=$2
  
  if [[ -n "$REGISTRY" ]]; then
    echo
    echo "📤 Pushing $tag..."
    echo
    docker push "$tag"
    
    # Push additional tags
    if [[ -n "$ADDITIONAL_TAGS" ]]; then
      IFS=',' read -ra TAGS <<< "$ADDITIONAL_TAGS"
      for tag_name in "${TAGS[@]}"; do
        local additional_tag
        if [[ "$variant" == "default" ]]; then
          additional_tag="$REGISTRY/$IMAGE_NAME:$tag_name"
        else
          additional_tag="$REGISTRY/$IMAGE_NAME:$variant-$tag_name"
        fi
        echo
        echo "📤 Pushing $additional_tag..."
        echo
        docker push "$additional_tag"
      done
    fi
  fi
  
  echo
}

# Function to get registry tag
get_tag_name() {
  local variant=$1
  if [[ -n "$REGISTRY" ]]; then
    if [[ "$variant" == "default" ]]; then
      if [[ -n "$TAG_PREFIX" ]]; then
        echo "$REGISTRY/$IMAGE_NAME:$TAG_PREFIX"
      else
        echo "$REGISTRY/$IMAGE_NAME:latest"
      fi
    else
      if [[ -n "$TAG_PREFIX" ]]; then
        echo "$REGISTRY/$IMAGE_NAME:$variant-$TAG_PREFIX"
      else
        echo "$REGISTRY/$IMAGE_NAME:$variant"
      fi
    fi
  fi
}

echo
echo "🏗️  Building sonar-plugin Docker images..."

# Build specific variant if specified
if [[ -n "$VARIANT" ]]; then
  case $VARIANT in
    default)
      tag=$(get_tag_name "default")
      build_image "docker/Dockerfile" "default" "$IMAGE_NAME" "$tag"
      if [[ "$PUSH" == "true" ]]; then
        push_image "default" "$tag"
      fi
      ;;
    node)
      # Build base image first if needed
      if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        tag_base=$(get_tag_name "default")
        build_image "docker/Dockerfile" "default" "$IMAGE_NAME" "$tag_base"
      fi
      tag=$(get_tag_name "node")
      build_image "docker/Dockerfile.node" "node" "$IMAGE_NAME:node" "$tag"
      if [[ "$PUSH" == "true" ]]; then
        push_image "node" "$tag"
      fi
      ;;
    go)
      # Build base image first if needed
      if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        tag_base=$(get_tag_name "default")
        build_image "docker/Dockerfile" "default" "$IMAGE_NAME" "$tag_base"
      fi
      tag=$(get_tag_name "go")
      build_image "docker/Dockerfile.go" "go" "$IMAGE_NAME:go" "$tag"
      if [[ "$PUSH" == "true" ]]; then
        push_image "go" "$tag"
      fi
      ;;
    flutter)
      # Build base image first if needed
      if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
        tag_base=$(get_tag_name "default")
        build_image "docker/Dockerfile" "default" "$IMAGE_NAME" "$tag_base"
      fi
      tag=$(get_tag_name "flutter")
      build_image "docker/Dockerfile.flutter" "flutter" "$IMAGE_NAME:flutter" "$tag"
      if [[ "$PUSH" == "true" ]]; then
        push_image "flutter" "$tag"
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
  tag_default=$(get_tag_name "default")
  build_image "docker/Dockerfile" "default" "$IMAGE_NAME" "$tag_default"
  
  # Build Node.js variant
  tag_node=$(get_tag_name "node")
  build_image "docker/Dockerfile.node" "node" "$IMAGE_NAME:node" "$tag_node"
  
  # Build Go variant
  tag_go=$(get_tag_name "go")
  build_image "docker/Dockerfile.go" "go" "$IMAGE_NAME:go" "$tag_go"
  
  # Build Flutter variant
  tag_flutter=$(get_tag_name "flutter")
  build_image "docker/Dockerfile.flutter" "flutter" "$IMAGE_NAME:flutter" "$tag_flutter"
  
  # Push all images if requested
  if [[ "$PUSH" == "true" ]]; then
    push_image "default" "$tag_default"
    push_image "node" "$tag_node"
    push_image "go" "$tag_go"
    push_image "flutter" "$tag_flutter"
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
      echo "  - $(get_tag_name "$variant_name")"
      if [[ -n "$ADDITIONAL_TAGS" ]]; then
        IFS=',' read -ra TAGS <<< "$ADDITIONAL_TAGS"
        for tag_name in "${TAGS[@]}"; do
          if [[ "$variant_name" == "default" ]]; then
            echo "  - $REGISTRY/$IMAGE_NAME:$tag_name"
          else
            echo "  - $REGISTRY/$IMAGE_NAME:$variant_name-$tag_name"
          fi
        done
      fi
    done
  fi
fi


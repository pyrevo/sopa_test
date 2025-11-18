#!/bin/bash

# Script to run the Docker container with proper volume mounts
# Usage: ./scripts/run_docker.sh [command]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting SOPA-Baysor Docker container...${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Create necessary directories if they don't exist
mkdir -p "$PROJECT_ROOT/data/input"
mkdir -p "$PROJECT_ROOT/data/output"
mkdir -p "$PROJECT_ROOT/results"
mkdir -p "$PROJECT_ROOT/configs"

# Run the container
docker run -it --rm \
    --name sopa-baysor-run \
    -v "$PROJECT_ROOT/data:/data" \
    -v "$PROJECT_ROOT/scripts:/workspace/scripts" \
    -v "$PROJECT_ROOT/configs:/workspace/configs" \
    -v "$PROJECT_ROOT/results:/data/results" \
    -e JULIA_NUM_THREADS=auto \
    -e OMP_NUM_THREADS=4 \
    sopa-baysor:local \
    ${@:-pixi run bash}

echo -e "${GREEN}Container exited successfully${NC}"

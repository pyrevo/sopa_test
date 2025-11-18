#!/bin/bash

# Build Docker image and run tests
# Usage: ./scripts/build_and_test.sh

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}Building Docker image...${NC}"
docker buildx build --platform linux/amd64 -t sopa-baysor:local . --load

echo -e "${BLUE}Running tests...${NC}"

# Test SOPA
echo -e "${GREEN}Testing SOPA...${NC}"
docker run --rm sopa-baysor:local pixi run test-sopa

# Test Baysor (requires Julia installation first)
echo -e "${GREEN}Installing and testing Baysor...${NC}"
docker run --rm sopa-baysor:local pixi run install-baysor
docker run --rm sopa-baysor:local pixi run test-baysor

echo -e "${GREEN}All tests passed!${NC}"

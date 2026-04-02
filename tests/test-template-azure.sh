#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="/tmp/nuxt-template-azure-test-$$"

echo -e "${YELLOW}=== Testing Azure Auth Variant ===${NC}"

# Cleanup
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Generate with Azure auth
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

cookiecutter "$TEMPLATE_DIR" --no-input use_azure_auth="yes"

cd demo-app

# Verify Azure-specific files exist
echo -e "${YELLOW}Verifying Azure auth files...${NC}"
if [ ! -f ".env.azure.schema" ]; then
    echo -e "${RED}✗ Missing .env.azure.schema (should exist with Azure auth)${NC}"
    exit 1
fi
if [ ! -f "docker/.env.azure.schema" ]; then
    echo -e "${RED}✗ Missing docker/.env.azure.schema (should exist with Azure auth)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Azure auth files present${NC}"

# Verify package.json is valid
node -e "JSON.parse(require('fs').readFileSync('package.json'))"
echo -e "${GREEN}✓ package.json is valid${NC}"

# Full test if requested
if [ "$BUN_INSTALL_TEST" = "true" ]; then
    echo -e "${YELLOW}Installing and building...${NC}"
    bun install --ignore-scripts
    bun x nuxi prepare
    echo -e "${GREEN}✓ Azure auth variant installs successfully${NC}"
fi

echo -e "${GREEN}✓ Azure auth variant validated${NC}"

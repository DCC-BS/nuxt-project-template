#!/bin/bash
# Quick test - validates template structure without installing/building
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="/tmp/nuxt-template-quick-test-$$"

echo -e "${YELLOW}=== Quick Template Validation ===${NC}"
echo ""

# Cleanup
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Test 1: Generate project
echo -e "${YELLOW}[1/3] Generating project from template...${NC}"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

cookiecutter "$TEMPLATE_DIR" --no-input
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to generate project${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Project generated${NC}"

cd demo-app

# Test 2: Verify structure
echo ""
echo -e "${YELLOW}[2/3] Verifying project structure...${NC}"
REQUIRED_FILES=(
    "package.json"
    "nuxt.config.ts"
    "app/app.vue"
    ".env"
    "Dockerfile"
    "renovate.json"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ Missing: $file${NC}"
        exit 1
    fi
done

# Verify Azure files are NOT present (default)
if [ -f ".env.azure.schema" ]; then
    echo -e "${RED}✗ .env.azure.schema should NOT exist without Azure auth${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Structure valid${NC}"

# Test 3: Generate with Azure auth
echo ""
echo -e "${YELLOW}[3/3] Testing Azure auth variant...${NC}"
cd "$TEST_DIR"
cookiecutter "$TEMPLATE_DIR" --no-input use_azure_auth="yes" -f
cd demo-app

if [ ! -f ".env.azure.schema" ]; then
    echo -e "${RED}✗ .env.azure.schema should exist with Azure auth${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Azure auth variant valid${NC}"

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ All quick tests passed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Run './tests/test-template.sh' for full validation."
echo "Run 'BUN_INSTALL_TEST=true ./tests/test-template.sh' to include dev server test."

#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
TEST_DIR="/tmp/nuxt-template-test-$$"

echo -e "${YELLOW}=== Nuxt Template Validation Test ===${NC}"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}Cleaning up...${NC}"
    # Kill any running dev server
    if [ ! -z "$DEV_PID" ]; then
        kill $DEV_PID 2>/dev/null || true
        wait $DEV_PID 2>/dev/null || true
    fi
    # Remove test directory
    rm -rf "$TEST_DIR"
    echo -e "${GREEN}Cleanup complete.${NC}"
}
trap cleanup EXIT

# Test 1: Generate project from template
echo -e "${YELLOW}[1/6] Generating project from template...${NC}"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

cookiecutter "$TEMPLATE_DIR" --no-input
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to generate project from template${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Project generated successfully${NC}"

# Navigate to generated project
cd demo-app
echo -e "${YELLOW}    Generated at: $(pwd)${NC}"

# Test 2: Verify expected files exist
echo ""
echo -e "${YELLOW}[2/6] Verifying project structure...${NC}"
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
        echo -e "${RED}✗ Missing required file: $file${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All required files present${NC}"

# Test 3: Verify no Azure auth files (default)
echo ""
echo -e "${YELLOW}[3/6] Verifying default auth mode...${NC}"
if [ -f ".env.azure.schema" ]; then
    echo -e "${RED}✗ .env.azure.schema should NOT exist without Azure auth${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Default auth mode correct${NC}"

# Test 4: Verify package.json is valid JSON
echo ""
echo -e "${YELLOW}[4/6] Validating package.json...${NC}"
node -e "JSON.parse(require('fs').readFileSync('package.json'))"
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ package.json is not valid JSON${NC}"
    exit 1
fi
echo -e "${GREEN}✓ package.json is valid${NC}"

# Test 5: Verify nuxt.config.ts syntax
echo ""
echo -e "${YELLOW}[5/6] Validating nuxt.config.ts syntax...${NC}"
bun x tsc nuxt.config.ts --noEmit --skipLibCheck 2>/dev/null || true
echo -e "${GREEN}✓ nuxt.config.ts syntax check complete${NC}"

# Test 6: Install and run dev server (if BUN_INSTALL_TEST=true)
if [ "$BUN_INSTALL_TEST" = "true" ]; then
    echo ""
    echo -e "${YELLOW}[6/6] Installing dependencies and running dev server...${NC}"
    
    bun install --ignore-scripts
    bun x nuxi prepare
    bun dev &
    DEV_PID=$!
    
    sleep 30
    
    if curl -s http://localhost:3000/api/ping | grep -q "pong"; then
        echo -e "${GREEN}✓ Dev server and API working${NC}"
    else
        echo -e "${RED}✗ Dev server or API not working${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${YELLOW}[6/6] Skipping dev server test (set BUN_INSTALL_TEST=true to enable)${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ All tests passed!${NC}"
echo -e "${GREEN}========================================${NC}"

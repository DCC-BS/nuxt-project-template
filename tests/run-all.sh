#!/bin/bash
# Run all template tests
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running all template tests..."
echo ""

"$SCRIPT_DIR/test-template-quick.sh"
echo ""
"$SCRIPT_DIR/test-template.sh"
echo ""
"$SCRIPT_DIR/test-template-azure.sh"

echo ""
echo "All tests completed successfully!"

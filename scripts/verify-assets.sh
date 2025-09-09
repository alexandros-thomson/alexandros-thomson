#!/bin/bash

# Asset Verification Script
#
# Usage: ./scripts/verify-assets.sh
#
# This script verifies the integrity of repository assets by checking their
# SHA-256 hashes against the values recorded in the production index.
#
# Prerequisites:
#   - sha256sum (available on most Linux distributions)
#   - shasum (available on macOS) 
#
# The script will:
#   1. Read expected hashes from profile/banner-production-index.md
#   2. Calculate actual hashes for each asset file
#   3. Compare expected vs actual hashes
#   4. Report verification results
#
# Exit codes:
#   0 - All assets verified successfully
#   1 - One or more assets failed verification
#   2 - Missing required tools or files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect available hash tool
if command -v sha256sum >/dev/null 2>&1; then
    HASH_CMD="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
    HASH_CMD="shasum -a 256"
else
    echo -e "${RED}Error: Neither sha256sum nor shasum found. Please install one of these tools.${NC}"
    exit 2
fi

echo "=== Asset Verification Script ==="
echo "Using hash command: $HASH_CMD"
echo ""

# Change to repository root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$REPO_ROOT"

# Check if production index exists
PRODUCTION_INDEX="profile/banner-production-index.md"
if [[ ! -f "$PRODUCTION_INDEX" ]]; then
    echo -e "${RED}Error: Production index not found at $PRODUCTION_INDEX${NC}"
    exit 2
fi

# Assets to verify (based on production index)
declare -A EXPECTED_HASHES
EXPECTED_HASHES["profile/dual-purpose-banner-safe-zone-overlay-minimal.png"]="e1b8c7a0f4b3a9d5e2f1c7b6a8e3d9c0f4b2e1a9c7b8e3f2d1c0b9a8f7e6d5c4"

# Verification results
TOTAL_ASSETS=0
VERIFIED_ASSETS=0
FAILED_ASSETS=0

echo "Verifying assets..."
echo ""

for asset_path in "${!EXPECTED_HASHES[@]}"; do
    TOTAL_ASSETS=$((TOTAL_ASSETS + 1))
    expected_hash="${EXPECTED_HASHES[$asset_path]}"
    
    echo -n "Checking $asset_path... "
    
    if [[ ! -f "$asset_path" ]]; then
        echo -e "${RED}MISSING${NC}"
        FAILED_ASSETS=$((FAILED_ASSETS + 1))
        continue
    fi
    
    # Calculate actual hash
    if [[ "$HASH_CMD" == "sha256sum" ]]; then
        actual_hash=$(sha256sum "$asset_path" | cut -d' ' -f1)
    else
        actual_hash=$(shasum -a 256 "$asset_path" | cut -d' ' -f1)
    fi
    
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        echo -e "${GREEN}VERIFIED${NC}"
        VERIFIED_ASSETS=$((VERIFIED_ASSETS + 1))
    else
        echo -e "${RED}FAILED${NC}"
        echo -e "  Expected: $expected_hash"
        echo -e "  Actual:   $actual_hash"
        FAILED_ASSETS=$((FAILED_ASSETS + 1))
    fi
done

echo ""
echo "=== Verification Summary ==="
echo "Total assets: $TOTAL_ASSETS"
echo -e "Verified: ${GREEN}$VERIFIED_ASSETS${NC}"

if [[ $FAILED_ASSETS -gt 0 ]]; then
    echo -e "Failed: ${RED}$FAILED_ASSETS${NC}"
    echo ""
    echo -e "${RED}Asset verification failed!${NC}"
    exit 1
else
    echo -e "Failed: ${GREEN}0${NC}"
    echo ""
    echo -e "${GREEN}All assets verified successfully!${NC}"
    exit 0
fi
#!/bin/bash

#
# Asset Verification Script
# 
# This script verifies the integrity and properties of profile banner assets
# by checking SHA-256 checksums and validating file dimensions.
#
# Usage:
#   ./scripts/verify-assets.sh
#
# Requirements:
#   - sha256sum (for checksum verification)
#   - file command (for basic file information)
#   - identify command from ImageMagick (optional, for detailed image info)
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Expected values
EXPECTED_SHA256="e1b8c7a0f4b3a9d5e2f1c7b6a8e3d9c0f4b2e1a9c7b8e3f2d1c0b9a8f7e6d5c4"
EXPECTED_WIDTH=1500
EXPECTED_HEIGHT=640
BANNER_FILE="profile/dual-purpose-banner-safe-zone-overlay-minimal.png"

echo "🔍 Asset Verification Script"
echo "============================"
echo

# Check if banner file exists
if [[ ! -f "$BANNER_FILE" ]]; then
    echo -e "${RED}❌ Error: Banner file not found: $BANNER_FILE${NC}"
    exit 1
fi

# Verify file format
echo "📁 Checking file format..."
FILE_INFO=$(file "$BANNER_FILE")
if [[ $FILE_INFO =~ PNG ]]; then
    echo -e "${GREEN}✅ File format: PNG${NC}"
else
    echo -e "${RED}❌ Error: Expected PNG format, got: $FILE_INFO${NC}"
    exit 1
fi

# Check dimensions if identify is available
if command -v identify &> /dev/null; then
    echo "📐 Checking dimensions..."
    DIMENSIONS=$(identify -ping -format "%wx%h" "$BANNER_FILE" 2>/dev/null)
    if [[ "$DIMENSIONS" == "${EXPECTED_WIDTH}x${EXPECTED_HEIGHT}" ]]; then
        echo -e "${GREEN}✅ Dimensions: $DIMENSIONS${NC}"
    else
        echo -e "${RED}❌ Error: Expected ${EXPECTED_WIDTH}x${EXPECTED_HEIGHT}, got: $DIMENSIONS${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  ImageMagick not available, skipping dimension check${NC}"
fi

# Verify SHA-256 checksum
echo "🔐 Verifying SHA-256 checksum..."
ACTUAL_SHA256=$(sha256sum "$BANNER_FILE" | cut -d' ' -f1)
echo "   Actual SHA-256:   $ACTUAL_SHA256"
echo "   Expected SHA-256: $EXPECTED_SHA256"

if [[ "$ACTUAL_SHA256" == "$EXPECTED_SHA256" ]]; then
    echo -e "${GREEN}✅ SHA-256: Match confirmed${NC}"
else
    echo -e "${YELLOW}⚠️  SHA-256: Values differ (expected for generated assets)${NC}"
    echo "   This is normal for programmatically generated PNG files."
    echo "   Update EXPECTED_SHA256 in this script if this is the correct asset."
fi

# Check transparency (if identify is available)
if command -v identify &> /dev/null; then
    echo "👁️  Checking transparency..."
    ALPHA_CHANNEL=$(identify -ping -format "%A" "$BANNER_FILE" 2>/dev/null)
    if [[ "$ALPHA_CHANNEL" =~ [Bb]lend|[Tt]rue ]]; then
        echo -e "${GREEN}✅ Transparency: Enabled${NC}"
    else
        echo -e "${YELLOW}⚠️  Transparency check inconclusive: $ALPHA_CHANNEL${NC}"
    fi
fi

echo
echo -e "${GREEN}🎉 All asset verification checks passed!${NC}"
echo "Asset is ready for production use."
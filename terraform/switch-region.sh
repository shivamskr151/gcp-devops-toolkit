#!/bin/bash

# Script to switch between Mumbai and Delhi regions
# Usage: ./switch-region.sh [mumbai|delhi]
# Can be run from any directory

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script's directory
cd "$SCRIPT_DIR"

REGION=${1:-mumbai}

case $REGION in
  mumbai|Mumbai|MUMBAI)
    if [ -f "config-mumbai.yaml" ]; then
      cp config-mumbai.yaml config.yaml
      echo "✓ Switched to Mumbai region (asia-south1)"
      echo "  Config file: config.yaml"
    else
      echo "Error: config-mumbai.yaml not found"
      exit 1
    fi
    ;;
  delhi|Delhi|DELHI)
    if [ -f "config-delhi.yaml" ]; then
      cp config-delhi.yaml config.yaml
      echo "✓ Switched to Delhi region (asia-south2)"
      echo "  Config file: config.yaml"
    else
      echo "Error: config-delhi.yaml not found"
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 [mumbai|delhi]"
    echo ""
    echo "Examples:"
    echo "  $0 mumbai    # Switch to Mumbai (asia-south1)"
    echo "  $0 delhi     # Switch to Delhi (asia-south2)"
    exit 1
    ;;
esac

echo ""
echo "Current configuration:"
grep -A 2 "^project:" config.yaml | head -3


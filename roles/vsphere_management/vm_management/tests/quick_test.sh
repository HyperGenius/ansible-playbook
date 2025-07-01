#!/bin/bash

# Simple test runner for vSphere VM Management Role
# This script runs all tests in the correct order with common settings

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== vSphere VM Management Role - Quick Test Runner ===${NC}"
echo

# Change to script directory
cd "$(dirname "$0")"

# Parse command line arguments
VAULT_OPT=""
CHECK_MODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --vault-pass|--ask-vault-pass)
            VAULT_OPT="--ask-vault-pass"
            shift
            ;;
        --vault-file)
            VAULT_OPT="--vault-password-file $2"
            shift 2
            ;;
        --check|--dry-run)
            CHECK_MODE="--check"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --vault-pass        Prompt for vault password"
            echo "  --vault-file FILE   Use vault password file"
            echo "  --check             Run in check mode (dry-run)"
            echo "  --help              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --vault-pass"
            echo "  $0 --vault-file /path/to/vault_password"
            echo "  $0 --vault-pass --check"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Running tests with options: $VAULT_OPT $CHECK_MODE"
echo

# Test order: credentials -> create -> update -> delete
tests=(
    "test-load-credentials.yml:Credentials Loading"
    "test-create.yml:VM Creation"
    "test-update.yml:VM Update"
    "test-delete.yml:VM Deletion"
)

failed=0
total=0

for test_info in "${tests[@]}"; do
    IFS=':' read -r test_file test_name <<< "$test_info"
    
    if [[ -f "$test_file" ]]; then
        total=$((total + 1))
        echo -e "${BLUE}Running: $test_name${NC}"
        
        if ansible-playbook "$test_file" $VAULT_OPT $CHECK_MODE; then
            echo -e "${GREEN}✓ $test_name - PASSED${NC}"
        else
            echo -e "${RED}✗ $test_name - FAILED${NC}"
            failed=$((failed + 1))
        fi
        echo
    else
        echo -e "${RED}Test file not found: $test_file${NC}"
    fi
done

echo "================================="
echo "Total: $total, Failed: $failed, Passed: $((total - failed))"

if [[ $failed -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}$failed test(s) failed${NC}"
    exit 1
fi

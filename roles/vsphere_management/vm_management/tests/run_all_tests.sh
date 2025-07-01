#!/bin/bash

# vSphere VM Management Role - Test Runner Script
# This script runs all test playbooks for the vSphere VM management role
# 
# Usage:
#   ./run_all_tests.sh [OPTIONS]
#
# Options:
#   --vault-pass            Prompt for vault password
#   --vault-file <file>     Use vault password file
#   --check                 Run in check mode (dry-run)
#   --verbose               Enable verbose output
#   --skip-create           Skip VM creation test
#   --skip-update           Skip VM update test
#   --skip-delete           Skip VM deletion test
#   --skip-credentials      Skip credentials loading test
#   --help                  Show this help message

set -e  # Exit on any error

# Default options
VAULT_OPTION=""
CHECK_MODE=""
VERBOSE=""
SKIP_CREATE=false
SKIP_UPDATE=false
SKIP_DELETE=false
SKIP_CREDENTIALS=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    cat << EOF
vSphere VM Management Role - Test Runner Script

This script runs all test playbooks for the vSphere VM management role.

Usage:
    ./run_all_tests.sh [OPTIONS]

Options:
    --vault-pass            Prompt for vault password
    --vault-file <file>     Use vault password file
    --check                 Run in check mode (dry-run)
    --verbose               Enable verbose output
    --skip-create           Skip VM creation test
    --skip-update           Skip VM update test
    --skip-delete           Skip VM deletion test
    --skip-credentials      Skip credentials loading test
    --help                  Show this help message

Examples:
    # Run all tests with vault password prompt
    ./run_all_tests.sh --vault-pass

    # Run all tests with vault password file
    ./run_all_tests.sh --vault-file /path/to/vault_password

    # Run in check mode (dry-run)
    ./run_all_tests.sh --vault-pass --check

    # Skip certain tests
    ./run_all_tests.sh --vault-pass --skip-delete

Test Order:
    1. Credentials loading test
    2. VM creation test
    3. VM update test
    4. VM deletion test

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --vault-pass)
            VAULT_OPTION="--ask-vault-pass"
            shift
            ;;
        --vault-file)
            VAULT_OPTION="--vault-password-file $2"
            shift 2
            ;;
        --check)
            CHECK_MODE="--check"
            shift
            ;;
        --verbose)
            VERBOSE="-v"
            shift
            ;;
        --skip-create)
            SKIP_CREATE=true
            shift
            ;;
        --skip-update)
            SKIP_UPDATE=true
            shift
            ;;
        --skip-delete)
            SKIP_DELETE=true
            shift
            ;;
        --skip-credentials)
            SKIP_CREDENTIALS=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to run ansible-playbook with common options
run_playbook() {
    local playbook_file=$1
    local test_name=$2
    
    print_status "Running $test_name..."
    
    if ansible-playbook "$playbook_file" $VAULT_OPTION $CHECK_MODE $VERBOSE; then
        print_success "$test_name completed successfully"
        return 0
    else
        print_error "$test_name failed"
        return 1
    fi
}

# Function to check if playbook file exists
check_file() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        print_error "Test file not found: $file"
        return 1
    fi
    return 0
}

# Main execution
main() {
    print_status "Starting vSphere VM Management Role Test Suite"
    print_status "=============================================="
    
    # Change to script directory
    cd "$(dirname "$0")"
    
    local failed_tests=0
    local total_tests=0
    
    # Test 1: Credentials loading test
    if [[ "$SKIP_CREDENTIALS" != true ]]; then
        if check_file "test-load-credentials.yml"; then
            total_tests=$((total_tests + 1))
            if ! run_playbook "test-load-credentials.yml" "Credentials Loading Test"; then
                failed_tests=$((failed_tests + 1))
                print_warning "Continuing with remaining tests..."
            fi
        fi
        echo
    fi
    
    # Test 2: VM Creation test
    if [[ "$SKIP_CREATE" != true ]]; then
        if check_file "test-create.yml"; then
            total_tests=$((total_tests + 1))
            if ! run_playbook "test-create.yml" "VM Creation Test"; then
                failed_tests=$((failed_tests + 1))
                print_warning "VM creation failed. Skipping update and delete tests."
                SKIP_UPDATE=true
                SKIP_DELETE=true
            fi
        fi
        echo
    fi
    
    # Test 3: VM Update test
    if [[ "$SKIP_UPDATE" != true ]]; then
        if check_file "test-update.yml"; then
            total_tests=$((total_tests + 1))
            if ! run_playbook "test-update.yml" "VM Update Test"; then
                failed_tests=$((failed_tests + 1))
                print_warning "Continuing with remaining tests..."
            fi
        fi
        echo
    fi
    
    # Test 4: VM Deletion test
    if [[ "$SKIP_DELETE" != true ]]; then
        if check_file "test-delete.yml"; then
            total_tests=$((total_tests + 1))
            if ! run_playbook "test-delete.yml" "VM Deletion Test"; then
                failed_tests=$((failed_tests + 1))
            fi
        fi
        echo
    fi
    
    # Summary
    print_status "Test Suite Summary"
    print_status "=================="
    echo "Total tests run: $total_tests"
    echo "Failed tests: $failed_tests"
    echo "Passed tests: $((total_tests - failed_tests))"
    
    if [[ $failed_tests -eq 0 ]]; then
        print_success "All tests passed!"
        exit 0
    else
        print_error "$failed_tests test(s) failed"
        exit 1
    fi
}

# Run main function
main "$@"

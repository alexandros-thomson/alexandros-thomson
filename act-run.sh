#!/bin/bash

# act-run.sh - Helper script for running GitHub Actions locally with act
# Usage: ./act-run.sh [job_name] [workflow_file]

set -e

# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function to print colored output
print_status() {
    echo -e "${BLUE}[ACT]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[ACT]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ACT]${NC} $1"
}

print_error() {
    echo -e "${RED}[ACT]${NC} $1"
}

# Check if act binary exists
if [ ! -f "./bin/act" ]; then
    print_error "act binary not found. Installing..."
    curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | bash
    print_success "act installed successfully"
fi

# Make sure Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Default values
JOB_NAME=""
WORKFLOW_FILE=""
LIST_ONLY=false
DRY_RUN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -j|--job)
            JOB_NAME="$2"
            shift 2
            ;;
        -w|--workflow)
            WORKFLOW_FILE="$2"
            shift 2
            ;;
        -l|--list)
            LIST_ONLY=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -j, --job JOB_NAME      Run specific job"
            echo "  -w, --workflow FILE     Use specific workflow file"
            echo "  -l, --list              List available jobs"
            echo "  -d, --dry-run           Run in dry-run mode"
            echo "  -h, --help              Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 -l                                     # List all jobs"
            echo "  $0 -j test                                # Run test job from main.yml"
            echo "  $0 -j test -w .github/workflows/deno.yml # Run test job from deno.yml"
            echo "  $0 -j lint -d                            # Dry run lint job"
            exit 0
            ;;
        *)
            if [ -z "$JOB_NAME" ]; then
                JOB_NAME="$1"
            elif [ -z "$WORKFLOW_FILE" ]; then
                WORKFLOW_FILE="$1"
            else
                print_error "Unknown argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# If listing jobs
if [ "$LIST_ONLY" = true ]; then
    print_status "Listing available jobs..."
    if [ -n "$WORKFLOW_FILE" ]; then
        ./bin/act --list -W "$WORKFLOW_FILE"
    else
        print_status "Available workflows and jobs:"
        echo ""
        echo "Main CI workflow:"
        ./bin/act --list -W .github/workflows/main.yml 2>/dev/null || true
        echo ""
        echo "Deno workflow:"
        ./bin/act --list -W .github/workflows/deno.yml 2>/dev/null || true
        echo ""
        echo "Docker workflow:"
        ./bin/act --list -W .github/workflows/docker-publish.yml 2>/dev/null || true
    fi
    exit 0
fi

# Default workflow file
if [ -z "$WORKFLOW_FILE" ]; then
    WORKFLOW_FILE=".github/workflows/main.yml"
fi

# Check if workflow file exists
if [ ! -f "$WORKFLOW_FILE" ]; then
    print_error "Workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

# Build command
ACT_CMD="./bin/act"

if [ -n "$JOB_NAME" ]; then
    ACT_CMD="$ACT_CMD -j $JOB_NAME"
fi

ACT_CMD="$ACT_CMD -W $WORKFLOW_FILE"

if [ "$DRY_RUN" = true ]; then
    ACT_CMD="$ACT_CMD --dryrun"
fi

# Print what we're doing
if [ -n "$JOB_NAME" ]; then
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry running job '$JOB_NAME' from $WORKFLOW_FILE"
    else
        print_status "Running job '$JOB_NAME' from $WORKFLOW_FILE"
    fi
else
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry running all jobs from $WORKFLOW_FILE"
    else
        print_status "Running all jobs from $WORKFLOW_FILE"
    fi
fi

print_warning "This may take a while on first run (downloading Docker images)..."

# Execute the command
eval $ACT_CMD

if [ $? -eq 0 ]; then
    print_success "Act execution completed successfully!"
else
    print_error "Act execution failed!"
    exit 1
fi
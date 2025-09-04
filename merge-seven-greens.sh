#!/bin/bash
# Seven Greens Merge Orchestration Script
# Run this script to merge PRs in the correct dependency order

set -e  # Exit on any error

# Group 1: Foundation
echo "Merging PR #76: fix(workflows): correct triggers and YAML structure for main.yml and summary.yml"
gh pr merge 76 --merge --delete-branch
echo "✅ PR #76 merged"

echo "Group 1 completed. Waiting for CI to stabilize..."
sleep 30  # Allow CI to process

# Group 2: Summarization
echo "Merging PR #79: feat: add GitHub Actions workflow to automatically summarize new issues"
gh pr merge 79 --merge --delete-branch
echo "✅ PR #79 merged"
echo "Merging PR #80: feat: add workflow to summarize new GitHub issues"
gh pr merge 80 --merge --delete-branch
echo "✅ PR #80 merged"

echo "Group 2 completed. Waiting for CI to stabilize..."
sleep 30  # Allow CI to process

# Group 3: Restoration
echo "Merging PR #81: fix: restore GitHub Actions workflows for CI and issue summaries"
gh pr merge 81 --merge --delete-branch
echo "✅ PR #81 merged"

echo "Group 3 completed. Waiting for CI to stabilize..."
sleep 30  # Allow CI to process

# Group 4: Supporting
echo "Merging PR #78: Add comprehensive GitHub Copilot instructions with validated commands and business logic testing"
gh pr merge 78 --merge --delete-branch
echo "✅ PR #78 merged"
echo "Merging PR #75: feat: add GitHub Actions workflows for CI and issue summarization"
gh pr merge 75 --merge --delete-branch
echo "✅ PR #75 merged"
echo "Merging PR #74: 🏛 Keeper's Blessing: Seasonal Headlines Restored and CI Reforged"
gh pr merge 74 --merge --delete-branch
echo "✅ PR #74 merged"

echo "Group 4 completed. Waiting for CI to stabilize..."
sleep 30  # Allow CI to process

# Group 5: Orchestration
echo "Merging PR #83: 💠 Keeper's Benediction: Repository Analysis for PR Merge Orchestration"
gh pr merge 83 --merge --delete-branch
echo "✅ PR #83 merged"
echo "Merging PR #88: fix: minimal YAML correction for CI pass"
gh pr merge 88 --merge --delete-branch
echo "✅ PR #88 merged"

echo "Group 5 completed. Waiting for CI to stabilize..."
sleep 30  # Allow CI to process

echo "🎉 All Seven Greens merged successfully!"

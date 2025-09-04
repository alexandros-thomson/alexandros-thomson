#!/usr/bin/env python3
"""
Validation script for Seven Greens merge dependencies.
This script verifies that the merge order is correct and no dependencies are violated.
"""

import sys
import os
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

class MergeStatus(Enum):
    PENDING = "pending"
    READY = "ready"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"
    BLOCKED = "blocked"

@dataclass
class PR:
    number: int
    title: str
    description: str
    dependencies: List[int]
    status: MergeStatus
    group: str

class SevenGreensMerger:
    """Orchestrates the Seven Greens merge sequence."""
    
    def __init__(self):
        self.prs = self._define_merge_sequence()
        
    def _define_merge_sequence(self) -> Dict[int, PR]:
        """Define the Seven Greens PRs and their dependencies."""
        return {
            # Group 1: Foundation (must merge first)
            76: PR(
                number=76,
                title="fix(workflows): correct triggers and YAML structure for main.yml and summary.yml",
                description="Root YAML + trigger fix (foundation for all others)",
                dependencies=[],
                status=MergeStatus.READY,
                group="Foundation"
            ),
            
            # Group 2: Issue Summarization (depends on #76)
            79: PR(
                number=79,
                title="feat: add GitHub Actions workflow to automatically summarize new issues",
                description="Issue summarisation workflows (depend on #76)",
                dependencies=[76],
                status=MergeStatus.PENDING,
                group="Summarization"
            ),
            80: PR(
                number=80,
                title="feat: add workflow to summarize new GitHub issues",
                description="Issue summarisation workflows (depend on #76)",
                dependencies=[76],
                status=MergeStatus.PENDING,
                group="Summarization"
            ),
            
            # Group 3: Full Restore (depends on summarization)
            81: PR(
                number=81,
                title="fix: restore GitHub Actions workflows for CI and issue summaries",
                description="Full restore of CI + summaries",
                dependencies=[76, 79, 80],
                status=MergeStatus.PENDING,
                group="Restoration"
            ),
            
            # Group 4: Supporting Features (depends on foundation)
            78: PR(
                number=78,
                title="Add comprehensive GitHub Copilot instructions with validated commands and business logic testing",
                description="Copilot instructions",
                dependencies=[76],
                status=MergeStatus.PENDING,
                group="Supporting"
            ),
            75: PR(
                number=75,
                title="feat: add GitHub Actions workflows for CI and issue summarization",
                description="Combined CI",
                dependencies=[76],
                status=MergeStatus.PENDING,
                group="Supporting"
            ),
            74: PR(
                number=74,
                title="🏛 Keeper's Blessing: Seasonal Headlines Restored and CI Reforged",
                description="Seasonal headlines",
                dependencies=[76],
                status=MergeStatus.PENDING,
                group="Supporting"
            ),
            
            # Group 5: Orchestration (depends on restoration)
            83: PR(
                number=83,
                title="💠 Keeper's Benediction: Repository Analysis for PR Merge Orchestration",
                description="Orchestration",
                dependencies=[76, 81],
                status=MergeStatus.PENDING,
                group="Orchestration"
            ),
            88: PR(
                number=88,
                title="fix: minimal YAML correction for CI pass",
                description="Minimal YAML PRs",
                dependencies=[76, 81],
                status=MergeStatus.PENDING,
                group="Orchestration"
            )
        }
    
    def get_merge_order(self) -> List[List[int]]:
        """Get the correct merge order as groups that can be merged in parallel."""
        return [
            [76],           # Foundation first
            [79, 80],       # Summarization (can be parallel)
            [81],           # Restoration
            [78, 75, 74],   # Supporting (can be parallel)
            [83, 88]        # Orchestration (can be parallel)
        ]

def validate_dependencies():
    """Validate that the merge sequence respects all dependencies."""
    merger = SevenGreensMerger()
    merge_groups = merger.get_merge_order()
    
    print("🔍 Validating Seven Greens dependency order...\n")
    
    merged = set()
    all_valid = True
    
    for i, group in enumerate(merge_groups, 1):
        print(f"Group {i}: {[f'#{pr}' for pr in group]}")
        
        for pr_num in group:
            pr = merger.prs[pr_num]
            
            # Check if all dependencies are in the merged set
            unmet_deps = [dep for dep in pr.dependencies if dep not in merged]
            
            if unmet_deps:
                print(f"  ❌ PR #{pr_num} has unmet dependencies: {unmet_deps}")
                all_valid = False
            else:
                print(f"  ✅ PR #{pr_num} dependencies satisfied")
        
        # Add this group to merged set
        merged.update(group)
        print()
    
    if all_valid:
        print("🎉 All dependencies are correctly ordered!")
        print("✅ The Seven Greens can be merged safely in this sequence.")
    else:
        print("❌ Dependency violations found! Do not proceed with merge.")
    
    return all_valid

def show_dependency_graph():
    """Show the dependency graph for visual verification."""
    merger = SevenGreensMerger()
    
    print("📊 Seven Greens Dependency Graph:\n")
    
    for pr_num, pr in sorted(merger.prs.items()):
        deps_str = f" (depends on: {pr.dependencies})" if pr.dependencies else " (no dependencies)"
        print(f"PR #{pr_num}: {pr.title}")
        print(f"   Group: {pr.group}{deps_str}")
        print()

if __name__ == "__main__":
    print("=" * 70)
    show_dependency_graph()
    print("=" * 70)
    validate_dependencies()
    print("=" * 70)
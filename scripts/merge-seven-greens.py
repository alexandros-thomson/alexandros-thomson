#!/usr/bin/env python3
"""
Seven Greens Merge Orchestration Script

This script coordinates the merge of seven interdependent PRs in the correct
dependency order to prevent CI/CD pipeline failures mid-stream.

Merge Sequence (as per problem statement):
1. #76 — root YAML + trigger fix (foundation for all others)
2. #79 / #80 — issue summarisation workflows (depend on #76)
3. #81 — full restore of CI + summaries
4. #78 / #75 / #74 — Copilot instructions, combined CI, seasonal headlines
5. #83–#88 — orchestration, local testing, and minimal YAML PRs
"""

import json
import sys
import subprocess
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
        self.status_file = "seven-greens-status.json"
        
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
    
    def check_dependencies(self, pr_number: int) -> Tuple[bool, List[int]]:
        """Check if a PR's dependencies are satisfied."""
        pr = self.prs[pr_number]
        unmet_deps = []
        
        for dep in pr.dependencies:
            if self.prs[dep].status != MergeStatus.COMPLETED:
                unmet_deps.append(dep)
        
        return len(unmet_deps) == 0, unmet_deps
    
    def get_ready_prs(self) -> List[int]:
        """Get PRs that are ready to merge (dependencies satisfied)."""
        ready = []
        for pr_num, pr in self.prs.items():
            if pr.status in [MergeStatus.PENDING, MergeStatus.READY]:
                deps_met, _ = self.check_dependencies(pr_num)
                if deps_met:
                    ready.append(pr_num)
        return sorted(ready)
    
    def simulate_merge(self, pr_number: int) -> bool:
        """Simulate merging a PR (for testing)."""
        if pr_number not in self.prs:
            print(f"❌ PR #{pr_number} not found in Seven Greens sequence")
            return False
            
        deps_met, unmet_deps = self.check_dependencies(pr_number)
        if not deps_met:
            print(f"❌ PR #{pr_number} cannot be merged. Unmet dependencies: {unmet_deps}")
            return False
        
        self.prs[pr_number].status = MergeStatus.COMPLETED
        print(f"✅ PR #{pr_number} merged successfully")
        return True
    
    def generate_merge_script(self) -> str:
        """Generate GitHub CLI commands for the merge sequence."""
        script = "#!/bin/bash\n"
        script += "# Seven Greens Merge Orchestration Script\n"
        script += "# Run this script to merge PRs in the correct dependency order\n\n"
        script += "set -e  # Exit on any error\n\n"
        
        merge_groups = self.get_merge_order()
        
        for i, group in enumerate(merge_groups, 1):
            script += f"# Group {i}: {self.prs[group[0]].group}\n"
            for pr_num in group:
                pr = self.prs[pr_num]
                script += f"echo \"Merging PR #{pr_num}: {pr.title}\"\n"
                script += f"gh pr merge {pr_num} --merge --delete-branch\n"
                script += f"echo \"✅ PR #{pr_num} merged\"\n"
            script += f"\necho \"Group {i} completed. Waiting for CI to stabilize...\"\n"
            script += "sleep 30  # Allow CI to process\n\n"
        
        script += "echo \"🎉 All Seven Greens merged successfully!\"\n"
        return script
    
    def display_status(self):
        """Display current merge status."""
        print("🌿 Seven Greens Merge Status 🌿\n")
        
        merge_groups = self.get_merge_order()
        for i, group in enumerate(merge_groups, 1):
            group_name = self.prs[group[0]].group
            print(f"Group {i}: {group_name}")
            for pr_num in group:
                pr = self.prs[pr_num]
                status_icon = {
                    MergeStatus.COMPLETED: "✅",
                    MergeStatus.READY: "🟡",
                    MergeStatus.PENDING: "⏳",
                    MergeStatus.BLOCKED: "🔒",
                    MergeStatus.FAILED: "❌"
                }.get(pr.status, "❓")
                
                deps_met, unmet_deps = self.check_dependencies(pr_num)
                deps_status = "✅" if deps_met else f"❌ Waiting for: {unmet_deps}"
                
                print(f"  {status_icon} PR #{pr_num}: {pr.title}")
                print(f"     Dependencies: {deps_status}")
            print()
        
        ready_prs = self.get_ready_prs()
        if ready_prs:
            print(f"🎯 Ready to merge: {ready_prs}")
        else:
            print("⏳ No PRs ready to merge at this time")

def main():
    merger = SevenGreensMerger()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "status":
            merger.display_status()
        elif command == "script":
            script = merger.generate_merge_script()
            with open("merge-seven-greens.sh", "w") as f:
                f.write(script)
            print("📝 Merge script written to merge-seven-greens.sh")
            print("🔧 Make it executable: chmod +x merge-seven-greens.sh")
            print("🚀 Run it: ./merge-seven-greens.sh")
        elif command == "simulate":
            # Simulate the entire merge sequence
            print("🧪 Simulating Seven Greens merge sequence...\n")
            merge_groups = merger.get_merge_order()
            
            for i, group in enumerate(merge_groups, 1):
                print(f"Group {i}: {merger.prs[group[0]].group}")
                for pr_num in group:
                    merger.simulate_merge(pr_num)
                print()
            
            print("🎉 Simulation completed successfully!")
            merger.display_status()
        else:
            print(f"❓ Unknown command: {command}")
            print("Usage: python merge-seven-greens.py [status|script|simulate]")
    else:
        merger.display_status()

if __name__ == "__main__":
    main()
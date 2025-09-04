# Seven Greens Merge Orchestration

This directory contains the orchestration tools for merging the "Seven Greens" PRs in the correct dependency order to prevent CI/CD pipeline failures mid-stream.

## The Seven Greens

The merge sequence follows these dependencies:

### 1. Foundation Layer
- **PR #76** — Root YAML + trigger fix (foundation for all others)

### 2. Summarization Layer (depends on #76)
- **PR #79** — Issue summarization workflows
- **PR #80** — Issue summarization workflows

### 3. Restoration Layer (depends on #76, #79, #80)
- **PR #81** — Full restore of CI + summaries

### 4. Supporting Features Layer (depends on #76)
- **PR #78** — Copilot instructions
- **PR #75** — Combined CI workflows
- **PR #74** — Seasonal headlines

### 5. Orchestration Layer (depends on #76, #81)
- **PR #83** — Orchestration analysis
- **PR #88** — Minimal YAML PRs

## Usage

### Check Current Status
```bash
python scripts/merge-seven-greens.py status
```

### Generate Merge Script
```bash
python scripts/merge-seven-greens.py script
chmod +x merge-seven-greens.sh
./merge-seven-greens.sh
```

### Simulate Merge Sequence
```bash
python scripts/merge-seven-greens.py simulate
```

## Manual Merge Process

If you prefer to merge manually, follow this exact sequence:

1. **Merge PR #76 first** (Foundation)
   - This fixes the root YAML and triggers that all others depend on
   - Wait for CI to pass

2. **Merge PRs #79 and #80** (can be done in parallel)
   - Both depend on #76 being merged
   - Wait for CI to pass

3. **Merge PR #81**
   - Depends on #76, #79, and #80
   - This is the comprehensive restore
   - Wait for CI to pass

4. **Merge PRs #78, #75, and #74** (can be done in parallel)
   - All depend on #76 foundation
   - Wait for CI to pass

5. **Merge PRs #83 and #88** (can be done in parallel)
   - Both depend on #76 and #81
   - Final orchestration layer

## Why This Order Matters

- **#76** provides the foundational YAML fixes that other workflows depend on
- **#79/#80** build issue summarization on top of the fixed foundation
- **#81** provides comprehensive CI restoration that depends on all prior fixes
- **#78/#75/#74** add supporting features that need the foundation but can be parallel
- **#83/#88** complete the orchestration and testing, depending on the full restore

Breaking this order could result in:
- Workflow conflicts
- CI pipeline failures
- Merge conflicts
- Broken automation mid-stream

## Emergency Rollback

If something goes wrong during the merge process:

1. Identify the last successfully merged PR
2. Check which PRs are safe to merge next using the dependency graph
3. If needed, create hotfix PRs to address issues before continuing
4. Never merge out of dependency order

## Validation

Before merging each group, validate:
- [ ] Previous group's CI is green
- [ ] No conflicts exist
- [ ] Dependencies are satisfied
- [ ] Tests pass locally if possible

## Notes

- Each group should be allowed to stabilize (CI passes) before proceeding
- PRs within the same group can be merged in parallel
- The orchestration script includes 30-second delays between groups
- Monitor CI status carefully throughout the process
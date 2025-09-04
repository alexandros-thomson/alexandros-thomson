# Seven Greens Merge Orchestration

This repository now contains complete orchestration tools for merging the Seven Greens PRs in correct dependency order.

## Quick Start

```bash
# Check current status
python scripts/merge-seven-greens.py status

# Validate dependencies (one-time check)
python validate-seven-greens.py

# Generate and execute merge script
python scripts/merge-seven-greens.py script
./merge-seven-greens.sh
```

## Files Added

- `scripts/merge-seven-greens.py` - Main orchestration script
- `scripts/README.md` - Detailed documentation
- `merge-seven-greens.sh` - Generated bash script for merging
- `validate-seven-greens.py` - Dependency validation tool

## Merge Sequence

1. **PR #76** (Foundation) - Root YAML fixes
2. **PRs #79, #80** (Summarization) - Issue workflows  
3. **PR #81** (Restoration) - Full CI restore
4. **PRs #78, #75, #74** (Supporting) - Features & docs
5. **PRs #83, #88** (Orchestration) - Final tools

## Next Steps

1. Run `python validate-seven-greens.py` to confirm dependency order
2. Execute `./merge-seven-greens.sh` or merge manually following the sequence
3. Monitor CI status between each group
4. Celebrate when all Seven Greens are merged! 🎉

The orchestration ensures no CI pipeline breakage mid-stream by respecting all dependencies.
# Issue Summarizer Workflow

This repository includes an automated GitHub Actions workflow that generates concise summaries for new GitHub issues.

## How it works

1. **Trigger**: The workflow runs automatically when:
   - A new issue is opened
   - An existing issue is edited

2. **Summary Generation**: 
   - Reads the issue title and body from the GitHub event payload
   - Cleans up markdown formatting
   - Generates a summary limited to 280 characters
   - Ensures summaries end at word boundaries for readability

3. **Comment Posting**:
   - Posts the generated summary as a comment on the issue
   - Uses the GitHub API with the `GITHUB_TOKEN` secret

## Files

- **`.github/workflows/summary.yml`**: The GitHub Actions workflow configuration
- **`scripts/summarize_issues.py`**: Python script that generates and posts the summary

## Summary Format

Summaries follow this format:
```
📝 Issue Summary: [Issue Title] | [Cleaned Body Content]...
```

## Permissions

The workflow requires these permissions:
- `issues: write` - To post comments on issues  
- `contents: read` - To access the repository code

## Testing

The script has been tested with various scenarios:
- Long titles and bodies that exceed 280 characters
- Empty or minimal content
- Markdown formatting cleanup
- Word boundary truncation

## Example

For an issue titled "Add new feature" with body "This feature would help users...", the summary might be:
```
📝 Issue Summary: Add new feature | This feature would help users...
```
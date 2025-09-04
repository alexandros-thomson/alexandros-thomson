#!/usr/bin/env python3
"""
GitHub Issue Summarizer

This script reads GitHub issue data from environment variables,
generates a summary ≤280 characters, and posts it as a comment.
"""

import os
import json
import sys
import requests
from typing import Dict, Any


def get_issue_data() -> Dict[str, Any]:
    """Extract issue data from GitHub event payload."""
    # GitHub provides the event payload via GITHUB_EVENT_PATH
    event_path = os.environ.get('GITHUB_EVENT_PATH')
    if not event_path:
        raise ValueError("GITHUB_EVENT_PATH environment variable not found")
    
    with open(event_path, 'r') as f:
        event_data = json.load(f)
    
    return event_data


def generate_summary(title: str, body: str) -> str:
    """Generate a summary of the issue ≤280 characters."""
    # Clean up the body text
    body = body or ""
    body = body.strip()
    
    # If body is empty, just use the title
    if not body:
        summary = f"📝 Issue: {title}"
    else:
        # Try to create a meaningful summary
        # Remove excessive whitespace and newlines
        body_cleaned = ' '.join(body.split())
        
        # Start with title and add body content if space allows
        summary = f"📝 Issue: {title}"
        
        # Calculate remaining space for body content
        remaining_chars = 280 - len(summary) - 3  # 3 chars for " - "
        
        if remaining_chars > 10 and body_cleaned:  # Only add body if meaningful space left
            body_truncated = body_cleaned[:remaining_chars] + ("..." if len(body_cleaned) > remaining_chars else "")
            summary = f"{summary} - {body_truncated}"
    
    # Ensure summary is exactly ≤280 characters
    if len(summary) > 280:
        summary = summary[:277] + "..."
    
    return summary


def post_comment(issue_number: int, summary: str, repo_owner: str, repo_name: str, token: str) -> None:
    """Post the summary as a comment on the issue."""
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/issues/{issue_number}/comments"
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    }
    
    data = {
        'body': f"🤖 **Auto-generated Summary:**\n\n{summary}"
    }
    
    response = requests.post(url, headers=headers, json=data)
    response.raise_for_status()
    
    print(f"✅ Successfully posted summary comment on issue #{issue_number}")


def main():
    """Main function to orchestrate the issue summarization process."""
    try:
        # Get GitHub token
        github_token = os.environ.get('GITHUB_TOKEN')
        if not github_token:
            raise ValueError("GITHUB_TOKEN environment variable not found")
        
        # Get repository information
        github_repository = os.environ.get('GITHUB_REPOSITORY')
        if not github_repository:
            raise ValueError("GITHUB_REPOSITORY environment variable not found")
        
        repo_owner, repo_name = github_repository.split('/')
        
        # Get issue data from event payload
        event_data = get_issue_data()
        issue = event_data.get('issue', {})
        
        issue_number = issue.get('number')
        issue_title = issue.get('title', '')
        issue_body = issue.get('body', '')
        
        if not issue_number:
            raise ValueError("Issue number not found in event data")
        
        print(f"📋 Processing issue #{issue_number}: {issue_title}")
        
        # Generate summary
        summary = generate_summary(issue_title, issue_body)
        print(f"📝 Generated summary ({len(summary)} chars): {summary}")
        
        # Post comment
        post_comment(issue_number, summary, repo_owner, repo_name, github_token)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""
Script to summarize GitHub issues and post comments.
Reads issue data from GitHub event context and generates summaries.
"""
import os
import sys
import json
import requests
from github import Github


def generate_summary(title, body):
    """Generate a concise summary of the issue (≤ 280 chars)."""
    # Simple text processing approach for summarization
    if not body:
        summary = f"Issue: {title}"
    else:
        # Take first sentence or first 150 chars of body, whichever is shorter
        body_clean = body.replace('\n', ' ').replace('\r', ' ').strip()
        max_body_length = 200 - len(title) - 2  # Account for ": " separator
        
        if '.' in body_clean[:max_body_length] and len(body_clean) > max_body_length:
            # If there's more content after the period, truncate and add ellipsis
            first_sentence = body_clean.split('.')[0] + '.'
            if len(body_clean) > len(first_sentence):
                summary = f"{title}: {first_sentence[:-1]}..."
            else:
                summary = f"{title}: {first_sentence}"
        else:
            # No suitable period found or content is short
            truncated_body = body_clean[:max_body_length]
            if len(body_clean) > max_body_length:
                summary = f"{title}: {truncated_body}..."
            else:
                summary = f"{title}: {truncated_body}"
    
    # Ensure summary is ≤ 280 characters
    if len(summary) > 280:
        summary = summary[:277] + "..."
    
    return summary


def post_comment(repo_name, issue_number, summary, token):
    """Post the summary as a comment on the issue."""
    try:
        g = Github(token)
        repo = g.get_repo(repo_name)
        issue = repo.get_issue(issue_number)
        
        comment_body = f"🤖 **Issue Summary**\n\n{summary}"
        issue.create_comment(comment_body)
        print(f"Posted summary comment to issue #{issue_number}")
        return True
    except Exception as e:
        print(f"Error posting comment: {e}")
        return False


def main():
    """Main function to process GitHub issue and post summary."""
    # Get data from environment variables (set by GitHub Actions)
    github_token = os.getenv('GITHUB_TOKEN')
    github_repository = os.getenv('GITHUB_REPOSITORY')
    
    if not github_token or not github_repository:
        print("Error: Missing required environment variables")
        sys.exit(1)
    
    # Get issue data from GitHub event context
    github_event_path = os.getenv('GITHUB_EVENT_PATH')
    if not github_event_path:
        print("Error: GITHUB_EVENT_PATH not set")
        sys.exit(1)
    
    try:
        with open(github_event_path, 'r') as f:
            event_data = json.load(f)
        
        issue = event_data.get('issue', {})
        title = issue.get('title', '')
        body = issue.get('body', '')
        issue_number = issue.get('number')
        
        if not title or not issue_number:
            print("Error: Missing issue title or number")
            sys.exit(1)
        
        print(f"Processing issue #{issue_number}: {title}")
        
        # Generate summary
        summary = generate_summary(title, body)
        print(f"Generated summary: {summary}")
        
        # Post comment
        success = post_comment(github_repository, issue_number, summary, github_token)
        
        if success:
            print("Summary posted successfully!")
        else:
            sys.exit(1)
            
    except Exception as e:
        print(f"Error processing issue: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
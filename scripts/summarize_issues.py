#!/usr/bin/env python3
"""
GitHub Issue Summarizer Script

This script reads issue data from GitHub event payload and posts a concise summary
as a comment on the issue. The summary is limited to 280 characters.
"""

import json
import os
import sys
import re
from urllib.request import Request, urlopen
from urllib.parse import urlencode


def truncate_text(text, max_length=280):
    """Truncate text to specified length, ensuring it ends at a word boundary."""
    if len(text) <= max_length:
        return text
    
    # Find the last space before the max_length
    truncated = text[:max_length]
    last_space = truncated.rfind(' ')
    
    if last_space > 0:
        truncated = truncated[:last_space]
    
    return truncated + "..."


def generate_summary(title, body):
    """Generate a concise summary of the issue."""
    # Clean up the body text
    if not body:
        body = ""
    
    # Remove markdown formatting and excessive whitespace
    cleaned_body = re.sub(r'[#*`_\[\](){}]', '', body)
    cleaned_body = re.sub(r'\s+', ' ', cleaned_body).strip()
    
    # Create summary starting with title
    prefix = "📝 Issue Summary: "
    base_summary = f"{prefix}{title}"
    
    # Check if we need to add body content
    if len(base_summary) < 250 and cleaned_body:  # Leave room for separator and body
        # Add separator and body content
        separator = " | "
        available_chars = 280 - len(base_summary) - len(separator) - 3  # Reserve 3 for "..."
        
        if available_chars > 10:  # Only add body if we have meaningful space
            if len(cleaned_body) > available_chars:
                # Truncate body at word boundary
                truncated_body = cleaned_body[:available_chars]
                last_space = truncated_body.rfind(' ')
                if last_space > 0:
                    truncated_body = truncated_body[:last_space]
                summary = base_summary + separator + truncated_body + "..."
            else:
                summary = base_summary + separator + cleaned_body
        else:
            summary = base_summary
    else:
        summary = base_summary
    
    # Final safety check - ensure we never exceed 280 chars
    return truncate_text(summary, 280)


def post_comment(repo, issue_number, comment_body, token):
    """Post a comment to the GitHub issue."""
    url = f"https://api.github.com/repos/{repo}/issues/{issue_number}/comments"
    
    data = json.dumps({"body": comment_body}).encode('utf-8')
    
    request = Request(url, data=data, method='POST')
    request.add_header('Authorization', f'token {token}')
    request.add_header('Content-Type', 'application/json')
    request.add_header('User-Agent', 'GitHub-Issue-Summarizer/1.0')
    
    try:
        with urlopen(request) as response:
            if response.status == 201:
                print("✅ Successfully posted issue summary comment")
                return True
            else:
                print(f"❌ Failed to post comment. Status: {response.status}")
                print(f"Response: {response.read().decode('utf-8')}")
                return False
    except Exception as e:
        print(f"❌ Error posting comment: {e}")
        return False


def main():
    """Main function to process the GitHub issue and post summary."""
    # Get required environment variables
    github_token = os.getenv('GITHUB_TOKEN')
    github_repository = os.getenv('GITHUB_REPOSITORY')
    github_event_path = os.getenv('GITHUB_EVENT_PATH')
    
    if not all([github_token, github_repository, github_event_path]):
        print("❌ Missing required environment variables:")
        print(f"  GITHUB_TOKEN: {'✓' if github_token else '✗'}")
        print(f"  GITHUB_REPOSITORY: {'✓' if github_repository else '✗'}")
        print(f"  GITHUB_EVENT_PATH: {'✓' if github_event_path else '✗'}")
        sys.exit(1)
    
    # Read the GitHub event payload
    try:
        with open(github_event_path, 'r', encoding='utf-8') as f:
            event_data = json.load(f)
    except Exception as e:
        print(f"❌ Error reading event payload: {e}")
        sys.exit(1)
    
    # Extract issue information
    if 'issue' not in event_data:
        print("❌ No issue data found in event payload")
        sys.exit(1)
    
    issue = event_data['issue']
    issue_number = issue['number']
    issue_title = issue['title']
    issue_body = issue.get('body', '')
    
    print(f"📋 Processing issue #{issue_number}: {issue_title}")
    
    # Generate summary
    summary = generate_summary(issue_title, issue_body)
    print(f"📝 Generated summary ({len(summary)} chars): {summary}")
    
    # Post comment
    success = post_comment(github_repository, issue_number, summary, github_token)
    
    if not success:
        sys.exit(1)
    
    print("🎉 Issue summarization completed successfully!")


if __name__ == "__main__":
    main()
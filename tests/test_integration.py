#!/usr/bin/env python3
"""
Integration test for the issue summarization workflow.
Tests the script without making actual GitHub API calls.
"""
import pytest
import sys
import os
import json
import tempfile
from unittest.mock import patch, MagicMock

# Add scripts directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from summarize_issues import main


def test_full_workflow_integration():
    """Test the complete workflow with mocked GitHub API."""
    # Create a temporary event file
    event_data = {
        "issue": {
            "number": 123,
            "title": "Integration test issue",
            "body": "This is a test issue body for integration testing."
        }
    }
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
        json.dump(event_data, f)
        event_path = f.name
    
    try:
        # Set environment variables
        os.environ['GITHUB_TOKEN'] = 'test_token'
        os.environ['GITHUB_REPOSITORY'] = 'test/repo'
        os.environ['GITHUB_EVENT_PATH'] = event_path
        
        # Mock the GitHub API calls
        with patch('summarize_issues.Github') as mock_github:
            mock_repo = MagicMock()
            mock_issue = MagicMock()
            mock_github.return_value.get_repo.return_value = mock_repo
            mock_repo.get_issue.return_value = mock_issue
            mock_issue.create_comment.return_value = None
            
            # This should not raise an exception
            try:
                main()
            except SystemExit as e:
                if e.code != 0:
                    pytest.fail(f"Script failed with exit code {e.code}")
            
            # Verify the GitHub API was called correctly
            mock_github.assert_called_once_with('test_token')
            mock_github.return_value.get_repo.assert_called_once_with('test/repo')
            mock_repo.get_issue.assert_called_once_with(123)
            
            # Check that a comment was created
            assert mock_issue.create_comment.called
            comment_body = mock_issue.create_comment.call_args[0][0]
            assert "🤖 **Issue Summary**" in comment_body
            assert "Integration test issue" in comment_body
    
    finally:
        # Clean up
        os.unlink(event_path)
        # Clean up environment variables
        for var in ['GITHUB_TOKEN', 'GITHUB_REPOSITORY', 'GITHUB_EVENT_PATH']:
            os.environ.pop(var, None)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
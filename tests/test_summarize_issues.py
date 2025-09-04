#!/usr/bin/env python3
"""
Basic tests for the issue summarization functionality.
"""
import pytest
import sys
import os

# Add scripts directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from summarize_issues import generate_summary


def test_generate_summary_basic():
    """Test basic summary generation."""
    title = "Fix bug in authentication"
    body = "There is an issue with the login system. Users cannot authenticate properly."
    
    summary = generate_summary(title, body)
    
    assert len(summary) <= 280
    assert title in summary
    assert len(summary) > 0


def test_generate_summary_long_text():
    """Test summary generation with long text that needs truncation."""
    title = "Very long title that might need to be truncated in some cases"
    body = ("This is a very long body text that contains many details about the issue. " * 10)
    
    summary = generate_summary(title, body)
    
    assert len(summary) <= 280
    assert summary.endswith("...")


def test_generate_summary_empty_body():
    """Test summary generation with empty body."""
    title = "Simple issue title"
    body = ""
    
    summary = generate_summary(title, body)
    
    assert len(summary) <= 280
    assert title in summary


def test_generate_summary_no_period():
    """Test summary generation when body has no periods."""
    title = "Issue title"
    body = "Body without periods but with lots of text that goes on and on"
    
    summary = generate_summary(title, body)
    
    assert len(summary) <= 280
    assert title in summary


if __name__ == "__main__":
    pytest.main([__file__])
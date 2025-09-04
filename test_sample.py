"""Test module for workflow validation."""

def test_sample():
    """Sample test to ensure pytest can run."""
    assert True

def test_basic_math():
    """Basic math test."""
    assert 1 + 1 == 2
    assert 2 * 3 == 6

def test_string_operations():
    """Test string operations."""
    test_string = "hello world"
    assert len(test_string) == 11
    assert test_string.upper() == "HELLO WORLD"

def test_list_operations():
    """Test list operations."""
    test_list = [1, 2, 3, 4, 5]
    assert len(test_list) == 5
    assert sum(test_list) == 15
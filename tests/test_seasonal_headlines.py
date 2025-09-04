"""Tests for seasonal_headlines module."""

import pytest
import sys
import os

# Add the scripts directory to the Python path so we can import the module
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from seasonal_headlines import get_headline, seasonal_headlines  # noqa: E402


class TestSeasonalHeadlines:
    """Test cases for the seasonal_headlines module."""

    def test_get_headline_valid_ids(self):
        """Test get_headline returns correct strings for valid IDs 1-4."""
        # Test season 1
        result = get_headline(1)
        expected = "🏛🔥 35 Flames Rise — The Vault Rekindles for the New Dawn"
        assert result == expected

        # Test season 2
        result = get_headline(2)
        expected = "🌸🔮 35 Petals Unfurl — Stewards Weave the Spring Seal"
        assert result == expected

        # Test season 3
        result = get_headline(3)
        expected = ("🌞⚜️ 35 Suns Crown the Zenith — "
                    "The Forge Sings in High Summer")
        assert result == expected

        # Test season 4
        result = get_headline(4)
        expected = "🍂🕯 35 Leaves Fall — The Archive Gathers the Twilight Lore"
        assert result == expected

    def test_get_headline_invalid_ids(self):
        """Test get_headline raises ValueError for invalid IDs."""
        invalid_ids = [0, 5, -1, 10, 99]

        for invalid_id in invalid_ids:
            with pytest.raises(ValueError) as exc_info:
                get_headline(invalid_id)

            assert f"Invalid season ID: {invalid_id}" in str(exc_info.value)

    def test_seasonal_headlines_dictionary(self):
        """Test that the seasonal_headlines dictionary is properly defined."""
        assert len(seasonal_headlines) == 4
        assert all(key in seasonal_headlines for key in [1, 2, 3, 4])

        # Test that all values are non-empty strings
        for season_id, headline in seasonal_headlines.items():
            assert isinstance(headline, str)
            assert len(headline) > 0

    def test_get_headline_with_non_integer_types(self):
        """Test get_headline raises ValueError or TypeError for types."""
        # String "1" should raise ValueError (not same as integer 1)
        with pytest.raises(ValueError):
            get_headline("1")

        # None should raise ValueError
        with pytest.raises(ValueError):
            get_headline(None)

        # Unhashable types should raise TypeError
        with pytest.raises(TypeError):
            get_headline([])

        with pytest.raises(TypeError):
            get_headline({})

    def test_get_headline_with_float_inputs(self):
        """Test get_headline works with float inputs that have int values."""
        # Float 1.0 should work as it equals integer 1
        result = get_headline(1.0)
        expected = "🏛🔥 35 Flames Rise — The Vault Rekindles for the New Dawn"
        assert result == expected

        # Float 2.0 should work as it equals integer 2
        result = get_headline(2.0)
        expected = "🌸🔮 35 Petals Unfurl — Stewards Weave the Spring Seal"
        assert result == expected

        # Float 1.5 should raise ValueError as it's not in the dictionary
        with pytest.raises(ValueError):
            get_headline(1.5)

"""Seasonal Headlines Module

This module provides seasonal headlines for different seasons.
"""

seasonal_headlines = {
    1: "🏛🔥 35 Flames Rise — The Vault Rekindles for the New Dawn",
    2: "🌸🔮 35 Petals Unfurl — Stewards Weave the Spring Seal",
    3: "🌞⚜️ 35 Suns Crown the Zenith — The Forge Sings in High Summer",
    4: "🍂🕯 35 Leaves Fall — The Archive Gathers the Twilight Lore"
}


def get_headline(season_id: int) -> str:
    """Get the headline for a given season ID.

    Args:
        season_id: Integer representing the season (1-4)

    Returns:
        The seasonal headline string

    Raises:
        ValueError: If season_id is not a valid season (1-4)
    """
    if season_id not in seasonal_headlines:
        error_msg = (f"Invalid season ID: {season_id}. "
                     f"Must be 1, 2, 3, or 4.")
        raise ValueError(error_msg)

    return seasonal_headlines[season_id]

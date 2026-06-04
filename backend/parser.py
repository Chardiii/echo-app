"""
Echo — Natural Language Memory Parser

Extracts task, date, and trigger type from natural language input.
Uses regex patterns and dateparser for V1 (no external AI APIs needed).

Examples:
    "Remind me to buy coffee tomorrow"
    → {"task": "Buy coffee", "date": "2026-06-06", "trigger": "time"}

    "Remind me to submit my assignment tomorrow at 8 PM"
    → {"task": "Submit my assignment", "date": "2026-06-06T20:00:00", "trigger": "time"}
"""

import re
from datetime import datetime

import dateparser


# Patterns that indicate a reminder prefix (to be stripped from the task)
REMINDER_PREFIXES = [
    r"remind me to\s+",
    r"remind me that\s+",
    r"remind me\s+",
    r"don'?t forget to\s+",
    r"don'?t let me forget to\s+",
    r"i need to\s+",
    r"i have to\s+",
    r"i should\s+",
    r"i must\s+",
    r"remember to\s+",
    r"note to self\s*:?\s*",
]

# Patterns that indicate a date/time expression (to be stripped from the task)
DATE_PATTERNS = [
    r"\b(?:today|tonight|tomorrow|yesterday)\b",
    r"\b(?:next|this|coming)\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b",
    r"\b(?:next|this|coming)\s+(?:week|month|year)\b",
    r"\b(?:in\s+\d+\s+(?:minutes?|hours?|days?|weeks?|months?))\b",
    r"\b(?:on|by|before|after|at|around)\s+\d{1,2}(?::\d{2})?\s*(?:am|pm|AM|PM)?\b",
    r"\b(?:on|by|before|after)\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b",
    r"\b(?:on|by|before|after)\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*\s+\d{1,2}\b",
    r"\bat\s+\d{1,2}(?::\d{2})?\s*(?:am|pm|AM|PM)\b",
    r"\b\d{1,2}/\d{1,2}(?:/\d{2,4})?\b",
    r"\b\d{4}-\d{2}-\d{2}\b",
]


def extract_task(text: str) -> str:
    """
    Extract the core task from the user's input by removing
    reminder prefixes and date/time expressions.
    """
    cleaned = text.strip()

    # Remove reminder prefixes (case-insensitive)
    for prefix in REMINDER_PREFIXES:
        cleaned = re.sub(prefix, "", cleaned, flags=re.IGNORECASE).strip()

    # Remove date/time patterns
    for pattern in DATE_PATTERNS:
        cleaned = re.sub(pattern, "", cleaned, flags=re.IGNORECASE).strip()

    # Clean up leftover punctuation and extra whitespace
    cleaned = re.sub(r"\s{2,}", " ", cleaned)  # collapse multiple spaces
    cleaned = re.sub(r"^\s*[,.\-:;]+\s*", "", cleaned)  # leading punctuation
    cleaned = re.sub(r"\s*[,.\-:;]+\s*$", "", cleaned)  # trailing punctuation

    # Capitalize first letter
    if cleaned:
        cleaned = cleaned[0].upper() + cleaned[1:]

    return cleaned


def extract_date(text: str) -> str | None:
    """
    Extract a date/datetime from the user's input using dateparser.
    Uses search_dates to find date expressions within longer text,
    with a regex-based fallback for tricky cases.
    Returns an ISO format string, or None if no date is found.
    """
    from dateparser.search import search_dates

    settings = {
        "PREFER_DATES_FROM": "future",
        "PREFER_DAY_OF_MONTH": "first",
        "RETURN_AS_TIMEZONE_AWARE": False,
    }

    # Known date keywords for validation
    date_keywords = {
        "today", "tonight", "tomorrow", "yesterday",
        "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday",
        "january", "february", "march", "april", "may", "june",
        "july", "august", "september", "october", "november", "december",
        "jan", "feb", "mar", "apr", "jun", "jul", "aug", "sep", "oct", "nov", "dec",
        "next", "week", "month", "year", "am", "pm",
    }

    def _format_date(parsed):
        """Format a parsed datetime into ISO string."""
        if parsed.hour == 0 and parsed.minute == 0 and parsed.second == 0:
            return parsed.strftime("%Y-%m-%d")
        return parsed.strftime("%Y-%m-%dT%H:%M:%S")

    # Strategy 1: Use search_dates for full-sentence parsing
    results = search_dates(text, settings=settings)

    if results:
        valid_results = []
        for matched_text, parsed_date in results:
            text_lower = matched_text.strip().lower()
            has_digit = any(c.isdigit() for c in text_lower)
            has_keyword = any(kw in text_lower for kw in date_keywords)
            is_long_enough = len(text_lower) > 2

            # Reject time-like patterns (e.g. "9 AM") that search_dates
            # misinterprets as months — let the regex fallback handle these
            if re.match(r"^\d{1,2}\s*(?:am|pm)$", text_lower):
                continue

            if (has_digit or has_keyword) and is_long_enough:
                valid_results.append((matched_text, parsed_date))

        if valid_results:
            _, parsed = valid_results[-1]
            return _format_date(parsed)

    # Strategy 2: Regex fallback — extract date-like substrings and parse them
    fallback_patterns = [
        # "on June 15", "by March 3rd", "before December 25"
        r"(?:on|by|before|after)\s+(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+\d{1,2}(?:st|nd|rd|th)?",
        # "at 9 AM", "at 8:30 PM"
        r"(?:at|around)\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)",
        # "tomorrow at 8 PM"
        r"tomorrow\s+at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)?",
        # "next Monday", "this Friday"
        r"(?:next|this|coming)\s+(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)",
        # "in 3 days", "in 2 hours"
        r"in\s+\d+\s+(?:minutes?|hours?|days?|weeks?|months?)",
        # "June 15", "Dec 25"
        r"(?:jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|june?|july?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+\d{1,2}(?:st|nd|rd|th)?",
        # Standalone time: "8 PM", "9:30 AM"
        r"\d{1,2}(?::\d{2})?\s*(?:am|pm)",
    ]

    for pattern in fallback_patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            import dateparser as dp
            match_text = match.group()
            # For standalone time patterns (e.g., "9 AM"), prepend "today"
            # so dateparser interprets them as times, not months
            if re.match(r"^\d{1,2}(?::\d{2})?\s*(?:am|pm)$", match_text, re.IGNORECASE):
                match_text = f"today at {match_text}"
            parsed = dp.parse(match_text, settings=settings)
            if parsed:
                return _format_date(parsed)

    return None


def parse_memory(text: str) -> dict:
    """
    Parse a natural language memory input and return structured data.

    Args:
        text: Raw user input (e.g., "Remind me to buy coffee tomorrow")

    Returns:
        dict with keys: task, date, trigger
        Example: {"task": "Buy coffee", "date": "2026-06-06", "trigger": "time"}
    """
    if not text or not text.strip():
        return {"error": "Empty input"}

    task = extract_task(text)
    date = extract_date(text)

    if not task:
        task = text.strip()
        if task:
            task = task[0].upper() + task[1:]

    result = {
        "task": task,
        "date": date,
        "trigger": "time" if date else "none",
    }

    return result


# Quick test when running directly
if __name__ == "__main__":
    test_inputs = [
        "Remind me to buy coffee tomorrow",
        "Remind me to submit my assignment tomorrow at 8 PM",
        "Don't forget to call mom next Monday",
        "I need to pay the electricity bill on June 15",
        "Remember to take medicine at 9 AM",
        "Buy shampoo",
    ]

    for text in test_inputs:
        result = parse_memory(text)
        print(f"\nInput:   {text}")
        print(f"Task:    {result['task']}")
        print(f"Date:    {result['date']}")
        print(f"Trigger: {result['trigger']}")

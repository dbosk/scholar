"""Top-level shim for questionary used in tests when real package isn't installed.

This mirrors the minimal functionality used by tests: provide a `checkbox`
function that returns an object with an `ask()` method. Tests monkeypatch
`checkbox` to simulate user choices; this shim allows imports to succeed when
`questionary` isn't installed in the environment.
"""
from typing import Any

class _FakeQuestion:
    def __init__(self, choices: Any):
        self.choices = choices
    def ask(self):
        return None

def checkbox(*args, **kwargs):
    """Return a fake checkbox prompt object.

    If tests don't monkeypatch this function, calling ask() returns None to
    simulate an aborted prompt.
    """
    # Accept either keyword 'choices' or positional second arg
    choices = kwargs.get("choices")
    if choices is None and len(args) >= 2:
        choices = args[1]
    return _FakeQuestion(choices or [])

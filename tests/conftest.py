# tests/conftest.py
import random
import string
import re
import types
import pytest
from namespace_buc_validator import collect_patterns

random.seed(20250808)

def _digits(n: int) -> str:
    return "".join(random.choice(string.digits) for _ in range(n))

def gen_value_pattern1() -> str:
    return ".".join([_digits(4), _digits(6), _digits(4), _digits(6), _digits(4), "C139", _digits(4)])

def gen_value_pattern2() -> str:
    # 4.6.4..4.4.4
    return ".".join([_digits(4), _digits(6), _digits(4), "", _digits(4), _digits(4), _digits(4)])

def gen_value_pattern3() -> str:
    return ".".join([_digits(4), _digits(6), _digits(4), _digits(6), _digits(4), _digits(4), _digits(4)])

def gen_value_invalid() -> str:
    choices = [
        ".".join([_digits(3), _digits(6), _digits(4), _digits(6), _digits(4), _digits(4), _digits(4)]),
        ".".join([_digits(4), _digits(6), _digits(5), _digits(6), _digits(4), _digits(4), _digits(4)]),
        ".".join([_digits(4), _digits(6), _digits(4), _digits(6), _digits(4), "X139", _digits(4)]),
        ".".join([_digits(4), _digits(6), _digits(4), "", _digits(3), _digits(4), _digits(4)]),
    ]
    return random.choice(choices)

def make_ns(name: str, labels: dict | None):
    meta = types.SimpleNamespace(name=name, labels=labels)
    return types.SimpleNamespace(metadata=meta)

@pytest.fixture
def patterns():
    return collect_patterns()

@pytest.fixture
def sample_namespaces(patterns):
    """
    50 reproducible namespaces: half with “lob” in the name.
    Among the “lob” ones:
    - some with a valid buc,
    - some with an invalid buc,
    - some without a buc.
    """
    items = []
    for i in range(50):
        has_lob = random.random() < 0.5
        suffix = "".join(random.choice(string.ascii_lowercase + string.digits) for _ in range(6))
        name = (f"ns-lob-{suffix}" if has_lob else f"ns-{suffix}")

        labels = None
        if has_lob:
            roll = random.random()
            if roll < 0.45:         # valid
                labels = {"buc": random.choice([gen_value_pattern1(), gen_value_pattern2(), gen_value_pattern3()])}
            elif roll < 0.75:       # invalid
                labels = {"buc": gen_value_invalid()}
            else:                   # no buc
                labels = {}
        else:
            if random.random() < 0.3:
                labels = {"other": "x"}
            else:
                labels = {}

        items.append(make_ns(name, labels))
    return items

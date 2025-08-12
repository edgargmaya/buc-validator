# tests/test_k8s_buc_validator.py
import re
import types
import namespace_buc_validator as mod
from namespace_buc_validator import evaluate_namespaces, collect_patterns

def test_collect_patterns_autodiscovery():
    pats = collect_patterns()
    assert len(pats) >= 3
    assert all(isinstance(p, re.Pattern) for p in pats)

def test_collect_patterns_picks_new_globals(monkeypatch):
    monkeypatch.setattr(
        mod,
        "PATTERN_999",
        re.compile(r"^9999\.\d{6}\.\d{4}\.\d{6}\.\d{4}\.\d{4}\.\d{4}$"),
        raising=False,
    )
    pats = collect_patterns(mod.__dict__)
    assert any(p.pattern.startswith("^9999") for p in pats)

def test_evaluate_namespaces_returns_only_invalid(sample_namespaces):
    pats = collect_patterns()
    result = evaluate_namespaces(sample_namespaces, patterns=pats)
    output = set(result["namespaces_with_invalid_buc"])

    invalid = set()
    for ns in sample_namespaces:
        if "lob" not in ns.metadata.name:
            continue
        labels = ns.metadata.labels or {}
        buc = labels.get("buc")
        if not buc:
            continue
        if not any(p.match(buc) for p in pats):
            invalid.add(ns.metadata.name)

    assert output == invalid

def test_missing_buc_is_not_reported(sample_namespaces):
    pats = collect_patterns()
    result = evaluate_namespaces(sample_namespaces, patterns=pats)
    output = set(result["namespaces_with_invalid_buc"])

    without_buc = {
        ns.metadata.name
        for ns in sample_namespaces
        if "lob" in ns.metadata.name and not (ns.metadata.labels or {}).get("buc")
    }
    assert output.isdisjoint(without_buc)

def test_respects_substring_and_labelkey():
    def NS(name, labels):
        meta = types.SimpleNamespace(name=name, labels=labels)
        return types.SimpleNamespace(metadata=meta)

    pats = collect_patterns()
    data = [
        NS("ns-lob-a", {"foo": "1234"}),
        NS("ns-lob-b", {"buc": "notmatching"}),
        NS("ns-x", {"buc": "1234"}),
    ]

    out = evaluate_namespaces(data, patterns=pats, name_substring="zzz")
    assert out["namespaces_with_invalid_buc"] == []

    out2 = evaluate_namespaces(data, patterns=pats, label_key="foo")
    assert set(out2["namespaces_with_invalid_buc"]) == {"ns-lob-a"}

def test_empty_patterns_flags_all_with_label_as_invalid():
    def NS(name, labels):
        meta = types.SimpleNamespace(name=name, labels=labels)
        return types.SimpleNamespace(metadata=meta)

    data = [
        NS("ns-lob-a", {"buc": "anything"}),
        NS("ns-lob-b", {}),                     # no buc
        NS("ns-lob-c", {"buc": "123"}),
    ]
    out = evaluate_namespaces(data, patterns=[], name_substring="lob", label_key="buc")
    assert set(out["namespaces_with_invalid_buc"]) == {"ns-lob-a", "ns-lob-c"}

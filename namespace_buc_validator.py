#!/usr/bin/env python3
import re
import json
from typing import Iterable, List, Dict, Any, Sequence
from kubernetes import client, config

PATTERN_1 = re.compile(r'^\d{4}\.\d{6}\.\d{4}\.\d{6}\.\d{4}\.C139\.\d{4}$')
PATTERN_2 = re.compile(r'^\d{4}\.\d{6}\.\d{4}\.\.\d{4}\.\d{4}\.\d{4}$')
PATTERN_3 = re.compile(r'^\d{4}\.\d{6}\.\d{4}\.\d{6}\.\d{4}\.\d{4}\.\d{4}$')

def collect_patterns(ns: Dict[str, Any] | None = None) -> Sequence[re.Pattern]:
    """
    Discover global variables of the type PATTERN_* and return a list of compiled patterns.
    Accepts both re.Pattern and str. str fields are compiled.
    """
    ns = ns or globals()
    patterns: List[re.Pattern] = []
    for name, value in ns.items():
        if not name.startswith("PATTERN_"):
            continue
        if isinstance(value, re.Pattern):
            patterns.append(value)
        elif isinstance(value, str):
            patterns.append(re.compile(value))
    patterns.sort(key=lambda p: p.pattern)
    return patterns

def evaluate_namespaces(
    ns_items: Iterable[Any],
    patterns: Sequence[re.Pattern] | None = None,
    name_substring: str = "lob",
    label_key: str = "buc",
) -> Dict[str, Any]:
    """
    Receives an iterable list of objects with .metadata.name and .metadata.labels, and returns the non compliance list.
    """
    patterns = tuple(patterns or collect_patterns())
    lob_ns = [ns for ns in ns_items if name_substring in ns.metadata.name]

    namespaces_with_invalid_buc: List[str] = []

    for ns in lob_ns:
        labels = ns.metadata.labels or {}
        buc = labels.get(label_key)
        
        if buc and not any(p.match(buc) for p in patterns):
                namespaces_with_invalid_buc.append(ns.metadata.name)

    return {
        "namespaces_with_invalid_buc": namespaces_with_invalid_buc,
    }

def main() -> None:
    config.load_kube_config()
    v1 = client.CoreV1Api()
    ns_items = v1.list_namespace().items
    result = evaluate_namespaces(ns_items)
    print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    main()

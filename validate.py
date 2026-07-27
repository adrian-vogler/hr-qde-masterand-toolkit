#!/usr/bin/env python3
"""Authoritative SHACL validation for HR-QDE deliveries.

Validates a delivery TTL file against the combined HR-QDE shapes
using pyshacl. This is the authoritative check: the neosemantics
validator inside the Neo4j container does not evaluate sh:pattern
constraints on IRI values (for example the canonical-UUID rule for
ESCO skill URIs, enforced since shapes v0.2.0). pyshacl evaluates
them fully.

Usage:
    python validate.py <delivery.ttl> [<shapes.ttl>]

Default shapes file: ontology/hrqde-shapes-all.ttl (relative to the
toolkit root, i.e. the directory of this script).

Requirements:
    pip install pyshacl

Exit codes: 0 = conformant, 1 = violations found, 2 = usage/parse error.
"""

from __future__ import annotations

import sys
from pathlib import Path

try:
    import rdflib
    from pyshacl import validate
except ImportError:
    sys.stderr.write(
        "pyshacl is not installed. Run: pip install pyshacl\n"
    )
    sys.exit(2)

DEFAULT_SHAPES = Path(__file__).resolve().parent / "ontology" / "hrqde-shapes-all.ttl"


def main() -> int:
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        sys.stderr.write(__doc__ or "")
        return 2

    data_path = Path(sys.argv[1])
    shapes_path = Path(sys.argv[2]) if len(sys.argv) == 3 else DEFAULT_SHAPES

    for p, kind in ((data_path, "delivery"), (shapes_path, "shapes")):
        if not p.is_file():
            sys.stderr.write(f"{kind} file not found: {p}\n")
            return 2

    try:
        data_graph = rdflib.Graph().parse(str(data_path), format="turtle")
        shapes_graph = rdflib.Graph().parse(str(shapes_path), format="turtle")
    except Exception as exc:  # noqa: BLE001 - report any parse failure
        sys.stderr.write(f"Turtle parse error: {exc}\n")
        return 2

    conforms, _, results_text = validate(
        data_graph,
        shacl_graph=shapes_graph,
        inference="none",
        abort_on_first=False,
    )

    print(f"Delivery: {data_path}")
    print(f"Shapes:   {shapes_path}")
    if conforms:
        print("Result:   CONFORMS")
        return 0

    print("Result:   DOES NOT CONFORM")
    print()
    print(results_text)
    return 1


if __name__ == "__main__":
    sys.exit(main())

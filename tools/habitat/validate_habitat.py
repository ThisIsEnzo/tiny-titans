#!/usr/bin/env python3
"""Validate committed Habitat model assets for structural integrity.

The playable starting level (Ancient Ruins / Ancient Weight) is generated at runtime by
AncientWeightFixture.lua. It is deliberately not inferred from the unrelated legacy
Habitat model files in this directory.

This offline validator checks only the committed *.model.json assets: their structure,
part budgets, bounds, static-part properties, and CFrame rotations. It does not claim
to simulate Roblox collision or validate runtime-generated geometry; use Roblox Studio
for those checks.
"""
import json
import math
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
HAB = os.path.join(ROOT, "src", "Workspace", "Habitat")
HALF = 70
MAX_PARTS = 260
failures = []


def check(name, ok, detail=""):
    print(("ok:   " if ok else "FAIL: ") + name + (f"  [{detail}]" if detail and not ok else ""))
    if not ok:
        failures.append(name)


def load_assets():
    assets = []
    if not os.path.isdir(HAB):
        check("Habitat asset directory exists", False, HAB)
        return assets

    files = sorted(fn for fn in os.listdir(HAB) if fn.endswith(".model.json"))
    check("at least one committed Habitat model asset", bool(files))
    for filename in files:
        path = os.path.join(HAB, filename)
        try:
            with open(path, encoding="utf-8") as stream:
                data = json.load(stream)
        except (OSError, json.JSONDecodeError) as exc:
            check(f"{filename} is valid JSON", False, str(exc))
            continue

        valid_root = isinstance(data, dict) and data.get("className") == "Folder"
        check(f"{filename} has a Folder root", valid_root)
        if not valid_root:
            continue

        children = data.get("children")
        valid_children = isinstance(children, list)
        check(f"{filename} has a children array", valid_children)
        if not valid_children:
            continue

        for child in children:
            if not isinstance(child, dict):
                check(f"{filename} child is an object", False)
                continue
            props = child.get("properties")
            if not isinstance(props, dict):
                check(f"{filename}/{child.get('name', '<unnamed>')} has properties", False)
                continue
            cframe = props.get("CFrame")
            nested = cframe.get("CFrame") if isinstance(cframe, dict) else None
            position = nested.get("position") if isinstance(nested, dict) else None
            orientation = nested.get("orientation") if isinstance(nested, dict) else None
            assets.append({
                "file": filename,
                "name": child.get("name"),
                "class": child.get("className"),
                "props": props,
                "position": position,
                "orientation": orientation,
            })
    return assets


def valid_rotation(matrix):
    if not isinstance(matrix, list) or len(matrix) != 3:
        return False
    if any(not isinstance(row, list) or len(row) != 3 for row in matrix):
        return False
    try:
        rows = [[float(value) for value in row] for row in matrix]
    except (TypeError, ValueError):
        return False

    # Rows of a proper rotation matrix are orthonormal and have determinant +1.
    for i in range(3):
        for j in range(i, 3):
            dot = sum(rows[i][k] * rows[j][k] for k in range(3))
            expected = 1.0 if i == j else 0.0
            if abs(dot - expected) >= 1e-4:
                return False
    a, b, c = rows
    determinant = (
        a[0] * (b[1] * c[2] - b[2] * c[1])
        - a[1] * (b[0] * c[2] - b[2] * c[0])
        + a[2] * (b[0] * c[1] - b[1] * c[0])
    )
    return abs(determinant - 1.0) < 1e-4


def main():
    parts = load_assets()
    print(f"loaded {len(parts)} parts from committed Habitat model assets")

    names = [(part["file"], part["name"]) for part in parts]
    check("all model children have unique names within their asset",
          all(name is not None for _, name in names)
          and len(names) == len(set(names)))

    check(f"part count within mobile budget (<= {MAX_PARTS})", len(parts) <= MAX_PARTS, str(len(parts)))

    positive_sizes = True
    in_bounds = True
    static_parts = True
    rotations = True
    for part in parts:
        label = f"{part['file']}/{part['name']}"
        props = part["props"]
        size = props.get("Size")
        if not isinstance(size, list) or len(size) != 3:
            positive_sizes = False
        else:
            try:
                if not all(math.isfinite(float(value)) and float(value) > 0 for value in size):
                    positive_sizes = False
            except (TypeError, ValueError):
                positive_sizes = False

        position = part["position"]
        if not isinstance(position, list) or len(position) != 3:
            in_bounds = False
        else:
            try:
                x, _, z = (float(value) for value in position)
                if not (math.isfinite(x) and math.isfinite(z)
                        and abs(x) <= HALF + 4 and abs(z) <= HALF + 4):
                    in_bounds = False
            except (TypeError, ValueError):
                in_bounds = False

        if props.get("Anchored") is not True or props.get("Locked") is not True or props.get("CanTouch") is not False:
            static_parts = False

        if not valid_rotation(part["orientation"]):
            rotations = False

    check("all parts have positive finite sizes", positive_sizes)
    check(f"all parts lie inside habitat asset bounds (+/- {HALF + 4} studs)", in_bounds)
    check("all committed Habitat parts are anchored, locked, and have CanTouch disabled", static_parts)
    check("every CFrame orientation is a proper rotation", rotations)

    print("\nRESULT:", "FAILED " + str(len(failures)) if failures else "all checks passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())

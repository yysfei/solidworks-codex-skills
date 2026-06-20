"""
Paste this file into the solidworks MCP `execute_python` tool.

Use when `list_features` only returns Favorites, or when SW2019 / pywin32
late-bound COM does not expose ModelDoc2.FirstFeature().

Expected MCP globals:
  sw  - SOLIDWORKS application object
  doc - active ModelDoc2 object
"""

import traceback


def read0(obj, name):
    """Read a zero-argument COM method that may be exposed as a property."""
    attr = getattr(obj, name)
    if callable(attr):
        try:
            return attr()
        except TypeError:
            return attr
        except Exception:
            return attr
    return attr


try:
    model = doc
    title = read0(model, "GetTitle")
    path = read0(model, "GetPathName")
    count = read0(model, "GetFeatureCount")

    print(f"ActiveDoc: {title}")
    print(f"Path: {path}")
    print(f"Feature count reported: {count}")

    feature_by_position_reverse = getattr(model, "FeatureByPositionReverse")
    read_count = 0

    for idx in range(int(count)):
        feat = feature_by_position_reverse(idx)
        if feat is None:
            continue

        read_count += 1
        name = read0(feat, "Name")

        try:
            type_name = read0(feat, "GetTypeName2")
        except Exception:
            try:
                type_name = read0(feat, "GetTypeName")
            except Exception:
                type_name = "<no type>"

        try:
            suppressed = read0(feat, "IsSuppressed")
        except Exception:
            suppressed = None

        print(
            f"{read_count:03d}\tidx={idx}\t{name}\t{type_name}\t"
            f"suppressed={suppressed}"
        )

    print(f"Read via FeatureByPositionReverse: {read_count}")

except Exception:
    traceback.print_exc()

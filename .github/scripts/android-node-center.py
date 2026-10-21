import re
import sys
import xml.etree.ElementTree as ET

def center(xml, label):
    matches = [n for n in ET.fromstring(xml).iter("node") if n.get("text") == label or n.get("content-desc") == label]
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one visible {label!r} node, got {len(matches)}")
    match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", matches[0].get("bounds", ""))
    if not match:
        raise ValueError("Missing valid native bounds")
    x1,y1,x2,y2 = map(int, match.groups())
    if x2 <= x1 or y2 <= y1:
        raise ValueError("Empty native bounds")
    return (x1+x2)//2, (y1+y2)//2

if __name__ == "__main__":
    from pathlib import Path
    print(*center(Path(sys.argv[1]).read_text(), sys.argv[2]))

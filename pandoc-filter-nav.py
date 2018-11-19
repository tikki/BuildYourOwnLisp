#!/usr/bin/env python

"""Filter out navigation blocks from pandoc AST. """

import json
import sys


def is_header(block: dict) -> bool:
    "Return True if this block is a header"
    return block["t"] == "Header"


_nav_header = [{"t": "Str", "c": "Navigation"}]


def is_nav_header(block: dict) -> bool:
    "Return True if this block is a navigation header"
    return is_header(block) and block["c"][0] == 2 and block["c"][2] == _nav_header


_is_nav = False


def is_nav(block: dict) -> bool:
    "Return True if this block is *part* of the navigation"
    global _is_nav
    if is_header(block):
        _is_nav = is_nav_header(block)
    return _is_nav


def main():
    ast = json.load(sys.stdin)
    ast["blocks"] = [block for block in ast["blocks"] if not is_nav(block)]
    sys.stdout.write(json.dumps(ast))


if __name__ == "__main__":
    main()

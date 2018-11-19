#!/usr/bin/env python

"""Resolve <references /> tag in chapter files."""

import lispy
import sys


def deref(page: str, in_, out) -> None:
    index = lispy.pages.index(page)
    codes = lispy.sources[index]
    out.write(in_.read().replace("<references />", lispy.code_html(codes)))


def main() -> None:
    page = sys.argv[1]
    deref(page, sys.stdin, sys.stdout)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""List Markdown headings or print one section verbatim, including its children."""

import argparse
from pathlib import Path
import re
import sys


def headings(lines):
    fence = ""
    for index, line in enumerate(lines):
        marker = re.match(r"^ {0,3}(`{3,}|~{3,})", line)
        if marker:
            run = marker[1]
            if not fence:
                fence = run
            elif run[0] == fence[0] and len(run) >= len(fence) and not line[marker.end():].strip():
                fence = ""
            continue
        match = re.match(r"^ {0,3}(#{1,6})[ \t]+(.+?)\s*$", line)
        if match and not fence:
            title = re.sub(r"[ \t]+#+[ \t]*$", "", match[2])
            yield index, len(match[1]), title


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=Path)
    parser.add_argument("heading", nargs="?", help="exact heading text, case-insensitive")
    args = parser.parse_args()
    try:
        with args.file.open(encoding="utf-8", newline="") as source:
            lines = source.readlines()
    except (OSError, UnicodeError) as error:
        parser.error(str(error))
    entries = list(headings(lines))
    if args.heading is None:
        for index, level, title in entries:
            print(f"{args.file}:{index + 1}: {'#' * level} {title}")
        if not entries:
            parser.error("no Markdown # headings found")
        return
    matches = [entry for entry in entries if entry[2].casefold() == args.heading.casefold()]
    if len(matches) != 1:
        parser.error(f"expected one heading matching {args.heading!r}, found {len(matches)}; "
                     "omit the heading to list titles and line numbers")
    start, level, _ = matches[0]
    end = next((index for index, depth, _ in entries if index > start and depth <= level), len(lines))
    print(f"{args.file}:{start + 1}-{end}")
    sys.stdout.write("".join(lines[start:end]))


if __name__ == "__main__":
    main()

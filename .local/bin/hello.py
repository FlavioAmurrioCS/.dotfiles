#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterable


def main(argv: Iterable[str] | None = None) -> int:
    import argparse

    parser = argparse.ArgumentParser()
    args, rest = parser.parse_known_args(argv)
    print(f"Hello World! {args} {rest}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

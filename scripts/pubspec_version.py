#!/usr/bin/env python3
"""Store version for Safini lives only in pubspec.yaml (`name+build`).

Play versionCode and iOS CFBundleVersion are the +N suffix and must strictly
increase on every upload. Feature PRs must not touch this line — bump on an
up-to-date main with `make bump-build` / `make bump-patch` / `make bump-minor`.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = ROOT / "pubspec.yaml"
VERSION_RE = re.compile(r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$", re.M)
REMOTE_REF = "origin/main"


class Version:
    def __init__(self, major: int, minor: int, patch: int, build: int) -> None:
        self.major = major
        self.minor = minor
        self.patch = patch
        self.build = build

    @property
    def name(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}"

    def __str__(self) -> str:
        return f"{self.name}+{self.build}"

    def as_tuple(self) -> tuple[int, int, int, int]:
        return (self.major, self.minor, self.patch, self.build)

    def name_tuple(self) -> tuple[int, int, int]:
        return (self.major, self.minor, self.patch)

    def bumped(self, part: str) -> Version:
        if part == "build":
            return Version(self.major, self.minor, self.patch, self.build + 1)
        if part == "patch":
            return Version(self.major, self.minor, self.patch + 1, self.build + 1)
        if part == "minor":
            return Version(self.major, self.minor + 1, 0, self.build + 1)
        if part == "major":
            return Version(self.major + 1, 0, 0, self.build + 1)
        raise SystemExit(f"unknown bump part: {part}")


def parse_version(text: str, source: str) -> Version:
    match = VERSION_RE.search(text)
    if not match:
        raise SystemExit(f"No `version: X.Y.Z+N` line in {source}")
    return Version(*(int(g) for g in match.groups()))


def read_local() -> Version:
    return parse_version(PUBSPEC.read_text(encoding="utf-8"), "pubspec.yaml")


def git(*args: str, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        ["git", *args],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=check,
    )


def fetch_main() -> None:
    result = git("fetch", "origin", "main", check=False)
    if result.returncode != 0:
        sys.stderr.write(result.stderr)
        raise SystemExit("Could not fetch origin/main — needed to compare store versions.")


def remote_version() -> Version:
    result = git("show", f"{REMOTE_REF}:pubspec.yaml")
    return parse_version(result.stdout, f"{REMOTE_REF}:pubspec.yaml")


def current_branch() -> str:
    return git("rev-parse", "--abbrev-ref", "HEAD").stdout.strip()


def is_behind_main() -> bool:
    head = git("rev-parse", "HEAD").stdout.strip()
    main = git("rev-parse", REMOTE_REF).stdout.strip()
    if head == main:
        return False
    merged = git("merge-base", "--is-ancestor", "HEAD", REMOTE_REF, check=False)
    return merged.returncode == 0


def print_rules(local: Version) -> None:
    print(f"Current: {local}")
    print(f"  name  {local.name}  -> Play versionName / iOS short version")
    print(f"  build {local.build}     -> Play versionCode / iOS CFBundleVersion")
    print()
    print("Rules:")
    print("  - One source of truth: pubspec.yaml `version:`")
    print("  - Never edit that line by hand. Use make bump-build / bump-patch / bump-minor.")
    print("  - Do not bump versions in feature or fix PRs. Land the change, then bump on main.")
    print("  - Every store upload needs a new +N. Play rejects a reused or lower versionCode.")
    print("  - Marketing version must not go backwards vs origin/main (1.0.9 must not become 1.0.3).")
    print("  - Pull main first. A bump on a stale checkout is how Play/App Store get a bad number.")
    print()
    print("Commands:")
    print("  make version       show this")
    print("  make bump-build    1.0.9+33 -> 1.0.9+34   (every upload)")
    print("  make bump-patch    1.0.9+33 -> 1.0.10+34  (fixes)")
    print("  make bump-minor    1.0.9+33 -> 1.1.0+34   (features)")
    print("  make version-check CI / pre-PR guard vs origin/main")
    print("  make build-android / make build-ios  bump-build, then release artifacts")


def cmd_show(_: argparse.Namespace) -> None:
    local = read_local()
    print_rules(local)
    fetch_main()
    remote = remote_version()
    print()
    print(f"origin/main: {remote}")
    if str(local) == str(remote):
        print("Local matches origin/main.")
        return
    if local.build <= remote.build or local.name_tuple() < remote.name_tuple():
        print("Local is behind origin/main. git pull, then bump if you are shipping.")
        return
    print("Local is ahead of origin/main (uncommitted or unpushed bump).")


def _version_line_changed(diff: str) -> bool:
    in_pubspec = False
    for line in diff.splitlines():
        if line.startswith("diff --git"):
            in_pubspec = line.endswith("pubspec.yaml") or "/pubspec.yaml" in line
            continue
        if in_pubspec and line.startswith(("+", "-")) and not line.startswith(("+++", "---")):
            if line[1:].startswith("version:"):
                return True
    return False


def cmd_check(args: argparse.Namespace) -> None:
    fetch_main()
    local = read_local()
    remote = remote_version()
    print(f"local {local}")
    print(f"{REMOTE_REF} {remote}")

    if local.build < remote.build:
        raise SystemExit(
            f"Build number {local.build} is behind origin/main ({remote.build}). "
            "Play versionCode cannot go backwards. git pull, then make bump-build."
        )
    if local.name_tuple() < remote.name_tuple():
        raise SystemExit(
            f"Marketing version {local.name} is behind origin/main ({remote.name}). "
            "Do not set this in a feature PR — that is how 1.0.9 became 1.0.3 in PR #109."
        )

    if str(local) == str(remote):
        print("Version matches origin/main.")
        return

    if local.build == remote.build and local.name_tuple() > remote.name_tuple():
        raise SystemExit(
            f"{local} keeps build {local.build} while changing the name vs {remote}. "
            "Every store upload needs a new +N; use make bump-patch or make bump-minor."
        )

    pr_mode = args.pr or os.environ.get("VERSION_CHECK_PR") == "1"
    if pr_mode:
        pubspec_diff = "\n".join(
            (
                git("diff", f"{REMOTE_REF}...HEAD", "--", "pubspec.yaml").stdout,
                git("diff", "--cached", REMOTE_REF, "--", "pubspec.yaml").stdout,
                git("diff", REMOTE_REF, "--", "pubspec.yaml").stdout,
            )
        )
        if _version_line_changed(pubspec_diff):
            names = set(
                git("diff", "--name-only", f"{REMOTE_REF}...HEAD").stdout.split()
            )
            names.update(git("diff", "--name-only", "--cached", REMOTE_REF).stdout.split())
            names.update(git("diff", "--name-only", REMOTE_REF).stdout.split())
            extras = sorted(n for n in names if n != "pubspec.yaml")
            if extras:
                extra = ", ".join(extras[:12])
                more = "" if len(extras) <= 12 else f" (+{len(extras) - 12} more)"
                raise SystemExit(
                    "Do not mix a pubspec.yaml version bump with other changes "
                    f"({extra}{more}).\n"
                    "Land the fix/feature first. On an up-to-date main, run "
                    "make bump-build (or bump-patch / bump-minor) in its own commit/PR."
                )
    print("Version is ahead of origin/main.")


def write_version(new: Version) -> None:
    text = PUBSPEC.read_text(encoding="utf-8")
    updated, count = VERSION_RE.subn(f"version: {new}", text, count=1)
    if count != 1:
        raise SystemExit("Could not rewrite the version line in pubspec.yaml")
    PUBSPEC.write_text(updated, encoding="utf-8")


def cmd_bump(args: argparse.Namespace) -> None:
    force = args.force or os.environ.get("FORCE") == "1"
    fetch_main()
    branch = current_branch()
    if branch != "main" and not force:
        raise SystemExit(
            f"Version bumps belong on main, not `{branch}`.\n"
            "Land the PR, then: git checkout main && git pull && make bump-{build|patch|minor}\n"
            "Override only for a known store upload: FORCE=1 make bump-build"
        )
    if is_behind_main() and not force:
        raise SystemExit(
            "Local main is behind origin/main. git pull, then bump, or you will "
            "commit a stale (or colliding) store version."
        )

    local = read_local()
    remote = remote_version()
    new = local.bumped(args.part)
    if new.build <= remote.build:
        raise SystemExit(
            f"{new} would not beat origin/main build {remote.build}. "
            "git pull and bump again."
        )
    if new.name_tuple() < remote.name_tuple():
        raise SystemExit(
            f"{new} would move the marketing version behind origin/main {remote}."
        )
    write_version(new)
    print(f"{local} -> {new}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("show", help="Print current version and the team rules")

    check = sub.add_parser("check", help="Fail if local version is invalid vs origin/main")
    check.add_argument(
        "--pr",
        action="store_true",
        help="Also fail when a version bump is mixed with other files",
    )

    bump = sub.add_parser("bump", help="Rewrite pubspec.yaml version")
    bump.add_argument("part", choices=("build", "patch", "minor", "major"))
    bump.add_argument("--force", action="store_true")

    args = parser.parse_args()
    if args.cmd == "show":
        cmd_show(args)
    elif args.cmd == "check":
        cmd_check(args)
    else:
        cmd_bump(args)


if __name__ == "__main__":
    main()

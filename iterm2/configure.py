#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.9"
# dependencies = ["iterm2"]
# ///
"""Apply iTerm2 profile settings live, with a snapshot taken first so any
change can be undone.

iTerm2 keeps preferences in memory and flushes them to the plist itself, so
writing the plist from outside while iTerm2 runs loses the change. Going
through the API instead means settings take effect immediately, persist, and
need no restart.

Usage:
    ./configure.py show              # current vs desired, marks drift
    ./configure.py apply --dry-run   # what would change, writes nothing
    ./configure.py apply             # snapshot, then write
    ./configure.py revert            # restore the most recent snapshot

Snapshots land in ~/.local/state/iterm2-config/ and are never pruned; each
apply writes a new one. To add a setting, put it in SETTINGS — any name for
which iterm2.profile.Profile has both a getter and an async_set_<name> works.
Discover them with:

    uv run --with iterm2 python -c "import iterm2.profile as p; \
        print([m[10:] for m in dir(p.Profile) if m.startswith('async_set_')])"
"""

import argparse
import datetime
import enum
import json
import pathlib

import iterm2
import iterm2.profile

STATE_DIR = pathlib.Path.home() / ".local/state/iterm2-config"

# name -> (desired value, why it is wanted)
SETTINGS = {
    "scrollback_lines": (
        100_000,
        "the stock buffer is smaller than one verbose terraform plan",
    ),
    "left_option_key_sends": (
        iterm2.profile.OptionKeySends.OPTION_KEY_ESC,
        "Option-B/Option-F word navigation in zsh readline; Normal sends neither",
    ),
    "status_bar_enabled": (
        True,
        "tells concurrent agent sessions apart without reading tab titles; "
        "choose components in Settings > Profiles > Session",
    ),
}


def _plain(value):
    """Unwrap an enum to the value both the API and the snapshot file want.

    The setters are annotated with enum types (OptionKeySends and friends) but
    hand the value straight to json.dumps, and those enums do not subclass int,
    so passing the enum a signature asks for raises TypeError. Getters likewise
    return plain ints. SETTINGS keeps the enum member because OPTION_KEY_ESC
    documents itself where 2 does not; everything downstream sees the int.
    """
    return value.value if isinstance(value, enum.Enum) else value


async def _profile(connection, name):
    partials = await iterm2.PartialProfile.async_query(connection)
    for partial in partials:
        if partial.name == name:
            return await partial.async_get_full_profile()
    raise SystemExit(
        f"no profile named {name!r}; found: {', '.join(p.name for p in partials)}"
    )


def _rows(profile):
    for name, (desired, why) in SETTINGS.items():
        yield name, _plain(getattr(profile, name)), _plain(desired), why


async def show(connection, args):
    profile = await _profile(connection, args.profile)
    for name, current, desired, why in _rows(profile):
        mark = " " if current == desired else "*"
        print(f"{mark} {name}\n    current={current!r} desired={desired!r}\n    {why}")
    print("\n* = differs from desired")


async def apply(connection, args):
    profile = await _profile(connection, args.profile)
    changes = [(n, c, d) for n, c, d, _ in _rows(profile) if c != d]
    if not changes:
        print("nothing to change")
        return

    for name, current, desired in changes:
        print(f"{name}: {current!r} -> {desired!r}")
    if args.dry_run:
        print("\ndry run, nothing written")
        return

    STATE_DIR.mkdir(parents=True, exist_ok=True)
    stamp = datetime.datetime.now().strftime("%Y%m%dT%H%M%S")
    path = STATE_DIR / f"{stamp}.json"
    path.write_text(
        json.dumps(
            {
                "profile": args.profile,
                "values": {name: current for name, current, _ in changes},
            },
            indent=2,
        )
    )
    print(f"\nsnapshot: {path}")

    for name, _, desired in changes:
        await getattr(profile, "async_set_" + name)(desired)
    print(f"applied {len(changes)} setting(s)")


async def revert(connection, args):
    if args.snapshot:
        path = pathlib.Path(args.snapshot)
    else:
        snapshots = sorted(STATE_DIR.glob("*.json")) if STATE_DIR.is_dir() else []
        if not snapshots:
            raise SystemExit(f"no snapshots in {STATE_DIR}")
        path = snapshots[-1]

    saved = json.loads(path.read_text())
    profile = await _profile(connection, saved["profile"])
    print(f"restoring {path}")
    for name, value in saved["values"].items():
        print(f"  {name} -> {value!r}")
        await getattr(profile, "async_set_" + name)(value)
    print(f"restored {len(saved['values'])} setting(s)")


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--profile", default="Default", help="profile name")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("show")
    apply_parser = sub.add_parser("apply")
    apply_parser.add_argument("--dry-run", action="store_true")
    revert_parser = sub.add_parser("revert")
    revert_parser.add_argument("--snapshot", help="defaults to the most recent")
    args = parser.parse_args()

    handler = {"show": show, "apply": apply, "revert": revert}[args.command]

    async def run(connection):
        await handler(connection, args)

    try:
        iterm2.run_until_complete(run)
    except (ConnectionRefusedError, FileNotFoundError, OSError) as exc:
        raise SystemExit(
            f"cannot reach iTerm2's API socket ({exc}). Is iTerm2 running, and is "
            "the Python API enabled in Settings > General > Magic?"
        )


if __name__ == "__main__":
    main()

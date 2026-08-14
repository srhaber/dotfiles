#!/usr/bin/env python3
"""PreToolUse/Bash hook: deny recursive rm regardless of flag position.

The permission deny-list matches on string prefixes, so `rm -rf x` is caught but
`rm -f -r x` is not — and neither are `sudo rm -fr x`, `xargs rm -r`, or
`find . -exec rm -r {} +`. This inspects the actual command instead.

Allowed:  rm file, rm -f file, rm *.log, rm -d emptydir, rmdir emptydir
Denied:   any rm whose flags include r/R, in any order, behind any prefix.

`-d` and `rmdir` are deliberately allowed: both only remove *empty* directories,
so neither can delete anything that isn't already gone.
"""
import json
import re
import sys

RECURSIVE_LONG = {"--recursive"}
# Shell separators that start a new command within one Bash call.
SEGMENT_SPLIT = re.compile(r"[;&|\n]+")


def is_recursive_flag(token: str) -> bool:
    if token in RECURSIVE_LONG:
        return True
    if token.startswith("--") or not token.startswith("-"):
        return False
    # Short flag cluster: -rf, -fr, -Rf, -if ...
    return any(ch in "rR" for ch in token[1:])


# Tokens that can legitimately precede the real `rm` command without changing what it is.
# Anything else before `rm` means it's a subcommand of another tool (`git rm`, `docker image rm`),
# whose deletions are that tool's business — and are recoverable in a way `rm -rf` is not.
RM_PREFIXES = {"sudo", "doas", "env", "time", "nohup", "command", "xargs", "exec", "then", "do", "&&", "||"}


def is_rm_in_command_position(tokens: list[str], i: int) -> bool:
    if i == 0:
        return True
    if tokens[i - 1] in ("-exec", "-execdir"):  # find . -exec rm -r {} +
        return True
    for t in tokens[:i]:
        base = t.split("/")[-1]
        if base in RM_PREFIXES:
            continue
        if "=" in t and not t.startswith("-"):  # FOO=bar rm ...
            continue
        if t.startswith("-"):  # flags belonging to an allowed prefix, e.g. xargs -0
            continue
        return False
    return True


def segment_has_recursive_rm(segment: str) -> bool:
    tokens = segment.split()
    for i, token in enumerate(tokens):
        # basename, so /bin/rm and sudo/xargs/find -exec prefixes all resolve
        if token.split("/")[-1] != "rm":
            continue
        if not is_rm_in_command_position(tokens, i):
            continue
        for arg in tokens[i + 1:]:
            if arg == "--":
                break  # everything after is an operand, not a flag
            if is_recursive_flag(arg):
                return True
    return False


def main() -> None:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)  # not our business — let the normal flow decide

    command = payload.get("tool_input", {}).get("command", "")
    if not any(segment_has_recursive_rm(s) for s in SEGMENT_SPLIT.split(command)):
        sys.exit(0)

    json.dump({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "Recursive rm is blocked. Single-file rm is allowed — drop the "
                "-r/-R/-d flag, or run the recursive delete yourself."
            ),
        }
    }, sys.stdout)


if __name__ == "__main__":
    main()

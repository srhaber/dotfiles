#!/usr/bin/env python3
"""Exercise the deny_recursive_rm hook without putting the patterns in a shell command."""
import json
import subprocess
import sys

HOOK = "/Users/shaun/.claude/hooks/deny_recursive_rm.py"

MUST_DENY = [
    "rm -rf dir",
    "rm -f -r dir",
    "rm -i -R dir",
    "sudo rm -fr /x",
    "ls | xargs rm -r",
    "find . -exec rm -r {} +",
    "cd /tmp && rm -rf d",
    "FOO=1 rm -rf d",
    "/bin/rm -R dir",
    "rm --recursive dir",
]

MUST_ALLOW = [
    # subcommands of other tools — their deletions are that tool's business, and recoverable
    "git rm -r --cached path",
    "git rm -rf path",
    "docker image rm -f img",
    "npm rm -D pkg",
    "cargo rm -p thing",
    # genuinely fine
    "rm -f file",
    "rm file.txt",
    "rm *.log",
    "rmdir empty",
    "rmdir -p a/b/c",
    "rm -d emptydir",
    "grep -r pat; rm f",
    "rm -- -r",
]


def denied(cmd: str) -> bool:
    out = subprocess.run(
        [sys.executable, HOOK],
        input=json.dumps({"tool_input": {"command": cmd}}),
        capture_output=True, text=True,
    ).stdout.strip()
    return bool(out)


fails = 0
for cmd in MUST_DENY:
    ok = denied(cmd)
    print(f"{'DENY  ok ' if ok else 'FAIL     '} {cmd}")
    fails += 0 if ok else 1
print()
for cmd in MUST_ALLOW:
    ok = not denied(cmd)
    print(f"{'allow ok ' if ok else 'FAIL     '} {cmd}")
    fails += 0 if ok else 1

print(f"\n{len(MUST_DENY) + len(MUST_ALLOW) - fails}/{len(MUST_DENY) + len(MUST_ALLOW)} cases correct")
sys.exit(1 if fails else 0)

#!/bin/bash

LAST_TAG=`git tag | grep ^v | tail -n1`

# Determine the lastest two versions sorting the semvers correctly.
REV_RANGE=$(git tag -l | python -c '
import sys, re
version_re = re.compile(r"^(.*/)?(v[0-9.]+)$")
key = lambda m: tuple(map(int, m.group(2)[1:].split(".")))
matches = sorted(dict(
    (key(m), m) for m in map(version_re.search, sys.stdin) if m).items())
print "%s..%s" % (matches[-2][1].group(0), matches[-1][1].group(0))
')

echo $REV_RANGE

# Canonicalize by BOTH e-mail address and by name.
# e.g. Matias Niemelä (Matias Niemela\xcc\x88) and
#      Matias Niemelä (Matias Niemel\xc3\xa4) are the same.
git log --pretty=tformat:'%ae %an' "$REV_RANGE" | python -c '
import sys
authors = set(dict(line.split(" ", 1) for line in sys.stdin).values())
print ", ".join(sorted(authors)).replace("\n", "")
'

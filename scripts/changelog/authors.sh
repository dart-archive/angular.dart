#!/bin/bash

LAST_TAG=`git tag | grep ^v | tail -n1`

git log v0.9.3..HEAD | grep Author | sort | uniq | sed 's/Author: \(.*\) \<.*/\1/' | tr "\\n" ", " | sed 's/,$/\n/' | sed 's/\,/, /g'

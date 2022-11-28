#!/usr/bin/env bash

set -euo pipefail

ISSUE_NUM="$1"

gh repo create --clone --description "Reproduction of https://github.com/vercel/next.js/issues/$ISSUE_NUM" --public "next-repro-$ISSUE_NUM"
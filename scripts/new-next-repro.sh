#!/usr/bin/env bash

set -euo pipefail
set -o xtrace # print all commands

ISSUE_NUM="$1"
GH_REPO_NAME="next-repro-$ISSUE_NUM"
LOCAL_NAME="$ISSUE_NUM"

gh repo create --clone --description "Reproduction of https://github.com/vercel/next.js/issues/$ISSUE_NUM" --public "$GH_REPO_NAME"
mv "$GH_REPO_NAME" "$LOCAL_NAME"
steam-run pnpm create next-app --example reproduction-template "$LOCAL_NAME"
cd "$LOCAL_NAME"
git add --all
git commit -m "init"
git push --set-upstream origin main
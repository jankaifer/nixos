#!/usr/bin/env bash

set -euo pipefail
set -o xtrace # print all commands

ISSUE_NUM="$1"
GH_REPO_NAME="next-repro-$ISSUE_NUM"
LOCAL_NAME="$ISSUE_NUM"
TEMPLATE="reproduction-template-app-dir"

gh repo create --clone --description "Reproduction of https://github.com/vercel/next.js/issues/$ISSUE_NUM" --public "$GH_REPO_NAME"
mv "$GH_REPO_NAME" "$LOCAL_NAME"
pnpm create next-app --example "$TEMPLATE" "$LOCAL_NAME"
cd "$LOCAL_NAME"
git add --all
git commit -m "init"
git push --set-upstream origin main
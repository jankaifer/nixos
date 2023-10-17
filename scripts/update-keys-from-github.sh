#!/usr/bin/env bash
curl -fsSL "https://github.com/jankaifer.keys" | sed '/^$/d' > ./modules/public-ssh-keys.txt

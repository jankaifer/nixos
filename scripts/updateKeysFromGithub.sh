#!/usr/bin/env bash
curl -fsSL "https://github.com/jankaifer.keys" | sed '/^$/d' > ./modules/publicSshKeys.txt

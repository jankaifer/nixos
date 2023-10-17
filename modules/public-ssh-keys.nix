let
  rawKeys = builtins.readFile ./public-ssh-keys.txt;
  keyList = builtins.split "\n" rawKeys;
in
builtins.filter (key: key != "" && key != [ ]) keyList

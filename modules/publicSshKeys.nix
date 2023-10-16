let
  rawKeys = builtins.readFile ./publicSshKeys.txt;
  keyList = builtins.split "\n" rawKeys;
in
builtins.filter (key: key != "" && key != [ ]) keyList

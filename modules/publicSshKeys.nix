let
  rawKeys = builtins.readFile "./publicSshKeys.txt";
  keyList = builtins.split "\n" (builtins.replaceStrings [ "\r" ] [ "" ] rawKeys);
in
builtins.filter (key: key != "") keyList

GAME_NAME="$1"
nix-shell -p steam-run-native --run "steam-run $HOME/.local/share/Steam/steamapps/common/$GAME_NAME/$GAME_NAME"
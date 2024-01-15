{ lib, pkgs, ... }:

{
  options.custom.zsh = {
    enable = lib.mkEnableOption "zsh" // { default = true; };
  };

  config = {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    programs.zsh = {
      enable = true;
      history = {
        size = 10000;
      };
      initExtraBeforeCompInit = /* bash */ ''
        # Completion
        zstyle ':completion:*' menu yes select

        # Prompt
        source ${pkgs.spaceship-prompt}/lib/spaceship-prompt/spaceship.zsh
        autoload -U promptinit; promptinit
      '';
      initExtra = /* bash */ ''
        bindkey '^[[Z' reverse-menu-complete

        # Workaround for ZVM overwriting keybindings
        zvm_after_init_commands+=("bindkey '^[[A' history-substring-search-up")
        zvm_after_init_commands+=("bindkey '^[OA' history-substring-search-up")
        zvm_after_init_commands+=("bindkey '^[[B' history-substring-search-down")
        zvm_after_init_commands+=("bindkey '^[OB' history-substring-search-down")

        # TODO: I want to use fnm, but it slows down the start of a new terminal too much
        # eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
      '';
      localVariables = {
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=13,underline";
        ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
        KEYTIMEOUT = 1;
        ZSHZ_CASE = "smart";
        ZSHZ_ECHO = 1;
      };
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      historySubstringSearch = {
        enable = true;
        # searchUpKey = [ "^[[A" "^[OA" ];
        # searchDownKey = [ "^[[B" "^[OB" ];
      };
      plugins = [
        {
          name = "nix-shell";
          src = "${pkgs.zsh-nix-shell}/share/zsh-nix-shell";
        }
        {
          name = "you-should-use";
          src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
        }
        {
          name = "zsh-vi-mode";
          src = "${pkgs.unstable.zsh-vi-mode}/share/zsh-vi-mode";
        }
        {
          name = "zsh-z";
          src = "${pkgs.zsh-z}/share/zsh-z";
        }
      ];
    };
    home.file.".config/spaceship.zsh".source = ./spaceship.zsh;
  };
}

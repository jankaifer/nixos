{ config, lib, pkgs, ... }:

let
  cfg = config.custom.cli;
in
{
  options.custom.cli = {
    enable = (lib.mkEnableOption "cli") // { default = true; };
    personalGitEnable = (lib.mkEnableOption "personalGitEnable") // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      gh.enable = true;
      zsh.shellAliases = {
        ll = "eza -l --icons=auto";
        la = "eza -la --icons=auto";
        pls = "sudo";
        n = "pnpm";
        y = "yarn";
        gpf = "git push --force-with-lease";
        gfa = "git fetch --all";
        gr = "git rebase";
        gm = "git merge";
        gps = "git push";
        gpl = "git pull";
        rebuild = "sudo nixos-rebuild --flake \"\$(readlink -f '/etc/nixos')\"";
      };
      git = {
        enable = true;
        userName = lib.mkIf cfg.personalGitEnable "Jan Kaifer";
        userEmail = lib.mkIf cfg.personalGitEnable "jan@kaifer.cz";
        lfs.enable = true;
        extraConfig = {
          gpg.format = "ssh";
          gpg.ssh.defaultKeyCommand = "ssh-add -L";
          commit.gpgsign = true;
          tag.gpgsign = true;
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
        };
      };
      vim = {
        enable = true;
        extraConfig = builtins.readFile ../../../dotfiles/vim/.vimrc;
      };
    };

    home.file = {
      # For some reason vscode can't read the config when provided by impermanence
      ".vimrc".source = ../../../dotfiles/vim/.vimrc;
      # we can't use programs.ssh because it uses wrong permissions
      ".ssh/config" = {
        text = ''
          Host ssh-oldbox.kaifer.cz
            ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
        '';
        onChange = ''
          chmod 600 $out
        '';
      };
    };
    home.packages = [
      pkgs.curl
      pkgs.htop
      pkgs.tree
      pkgs.unzip
      pkgs.wget
      pkgs.xh # Like curl but better
      pkgs.killall
      pkgs.lshw
      pkgs.parted
      pkgs.tree
      pkgs.nixpkgs-fmt
      pkgs.fnm
    ];
  };
}

{
  default = { config, lib, ... }: {
    home = {
      username = lib.mkDefault "jankaifer";
      homeDirectory = lib.mkDefault "/home/${config.home.username}";
      stateVersion = lib.mkDefault "23.11";
    };
    xdg = {
      enable = lib.mkDefault true;
      userDirs = {
        enable = lib.mkDefault true;
        createDirectories = lib.mkDefault true;
        desktop = lib.mkDefault "${config.home.homeDirectory}/Desktop";
        documents = lib.mkDefault "${config.home.homeDirectory}/Documents";
        download = lib.mkDefault "${config.home.homeDirectory}/Downloads";
        music = lib.mkDefault "${config.home.homeDirectory}/Music";
        pictures = lib.mkDefault "${config.home.homeDirectory}/Pictures";
        videos = lib.mkDefault "${config.home.homeDirectory}/Videos";
        templates = lib.mkDefault "${config.home.homeDirectory}/Templates";
        publicShare = lib.mkDefault "${config.home.homeDirectory}/Public";
      };
    };
  };
  custom = import ./custom;
}

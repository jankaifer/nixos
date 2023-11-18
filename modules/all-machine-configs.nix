{
  # key is the hostname
  router = {
    static-ip = "192.168.88.1";
    username = "admin";
  };
  pearbox = {
    static-ip = "192.168.88.10";
    username = "pearman";
  };
  pearframe = {
    static-ip = "192.168.88.11";
    username = "pearman";
  };
  raspberry-1 = {
    static-ip = "192.168.88.30";
    username = "nixos";
  };
  raspeberry-minimal = {
    static-ip = null;
    username = "nixos";
  };
}

{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "htpc";
  networking.networkmanager.enable = true;
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  users.users.scott = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme"; # Set properly later
  };

  users.users.htpc = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    initialPassword = "changeme";
  };

  services.openssh.enable = true;

  services.xserver = {
    enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "htpc";
    displayManager.defaultSession = "none+openbox";
    windowManager.openbox.enable = true;
    videoDrivers = [ "modesetting" ];
  };

  environment.systemPackages = with pkgs; [
    brave
    thunar
    xorg.xset
    xbindkeys
    nfs-utils
    git
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];

  fileSystems."/mnt/media" = {
    device = "192.168.1.10:/Volume_1/media";
    fsType = "nfs";
    options = [ "defaults" "noatime" "nolock" "_netdev" "users" "soft" ];
  };

  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];

  system.stateVersion = "24.05";
}

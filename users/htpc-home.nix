{ config, pkgs, ... }:

{
  home.username = "htpc";
  home.homeDirectory = "/home/htpc";

  home.packages = [ pkgs.xbindkeys ];

  xsession.enable = true;

  home.file.".xinitrc".text = ''
    xset s off
    xset -dpms
    xset s noblank
    brave &
    exec openbox-session
  '';

  home.file.".xbindkeysrc".text = ''
    "thunar /mnt/media"
      Control+Alt+m
  '';

  home.file.".config/autostart/thunar.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Media Browser
    Exec=thunar /mnt/media
    Terminal=false
    X-GNOME-Autostart-enabled=true
  '';

  programs.home-manager.enable = true;
}

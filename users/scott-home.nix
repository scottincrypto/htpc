{ config, pkgs, ... }:

{
  home.username = "scott";
  home.homeDirectory = "/home/scott";
  programs.home-manager.enable = true;

  home.file.".ssh/authorized_keys".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFA0FHhKHY6qcAMwCx+gOhmLpC8kwq327pw5YJBk3qxF scott@goatherder.net
  '';
}

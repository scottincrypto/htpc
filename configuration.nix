{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Swap file configuration
  swapDevices = [{
    device = "/var/swap";
    size = 4096; # 4GB in MB
  }];

  # Networking
  networking.hostName = "htpc";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Australia/Sydney"; # Adjust to your timezone

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable X11 and display manager
  services.xserver = {
    enable = true;
    
    # Display manager with auto-login
    displayManager = {
      lightdm = {
        enable = true;
        greeter.enable = true;
      };
      autoLogin = {
        enable = true;
        user = "htpc";
      };
    };
    
    # Desktop environment (using XFCE for simplicity)
    desktopManager.xfce.enable = true;
  };

  # SSH server configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # NFS mount configuration
  fileSystems."/mnt/media" = {
    device = "192.168.1.10:/Volume_1/media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  # User accounts
  users.users.scott = {
    isNormalUser = true;
    description = "Scott";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      # Replace this with your actual SSH public key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFA0FHhKHY6qcAMwCx+gOhmLpC8kwq327pw5YJBk3qxF scott@goatherder.net"
    ];
  };

  users.users.htpc = {
    isNormalUser = true;
    description = "HTPC User";
    extraGroups = [ "audio" "video" "networkmanager" ];
  };

  # Enable sudo without password for wheel group (optional, remove if you want password prompts)
  security.sudo.wheelNeedsPassword = false;

  # System packages
  environment.systemPackages = with pkgs; [
    brave
    thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    vim
    wget
    git
    nfs-utils
    vlc
  ];

  # Brave auto-start configuration
  systemd.user.services.brave-autostart = {
    description = "Auto-start Brave browser";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.brave}/bin/brave --restore-last-session";
      Restart = "on-failure";
      RestartSec = 5;
    };
    environment = {
      DISPLAY = ":0";
    };
  };

  # Enable audio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable OpenGL for better video playback
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # Configure keyboard shortcuts for HTPC user
  system.activationScripts.htpcKeyboardShortcuts = ''
    mkdir -p /home/htpc/.config/xfce4/xfconf/xfce-perchannel-xml
    cat > /home/htpc/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml << 'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfce4-keyboard-shortcuts" version="1.0">
      <property name="commands" type="empty">
        <property name="custom" type="empty">
          <property name="&lt;Super&gt;e" type="string" value="thunar"/>
        </property>
      </property>
    </channel>
    EOF
    chown -R htpc:users /home/htpc/.config
  '';

  # System version
  system.stateVersion = "24.05"; # Adjust based on your NixOS version
}
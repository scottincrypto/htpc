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
  time.timeZone = "Australia/Sydney";

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
    };
    
    # Desktop environment (using XFCE for simplicity)
    desktopManager.xfce.enable = true;
  };

  # Auto-login configuration (moved out of xserver)
  services.displayManager.autoLogin = {
    enable = true;
    user = "htpc";
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

  # Enable audio using PipeWire (modern audio system)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable hardware acceleration for video playback
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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

  # Configure desktop shortcuts and user environment for HTPC user
  system.activationScripts.htpcDesktopSetup = ''
    # Create Desktop directory
    mkdir -p /home/htpc/Desktop
    
    # Create Thunar desktop shortcut
    cat > /home/htpc/Desktop/thunar.desktop << 'EOF'
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=File Manager
    Comment=Browse the file system
    Icon=system-file-manager
    Exec=thunar %F
    Categories=System;FileTools;FileManager;
    MimeType=inode/directory;
    EOF
    
    # Create VLC desktop shortcut
    cat > /home/htpc/Desktop/vlc.desktop << 'EOF'
    [Desktop Entry]
    Version=1.0
    Type=Application
    Name=VLC Media Player
    Comment=Play media files
    Icon=vlc
    Exec=vlc %U
    Categories=AudioVideo;Player;
    MimeType=video/;audio/;
    EOF
    
    # Create Media folder shortcut
    cat > /home/htpc/Desktop/media-folder.desktop << 'EOF'
    [Desktop Entry]
    Version=1.0
    Type=Link
    Name=Media Library
    Comment=Network media storage
    Icon=folder-remote
    URL=/mnt/media
    EOF
    
    # Make shortcuts executable and set ownership
    chmod +x /home/htpc/Desktop/*.desktop
    chown -R htpc:users /home/htpc/Desktop
    
    # Create user directories
    mkdir -p /home/htpc/{Documents,Downloads,Music,Pictures,Videos}
    chown -R htpc:users /home/htpc
  '';

  # Configure XFCE settings for better HTPC experience
  system.activationScripts.xfceSettings = ''
    mkdir -p /home/htpc/.config/xfce4/xfconf/xfce-perchannel-xml
    
    # Configure XFCE panel (minimal for HTPC use)
    cat > /home/htpc/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfce4-panel" version="1.0">
      <property name="configver" type="int" value="2"/>
      <property name="panels" type="array">
        <value type="int" value="1"/>
        <property name="panel-1" type="empty">
          <property name="position" type="string" value="p=8;x=683;y=754"/>
          <property name="size" type="uint" value="48"/>
          <property name="autohide-behavior" type="uint" value="1"/>
        </property>
      </property>
    </channel>
    EOF
    
    # Configure power management (prevent sleep during media playback)
    cat > /home/htpc/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml << 'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfce4-power-manager" version="1.0">
      <property name="xfce4-power-manager" type="empty">
        <property name="power-button-action" type="uint" value="4"/>
        <property name="show-tray-icon" type="bool" value="false"/>
        <property name="presentation-mode" type="bool" value="true"/>
        <property name="dpms-enabled" type="bool" value="false"/>
      </property>
    </channel>
    EOF
    
    chown -R htpc:users /home/htpc/.config
  '';

  # System version
  system.stateVersion = "24.05"; # Adjust based on your NixOS version
}
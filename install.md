# Install Process

## Identify your disk (usually /dev/sda or /dev/nvme0n1)
`lsblk`

## For UEFI systems (recommended):
```
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart ESP fat32 1MB 512MB
sudo parted /dev/sda -- set 1 esp on
sudo parted /dev/sda -- mkpart primary 512MB 100%
```

## Format partitions
```
sudo mkfs.fat -F 32 /dev/sda1
sudo fatlabel /dev/sda1 NIXBOOT
sudo mkfs.ext4 /dev/sda2 -L NIXROOT
```

## Mount root
`sudo mount /dev/disk/by-label/nixos /mnt`

## Create and mount boot
```
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot
```

## Generate hardware configuration
`sudo nixos-generate-config --root /mnt`
Update hardware-configuration to point to drive labels:
```
{ device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
};
{ device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
};
```

## Install git temporarily to clone your config if needed
`nix-shell -p git`

## Clone your configuration repository (replace with your actual repo URL)
`git clone https://github.com/yourusername/nixos-htpc-config.git /tmp/nixos-config`

## Copy your configuration.nix to the target system
`sudo cp /tmp/nixos-config/configuration.nix /mnt/etc/nixos/configuration.nix`

*Important: Keep the generated hardware-configuration.nix
(It contains your specific hardware settings)*

## Install the system
`sudo nixos-install -v`

### Troubleshooting 
If downloading from cache.nixos.org fails, hotspot phone and use wireless
```
sudo systemctl start wpa_supplicant
sudo wpa_cli
    add_network 0
    set_network 0 ssid "YourWifiSSID"
    set_network 0 psk "YourWifiPassword"
    enable_network 0
    save_config
    quit
```
Set root password when prompted

## Reboot
`sudo reboot`

## Bootloader
Check if bootloader is installed. If not:
```
nixos-enter
nixos-rebuild --install-bootloader boot
```

After reboot, login as root

## Set passwords for users
`passwd scott`
`passwd htpc`

## Switch to scott user
`su - scott`

## Add your SSH key to scott's authorized_keys if not done in config
```
mkdir -p ~/.ssh
echo "your-ssh-public-key" > ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## To rebuild/reinstall
nixos-rebuild switch
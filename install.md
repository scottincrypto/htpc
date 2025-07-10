# Identify your disk (usually /dev/sda or /dev/nvme0n1)
lsblk

# For UEFI systems (recommended):
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart ESP fat32 1MB 512MB
sudo parted /dev/sda -- set 1 esp on
sudo parted /dev/sda -- mkpart primary 512MB 100%

# Format partitions
sudo mkfs.fat -F32 -n BOOT /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2

# Mount root
sudo mount /dev/disk/by-label/nixos /mnt

# Create and mount boot
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot

# Generate hardware configuration
sudo nixos-generate-config --root /mnt

# Install git temporarily to clone your config
nix-shell -p git

# Clone your configuration repository (replace with your actual repo URL)
git clone https://github.com/yourusername/nixos-htpc-config.git /tmp/nixos-config

# Copy your configuration.nix to the target system
sudo cp /tmp/nixos-config/configuration.nix /mnt/etc/nixos/configuration.nix

# Important: Keep the generated hardware-configuration.nix
# (It contains your specific hardware settings)

# Install the system
sudo nixos-install

# Set root password when prompted

# Reboot
sudo reboot

# After reboot, login as root
# Set passwords for users
passwd scott
passwd htpc

# Switch to scott user
su - scott

# Add your SSH key to scott's authorized_keys if not done in config
mkdir -p ~/.ssh
echo "your-ssh-public-key" > ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

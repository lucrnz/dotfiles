{ config, pkgs, options, ... }:

{
  imports =
	[
	./hardware-configuration.nix
	];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.kernel.sysctl = {
  	"net.ipv6.conf.all.forwarding" = true;
	"net.ipv4.ip_forward" = true;
  };
  networking.hostName = "nix-peng";
  networking.networkmanager.enable = true;
  time.timeZone = "Etc/UTC";
  i18n.defaultLocale = "en_US.UTF-8";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  virtualisation.docker.enable = true;

  users.users.luc = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "docker" ];
     packages = with pkgs; [
     	nodejs
	neovim
     ];
   };

  environment.systemPackages = with pkgs; [
	curl
	git
	wget
	p7zip
	htop
	tmux
	neofetch
	docker-compose
  ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;
  services.openssh.ports = [ 4545 ];
  services.openssh.passwordAuthentication = false;
  services.tailscale.enable = true;

  networking.nameservers = [
  	"100.100.100.100"
	"1.1.1.1"
	"8.8.8.8"
  ];

  environment.enableAllTerminfo = true;

  services.resolved.fallbackDns = config.networking.nameservers;

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;
  networking.timeServers = options.networking.timeServers.default;

  security.sudo.wheelNeedsPassword = false;

  system.copySystemConfiguration = true;
  system.stateVersion = "22.05";
}

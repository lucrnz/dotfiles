{ config, pkgs, ... }:

{
  nix.package = pkgs.nix;
  home.username = "lucdev";
  home.homeDirectory = "/home/lucdev";
  home.stateVersion = "23.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  programs.neovim.enable = true;
  programs.htop.enable = true;
  programs.tmux.enable = true;
  home.packages = with pkgs; [
    devbox
    git
    nixpkgs-fmt
    asciinema
    jq
    jwt-cli
    bat
    neofetch
  ];
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "curses";
  };
}

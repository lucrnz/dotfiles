{ config, pkgs, ... }:

{
  nix.package = pkgs.nix;
  home.username = "luc";
  home.homeDirectory = "/home/luc";
  home.stateVersion = "23.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  programs.neovim.enable = true;
  programs.htop.enable = true;
  programs.tmux.enable = true;
  home.packages = [ pkgs.nixpkgs-fmt pkgs.asciinema pkgs.yt-dlp ];
}

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, fetchFromGithub, self, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${self}/machines/common.nix"
      inputs.sops-nix.nixosModules.sops
    ];
  
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.windowManager.dwm = {
    enable = true;
    package = pkgs.dwm.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "ssitra";
        repo = "dwm";
        rev = "c47f6c321505c686e3b112d2d9923cc73739ae10";
        sha256 = "sha256-285Hab5g3eynTLAfvtRFXbFhwjKyfGEiv2o26UbWlag=";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    dmenu
    stow
    zoxide
    zathura
    alacritty
    audacity
    evince
    feh
    fzf
    gimp
    gnumeric
    gnuplot
    graphviz
    hunspell
    imagemagick
    inkscape
    keychain
    mpv
    mullvad-vpn
    nautilus
    networkmanagerapplet
    networkmanager-l2tp
    nsxiv
    paperkey
    pdf2svg
    playerctl
    qrencode
    s-tui
    scrot
    sct
    smartmontools
    sqlitebrowser
    sxhkd
    texinfo
    typst
    tinymist
    tor-browser
    inetutils
    usbutils
    yt-dlp
    dmenu
  ];

  fonts.packages = with pkgs; [
    source-code-pro
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];


  # VM Stuff
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  services.fwupd.enable = true;
  
  
  
  networking.hostName = "topper";

  programs.chromium.enable = true;
  
  # networking.firewall = {
  #   # interfaces.tailscale0.allowedTCPPorts = [ 80 443 ];
  #   # allowedTCPPorts  = [ 80 443 ];
  # };

  # services.tailscale = {
  #   enable = true;
  # };

  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PermitRootLogin = "prohibit-password";
  #     PasswordAuthentication = false;
  #     ChallengeResponseAuthentication = false;
  #     KbdInteractiveAuthentication = false;
  #   };
  # };




  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}

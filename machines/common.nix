{ config, lib, pkgs, inputs, ... }:

{
  options = {
    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = "armu.me";
      description = "The base domain used for Caddy reverse proxies.";
    };
  };
  
  config = {
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    networking.useDHCP = true;

    time.timeZone = "Europe/Stockholm";

    services.xserver.xkb = {
      layout = "us,se,us";   # Corresponds to -layout "us,se,us"
      variant = ",,rus";     # Corresponds to -variant ",,rus"
      # Note: Empty strings for the first two layouts (us, se)
      # 'rus' variant applied to the third layout (us)
      options = "grp:rctrl_rshift_toggle,caps:ctrl_modifier";
      # Corresponds to -option, combining both desired options
      # separated by a comma.
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
      
      # Choose one of these update methods:
      # 1. For stable channel:
      # flake = null;
      # channel = "https://nixos.org/channels/nixos-25.05";
      
      # 2. For flakes (since you're using flakes):
      flake = "github:nixos/nixpkgs/nixos-unstable";
      flags = [];
      
      # Optional: Set a specific time for updates
      dates = "04:00";
      randomizedDelaySec = "45min";
    };

    
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    
    # Also recommended: Optimize Nix store
    nix.settings.auto-optimise-store = true;
    
    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
      emacs
      vim
      iperf3
      rsync
      iotop
      nmap
      ripgrep
      sqlite
      lm_sensors
      moreutils
      borgmatic
      wget
      git
      zsh
      ntfs3g
      exfatprogs
      openssl
      nss
      pass
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ ];     
    };

    
    security.sudo = {
      enable = true; # Ensure sudo itself is enabled (usually is by default)
      # This is the key option:
      wheelNeedsPassword = false; # Set this to false
    };





    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;


    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = lib.mkForce "us";
      useXkbConfig = true; # use xkb.options in tty.
    };


    users.users.ratso = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
      ];
      initialHashedPassword = "$6$sVQqjv.8KtTt2bsK$YNoRGOufpXndqyN4hmKytB4d17dIABLL56Xf82tM8FMG7CyjYHdEfS4frfWRpUNioGUcbL31bNFmmgs/vD/al/";
      openssh.authorizedKeys = {
        keyFiles = [ "${self}/id_ed25519.pub" ];
      };
    };

    environment.variables = {
      EDITOR = "emacs";
      VISUAL = "emacs";
    };
  };
}

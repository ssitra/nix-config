# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, self, ... }:
let
  tsIp = "100.122.33.91";
  domain = "armu.me";
  # landingPageContent = builtins.readFile ./landing-page.html;
  landingPageFile = ./landing_page.html;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-config-homelab.nix
      (self + "/machines/common.nix")
      (self + "/modules/jellyfin/default.nix")
      (self + "/modules/transmission/default.nix")
      (self + "/modules/sabnzbd/default.nix")
      (self + "/modules/arrs/prowlarr/default.nix")
      (self + "/modules/arrs/sonarr/default.nix")
      (self + "/modules/arrs/radarr/default.nix")
      inputs.sops-nix.nixosModules.sops
    ];

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/ratso/.config/sops/age/keys.txt";



  users.users.media = {
    isNormalUser = false; # Or true if you want it to be a login user
    isSystemUser = true;
    group = "media";
    # home = "/var/lib/homelab"; # Optional home directory
  };
  users.groups.media = {};

  environment.etc."caddy/static/index.html" = {
    source = landingPageFile;
    user = config.services.caddy.user;
    group = config.services.caddy.group;
    mode = "0444"; # Read-only is sufficient
  };


  
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };
  boot.kernelParams = [ "radeon.cik_support=0" "amdgpu.cik_support=1" ];


  
  fileSystems."/mnt/media" = 
    { device = "/dev/disk/by-uuid/aea6ebd3-3736-4496-9900-cf2bb81e4b29";
      fsType = "ext4";
      options = [
        "defaults" 
        "nofail"   
        "acl"
      ];
    };

  networking.hostName = "nixos";

  services.jellyfin.enable = true;
  services.transmission.enable = true;
  services.sonarr.enable = true;
  services.radarr.enable = true;
  services.prowlarr.enable = true;
  services.sabnzbd.enable = true;


  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };



  networking.firewall = {
    interfaces.tailscale0.allowedTCPPorts = [ 80 443 ];
  };



  services.immich = {
    enable = true;
    port = 2283;
    accelerationDevices = null;
    openFirewall = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/media/Photos";
    database = {
      enable = true; # Make sure this is true
      # ... other database options
    };
  };

  users.users.immich.extraGroups = [ "video" "render" ];


  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      # List the plugins you need here
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.1.0"
      ];
      hash = "sha256-1tpxaW6wueh4hVmTypLHSgXX/5t3Bf5TGOkbeI2H6nE=";
    };

    logFormat = "level INFO";

    virtualHosts = {
      "${domain}" = {
        extraConfig = ''
           tls {
             dns cloudflare {
             api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                       }
             }

           root * /etc/caddy/static


           file_server
         '';
      };
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unrar"
  ];

  
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];

  sops.secrets.CLOUDFLARE_API_TOKEN = {
    mode = "0440";
    # owner = config.services.caddy.user;
    # group = config.services.caddy.group;
    owner = "caddy";
    group = "caddy";
    # neededForUsers = true;
  };

  



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

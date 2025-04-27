# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
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
      inputs.sops-nix.nixosModules.sops
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/etc/sops/keys/keys.txt";

  sops.secrets = {
    CLOUDFLARE_API_TOKEN = {
      # Ensure Caddy user/group can read this file
      mode = "0440";
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
    };
    # Remove the 'caddy_cloudflare_env' definition if present
  };

  environment.etc."caddy/static/index.html" = {
    # Nix will copy landingPageFile to the Nix store and create a symlink
    # at /etc/caddy/static/index.html pointing to it.
    source = landingPageFile;
    # Ensure the Caddy user can read the symlink and the target file (target is world-readable in /nix/store)
    user = config.services.caddy.user;
    group = config.services.caddy.group;
    mode = "0444"; # Read-only is sufficient
  };


  sops.secrets.CLOUDFLARE_API_TOKEN.neededForUsers = true;
  
  environment.variables = {
    EDITOR = "emacs";
    VISUAL = "emacs";
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs.pkgsi686Linux; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  boot.kernelParams = [ "radeon.cik_support=0" "amdgpu.cik_support=1" ];


  
  fileSystems."/mnt/media" = # The mount point you chose (must start with /)
    { device = "/dev/disk/by-uuid/aea6ebd3-3736-4496-9900-cf2bb81e4b29"; # Use the UUID you found
      fsType = "ext4";                # Use the FSTYPE you found (e.g., "ext4", "ntfs", "exfat")

      # Common options (adjust as needed):
      options = [
        "defaults"  # Standard options (rw, suid, dev, exec, auto, nouser, async)
        "nofail"    # IMPORTANT for external/non-essential drives: Prevents boot failure if drive isn't connected.
        "acl"
      ];
    };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.useDHCP = true;

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
    # Add this line to allow Caddy to manage certs via Tailscale:
    # permitCertUid = config.users.users.caddy.name; # Or simply "caddy" if using default user name
    # Set useRoutingFeatures if needed for other reasons (subnet routes, exit nodes)
    # useRoutingFeatures = "client"; # Or "server" or "both"
  };

  
  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  services.xserver.xkb = {
    layout = "us,se,us";   # Corresponds to -layout "us,se,us"
    variant = ",,rus";     # Corresponds to -variant ",,rus"
    # Note: Empty strings for the first two layouts (us, se)
    # 'rus' variant applied to the third layout (us)
    options = "grp:rctrl_rshift_toggle,caps:ctrl_modifier";
    # Corresponds to -option, combining both desired options
    # separated by a comma.
  };

  # enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ratso = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    initialHashedPassword = "$6$sVQqjv.8KtTt2bsK$YNoRGOufpXndqyN4hmKytB4d17dIABLL56Xf82tM8FMG7CyjYHdEfS4frfWRpUNioGUcbL31bNFmmgs/vD/al/";
    openssh.authorizedKeys = {
      keyFiles = [ ./id_ed25519.pub ];
    };
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    emacs
    zsh
    ntfs3g
    exfatprogs
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    openssl
    nss
    pass
  ];

  security.sudo = {
    enable = true; # Ensure sudo itself is enabled (usually is by default)
    # This is the key option:
    wheelNeedsPassword = false; # Set this to false
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.jellyfin = {
    enable = true;
    # extraOptions = [
    #   "--cert=/home/ratso/nixos.tail143db8.ts.net.crt"
    #   "--cert-key=/home/ratso/nixos.tail143db8.ts.net.key" 
    # ];

  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];            # none globally
    interfaces.tailscale0.allowedTCPPorts = [ 80 443 ];
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  
  # services.certbot = {
  #   enable = true;
  #   agreeTerms = true;
  # };
  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-6.0.428"
    "aspnetcore-runtime-6.0.36"
  ];

  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    openRPCPort = true;
    settings = {
      rpc-bind-address = "0.0.0.0"; #Bind to own IP
      rpc-whitelist = "127.0.0.1,10.0.0.1,192.168.*.*,100.*.*.*"; #Whitelist
      
    };
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


  # services.syncthing = {
  #   enable = true;
  #   openDefaultPorts = true;
  #   # Optional: GUI credentials (can be set in the browser instead if you don't want plaintext credentials in your configuration.nix file)
  #   # or the password hash can be generated with "syncthing generate --config <path> --gui-password=<password>"
  #   settings = {
  #     gui = {
  #       user = "Artis";
  #       password = "$2a$10$aDXQgOJ0M6l6WUnnM6wjyODN31RRBoF7SLDTB.ZYiaIedmiJaNiLe";
  #       # Change this from the default to listen on all interfaces
  #       # address = "0.0.0.0:8384";
  #     };
  #     # Optional but recommended for security: restrict to local networks and Tailscale
  #     allowedNetworks = ["192.168.0.0/16" "100.64.0.0/10"];
  #   };
  # };

  services.caddy = {
    enable = true;

    package = pkgs.caddy.withPlugins {
      # List the plugins you need here
      plugins = [
        "github.com/caddy-dns/cloudflare@v0.1.0"
      ];
      hash = "sha256-1tpxaW6wueh4hVmTypLHSgXX/5t3Bf5TGOkbeI2H6nE=";
      # The version is usually automatically determined based on pkgs.caddy
      # A specific hash might be needed if auto-detection fails or for pinning,
      # but try without it first. The build will fail with a hash mismatch
      # message if one is needed, and it will tell you the expected hash.
    };

    logFormat = "level INFO";


    virtualHosts = {
      # --- Media Server ---
      "media.${domain}" = {
        extraConfig = ''
          tls {
            # Use Cloudflare DNS challenge, read token from environment
            dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
          }
          # No path stripping needed, subdomain handles routing
          reverse_proxy localhost:8096
        '';
      };

      # --- Downloads Management ---
      "downloads.${domain}" = {
        extraConfig = ''
          tls {
            dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
          }
          reverse_proxy localhost:9091 {
                        header_up Host {upstream_hostport}
                        header_up X-Real-IP {remote_ip}
                        header_up X-Forwarded-For {remote_ip}
                        header_up X-Forwarded-Proto {scheme}
          }
        '';
      };

      "radarr.${domain}" = {
        extraConfig = ''
          tls {
            # Use Cloudflare DNS challenge, read token from environment
            dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
          }
          # No path stripping needed, subdomain handles routing
          reverse_proxy localhost:7878
        '';
      };

      "sonarr.${domain}" = {
        extraConfig = ''
          tls {
            # Use Cloudflare DNS challenge, read token from environment
            dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
            }
          # No path stripping needed, subdomain handles routing
          #          reverse_proxy localhost:8989
          respond "TLS test successful"

        '';
      };
      

      # --- Optional: Root domain redirect or landing page ---
      "${domain}" = {
        extraConfig = ''
           tls {
             dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
           }
           # Example: Respond with a simple text page
           root * /etc/caddy/static
           # Or redirect to one of the services:
           # redir https://media.${domain}{uri} permanent
           file_server
         '';
      };
    };
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unrar"
  ];

  
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.sabnzbd = {
    enable = true;
    openFirewall = true;
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

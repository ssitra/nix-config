# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, self, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-config.nix
      (self + "/machines/common.nix")
      inputs.sops-nix.nixosModules.sops
    ];

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.defaultSopsFormat = "yaml";

  sops.age.keyFile = "/home/ratso/.config/sops/age/keys.txt";

  networking.hostName = "topper";

  networking.firewall = {
    # interfaces.tailscale0.allowedTCPPorts = [ 80 443 ];
    # allowedTCPPorts  = [ 80 443 ];
  };

  services.tailscale = {
    enable = true;
    permitCertUid = "caddy";
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
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

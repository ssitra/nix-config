{ config, lib, pkgs, ... }:
let
  domain = (config.baseDomain or "armu.me");
  vhost  = "photos.${domain}";
  port   = 2283;
in
{
  config = lib.mkIf config.services.immich.enable {
    # Immich service
    services.immich = {
      host = "127.0.0.1";
      port = port;
      mediaLocation = "/mnt/media/Photos";
      openFirewall = false;
      accelerationDevices = null;
      database.enable = true;
    };

    # Make sure the immich user can access everything needed
    users.users.immich.extraGroups = [ "media" "video" "render" ];

    # Create all needed directories with proper permissions
    systemd.tmpfiles.rules = [
      "d /mnt/media/Photos                    2775 root media - -"
      "d /mnt/media/Photos/encoded-video      2775 root media - -" 
      "d /mnt/media/Photos/library            2775 root media - -"
      "d /mnt/media/Photos/thumbs             2775 root media - -"
      "d /mnt/media/Photos/profile            2775 root media - -"
      # Create the .immich-keep file that it's looking for
      "f /mnt/media/Photos/encoded-video/.immich-keep 0664 root media - -"
    ];

    # Service dependencies
    systemd.services.immich-server.after = [ "mnt-media.mount" "postgresql.service" ];
    systemd.services.immich-server.requires = [ "mnt-media.mount" ];

    # Caddy vhost
    services.caddy.virtualHosts."${vhost}".extraConfig = ''
      tls {
        dns cloudflare {
          api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
        }
      }
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };
}

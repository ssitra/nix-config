{ config, lib, pkgs, ...}:
{
  

  config = lib.mkIf config.services.sonarr.enable {

    services.sonarr = {
      openFirewall = true;
      user = "media";
      group = "media";
    };

    services.caddy.virtualHosts."sonarr.${config.baseDomain}" = {
        extraConfig = ''
          tls {
          dns cloudflare {
          api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                    }
          }
           reverse_proxy localhost:8989
        '';
      };
    };
}

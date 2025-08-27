{ config, lib, pkgs, ...}:
{
  

  config = lib.mkIf config.services.lidarr.enable {

    services.lidarr = {
      openFirewall = true;
      user = "media";
      group = "media";
    };

    services.caddy.virtualHosts."lidarr.${config.baseDomain}" = {
        extraConfig = ''
          tls {
              dns cloudflare {
                  api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                    }
              }
           reverse_proxy localhost:8686
        '';

      };
    };
}

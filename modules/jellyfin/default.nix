{ config, lib, pkgs, ...}:

{

  config = lib.mkIf config.services.jellyfin.enable {
    services.jellyfin = {
      user = "media";    
      group = "media";
    };

    services.caddy.virtualHosts = {
      "media.${config.baseDomain}" = {
        extraConfig = ''
          tls {
            dns cloudflare {
            api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                      }
            }
          reverse_proxy localhost:8096
        '';
      };
    };
  };
}

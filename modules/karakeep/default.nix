{ config, lib, pkgs, ...}:

{

  config = lib.mkIf config.services.karakeep.enable {

    # services.karakeep = {
    #   enable = true;
    # };

    services.caddy.virtualHosts = {
      "karakeep.${config.baseDomain}" = {
        extraConfig = ''
          tls {
            dns cloudflare {
            api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                      }
            }
          reverse_proxy localhost:3000
        '';
      };
    };
  };
}

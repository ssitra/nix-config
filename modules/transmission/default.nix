{ config, lib, pkgs, ...}:
{
  config = lib.mkIf config.services.transmission.enable {

    services.transmission = {
      user = "media";
      group = "media";

      
      package = pkgs.transmission_4;
      openRPCPort = true;
      settings = {
        umask = 2;
        rpc-bind-address = "0.0.0.0"; #Bind to own IP
        rpc-whitelist = "127.0.0.1,10.0.0.1,192.168.*.*,100.*.*.*"; #Whitelist
      };
    };

    services.caddy.virtualHosts."downloads.${config.baseDomain}" = {
      extraConfig = ''
          tls {
            dns cloudflare {
            api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                      }
            }
          reverse_proxy localhost:9091 {
                        header_up Host {upstream_hostport}
                        header_up X-Real-IP {remote_ip}
                        header_up X-Forwarded-For {remote_ip}
                        header_up X-Forwarded-Proto {scheme}
          }
        '';
    };
  };
}

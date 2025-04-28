{ config, lib, pkgs, ...}:
{
  

  config = lib.mkIf config.services.jellyfin.enable {

    nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "aspnetcore-runtime-6.0.36"
    ];
    
    services.sonarr = {
      openFirewall = true;
      user = "media";
      group = "media";
    };

    services.radarr = {
      openFirewall = true;
      user = "media";
      group = "media";
    };

    services.prowlarr = {
      openFirewall = true;
    };


    services.caddy.virtualHosts = {
      "radarr.${config.baseDomain}" = {
        extraConfig = ''
          tls {
            dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
           }
           reverse_proxy localhost:7878
        '';
      };

      "sonarr.${config.baseDomain}" = {
        extraConfig = ''
          tls {
            dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
              }
          reverse_proxy localhost:8989
        '';
      };

      "prowlarr.${config.baseDomain}" = {
        extraConfig = ''
          tls {
            dns cloudflare {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                           }
          reverse_proxy localhost:9696
        '';
      };
    };
  };
}

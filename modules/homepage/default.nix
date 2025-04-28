{ config, lib, pkgs, ...}:
{
  

  config = lib.mkIf config.services.homepage-dashboard.enable {

    services.homepage-dashboard = {
      allowedHosts = "*";
      openFirewall = true;
      services = [
        {
          "Media Management" = [
            {
              "Radarr" = {
                icon = "radarr.png"; # Or use mdi-/si- icons
                href = "armu.me:7878"; # <-- ADJUST URL
                description = "Movie Management";
                # Optional: Monitor service availability via HTTP HEAD/GET
                # siteMonitor = "http://YOUR_RADARR_IP_OR_HOSTNAME:7878";
              };
            }
            {
              "Sonarr" = {
                icon = "sonarr.png";
                href = "armu.me:8989"; # <-- ADJUST URL
                description = "Series Management";

                # siteMonitor = "http://YOUR_SONARR_IP_OR_HOSTNAME:8989";
              };
            }
            {
              "Prowlarr" = {
                icon = "prowlarr.png";
                href = "armu.me:9696"; # <-- ADJUST URL
                description = "Indexer Management";
              };
            }
          ];
        }
        {
          "Media Server" = [
            {
              # Assuming Jellyfish meant Jellyfin
              "Jellyfin" = {
                icon = "jellyfin.png";
                href = "armu.me:8096"; # <-- ADJUST URL
                description = "Media Streaming";
                # siteMonitor = "http://YOUR_JELLYFIN_IP_OR_HOSTNAME:8096";
              };
            }
          ];
        }
        {
          "Download Clients" = [
            {
              "Transmission" = {
                icon = "transmission.png";
                href = "armu.me:9091"; # <-- ADJUST URL
                description = "Torrent Client";
                # siteMonitor = "http://YOUR_TRANSMISSION_IP_OR_HOSTNAME:9091";
              };
            }
            {
              "SABnzbd" = {
                icon = "sabnzbd.png";
                href = "armu.me:8080"; # <-- ADJUST URL
                description = "Usenet Client";
                # siteMonitor = "http://YOUR_SABNZBD_IP_OR_HOSTNAME:8080";
              };
            }
          ];
        }
      ];

      
      customCSS = ''
        body, html {
          font-family: SF Pro Display, Helvetica, Arial, sans-serif !important;
        }
        .font-medium {
          font-weight: 700 !important;
        }
        .font-light {
          font-weight: 500 !important;
        }
        .font-thin {
          font-weight: 400 !important;
        }
        #information-widgets {
          padding-left: 1.5rem;
          padding-right: 1.5rem;
        }
        div#footer {
          display: none;
        }
        .services-group.basis-full.flex-1.px-1.-my-1 {
          padding-bottom: 3rem;
        };
      '';
    };

    services.caddy.virtualHosts."${config.baseDomain}" = {
        extraConfig = ''
          tls {
              dns cloudflare {
                  api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
                    }
              }
           reverse_proxy localhost:8082
        '';

      };
    };
}

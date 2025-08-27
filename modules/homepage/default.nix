{ config, lib, pkgs, ... }:
let
  domain = "armu.me";
in {
  config = lib.mkIf config.services.homepage-dashboard.enable {
    services.homepage-dashboard = {
      allowedHosts = "*";
      openFirewall = true;

      settings = {
        favicon = "https://fav.farm/😘";
      };

      services = [
        {
          "Media Management" = [
            {
              "Radarr" = {
                icon = "radarr.png";
                href = "https://radarr.${domain}";
                description = "Movie Management";
                siteMonitor = "https://radarr.${domain}";
              };
            }
            {
              "Sonarr" = {
                icon = "sonarr.png";
                href = "https://sonarr.${domain}";
                description = "Series Management";
                siteMonitor = "https://sonarr.${domain}";
              };
            }
            {
              "Lidarr" = {
                icon = "lidarr.png";
                href = "https://lidarr.${domain}";
                description = "Music Management";
                siteMonitor = "https://lidarr.${domain}";
              };
            }
            {
              "Prowlarr" = {
                icon = "prowlarr.png";
                href = "https://prowlarr.${domain}";
                description = "Indexer Management";
                siteMonitor = "https://prowlarr.${domain}";
              };
            }
          ];
        }
        {
          "Media Server" = [
            {
              "Jellyfin" = {
                icon = "jellyfin.png";
                href = "https://media.${domain}";
                description = "Media Streaming";
                siteMonitor = "https://media.${domain}";
              };
            }
            {
              "Immich" = {
                icon = "immich.png";
                href = "https://photos.${domain}";
                description = "Photos & Videos";
                siteMonitor = "https://photos.${domain}";
              };
            }
          ];
        }
        {
          "Download Clients" = [
            {
              "Transmission" = {
                icon = "transmission.png";
                href = "https://downloads.${domain}";
                description = "Torrent Client";
                siteMonitor = "https://downloads.${domain}";
              };
            }
            {
              "SABnzbd" = {
                icon = "sabnzbd.png";
                href = "https://usenet.${domain}";
                description = "Usenet Client";
                siteMonitor = "https://usenet.${domain}";
              };
            }
          ];
        }
        {
          "Productivity" = [
            {
              "Paperless" = {
                icon = "paperless-ngx.png";
                href = "https://paperless.${domain}";
                description = "Document Management";
                siteMonitor = "https://paperless.${domain}";
              };
            }
          ];
        }
        {
          "Other" = [
            {
              "Gitea" = {
                icon = "gitea.png";
                href = "https://git.${domain}";
                description = "Git Hosting";
                siteMonitor = "https://git.${domain}";
              };
            }
            {
              "Karakeep" = {
                icon = "https://karakeep.app/favicon.ico"; # or a custom karakeep.png if you have one
                href = "https://karakeep.${domain}";
                description = "Bookmarks";
                siteMonitor = "https://karakeep.${domain}";
              };
            }
          ];
        }
      ];

      customCSS = ''
        body, html { font-family: SF Pro Display, Helvetica, Arial, sans-serif !important; }
        .font-medium { font-weight: 700 !important; }
        .font-light { font-weight: 500 !important; }
        .font-thin { font-weight: 400 !important; }
        #information-widgets { padding-left: 1.5rem; padding-right: 1.5rem; }
        div#footer { display: none; }
        .services-group.basis-full.flex-1.px-1.-my-1 { padding-bottom: 3rem; }
      '';
    };

    # Serve Homepage at https://armu.me
    services.caddy.virtualHosts."${domain}" = {
      extraConfig = ''
        tls {
          dns cloudflare {
            api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
          }
        }
        reverse_proxy 127.0.0.1:8082
      '';
    };
  };
}

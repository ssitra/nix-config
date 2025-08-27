{ config, lib, pkgs, ... }:

let
  domain        = (config.baseDomain or "armu.me");
  vhost         = "paperless.${domain}";
  paperlessPort = 28981;
  gotenbergPort = 3500; # avoid clashes with Gitea's 3000
in
{
  config = lib.mkIf config.services.paperless.enable {

    # Gotenberg (PDF conversions)
    services.gotenberg = {
      enable = true;
      bindIP = "127.0.0.1";
      port   = gotenbergPort;
      chromium.disableJavascript = true;
    };

    # Paperless-NGX
    services.paperless = {
      address = "0.0.0.0";
      port    = paperlessPort;

      # storage
      dataDir  = "/var/lib/paperless";
      mediaDir = "/mnt/media/Paperless/media";

      # inbox
      consumptionDir = "/mnt/media/Paperless/consume";
      consumptionDirIsPublic = true;

      # local Postgres
      database.createLocally = true;

      # Start Tika; let the module set PAPERLESS_TIKA_ENABLED/ENDPOINT
      # configureTika = true;

      # App-level settings (no duplicate TIKA_* here)
      settings = {
        PAPERLESS_URL             = "https://${vhost}";
        PAPERLESS_TIME_ZONE       = "Europe/Stockholm";
        PAPERLESS_OCR_LANGUAGE    = "eng";
        PAPERLESS_FILENAME_FORMAT = "{created}-{title}";

        PAPERLESS_TIKA_ENABLED = false;

        # Tell Paperless where Gotenberg is (base URL, no /forms/... path)
        PAPERLESS_TIKA_GOTENBERG_ENDPOINT =
          "http://127.0.0.1:${toString gotenbergPort}";
      };
    };

    # Dirs & perms
    systemd.tmpfiles.rules = [
      "d /var/lib/paperless                 0750 paperless paperless - -"
      "d /mnt/media/Paperless               0775 paperless media     - -"
      "d /mnt/media/Paperless/media         0775 paperless media     - -"
      "d /mnt/media/Paperless/consume       2775 paperless media     - -"
    ];

    # Caddy vhost
    services.caddy.virtualHosts."${vhost}".extraConfig = ''
      tls {
        dns cloudflare {
          api_token {file.${config.sops.secrets.CLOUDFLARE_API_TOKEN.path}}
        }
      }
      reverse_proxy 127.0.0.1:${toString paperlessPort}
    '';
  };
}

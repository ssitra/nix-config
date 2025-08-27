{ config, lib, pkgs, ...}:

{

  config = lib.mkIf config.services.calibre.enable {

    # services.calibre-web= {
    #   enable = true;
    #   user = "media";
    #   group = "media";
    #   listen = {
    #     ip = "0.0.0.0";
    #     port = 8083;
    #   };
    #   options = {
    #     calibreLibrary = "/mnt/media/books";
    #     enableBookUploading = true;
    #     enableBookConversion = true;
    #   };
    # };

    # services.calibre-server= {
    #   enable = true;
    #   user = "media";
    #   group = "media";
    #   listen = {
    #     ip = "0.0.0.0";
    #     port = 8083;
    #   };
    #   options = {
    #     calibreLibrary = "/mnt/media/books";
    #     enableBookUploading = true;
    #     enableBookConversion = true;
    #   };
    # };

    services.caddy.virtualHosts = {
      "books.${config.baseDomain}" = {
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

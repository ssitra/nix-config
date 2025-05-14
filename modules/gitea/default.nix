{ config, lib, pkgs, ...}:

{

  config = lib.mkIf config.services.gitea.enable {
    services.gitea = {
      settings = {

        # 1.  Let anyone who reaches the URL browse, clone & pull
        service = {
          REQUIRE_SIGNIN_VIEW   = false;  # show Explore pages without login
          DISABLE_REGISTRATION  = false;   # nobody can create new accounts
          REGISTER_EMAIL_CONFIRM = false; # no e‑mail round‑trips
          ENABLE_CAPTCHA        = false;  # no captcha on the (disabled) sign‑up
          ENABLE_PUSH_CREATE_USER = true;
          ENABLE_PUSH_CREATE_ORG = true;
        };

        # 2.  Make new repositories public by default
        repository.DEFAULT_PRIVATE = "public";

        # 3.  Quality‑of‑life: land directly on the repo list
        ui.LANDING_PAGE = "explore";

        # 4.  (Optional) make the clone URLs pretty if you use SSH
        server = {
          DOMAIN    = "${config.baseDomain}";  # what shows up in clone/push URLs
          SSH_PORT  = 22;               # displayed, not listened‑on
        };
      };

    };

    services.caddy.virtualHosts = {
      "git.${config.baseDomain}" = {
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

self: super:

{
  # replace the official dwm with your own fork
  dwm = super.dwm.overrideAttrs (old: rec {
    # Optional: give it a custom name / version string
    pname   = "dwm-artis";
    version = "6.4-20250514";

    # Any fetcher is fine – pick one that fits your repo
    src = super.fetchFromGitea {
      domain = "armu.me";
      owner = "artis";
      repo = "dwm";
      rev = "master";
      sha256 = "sha256-285Hab5g3eynTLAfvtRFXbFhwjKyfGEiv2o26UbWlag=";
    };
  };

    # You can change anything else here (patches, buildInputs, …)
    # patches = [ ./my-tilegap.patch ];
  });
}

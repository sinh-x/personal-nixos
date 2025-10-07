{
  lib,
  config,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.apps.web.zen-browser;
in
{
  options.${namespace}.apps.web.zen-browser.enable = lib.mkEnableOption "zen-browser";

  config = lib.mkIf cfg.enable {
    # 2. CONFIGURE THE PROGRAM
    programs.zen-browser = {
      # This enables the configuration and usually installs the package
      enable = true;

      # 3. ADD YOUR CONFIGURATION OPTIONS
      policies = {
        # Note: These options match Firefox's policies
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };

      # Example of other options (like configuring spaces)
      # spaces = {
      #   work = {
      #     name = "Work Space";
      #     # IMPORTANT: You must generate and use a stable UUID for the ID
      #     id = "a0b1c2d3-e4f5-6789-0123-456789abcdef";
      #     position = 1;
      #   };
      # };
    };

    # The original package install line is now redundant and can be removed
    # home.packages = [
    #   inputs.zen-browser.packages."${system}".default
    # ];
  };
}

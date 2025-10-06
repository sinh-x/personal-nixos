{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.zen-browser;
in
{
  options = {
    modules.zen-browser.enable = lib.mkEnableOption "zen-browser";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Only 'x86_64-linux' and 'aarch64-linux' are supported
      inputs.zen-browser.packages."${system}".default
    ];

    programs.zen-browser.policies = {
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
  };
}

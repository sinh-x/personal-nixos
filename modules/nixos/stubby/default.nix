{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.modules.stubby;
in
{
  options = {
    modules.stubby.enable = lib.mkEnableOption "Stubby services";
  };
  config = lib.mkIf cfg.enable {
    services.stubby = {
      enable = true;
      settings = pkgs.stubby.passthru.settingsExample // {
        upstream_recursive_servers = [
          {
            address_data = "1.1.1.1";
            tls_auth_name = "cloudflare-dns.com";
            tls_pubkey_pinset = [
              {
                digest = "sha256";
                value = "4pqQ+yl3lAtRvKdoCCUR8iDmA53I+cJ7orgBLiF08kQ=";
              }
            ];
          }
          {
            address_data = "1.0.0.1";
            tls_auth_name = "cloudflare-dns.com";
            tls_pubkey_pinset = [
              {
                digest = "sha256";
                value = "4pqQ+yl3lAtRvKdoCCUR8iDmA53I+cJ7orgBLiF08kQ=";
              }
            ];
          }
        ];
      };
    };
  };
}

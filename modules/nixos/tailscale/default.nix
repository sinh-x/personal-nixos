{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.tailscale;
in
{
  options.modules.tailscale = {
    enable = mkEnableOption "Tailscale VPN with firewall and optional suspend/resume fix";

    authKeySecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SOPS secret path for the Tailscale auth key (e.g. \"tailscale/Drgnfly\")";
    };

    operator = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "User allowed to operate tailscale without sudo";
    };

    ssh = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Tailscale SSH";
    };

    resumeFix = mkOption {
      type = types.bool;
      default = false;
      description = "Restart tailscaled after suspend/resume to avoid 'node not found' loop";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };

    sops.secrets.${cfg.authKeySecret} = mkIf (cfg.authKeySecret != null) { };

    services.tailscale = {
      enable = true;
      authKeyFile = mkIf (cfg.authKeySecret != null) config.sops.secrets.${cfg.authKeySecret}.path;
      extraUpFlags = mkIf cfg.ssh [
        "--ssh"
        "--reset"
      ];
      extraSetFlags = mkIf (cfg.operator != null) [ "--operator=${cfg.operator}" ];
    };

    # Restart tailscaled after suspend/resume to avoid "node not found" loop
    # See: https://github.com/tailscale/tailscale/issues — s2idle causes network drop,
    # tailscaled never re-registers with coordination server
    systemd.services.tailscale-resume = mkIf cfg.resumeFix {
      description = "Restart Tailscale after suspend";
      after = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
      wantedBy = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${config.systemd.package}/bin/systemctl restart tailscaled.service";
      };
    };
  };
}

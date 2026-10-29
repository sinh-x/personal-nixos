# Pure configuration evaluation only. Does NOT activate a service or issue a certificate.
{ nixpkgs }:
let
  make =
    extra:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./drgnfly-timelapse.nix
        ({ lib, ... }: {
          options.modules.impermanence = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
            };
            persistPath = lib.mkOption {
              type = lib.types.str;
              default = "/persist";
            };
          };
          options.environment.persistence = lib.mkOption {
            type = lib.types.attrs;
            default = { };
          };
          config = {
            system.stateVersion = "26.11";
            networking.hostName = "Drgnfly";
            services.tailscale.enable = true;
            networking.firewall.trustedInterfaces = [ "tailscale0" ];
          };
        })
        extra
      ];
    };
  system = make { };
  c = system.config;
  unit = c.systemd.services.timestamp-timelapse;
  root = c.systemd.services.timestamp-timelapse-prepare;
  renewal = c.systemd.services.timestamp-timelapse-renew;
  mine =
    s:
    (import ./drgnfly-timelapse.nix {
      inherit (s) config pkgs;
      inherit (nixpkgs) lib;
    }).assertions;
  wrongHost = make ({ lib, ... }: { networking.hostName = lib.mkForce "OtherHost"; });
  noTailnet = make ({ lib, ... }: { services.tailscale.enable = lib.mkForce false; });
  noFirewall = make ({ lib, ... }: { networking.firewall.trustedInterfaces = lib.mkForce [ ]; });
  noPersistence = make ({ lib, ... }: { modules.impermanence.enable = lib.mkForce false; });
in
assert c.services.timestamp-timelapse.tailnetAddress == "100.83.89.101";
assert c.services.timestamp-timelapse.hostname == "drgnfly.tail10c2c6.ts.net";
assert c.services.timestamp-timelapse.port == 8443;
assert
  c.services.timestamp-timelapse.package.outPath
  == "/nix/store/9c7mld4w5m2qjpw01ksm7ha91bq995p0-timelapse-server-0.1.0";
assert c.networking.firewall.allowedTCPPorts == [ ];
assert
  c.networking.firewall.trustedInterfaces == [
    "tailscale0"
    "lo"
  ]; # locked NixOS adds loopback
assert unit.serviceConfig.User == "timestamp-timelapse";
assert unit.serviceConfig.ReadWritePaths == [ "/var/lib/timestamp-timelapse" ];
assert unit.serviceConfig.IPAddressDeny == "any";
assert builtins.elem "timestamp-timelapse-prepare.service" unit.requires;
assert builtins.elem "timestamp-timelapse-prepare.service" unit.after;
assert root.serviceConfig.User == "root";
assert root.serviceConfig.ProtectSystem == "strict";
assert root.serviceConfig.ReadWritePaths == [ "/var/lib/timelapse-credentials" ];
assert root.serviceConfig.RestrictAddressFamilies == [ "AF_UNIX" ];
assert renewal.serviceConfig.ReadWritePaths == [ "/var/lib/timelapse-credentials" ];
assert c.systemd.timers.timestamp-timelapse-renew.timerConfig.Persistent;
assert c.systemd.timers.timestamp-timelapse-renew.timerConfig.OnCalendar == "daily";
assert builtins.all (
  d: d.user == "timestamp-timelapse" && d.group == "timestamp-timelapse" && d.mode == "0700"
) c.environment.persistence."/persist/system".directories;
assert
  map (d: d.directory) c.environment.persistence."/persist/system".directories == [
    "/var/lib/timestamp-timelapse"
    "/var/lib/timelapse-credentials"
  ];
assert builtins.all (a: a.assertion) (mine system);
assert !(builtins.all (a: a.assertion) (mine wrongHost));
assert !(builtins.all (a: a.assertion) (mine noTailnet));
assert !(builtins.all (a: a.assertion) (mine noFirewall));
assert !(builtins.all (a: a.assertion) (mine noPersistence));
{
  passed = true;
  fixture = "drgnfly-timelapse-isolation-persistence-renewal";
  liveEffects = false;
  package = c.services.timestamp-timelapse.package.outPath;
  rootPrepareScript = root.script;
  renewalProgram = renewal.serviceConfig.ExecStart;
}

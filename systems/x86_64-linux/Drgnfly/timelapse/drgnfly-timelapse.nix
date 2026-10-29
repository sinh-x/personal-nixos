# Operator-reviewed Drgnfly deployment of TTL-014 candidate 967380ba862d88e352b8947a3b9ee59e71083147.
# This file contains paths/configuration only, NEVER password/token/private-key contents.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Keep the server on the reviewed/cache-verified Go1.26.8 package set even if
  # the host has a separate pending nixpkgs upgrade. No host lock update occurs.
  archivePkgs = import (builtins.fetchTree {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "e7439b6b14ad3cc35d05608ebca9bce01a25f5f8";
    narHash = "sha256-H83yz/do+hjOO0uujHyH8RgtIQP2v7Mw+cLwcZK/xKc=";
  }) { system = pkgs.stdenv.hostPlatform.system; };
  account = "timestamp-timelapse";
  credentials = "/var/lib/timelapse-credentials";
  hostname = "drgnfly.tail10c2c6.ts.net";
  manage = ./manage.py;
  python = "${pkgs.python3}/bin/python3";
  server = lib.getExe config.services.timestamp-timelapse.package;
  renew = pkgs.writeShellScript "timestamp-timelapse-renew" ''
    set -euo pipefail
    umask 077
    stage="$(${pkgs.coreutils}/bin/mktemp -d "$RUNTIME_DIRECTORY/cert.XXXXXXXX")"
    # No --serve-demo, no HTTP challenge listener, no Funnel or ACL changes.
    ${pkgs.tailscale}/bin/tailscale cert --min-validity=720h \
      --cert-file="$stage/cert.pem" --key-file="$stage/key.pem" ${hostname}
    ${pkgs.coreutils}/bin/chmod 0600 "$stage/cert.pem" "$stage/key.pem"
    ${pkgs.openssl}/bin/openssl x509 -in "$stage/cert.pem" -noout -checkhost ${hostname} >/dev/null
    ${pkgs.openssl}/bin/openssl x509 -in "$stage/cert.pem" -noout -checkend 86400 >/dev/null
    ${pkgs.openssl}/bin/openssl verify -CAfile ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
      -untrusted "$stage/cert.pem" "$stage/cert.pem" >/dev/null
    cert_public="$(${pkgs.openssl}/bin/openssl x509 -in "$stage/cert.pem" -pubkey -noout | \
      ${pkgs.openssl}/bin/openssl pkey -pubin -outform DER | ${pkgs.coreutils}/bin/sha256sum)"
    key_public="$(${pkgs.openssl}/bin/openssl pkey -in "$stage/key.pem" -pubout -outform DER | \
      ${pkgs.coreutils}/bin/sha256sum)"
    test "$cert_public" = "$key_public"
    ${python} ${manage} publish "$stage" ${credentials} ${account}
    # Remove only these exact successful, privately generated staging files.
    ${pkgs.coreutils}/bin/rm -- "$stage/cert.pem" "$stage/key.pem"
    ${pkgs.coreutils}/bin/rmdir -- "$stage"
  '';
  rootUnit = {
    Type = "oneshot";
    User = "root";
    UMask = "0077";
    ProtectSystem = "strict";
    ProtectHome = true;
    ReadWritePaths = [ credentials ];
    PrivateTmp = true;
    PrivateDevices = true;
    NoNewPrivileges = true;
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    RestrictAddressFamilies = [ "AF_UNIX" ];
    RuntimeDirectoryMode = "0700";
    RuntimeDirectoryPreserve = "yes"; # failed private staging is retained for operator review
    TimeoutStartSec = "5min";
  };
in
{
  imports = [ ./nix/timelapse-server.nix ];
  assertions = [
    {
      assertion = config.networking.hostName == "Drgnfly";
      message = "This timelapse configuration is only approved for Drgnfly.";
    }
    {
      assertion = config.services.tailscale.enable;
      message = "Existing Tailscale must already be enabled; this module never enables/reconfigures it.";
    }
    {
      assertion = builtins.elem "tailscale0" config.networking.firewall.trustedInterfaces;
      message = "Review Tailscale firewall readiness separately; this module opens no firewall ports.";
    }
    {
      assertion = config.modules.impermanence.enable;
      message = "Review archive/credential persistence before using this host-specific deployment.";
    }
  ];
  services.timestamp-timelapse = {
    enable = true;
    package = archivePkgs.callPackage ./nix/package.nix { };
    tailnetAddress = "100.83.89.101";
    inherit hostname;
    port = 8443;
    stateDirectory = "/var/lib/timestamp-timelapse";
    certificateFile = "${credentials}/cert.pem";
    privateKeyFile = "${credentials}/key.pem";
    credentialsFile = "${credentials}/auth.json";
  };
  # Bind mounts, not symlinks: native canonical-path checks remain intact.
  environment.persistence."${config.modules.impermanence.persistPath}/system".directories = [
    {
      directory = "/var/lib/timestamp-timelapse";
      user = account;
      group = account;
      mode = "0700";
    }
    {
      directory = credentials;
      user = account;
      group = account;
      mode = "0700";
    }
  ];
  systemd = {
    tmpfiles.rules = [ "d ${credentials} 0700 ${account} ${account} -" ];
    services = {
      timestamp-timelapse = {
        requires = [ "timestamp-timelapse-prepare.service" ];
        after = [ "timestamp-timelapse-prepare.service" ];
      };
      timestamp-timelapse-prepare = {
        description = "Prepare private timelapse credentials/certificate without resetting existing state";
        requires = [ "tailscaled.service" ];
        after = [
          "tailscaled.service"
          "systemd-tmpfiles-setup.service"
        ];
        serviceConfig = rootUnit // {
          RuntimeDirectory = "timestamp-timelapse-prepare";
          RemainAfterExit = true;
        };
        script = ''
          set -euo pipefail
          ${python} ${manage} init ${server} ${credentials} ${account}
          ${renew}
        '';
      };
      timestamp-timelapse-renew = {
        description = "Renew only the private timelapse trusted Tailscale certificate";
        requires = [ "tailscaled.service" ];
        after = [
          "tailscaled.service"
          "systemd-tmpfiles-setup.service"
        ];
        serviceConfig = rootUnit // {
          RuntimeDirectory = "timestamp-timelapse-renew";
          ExecStart = renew;
        };
      };
    };
    timers.timestamp-timelapse-renew = {
      description = "Check timelapse certificate daily";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
        Unit = "timestamp-timelapse-renew.service";
      };
    };
  };
}

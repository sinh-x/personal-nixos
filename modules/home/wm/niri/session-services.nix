{
  pkgs,
  homeDirectory,
  inputMethodPackage,
}:
let
  unit = {
    ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
    After = [
      "niri.service"
      "niri-session.target"
    ];
    PartOf = [ "niri-session.target" ];
    BindsTo = [ "niri.service" ];
  };
  service = command: {
    Unit = unit;
    Service = {
      ExecStart = command;
      Restart = "on-failure";
      TimeoutStopSec = 5;
    };
    Install.WantedBy = [ "niri-session.target" ];
  };
in
{
  waybar = service "${pkgs.waybar}/bin/waybar --bar main-bar --log-level error --config ${homeDirectory}/.config/waybar/config --style ${homeDirectory}/.config/waybar/style.css";
  # Use the existing D-Bus activation unit name. A notification must not create
  # a second Mako instance or activate it in the Umbriel desktop.
  mako = (service "${pkgs.mako}/bin/mako") // {
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
      TimeoutStopSec = 5;
    };
  };
  niri-awww = service "${pkgs.awww}/bin/awww-daemon";
  niri-wallpaper = {
    Unit = unit // {
      After = unit.After ++ [ "niri-awww.service" ];
      Requires = [ "niri-awww.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "niri-default-wallpaper" ''
        sleep 1
        exec ${pkgs.bash}/bin/bash ${homeDirectory}/.config/niri/scripts/wallpaper --default
      '';
    };
    Install.WantedBy = [ "niri-session.target" ];
  };
  niri-cliphist-text = service "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
  niri-cliphist-image = service "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
  fcitx5-niri = service "${inputMethodPackage}/bin/fcitx5";
}

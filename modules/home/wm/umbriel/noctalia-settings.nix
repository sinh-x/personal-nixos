{ controls, homeDirectory }:
let
  command = action: "${controls}/bin/umbriel-controls ${action}";
in
{
  storage = {
    key_source = "secret-service";
    key_file = "";
  };
  audio.enable_overdrive = false;
  lockscreen.enabled = false; # swaylock is the only lock client/PAM path.
  wallpaper = {
    enabled = true;
    directory = "${homeDirectory}/Pictures/Wallpapers";
  };
  # Match the source desktop's lack of automatic idle power policy. Also keep
  # the underlying suspend override guarded for explicit built-in IPC requests.
  idle = {
    behavior_order = [
      "lock"
      "screen-off"
      "lock-and-suspend"
    ];
    behavior = {
      lock.enabled = false;
      screen-off.enabled = false;
      lock-and-suspend.enabled = false;
    };
  };
  shell = {
    polkit_agent = false;
    setup_wizard_enabled = false;
    telemetry_enabled = false;
    clipboard_enabled = true;
    clipboard_auto_paste = "off";
    screenshot = {
      annotate = true;
      skip_annotate_on_copy_save = false;
      save_to_file = false;
      copy_to_clipboard = false;
      pipe_to_command = false;
      copy_on_close = false;
      close_on_copy = false;
      close_on_save = false;
      directory = "${homeDirectory}/Pictures/Screenshots";
      format = "png";
    };
    session = {
      actions = [
        {
          action = "command";
          label = "Lock";
          command = command "lock";
        }
        {
          action = "command";
          label = "Hibernate";
          command = command "hibernate";
        }
        {
          action = "logout";
          label = "Logout";
          command = command "logout";
        }
        {
          action = "reboot";
          label = "Reboot";
          command = command "reboot";
        }
        {
          action = "shutdown";
          label = "Shutdown";
          command = command "shutdown";
        }
      ];
      power = {
        suspend = command "hibernate";
        reboot = command "reboot";
        shutdown = command "shutdown";
      };
    };
  };
}

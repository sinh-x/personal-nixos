{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.modules.thermal-printer;
in
{
  options.modules.thermal-printer = {
    enable = mkEnableOption "Y41BT USB thermal printer support";
  };

  config = mkIf cfg.enable {
    # Load usblp kernel module on boot
    boot.kernelModules = [ "usblp" ];

    # Udev rule for Y41BT USB thermal printer (VID: 5958, PID: 0041)
    # - Sets MODE 0666 for all-user read/write access
    # - Creates stable symlink /dev/thermal-printer
    # Note: usblp claims the device from libusb, which inherently prevents
    # CUPS from accessing it. This is the desired behavior for direct USB access.
    services.udev.extraRules = ''
      # Y41BT USB Thermal Printer (VID: 5958, PID: 0041)
      # Set world-readable/writable permissions and create stable symlink
      SUBSYSTEM=="usbmisc", ATTRS{idVendor}=="5958", ATTRS{idProduct}=="0041", MODE:="0666", SYMLINK+="thermal-printer"
    '';
  };
}

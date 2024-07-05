{
  networking.hostName = "Drgnfly"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless = {
    environmentFile = "/home/sinh/wireless.env";
    enable = true;  # Enables wireless support via wpa_supplicant.
    userControlled.enable = true;
    networks = {
      "5G_Vuon Nha" = {
        psk = "@vuonnha@";
      };
      "VINA_NHA MINH 1" = {
        psk = "@vinanhaminh@";
      };
      "La Preso 5.0Ghz" = {
        psk = "@lapreso@";
      };
      "MSTT_5G" = {
        psk = "@mstt@";
      };
      "MSTT_5G_Plus_5G" = {
        psk = "@mstt@";
      };
      "Mai Trang" = {
        psk = "@maitrang@";
      };
      "Kashew Deli" = {
        psk = "@kashew@";
      };
      "DoveZi Coffee" = {
        psk = "@dovezi@";
      };
    };
  };
}

{
  # Pick only one of the below networking options.
  networking.wireless = {
    secretsFile = "/home/sinh/wireless.env";
    enable = true; # Enables wireless support via wpa_supplicant.
    userControlled.enable = true;
    networks = {
      "5G_Vuon Nha" = {
        psk = "ext:vuonnha";
      };
      "VINA_NHA MINH 1" = {
        psk = "ext:nhaminh";
      };
      "VINA_NHA MINH" = {
        psk = "ext:nhaminh";
      };
      "La Preso 5.0Ghz" = {
        psk = "ext:lapreso";
      };
      "MSTT_5G" = {
        psk = "ext:mstt";
      };
      "MSTT_5G_Plus_5G" = {
        psk = "ext:mstt";
      };
      "Mai Trang" = {
        psk = "ext:maitrang";
      };
      "Kashew Deli" = {
        psk = "ext:kashew";
      };
      "DoveZi Coffee" = {
        psk = "ext:dovezi";
      };
      "CAFE_KOHI_5Ghz" = {
        psk = "ext:kohitayninh";
      };
      "Tra Sua L'Latino 5 5Ghz" = {
        psk = "ext:llatino";
      };
      "5 SENSES_vina" = {
        psk = "ext:5senses";
      };
      "Home Coffee 01" = {
        psk = "ext:homecoffee";
      };
      "YAMA_5G" = {
        psk = "ext:yama";
      };
      "Yama1" = {
        psk = "ext:yama";
      };
      "Ngot.Cafe_5G" = {
        psk = "ext:ngotcafe";
      };
      "LyLy Coffee" = {
        psk = "ext:lyly";
      };
      "Sales Bua" = {
        psk = "ext:salesbua";
      };
      "Le Montage Bar & Bistro" = {
        psk = "ext:lemontage";
      };
      "TomatoBookKafe New" = {
        psk = "ext:tomato";
      };
      "1273" = {
        psk = "ext:nhalan";
      };
      "ROOM NHA NOI" = {
        psk = "ext:cafenhanoi";
      };
    };
  };
}

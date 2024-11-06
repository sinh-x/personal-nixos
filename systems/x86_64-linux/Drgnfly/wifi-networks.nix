{
  # Pick only one of the below networking options.
  networking.wireless = {
    secretsFile = "/home/sinh/wireless.env";
    enable = true; # Enables wireless support via wpa_supplicant.
    userControlled.enable = true;
    networks = {
      "5G_Vuon Nha" = {
        pskRaw = "ext:vuonnha";
      };
      "VINA_NHA MINH 1" = {
        pskRaw = "ext:nhaminh";
      };
      "VINA_NHA MINH" = {
        pskRaw = "ext:nhaminh";
      };
      "La Preso 5.0Ghz" = {
        pskRaw = "ext:lapreso";
      };
      "MSTT_5G" = {
        pskRaw = "ext:mstt";
      };
      "MSTT_5G_Plus_5G" = {
        pskRaw = "ext:mstt";
      };
      "Mai Trang" = {
        pskRaw = "ext:maitrang";
      };
      "Kashew Deli" = {
        pskRaw = "ext:kashew";
      };
      "DoveZi Coffee" = {
        pskRaw = "ext:dovezi";
      };
      "CAFE_KOHI_5Ghz" = {
        pskRaw = "ext:kohitayninh";
      };
      "Tra Sua L'Latino 5 5Ghz" = {
        pskRaw = "ext:llatino";
      };
      "5 SENSES_vina" = {
        pskRaw = "ext:5senses";
      };
      "Home Coffee 01" = {
        pskRaw = "ext:homecoffee";
      };
      "YAMA_5G" = {
        pskRaw = "ext:yama";
      };
      "Yama1" = {
        pskRaw = "ext:yama";
      };
      "Ngot.Cafe_5G" = {
        pskRaw = "ext:ngotcafe";
      };
      "LyLy Coffee" = {
        pskRaw = "ext:lyly";
      };
      "Sales Bua" = {
        pskRaw = "ext:salesbua";
      };
      "Le Montage Bar & Bistro" = {
        pskRaw = "ext:lemontage";
      };
      "TomatoBookKafe New" = {
        pskRaw = "ext:tomato";
      };
      "1273" = {
        pskRaw = "ext:nhalan";
      };
      "ROOM NHA NOI" = {
        psk = "183chauvanliem";
      };
    };
  };
}

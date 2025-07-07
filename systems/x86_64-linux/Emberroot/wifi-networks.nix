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
      "YAMA 1" = {
        pskRaw = "ext:yama";
      };
      "Ngot.Cafe" = {
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
      "Homestay in Tay Ninh" = {
        psk = "02112011";
      };
      "Hem ca phe 5g" = {
        pskRaw = "ext:cafehem";
      };
      "The Coffee Bean & Tea Leaf" = {
        pskRaw = "ext:coffeebean";
      };
      "Giong Cafe" = {
        pskRaw = "ext:giongcafe";
      };
      "Green Cafe" = {
        pskRaw = "ext:greencafe";
      };
      "KAI Coffee" = {
        pskRaw = "ext:kaicoffee";
      };
      "G1910 SSR" = {
        pskRaw = "ext:g1910";
      };
      "Sinh-x" = {
        pskRaw = "ext:sinhiphone";
      };
      "KIM SON" = {
        pskRaw = "ext:kimson";
      };
      "A MERCI" = {
        pskRaw = "ext:amercy";
      };
      "The Risu_5G" = {
        pskRaw = "ext:risu";
      };
      "The Coffee House" = {
        pskRaw = "ext:coffeehouseTN";
      };
      "CAFE TAM 3" = {
        pskRaw = "ext:cafetam";
      };
      "THE MOON" = {
        pskRaw = "ext:themoon";
      };
      "Adiuvat Coffee Roasters" = {
        pskRaw = "ext:nhadiu";
        # psk = "57nguyenhue";
      };
      "ADIUVAT Coffee Roasters" = {
        pskRaw = "ext:adiuvat";
      };
      "TOCEPO" = {
      };
      "JollyTea" = {
      };
      "TheLaiKafe" = {
        pskRaw = "ext:laikafe";
      };
      "Grandma Lu's" = {
        pskRaw = "ext:grandmalu";
      };
      "LAZANIA" = {
        pskRaw = "ext:lazania";
      };
      "80+ COFFEE ROASTERY" = {
        pskRaw = "ext:hcm80plus";
      };
      "BHouse 2" = {
        pskRaw = "ext:bhouse";
      };
      "LOTUS 18 NPK L4" = {
        pskRaw = "ext:lotusnpk";
      };
      "Happy House" = {
        pskRaw = "ext:sg_vin_hh";
      };
      "GRIN_cafenstay" = {
        pskRaw = "ext:quinhon_grin";
      };
      "Nhoan L1" = {
        pskRaw = "ext:hcm_nhoan";
      };
      "Holo Fairy House" = {
        pskRaw = "ext:holoHanoi";
      };
      "WORKFLOW CAFE" = { };
      "Hotel du Parc Hanoi" = { };
      "Hust_C1_213" = { };
      "@ TASECO FREE WIFI" = { };
    };
  };
}

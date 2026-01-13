{
  config,
  lib,
  ...
}:

let
  cfg = config.modules.wifi;

  # All shared networks - single source of truth
  sharedNetworks = {
    # Home networks
    "5G_Vuon Nha" = {
      pskRaw = "ext:vuonnha";
    };
    "VINA_NHA MINH 1" = {
      pskRaw = "ext:nhaminh";
    };
    "VINA_NHA MINH" = {
      pskRaw = "ext:nhaminh";
    };

    # Cafes and restaurants
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
      pskRaw = "ext:roomnhanoi";
    };
    "Homestay in Tay Ninh" = {
      pskRaw = "ext:homestaytayninh";
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
    };
    "ADIUVAT Coffee Roasters" = {
      pskRaw = "ext:adiuvat";
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
    "LOTUS 18 NPK  L3" = {
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
    "K&T_Coffee" = {
      pskRaw = "ext:ktcoffee";
    };
    "CatAnhCoffee5G" = {
      pskRaw = "ext:sg_2_catanh";
    };
    "HWS_Member" = {
      pskRaw = "ext:sg_helloword";
    };
    "Hestia cafe" = {
      pskRaw = "ext:qn_hestia";
    };
    "tree hugger" = {
      pskRaw = "ext:qn_treehugger";
    };
    "vuon chan 16" = {
      pskRaw = "ext:qn_chantea";
    };
    "BINH MINH homestay_5G" = {
      pskRaw = "ext:nh_binhminh";
    };
    "JOY HomeL2-5G" = {
      pskRaw = "ext:sg_joyhome";
    };
    "Mango Tree" = {
      pskRaw = "ext:qn_mangotree";
    };
    "BaiDinhHotel-R125" = {
      pskRaw = "ext:hn_baidinh_hotel";
    };
    "Bar Coffee" = {
      pskRaw = "ext:hn_baidinh_hotel";
    };
    "LPH House 5G" = {
      pskRaw = "ext:hn_lphhouse";
    };
    "TENEMENT ZONE 1 5G" = {
      pskRaw = "ext:hn_tenement";
    };
    "Hoianese Old Town f4b" = {
      pskRaw = "ext:dn_hoianese";
    };
    "IKIGAI" = {
      pskRaw = "ext:dn_ikigai";
    };
    "TRA Coffee & Tea House 5GHz" = {
      pskRaw = "ext:dn_trateahouse";
    };
    "Seahorse Han Market by Haviland" = {
      pskRaw = "ext:dn_joycafe";
    };
    "The Interlude" = {
      pskRaw = "ext:dn_interlude";
    };
    "LAROSE COFFEE" = {
      pskRaw = "ext:qn_larose_1";
    };
    "Larose Coffee" = {
      pskRaw = "ext:qn_larose";
    };
    "Tiem Banh Doan Gia" = {
      pskRaw = "ext:kh_doangia";
    };
    "CENTRE HOTEL" = {
      pskRaw = "ext:dn_centre";
    };
    "KIEU GIANG" = {
      pskRaw = "ext:kh_nhaan";
    };
    "NHIEN cafe PL" = {
      pskRaw = "ext:kh_nhiencafe";
    };
    "S&D Suites 5F" = {
      pskRaw = "ext:sg_120_dongvancong";
    };
    "Adiuvat Home" = {
      pskRaw = "ext:nhadiu";
    };

    # Open networks (no password)
    "TOCEPO" = { };
    "JollyTea" = { };
    "Pax Ana Resort" = { };
    "Starbucks" = { };
    "WORKFLOW CAFE" = { };
    "Hotel du Parc Hanoi" = { };
    "Hust_C1_213" = { };
    "@ TASECO FREE WIFI" = { };
    "Highlands Coffee" = { };
  };
in
{
  options.modules.wifi = {
    enable = lib.mkEnableOption "Shared WiFi configuration using SOPS secrets";

    extraNetworks = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional per-host networks to merge with shared networks";
    };

    userControlled = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow user control via wpa_cli";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.modules.sops.enable;
        message = "modules.wifi requires modules.sops.enable = true for SOPS-encrypted WiFi credentials";
      }
    ];

    networking.wireless = {
      enable = true;
      secretsFile = config.sops.secrets."wifi/credentials".path;
      userControlled.enable = cfg.userControlled;
      networks = sharedNetworks // cfg.extraNetworks;
    };
  };
}

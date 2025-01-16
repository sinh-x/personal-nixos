{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.r_setup;
in
{
  options = {
    modules.r_setup.enable = lib.mkEnableOption "R and r-packages installation";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      R
      gnumake
      gcc
      libgcc
      rstudio
      (pkgs.rWrapper.override {
        packages = with pkgs.rPackages; [
          DT
          RColorBrewer
          RJSONIO
          RgoogleMaps
          Rlof
          V8
          arrow
          assertthat
          bindr
          bindrcpp
          brew
          broom
          covr
          cowplot
          crayon
          curl
          devtools
          doParallel
          doParallel
          feather
          foreach
          formatR
          futile_logger
          ggmap
          ggrepel
          ggvis
          ggpubr
          glue
          golem
          googleVis
          haven
          hms
          htmltools
          htmlwidgets
          httr
          igraph
          jpeg
          jqr
          jsonlite
          jsonvalidate
          knitr
          languageserver
          languageserversetup
          leaflet
          lgr
          lintr
          lubridate
          maps
          markdown
          modelr
          nlme
          nloptr
          openxlsx
          rJava
          reactable
          readxl
          readxl
          recipes
          renv
          reprex
          reshape2
          rex
          rhandsontable
          rio
          rjson
          rlang
          roxygen2
          rpart
          rvest
          rvg
          scales
          sessioninfo
          sf
          sfsmisc
          shiny
          shinyBS
          shinydashboard
          shinydashboardPlus
          shinythemes
          sjlabelled
          skimr
          slam
          sna
          stringdist
          stringi
          stringr
          testthat
          textcat
          tidyverse
          tidyverse
          tryCatchLog
          usethis
          xml2
          zip
          zoo
        ];
      })
    ];
  };
}

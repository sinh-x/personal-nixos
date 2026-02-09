{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config,
  namespace,
  ...
}:
with lib;
let
  cfg = config.${namespace}.cli-apps.multiplexers.zellij;
in
{
  options.${namespace}.cli-apps.multiplexers.zellij = {
    enable = mkEnableOption "Zellij";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.tmate
    ];

    xdg.configFile = {
      "zellij/config.kdl".source = ./config.kdl;
      # Zellij zsh completions with session name support
      "zsh/completions/_zellij".source = pkgs.runCommand "zellij-completion" { } ''
                # Generate base completion
                ${pkgs.zellij}/bin/zellij setup --generate-completion zsh > $out

                # Patch to add session name completion function
                ${pkgs.gnused}/bin/sed -i '/_zellij() {/a\
            # Function to complete session names\
            _zellij_sessions() {\
                local sessions\
                sessions=(''${(f)"$(${pkgs.zellij}/bin/zellij list-sessions -sn 2>/dev/null)"})\
                _describe -t sessions "session" sessions\
            }
        ' $out

                # Replace empty session-name completion with our function
                ${pkgs.gnused}/bin/sed -i "s/'::session-name -- Name of the session to attach to:'/'1:session-name -- Name of the session to attach to:_zellij_sessions'/" $out

                # Make session-name come before subcommands by changing subcommands to optional
                ${pkgs.gnused}/bin/sed -i "s/\":: :_zellij__attach_commands\"/\"2:: :_zellij__attach_commands\"/" $out
      '';
      "zellij/layouts/default.kdl".text = ''
        layout {
           swap_tiled_layout name="vertical" {
                tab max_panes=5 {
                    pane split_direction="vertical" {
                        pane
                        pane { children; }
                    }
                }
                tab max_panes=8 {
                    pane split_direction="vertical" {
                        pane { children; }
                        pane { pane; pane; pane; pane; }
                    }
                }
                tab max_panes=12 {
                    pane split_direction="vertical" {
                        pane { children; }
                        pane { pane; pane; pane; pane; }
                        pane { pane; pane; pane; pane; }
                    }
                }
            }

            swap_tiled_layout name="horizontal" {
                tab max_panes=5 {
                    pane
                    pane
                }
                tab max_panes=8 {
                    pane {
                        pane split_direction="vertical" { children; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                    }
                }
                tab max_panes=12 {
                    pane {
                        pane split_direction="vertical" { children; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                        pane split_direction="vertical" { pane; pane; pane; pane; }
                    }
                }
            }

            swap_tiled_layout name="stacked" {
                tab min_panes=5 {
                    pane split_direction="vertical" {
                        pane
                        pane stacked=true { children; }
                    }
                }
            }

            swap_floating_layout name="staggered" {
                floating_panes
            }

            swap_floating_layout name="enlarged" {
                floating_panes max_panes=10 {
                    pane { x "5%"; y 1; width "90%"; height "90%"; }
                    pane { x "5%"; y 2; width "90%"; height "90%"; }
                    pane { x "5%"; y 3; width "90%"; height "90%"; }
                    pane { x "5%"; y 4; width "90%"; height "90%"; }
                    pane { x "5%"; y 5; width "90%"; height "90%"; }
                    pane { x "5%"; y 6; width "90%"; height "90%"; }
                    pane { x "5%"; y 7; width "90%"; height "90%"; }
                    pane { x "5%"; y 8; width "90%"; height "90%"; }
                    pane { x "5%"; y 9; width "90%"; height "90%"; }
                    pane focus=true { x 10; y 10; width "90%"; height "90%"; }
                }
            }

            swap_floating_layout name="spread" {
                floating_panes max_panes=1 {
                    pane {y "50%"; x "50%"; }
                }
                floating_panes max_panes=2 {
                    pane { x "1%"; y "25%"; width "45%"; }
                    pane { x "50%"; y "25%"; width "45%"; }
                }
                floating_panes max_panes=3 {
                    pane focus=true { y "55%"; width "45%"; height "45%"; }
                    pane { x "1%"; y "1%"; width "45%"; }
                    pane { x "50%"; y "1%"; width "45%"; }
                }
                floating_panes max_panes=4 {
                    pane { x "1%"; y "55%"; width "45%"; height "45%"; }
                    pane focus=true { x "50%"; y "55%"; width "45%"; height "45%"; }
                    pane { x "1%"; y "1%"; width "45%"; height "45%"; }
                    pane { x "50%"; y "1%"; width "45%"; height "45%"; }
                }
            }

            default_tab_template {
                pane size=1 borderless=true {
                    plugin location="file://${pkgs.zjstatus}/bin/zjstatus.wasm" {
                        format_left   "{mode}#[bg=#181926] {tabs}"
                        format_center "#[bg=#181926,fg=#89b4fa]{datetime}"
                        format_right  "#[bg=#181926,fg=#89b4fa]#[bg=#89b4fa,fg=#1e2030,bold] #[bg=#363a4f,fg=#89b4fa,bold] {session}{command_hostname} #[bg=#181926,fg=#363a4f,bold]"
                        format_space  ""
                        format_hide_on_overlength "true"
                        format_precedence "crl"

                        border_enabled  "false"
                        border_char     "─"
                        border_format   "#[fg=#6C7086]{char}"
                        border_position "top"

                        mode_normal        "#[bg=#a6da95,fg=#181926,bold] NORMAL#[bg=#181926,fg=#a6da95]█"
                        mode_locked        "#[bg=#6e738d,fg=#181926,bold] LOCKED #[bg=#181926,fg=#6e738d]█"
                        mode_resize        "#[bg=#f38ba8,fg=#181926,bold] RESIZE#[bg=#181926,fg=#f38ba8]█"
                        mode_pane          "#[bg=#89b4fa,fg=#181926,bold] PANE#[bg=#181926,fg=#89b4fa]█"
                        mode_tab           "#[bg=#b4befe,fg=#181926,bold] TAB#[bg=#181926,fg=#b4befe]█"
                        mode_scroll        "#[bg=#f9e2af,fg=#181926,bold] SCROLL#[bg=#181926,fg=#f9e2af]█"
                        mode_enter_search  "#[bg=#8aadf4,fg=#181926,bold] ENT-SEARCH#[bg=#181926,fg=#8aadf4]█"
                        mode_search        "#[bg=#8aadf4,fg=#181926,bold] SEARCHARCH#[bg=#181926,fg=#8aadf4]█"
                        mode_rename_tab    "#[bg=#b4befe,fg=#181926,bold] RENAME-TAB#[bg=#181926,fg=#b4befe]█"
                        mode_rename_pane   "#[bg=#89b4fa,fg=#181926,bold] RENAME-PANE#[bg=#181926,fg=#89b4fa]█"
                        mode_session       "#[bg=#74c7ec,fg=#181926,bold] SESSION#[bg=#181926,fg=#74c7ec]█"
                        mode_move          "#[bg=#f5c2e7,fg=#181926,bold] MOVE#[bg=#181926,fg=#f5c2e7]█"
                        mode_prompt        "#[bg=#8aadf4,fg=#181926,bold] PROMPT#[bg=#181926,fg=#8aadf4]█"
                        mode_tmux          "#[bg=#f5a97f,fg=#181926,bold] TMUX#[bg=#181926,fg=#f5a97f]█"

                        // formatting for inactive tabs
                        tab_normal              "#[bg=#181926,fg=#89b4fa]█#[bg=#89b4fa,fg=#1e2030,bold]{index} #[bg=#363a4f,fg=#89b4fa,bold] {name}{floating_indicator}#[bg=#181926,fg=#363a4f,bold]█"
                        tab_normal_fullscreen   "#[bg=#181926,fg=#89b4fa]█#[bg=#89b4fa,fg=#1e2030,bold]{index} #[bg=#363a4f,fg=#89b4fa,bold] {name}{fullscreen_indicator}#[bg=#181926,fg=#363a4f,bold]█"
                        tab_normal_sync         "#[bg=#181926,fg=#89b4fa]█#[bg=#89b4fa,fg=#1e2030,bold]{index} #[bg=#363a4f,fg=#89b4fa,bold] {name}{sync_indicator}#[bg=#181926,fg=#363a4f,bold]█"

                        // formatting for the current active tab
                        tab_active              "#[bg=#181926,fg=#fab387]█#[bg=#fab387,fg=#1e2030,bold]{index} #[bg=#363a4f,fg=#fab387,bold] {name}{floating_indicator}#[bg=#181926,fg=#363a4f,bold]█"
                        tab_active_fullscreen   "#[bg=#181926,fg=#fab387]█#[bg=#fab387,fg=#1e2030,bold]{index} #[bg=#363a4f,fg=#fab387,bold] {name}{fullscreen_indicator}#[bg=#181926,fg=#363a4f,bold]█"
                        tab_active_sync         "#[bg=#181926,fg=#fab387]█#[bg=#fab387,fg=#1e2030,bold]{index} #[bg=#363a4f,fg=#fab387,bold] {name}{sync_indicator}#[bg=#181926,fg=#363a4f,bold]█"

                        // separator between the tabs
                        tab_separator           "#[bg=#181926] "

                        // indicator
                        tab_sync_indicator       " "
                        tab_fullscreen_indicator " 󰊓"
                        tab_floating_indicator   " 󰹙"

                        command_hostname_command       "hostname"
                        command_hostname_format      "#[fg=blue] @{stdout} "
                        command_hostname_interval    "10"
                        command_hostname_rendermode  "static"


                        datetime        "#[fg=#89b4fa,bold] {format} "
                        datetime_format "%A, %d %b %Y %H:%M"
                        datetime_timezone "Asia/Ho_Chi_Minh"
                    }
                }
                children
            }
        }
      '';
    };

    programs.zellij = {
      enable = true;
      enableFishIntegration = false;
      enableZshIntegration = false;
      # package = zellij-wrapped;
      # settings = {
      #   default_mode = "normal";
      #   default_shell = "fish";
      #   simplified_ui = true;
      #   pane_frames = false;
      #   theme = "catppuccin-mocha";
      #   copy_on_select = true;
      # };
    };
  };
}

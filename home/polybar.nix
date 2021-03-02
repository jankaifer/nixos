{ pkgs, toRelativePath }:

with builtins;
{
  enable = true;
  package = pkgs.polybar.override {
    i3GapsSupport = true;
    # iwSupport = true;
    githubSupport = true;
    alsaSupport = true;
    mpdSupport = true;
    pulseSupport = true;
  };
  script = "true";
  config =
    let
      commonBarConfig = {
        monitor = "\${env:MONITOR:}";
        width = "100%";
        height = 36;

        background = "#000000";
        foreground = "#ffffff";

        line-size = 2;

        spacing = 0;
        padding-right = 2;
        module-margin = 1;

        font-0 = "Fira Code:size=14;4";
        font-1 = "Fira Code Symbols:size=30;8";
        font-2 = "agave Nerd Font Mono:size=30;8";
      };

      bar-top = commonBarConfig // {
        top = true;
        modules-left = "menu";
        modules-right = "volume backlight wireless-network battery date";
      };
      bar-bottom = commonBarConfig // {
        bottom = true;
        modules-left = "i3";
        modules-right = "cpu memory";
      };
    in
    {
      "bar/top" = bar-top;
      "bar/primary-top" = bar-top // {
        tray-position = "left";
      };
      "bar/bottom" = bar-bottom;
      "bar/primary-bottom" = bar-bottom;

      "module/cpu" = {
        type = "internal/cpu";
        interval = "0.5";
        format = "<label> <ramp-coreload>";
        label = "";

        ramp-coreload-0 = "▁";
        ramp-coreload-0-foreground = "#aaff77";
        ramp-coreload-1 = "▂";
        ramp-coreload-1-foreground = "#aaff77";
        ramp-coreload-2 = "▃";
        ramp-coreload-2-foreground = "#aaff77";
        ramp-coreload-3 = "▄";
        ramp-coreload-3-foreground = "#aaff77";
        ramp-coreload-4 = "▅";
        ramp-coreload-4-foreground = "#fba922";
        ramp-coreload-5 = "▆";
        ramp-coreload-5-foreground = "#fba922";
        ramp-coreload-6 = "▇";
        ramp-coreload-6-foreground = "#ff5555";
        ramp-coreload-7 = "█";
        ramp-coreload-7-foreground = "#ff5555";
      };

      "module/memory" = {
        type = "internal/memory";
        format = "<label> <bar-used>";
        label = "";

        bar-used-width = 30;
        bar-used-foreground-0 = "#aaff77";
        bar-used-foreground-1 = "#aaff77";
        bar-used-foreground-2 = "#fba922";
        bar-used-foreground-3 = "#ff5555";
        bar-used-indicator = "─";
        bar-used-indicator-foreground = "#ff";
        bar-used-fill = "─";
        bar-used-empty = "─";
        bar-used-empty-foreground = "#444444";
      };

      "module/date" = {
        type = "internal/date";
        # https://en.cppreference.com/w/cpp/io/manip/put_time
        date = "%%{F#AA}%Y-%m-%d%%{F-} %%{F#FF}%H:%M:%S%%{F-}";
      };

      "module/battery" = {
        type = "internal/battery";
        full-at = 98;

        battery = "BAT1";
        adapter = "ADP1";

        format-charging = "<animation-charging> <label-charging>";
        format-discharging = "<ramp-capacity> <label-discharging>";
        format-full = "<ramp-capacity> <label-full>";

        ramp-capacity-0 = ""; #"";
        ramp-capacity-0-foreground = "#f53c3c";
        ramp-capacity-1 = "";
        ramp-capacity-1-foreground = "#ffa900";
        ramp-capacity-2 = "";
        ramp-capacity-3 = "";
        ramp-capacity-4 = "";

        bar-capacity-width = 10;
        bar-capacity-format = "%{+u}%{+o}%fill%%empty%%{-u}%{-o}";
        bar-capacity-fill = "█";
        bar-capacity-fill-foreground = "#ddffffff";
        bar-capacity-empty = "█";
        bar-capacity-empty-foreground = "#44ffffff";

        animation-charging-0 = "";
        animation-charging-1 = "";
        animation-charging-2 = "";
        animation-charging-3 = "";
        animation-charging-4 = "";
        animation-charging-framerate = 750;
      };

      "module/wireless-network" = {
        type = "internal/network";
        interface = "wlp0s20f3";
        interval = "3.0";
        ping-interval = "10";

        format-connected = "直 <label-connected>";
        label-connected = "%essid% %local_ip%";
        label-disconnected = "睊 not connected";
        label-disconnected-foreground = "#66";

        animation-packetloss-0 = "_";
        animation-packetloss-0-foreground = "#ffa64c";
        animation-packetloss-1 = "-";
        animation-packetloss-1-foreground = "\${bar/top.foreground}";
        animation-packetloss-framerate = "200";
      };

      "module/wired-network" = {
        type = "internal/network";
        interface = "net0";
        interval = "3.0";

        label-connected = "   %{T3}%local_ip%%{T-}";
        label-disconnected-foreground = "#66";
      };

      "module/volume" = {
        type = "internal/pulseaudio";
        # sink = "alsa_output.pci-0000_00_1f.3.analog-stereo";
        use-ui-max = true;

        interval = -5;

        format-volume = "墳 <label-volume>";
        format-muted = "婢  <label-muted>";
        format-muted-foreground = "#66";
      };

      "module/backlight" = {
        type = "internal/backlight";
        card = "intel_backlight";

        format = " <label>";
        label = "%percentage%%";
      };

      "module/i3" = {
        type = "internal/i3";

        pin-workspaces = true;

        # ; This will split the workspace name on ':'
        # ; Default: false
        # strip-wsnumbers = true

        # ; Sort the workspaces by index instead of the default
        # ; sorting that groups the workspaces by output
        # ; Default: false
        index-sort = true;

        # ; Create click handler used to focus workspace
        # ; Default: true
        enable-click = false;

        # ; Create scroll handlers used to cycle workspaces
        # ; Default: true
        enable-scroll = false;

        # ; Wrap around when reaching the first/last workspace
        # ; Default: true
        # wrapping-scroll = false;

        # ; Set the scroll cycle direction 
        # ; Default: true
        # reverse-scroll = false;

        # ; Use fuzzy (partial) matching on labels when assigning 
        # ; icons to workspaces
        # ; Example: code;♚ will apply the icon to all workspaces 
        # ; containing 'code' in the label
        # ; Default: false
        fuzzy-match = true;


        label-focused = "%name%";
        label-focused-foreground = "#fff";
        label-focused-background = "#555";
        label-focused-underline = "#aaa";
        label-focused-padding = "1";

        label-visible = "%name%";
        label-visible-foreground = "#ddd";
        label-visible-background = "#333";
        label-visible-underline = "#999";
        label-visible-padding = "1";

        label-unfocused = "%name%";
        label-unfocused-foreground = "#999";
        label-unfocused-padding = "1";



        label-urgent = "%name%";
        label-urgent-foreground = "#000000";
        label-urgent-background = "#bd2c40";
        label-urgent-underline = "#9b0a20";
        label-urgent-padding = "1";
      };

      "module/menu" = {
        type = "custom/menu";

        format = "<label-toggle> <menu>";

        format-padding = 1;

        label-open = "襤";
        label-close = "";

        menu-0-0 = "Poweroff";
        menu-0-0-padding = 2;
        menu-0-0-exec = "poweroff";
        menu-0-1 = "Reboot";
        menu-0-1-padding = 2;
        menu-0-1-exec = "reboot";
        menu-0-2 = "Suspend";
        menu-0-2-padding = 2;
        menu-0-2-exec = "sudo systemctl suspend";
      };

      # "module/spotify" = {
      #   type = "custom/script";
      #   format = "<label>";
      #   exec = "${toRelativePath "scripts/scroll_spotify_status.sh"} ${toRelativePath "scripts/get_spotify_status.sh"}";
      # };

      # "module/spotify-prev" = {
      #   type = "custom/script";
      #   exec = "echo '玲'";
      #   format = "<label>";
      #   click-left = "playerctl previous spotify";
      # };

      # "module/spotify-play-pause" = {
      #   type = "custom/ipc";
      #   hook-0 = "echo '契'";
      #   hook-1 = "echo ''";
      #   initial = 1;
      #   click-left = "playerctl play-pause spotify";
      # };

      # "module/spotify-next" = {
      #   type = "custom/script";
      #   exec = "echo '怜'";
      #   format = "<label>";
      #   click-left = "playerctl next spotify";
      # };
    };
}

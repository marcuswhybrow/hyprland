{ pkgs, inputs, ... }: let 
  alacritty = "${inputs.alacritty.packages.x86_64-linux.alacritty}/bin/alacritty";
  private = "${inputs.private.packages.x86_64-linux.private}/bin/private";
  logout = "${inputs.logout.packages.x86_64-linux.logout}/bin/logout";
  drun = "${inputs.rofi.packages.x86_64-linux.drun}/bin/drun";
  waybar = "${inputs.waybar.packages.x86_64-linux.waybar}/bin/waybar";
  volume = "${inputs.volume.packages.x86_64-linux.volume}/bin/volume";
  brightness = "${inputs.brightness.packages.x86_64-linux.brightness}/bin/brightness";
  pcmanfm = "${pkgs.pcmanfm}/bin/pcmanfm";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  assets = pkgs.stdenv.mkDerivation {
    name = "hyprland-assets";
    src = ./assets;
    installPhase = ''
      mkdir --parents $out
      cp --recursive * $out
    '';
  };
  find = "${pkgs.findutils}/bin/find";
  xargs = "${pkgs.findutils}/bin/xargs";
  sort = "${pkgs.coreutils}/bin/sort";
  tail = "${pkgs.coreutils}/bin/tail";
  swaybg = "${pkgs.swaybg}/bin/swaybg";
  wallpaper = pkgs.writeShellScript "randomise-wallpaper.sh" ''
    ${find} ${assets}/wallpapers -type f \
      | ${sort} --random-sort \
      | ${tail} --lines 1 \
      | ${xargs} ${swaybg} --output '*' --mode center --image
  '';
in ''

monitor=,preferred,auto,auto
monitor=eDP-1,1920x1080@60,0x0,1

env = XCURSOR_SIZE,24

input {
    kb_layout = gb
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    repeat_delay = 200
    repeat_rate = 40

    follow_mouse = 1

    touchpad {
        natural_scroll = yes
        disable_while_typing = false
    }

    sensitivity = 0 # as-is
}

general {
    gaps_in = 1
    gaps_out = 20
    border_size = 0
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
    allow_tearing = false
}

decoration {
    rounding = 4
    active_opacity = 1.0
    inactive_opacity = 1.0
    fullscreen_opacity = 1.0
    
    blur {
        enabled = true
        size = 5
        passes = 4
        xray = false
    }

    drop_shadow = no
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    bezier = easeOutCubic, 0.33, 1, 0.86, 1

    animation = windows, 1, 0.7, easeOutCubic
    animation = windowsIn, 1, 0.7, easeOutCubic
    animation = windowsOut, 1, 0.7, easeOutCubic, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 1, default
    animation = workspaces, 1, 2, default
}

dwindle {
    pseudotile = yes 
    preserve_split = yes 
}

master {
    new_is_master = true
}

gestures {
    workspace_swipe = off
}

misc {
    force_default_wallpaper = 0
}

device:epic-mouse-v1 {
    sensitivity = -0.5
}

$mainMod = ALT

bind = $mainMod, Q, exec, ${alacritty}
bind = $mainMod, RETURN, exec, ${alacritty}
bind = $mainMod SHIFT, RETURN, exec, ${private}
bind = $mainMod, ESCAPE, exec, bash ${logout}
bind = $mainMod SHIFT, Q, killactive, 
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, ${pcmanfm}
bind = $mainMod, V, togglefloating, 
bind = $mainMod, D, exec, ${drun}
bind = $mainMod, P, pseudo, 
bind = $mainMod, J, togglesplit, 
bind = $mainMod, F, fullscreen

bind = $mainMod, h, movefocus, l
bind = $mainMod, l, movefocus, r
bind = $mainMod, k, movefocus, u
bind = $mainMod, j, movefocus, d

bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

bind = $mainMod SHIFT, H, movewindow, l
bind = $mainMod SHIFT, L, movewindow, r
bind = $mainMod SHIFT, J, movewindow, d
bind = $mainMod SHIFT, K, movewindow, u

bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

exec-once = bash ${wallpaper}
exec-once = ${waybar}

binde = , XF86AudioLowerVolume, exec, ${volume} down
bind = , XF86AudioMute, exec, ${volume} toggle-mute
binde = , XF86AudioRaiseVolume, exec, ${volume} up
binde = , XF86MonBrightnessDown, exec, ${brightness} down
binde = , XF86MonBrightnessUp, exec, ${brightness} up

bind = , XF86AudioPlay, exec, ${playerctl} play-pause
bind = , XF86AudioNext, exec, ${playerctl} next
bind = , XF86AudioPrev, exec, ${playerctl} prev
bind = SHIFT, XF86AudioNext, exec, ${playerctl} position 5+
bind = SHIFT, XF86AudioPrev, exec, ${playerctl} position 5-

bind = SUPER, K, exec, ${playerctl} play-pause
bind = SUPER, J, exec, ${playerctl} position 1-
bind = SUPER, L, exec, ${playerctl} position 1+
bind = SUPER_SHIFT, J, exec, ${playerctl} position 5-
bind = SUPER_SHIFT, L, exec, ${playerctl} position 5+

bind = , PRINT, exec, hyprshot -m output --current --silent
''

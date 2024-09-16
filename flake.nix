{
  description = "Hyprland (window manager) configured by Marcus";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    alacritty.url = "github:marcuswhybrow/alacritty";
    private.url = "github:marcuswhybrow/private";
    logout.url = "github:marcuswhybrow/logout";
    rofi.url = "github:marcuswhybrow/rofi";
    waybar.url = "github:marcuswhybrow/waybar";
    volume.url = "github:marcuswhybrow/volume";
    brightness.url = "github:marcuswhybrow/brightness";

    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    mwpkgs = inputs.mwpkgs.packages.x86_64-linux;
    confText = import ./hyprland.conf.nix { inherit pkgs inputs mwpkgs; };
    conf = pkgs.writeText "hyprland.conf" confText;

    wrapper = pkgs.runCommand "hyprland-wrapper" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir --parents $out/share/hyprland
      ln --symbolic ${conf} $out/share/hyprland/hyprland.conf

      makeWrapper ${pkgs.hyprland}/bin/Hyprland $out/bin/Hyprland \
        --add-flags "--config $out/share/hyprland/hyprland.conf"
    '';
  in {
    packages.x86_64-linux.hyprland = pkgs.symlinkJoin {
      name = "hyprland";
      paths = [ 
        wrapper 
        pkgs.hyprland 
      ];
      meta.description = "Hyprland launched with Marcus' `--config` in the nix store";
    };

    packages.x86_64-linux.fish-auto-login = pkgs.writeTextDir "share/fish/vendor_conf.d/hyprland.fish" ''
      if status is-login
        ${inputs.self.packages.x86_64-linux.hyprland}/bin/Hyprland
      end
    '';

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.hyprland;

    apps.x86_64-linux.default = {
      type = "app";
      program = "${inputs.self.packages.x86_64-linux.hyprland}/bin/Hyprland";
    };
  };
}

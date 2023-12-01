{
  description = "Hyprland (window manager) configured by Marcus";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    alacritty = {
      url = "github:marcuswhybrow/alacritty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private = {
      url = "github:marcuswhybrow/private";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        alacritty.follows = "alacritty";
      };
    };
    logout = {
      url = "github:marcuswhybrow/logout";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rofi.follows = "rofi";
      };
    };
    rofi = {
      url = "github:marcuswhybrow/rofi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waybar = {
      url = "github:marcuswhybrow/waybar";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        alacritty.follows = "alacritty";
        logout.follows = "logout";
        # networking.inputs = {
        #   nixpkgs.follows = "nixpkgs";
        #   rofi.follows = "rofi";
        # };
        # nixpkgs-updates.inputs.nixpkgs.follows = "nixpkgs";
        rofi.follows = "rofi";
      };
    };
    volume = {
      url = "github:marcuswhybrow/volume";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brightness = {
      url = "github:marcuswhybrow/brightness";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    confText = import ./hyprland.conf.nix { inherit pkgs inputs; };
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
      paths = [ wrapper pkgs.hyprland ];
      meta.description = "Hyprland launched with Marcus' `--config` in the nix store";
    };

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.hyprland;

    apps.x86_64-linux.default = {
      type = "app";
      program = "${inputs.self.packages.x86_64-linux.hyprland}/bin/Hyprland";
    };
  };
}

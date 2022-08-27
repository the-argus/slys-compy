{
  description = "mae's laptop :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-22.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    webcord = {
      url = "github:fufexan/webcord-flake";
    };

    rycee-expressions = {
      url = "gitlab:rycee/nur-expressions";
      flake = false;
    };

    spicetify-nix = {
      url = "github:the-argus/spicetify-nix";
    };

    # non-nix imports (need fast updates):
    nvim-config = {
      url = "github:the-argus/nvim-config";
      flake = false;
    };

    arkenfox-userjs = {
      url = "github:arkenfox/user.js";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , home-manager
    , webcord
    , rycee-expressions
    , spicetify-nix
    , nvim-config
    , arkenfox-userjs
    , ...
    }@inputs:
    let
      allowedUnfree = [
        "spotify-unwrapped"
        "steam"
        "steam-original"
      ];

      system = "x86_64-linux";
      username = "sly";
      hostname = "maes-laptop";
      homeDirectory = "/home/${username}";

      pkgsInputs =
        {
          config = {
            allowUnfreePredicate =
              pkg: builtins.elem (pkgs.lib.getName pkg) allowedUnfree;
          };
          localSystem = {
            inherit system;
          };
        };

      pkgs = import nixpkgs pkgsInputs;
      unstable = import nixpkgs-unstable pkgsInputs;
      firefox-addons = (import "${rycee-expressions}" { inherit pkgs; }).firefox-addons;

      plymouth = let name = "rings"; in
        {
          themeName = name;
          themePath = "pack_4/${name}";
        };

      overlays = [
        (self: super: {
          plymouth-themes-package = import ./packages/plymouth-themes.nix ({
            inherit pkgs;
          } // plymouth);
        })

        (self: super: {
          gnome = super.gnome.overrideScope' (selfg: superg: {
            gnome-shell = superg.gnome-shell.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                (pkgs.substituteAll {
                  src = ./packages/patches/gnome-shell_3.38.3-3ubuntu1_3.38.3-3ubuntu2.patch;
                })
              ];
            });
          });
        })
      ];
    in
    {
      nixosConfigurations = {
        ${hostname} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs // {
            inherit unstable plymouth hostname username;
          };
          modules = [
            {
              nixpkgs.overlays = overlays;
              imports = [ ./system/configuration.nix ];
            }
          ];
        };
      };

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        inherit system username homeDirectory;
        configuration = { pkgs, ... }: {
          imports = [ ./user ];
          nixpkgs.overlays = overlays;
        };
        stateVersion = "22.05";
        extraSpecialArgs = inputs // {
          inherit unstable homeDirectory firefox-addons hostname username;
        };
      };

      devShell.${system} = pkgs.mkShell { };
    };
}

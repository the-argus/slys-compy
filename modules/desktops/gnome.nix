{ config, options, unstable, pkgs, lib, username, ... }:
let
  cfg = config.desktops.gnome;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.desktops.gnome = {
    enable = mkEnableOption "Gnome Desktop Environment";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      [com.ubuntu.login-screen]
      background-repeat='no-repeat'
      background-size='cover'
      background-color='#777777'
      background-picture-uri='file:///home/${username}/.local/GDM.png'
    '';
    desktops.wayland.enable = true;

    programs.dconf.enable = true;

    xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gnome ];

    environment.systemPackages = with pkgs.gnomeExtensions; [
      appindicator
      # unstable.gnomeExtensions.transparent-window
      # compiz-alike-windows-effect
      # compiz-windows-effect
      # desktop-cube
      burn-my-windows
      blur-my-shell
      just-perfection
      unstable.gnomeExtensions.keep-awake
      dash-to-panel
      gesture-improvements
      no-titlebar-when-maximized
      gtk-title-bar
      # desktop-icons-neo
      desktop-icons-ng-ding
      (pkgs.callPackage ../../packages/fly-pie { })
    ] ++ (with pkgs; [
      # maui apps (replacements for evince, totem, and gedit respectively
      # shelf
      # clip
      # nota
      # index-fm
      gnome.file-roller
      gnome.nautilus
      gnome.sushi
      gnome.gnome-terminal
      gnome-photos
      gnome.evince
      gnome.totem
      gnome.gedit
      gnome.gnome-disk-utility
      gnome.gnome-tweaks
    ]) ++ (
      # nemo and extensions
      let
        mkNemoExt = debname: extname: (pkgs.stdenv.mkDerivation {
          pname = extname;
          version = "mint20";
          src = pkgs.fetchurl {
            url = "https://github.com/linuxmint/nemo-extensions/releases/download/master.mint20/packages.tar.gz";
            sha256 = "0csama3p3jrr6ixz2xxwa8l3mp2xm4x2aj4abzi3bfahi34zj23x";
          };
          nativeBuildInputs = with pkgs; [ binutils ];
          unpackPhase = ''
            tar -xf $src
            ar x packages/${debname}
            tar -xf data.tar.xz
          '';
          installPhase = ''
            mkdir $out
            if [[ -d usr/share ]]; then
                cp -r usr/share $out
            fi
            if [[ -d usr/lib ]]; then
                cp -r usr/lib/x86_64-linux-gnu $out/lib
            fi
          '';
        });
      in
      [
        # pkgs.cinnamon.nemo
        # (mkNemoExt "nemo-fileroller_4.8.0_amd64.deb" "fileroller")
        # (mkNemoExt "nemo-image-converter_4.8.0_amd64.deb" "image-converter")
      ]
    );

    hardware.pulseaudio.enable = false;

    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-text-editor
      gnome-console
      gnome-usage
      gnome-connections
      gnome-secrets
    ]) ++ (with pkgs.gnome; [
      gnome-logs
      gnome-disk-utility
      gnome-weather
      gnome-clocks
      gnome-maps
      gnome-contacts
      nautilus
      gnome-terminal
      cheese # webcam tool
      gnome-music
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);
  };
}

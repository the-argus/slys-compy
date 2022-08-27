{ pkgs, unstable, lib, webcord, ... }: {
  imports = [
    ./config # configures *everything* that can't be done in nix
    ./local
    ./zsh.nix
    ./git.nix
    ./gtk
    ./firefox.nix
    ./alacritty.nix
    ./kitty.nix
    ./spicetify.nix
    ./webcord
  ];

  programs.chromium = {
    enable = true;
    # package = pkgs.callPackage ../../packages/ungoogled-chromium {};
    package = unstable.ungoogled-chromium;
  };

  # extra packages
  home.packages = with pkgs; [
    steam
    # unfree :(
    # slack
    # discord
    # spotify-unwrapped
    (webcord.packages.${unstable.system}.default)
    # lutris

    # gui applications---------
    obs-studio
    gnome.gnome-calculator
    unstable.heroic
    polymc
    pavucontrol
    # sxiv
    mpv
    # zathura
    # qpwgraph
    # qdirstat

    pinta
    inkscape

    # tui
    cava

    # cli
    transmission
    unstable.ani-cli

    # dev
    rnix-lsp

    # appearance
    # rose-pine-gtk-theme
    # paper-gtk-theme # Paper
    # Icons: Lounge-aux
    # Themes: Lounge Lounge-compact Lounge-night Lounge-night-compact
    # lounge-gtk-theme
    # juno-theme # Juno Juno-mirage Juno-ocean Juno-palenight
    # graphite-gtk-theme # Graphite Graphite-dark Graphite-light Graphite-dark-hdpi Graphite-hdpi ....

    # paper-icon-theme
    # zafiro-icons
    # pantheon.elementary-icon-theme
    # material-icons
    # numix-cursor-theme # Numix-Cursor Numix-Cursor-Light
    # capitaine-cursors
  ];
}

{ config, pkgs, lib, unstable, username, hostname, ... }:

{
  #choose what host is being used (laptop or pc)
  imports = [
    ../modules
    ./hardware-configuration.nix
  ];

  desktops.enable = true;
  desktops.gnome.enable = true;
  desktops.openbox.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # kernel version
  # boot.kernelPackages = unstable.linuxPackages_latest;
  boot.kernelPackages = unstable.linuxPackages_zen;
  # boot.kernelPackages = unstable.linux_xanmod_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi = {
    canTouchEfiVariables = true;
    efiSysMountPoint = "/boot/efi";
  };

  networking.networkmanager.enable = true;
  networking.hostName = hostname;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # enable nix flakes
  nix = {
    package = pkgs.nixFlakes;
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-old";
    # };
    settings = {
      extra-experimental-features = [ "nix-command" "flakes" ];
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "systemd-network"
      "networkmanager"
      "plugdev"
    ];
  };

  environment.pathsToLink = [ "/share/zsh" ];

  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal
    ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  environment.systemPackages = with pkgs; [
    # tui applications
    ranger
    unstable.neovim
    htop
    lynx

    # cli applications
    neofetch
    cmatrix
    zip
    unzip
    wget
    curl
    ffmpeg
    direnv
    nix-direnv-flakes

    # util
    git
    home-manager
    polkit
    usbutils
    nix-index
    alsa-utils
    ix
    killall
    pciutils
  ];

  #system.copySystemConfiguration = true;
  system.stateVersion = "22.05";
}


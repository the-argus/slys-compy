{ pkgs, ... }:
let
  cfg = config.desktops.openbox;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.desktops.openbox = {
    enable = mkEnableOption "Openbox Window Manager";
  };

  config = mkIf cfg.enable {
    desktops.wayland.enable = true;
    services.xserver.windowManager.openbox.enable = true;
    environment.systemPackages = with pkgs; [
      obconf
      rofi

      # picom fork
      (pkgs.picom.overrideAttrs (finalAttrs: previousAttrs: {
        src = pkgs.fetchgit {
          url = "https://github.com/Arian8j2/picom-jonaburg-fix";
          rev = "31d25da22b44f37cbb9be49fe5c239ef8d00df12";
          sha256 = "0vkf4azs2xr0j03vkmn4z9ll4lw7j8s2k0rdsfw630hd78l1ngnp";
        };
      }))
    ];
  };
}

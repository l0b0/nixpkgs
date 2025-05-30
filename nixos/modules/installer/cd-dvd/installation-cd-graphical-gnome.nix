# This module defines a NixOS installation CD that contains GNOME.

{ lib, ... }:

{
  imports = [ ./installation-cd-graphical-base.nix ];

  isoImage.edition = lib.mkDefault "gnome";

  services.desktopManager.gnome = {
    # Add Firefox and other tools useful for installation to the launcher
    favoriteAppsOverride = ''
      [org.gnome.shell]
      favorite-apps=[ 'firefox.desktop', 'nixos-manual.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'gparted.desktop' ]
    '';
    enable = true;
  };

  services.displayManager.gdm = {
    enable = true;
    # autoSuspend makes the machine automatically suspend after inactivity.
    # It's possible someone could/try to ssh'd into the machine and obviously
    # have issues because it's inactive.
    # See:
    # * https://github.com/NixOS/nixpkgs/pull/63790
    # * https://gitlab.gnome.org/GNOME/gnome-control-center/issues/22
    autoSuspend = false;
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };
}

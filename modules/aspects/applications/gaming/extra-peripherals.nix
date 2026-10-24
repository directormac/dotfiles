# Hardware Steam & Gamepad Udev Rules Aspect
{
  den.aspects.applications.gaming.extra-peripherals = {
    nixos =
      { lib, ... }:
      {
        hardware.steam-hardware.enable = lib.mkDefault true;
        # USB wire or official Xbox Wireless USB Dongle: modern xone driver
        hardware.xone.enable = lib.mkDefault true;
        # Bluetooth: xpadneo fixes the infamous Linux Bluetooth ERTM bug (pairing loops)
        # and enables trigger rumble + correct button mappings
        hardware.xpadneo.enable = lib.mkDefault true;
      };

    # The pinned nixpkgs xpad-noone package installs the .ko by hand instead of
    # going through `modules_install`, so it never emits the module signing
    # certificate. The kernel module aggregator concatenates every .ko.cer and
    # fails with `cat: .../xpad-noone.ko.cer: No such file or directory`.
    # Build it through `modules_install` like xone/xpadneo (same fix as nixpkgs master).
    nixpkgs-overlays = _: [
      (_final: prev: {
        linuxPackages_latest = prev.linuxPackages_latest.extend (
          _kfinal: kprev: {
            xpad-noone = kprev.xpad-noone.overrideAttrs (old: {
              installFlags = [
                "-C"
                "${kprev.kernel.dev}/lib/modules/${kprev.kernel.modDirVersion}/build"
                "M=$(PWD)"
              ];

              installPhase = null;
              installTargets = [ "modules_install" ];

              makeFlags = (old.makeFlags or [ ]) ++ [
                "KERNEL_SRC=${kprev.kernel.dev}/lib/modules/${kprev.kernel.modDirVersion}/build"
                "INSTALL_MOD_PATH=${placeholder "out"}"
                "INSTALL_MOD_DIR=kernel/drivers/xpad-noone"
              ];
            });
          }
        );
      })
    ];
  };
}

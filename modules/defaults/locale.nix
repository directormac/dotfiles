# [locale.nix](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/config/locale.nix)
{
  # [i18n](https://search.nixos.org/options?channel=unstable&query=i18n&source=home_manager&type=options)
  den.default.nixos.i18n.defaultLocale = "en_US.UTF-8";

  # [time](https://search.nixos.org/options?channel=unstable&query=time&type=options)
  den.default.nixos.time.timeZone = "Europe/Amsterdam";
}

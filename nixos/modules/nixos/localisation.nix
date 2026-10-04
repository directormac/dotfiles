{
  flake.nixosModules.base = {

    # Set your time zone.
    time.timeZone = "Asia/Manila";

    # English messages and date/number formats, Manila clock.
    i18n.defaultLocale = "en_US.UTF-8";
  };
}

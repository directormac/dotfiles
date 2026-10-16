# Core Locale & Timezone Aspect
{
  den.aspects.core.locale = {
    nixos =
      { lib, ... }:
      {
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
        time.timeZone = lib.mkDefault "Asia/Manila";
      };
  };
}

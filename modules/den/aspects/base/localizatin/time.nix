{
  den.aspects.base.localization.time = {
    os = {environment, ...}: {
      time.timeZone = environment.timezone or "UTC";
    };
  };
}

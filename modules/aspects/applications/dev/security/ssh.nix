# SSH Client Aspect
_:
{
  den.aspects.applications.dev.security.ssh = {
    homeManager = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };
    };
  };
}

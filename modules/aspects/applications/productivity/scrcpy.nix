# scrcpy & Android Tools Aspect
{ den, ... }:
{
  den.aspects.applications.productivity.scrcpy = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          android-tools
          scrcpy
        ];
      };
  };
}

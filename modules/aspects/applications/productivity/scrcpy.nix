# scrcpy & Android Tools Aspect
_:
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

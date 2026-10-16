# scrcpy & Android Tools Aspect
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

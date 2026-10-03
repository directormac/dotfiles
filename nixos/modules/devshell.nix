{
  perSystem =
    {
      config,
      pkgs,
      self',
      ...
    }:
    {
      devshells.default = {
        packages = [
          config.agenix-rekey.package
          pkgs.rage
          self'.packages.yazi
          self'.packages.nh
        ];

        commands = [
          {
            name = "age";
            command = "rage \"$@\"";
            help = "alias for rage";
          }
        ];

        env = [
          {
            name = "YAZI_CONFIG_HOME";
            eval = "$([ -d \"$PRJ_ROOT/config/yazi\" ] && echo \"$PRJ_ROOT/config/yazi\" || echo \"$PRJ_ROOT/../config/yazi\")";
          }
        ];
      };
    };
}

{den, ...}: {
  den.aspects.root = {config, ...}: {
    includes = [
      den.aspects.tools.provides.nix-trusted-user
    ];

    user = {
      initialPassword = "id";
      openssh.authorizedKeys.keys = config.meta.authorizedKeys;
    };

    meta = {
      authorizedKeys = [];
    };
  };
}

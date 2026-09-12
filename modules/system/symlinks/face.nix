let
  symlinkName = ".face";
in {
  den.ful.academia.symlink.homeManager = {config, ...}: {
    home.file.${symlinkName}.source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}";
  };
}

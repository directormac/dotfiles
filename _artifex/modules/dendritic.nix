{
  den,
  inputs,
  ...
}:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  # [Docs](https://den.denful.dev/guides/angle-brackets/)
  # [den-brackets.nix](https://github.com/denful/den/blob/main/nix/lib/den-brackets.nix)
  # In any file where you want to use the angle-brackets syntax,
  # add __findFile to the arguments attrset to bring it into that module’s lexical scope.

  # ```nix
  #  { den, __findFile, ... }: {
  #     ...
  #  }
  # ```
  # You can include it in the aspects includes after like
  #
  # <core/shell>
  # <den/primary-user>
  #
  #
  _module.args.__findFile = den.lib.__findFile;
}

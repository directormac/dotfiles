{ inputs, ... }: {
  imports = [
    # You can have several namespaces,
    # - true: exposes flake.denful.yours
    # - false: Not flake exposed.

    # You can also mixin from several inputs.
    # Just keep in mind that a namespace can be defined only once, use an array as argument:
    # (inputs.den.namespace "ours" [
    #   true
    #   inputs.mine
    #   inputs.theirs
    # ])

    # Reference https://den.denful.dev/guides/namespaces/

    # create local `core` (artifex's nix, also an antelope) namespace. false: not flake exposed.
    (inputs.den.namespace "core" false)
  ];
}

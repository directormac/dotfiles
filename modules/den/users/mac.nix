{den, ...}: {
  den.aspects.mac = {
    includes = [
      den.batteries.host-aspects
      den.aspects.base.nix.stateVersion
      den.aspects.tools.provides.nix-trusted-user
    ];
  };

  den.users.registry.mac = {
    system.uid = 1000;
    system.linger = true; # always-on per-user Syncthing daemon (replicateHome)
    groups = [
      "admins"
      # "users"
      "workstationc-access"
      "system-access"
      "libvirtd"
      "kvm"
    ];

    settings.git.signing.method = "ssh";
    settings.bitwarden.email = "markasena@gmail.com";

    identity = {
      displayName = "Mac Asena";

      email = "mac@mkra.dev";

      # opkssh: which kanidm OIDC identities may log in as this unix account.
      # The human's SSO login is the `json` identity-only person (json@json64.dev,
      # admins — see identity-only.nix), a DIFFERENT kanidm resource than the `sini`
      # unix-user person (jason@). The default would only map sini's own email, so
      # `opkssh login` (which authenticates as `json`) would be rejected. Authorize
      # both of Jason's kanidm identities to assume the `sini` unix account.
      # sshOidcPrincipals = [
      # ];

      sshKeys = [
      ];
    };
  };
}

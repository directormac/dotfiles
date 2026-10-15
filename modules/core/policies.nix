# Policies: define entity relations and data flow routing
{ den, ... }:
{
  # Expose user-contributed nixpkgs-overlays to the host scope when sharing global pkgs
  den.policies.project-user-overlays =
    { user, host, ... }:
    [
      (den.lib.policy.pipe.from "nixpkgs-overlays" [ den.lib.policy.pipe.expose ])
    ];

  den.schema.user.includes = [ den.policies.project-user-overlays ];
}

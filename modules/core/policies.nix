# Policies: define entity relations and data flow routing
{ den, ... }:
{
  # Expose user-contributed system quirks up to the host scope (see guides/quirks-cross-scope.mdx)
  den.policies.project-user-quirks =
    _:
    let
      inherit (den.lib.policy) pipe;
    in
    map (q: pipe.from q [ pipe.expose ]) [
      "nixpkgs-overlays"
      "persist"
      "cache"
      "firewall"
      "secrets"
    ];

  den.schema.user.includes = [ den.policies.project-user-quirks ];
}

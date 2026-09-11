/**
  [sops-nix](https://github.com/mic92/sops-nix)
SOPS-NIX integration: manages encrypted secrets via age encryption.
Host SSH keys are used for automatic decryption at boot time.
Secrets are stored in secrets.yaml (encrypted) in the repo root.
*/
{inputs, ...}: {
  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  den.aspects.sops.nixos = {
    imports = [inputs.sops-nix.nixosModules.sops];
    sops = {
      defaultSopsFile = ../../secrets.yaml;
      age = {
        # Use the host's SSH host key for decryption
        sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
        # Fallback key file (auto-generated if missing)
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
      secrets = {
        # Cloudflare dns api token
        "cloudflare-dns-api-token" = {};

        # WireGuard server private key
        "vpn-server/key" = {};

        # WireGuard client keys
        "vpn-clients/super" = {};
        "vpn-clients/phone" = {};

        # Syncthing device identities on different hosts
        "syncthing-hosts/super/key" = {};
        "syncthing-hosts/super/cert" = {};
      };
    };
  };
}

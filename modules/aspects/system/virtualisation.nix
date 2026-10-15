# Virtualisation & Containerization Aspect: Podman, Libvirt, Virt-Manager
{ core, lib, ... }:
{
  core.virtualisation-tools = {
    nixos =
      { pkgs, lib, ... }:
      {
        virtualisation.podman = {
          enable = lib.mkDefault true;
          dockerCompat = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
          };
        };

        virtualisation.libvirtd = {
          enable = lib.mkDefault true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;
          };
        };

        programs.virt-manager.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          podman-compose
          lazydocker
          virt-viewer
          spice
          spice-gtk
        ];

        boot.kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
        };

        networking.firewall.trustedInterfaces = [
          "virbr0"
        ];
      };
  };

  # Attach to workstation aspect
  core.workstation.includes = [
    core.virtualisation-tools
  ];
}

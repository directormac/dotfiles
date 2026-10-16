# Virtualization Libvirt / QEMU / Virt-Manager Leaf Aspect
{
  den.aspects.virtualization.libvirt = {
    nixos =
      { lib, pkgs, ... }:
      {
        boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault 1;

        environment.systemPackages = with pkgs; [
          dnsmasq
          virt-viewer
          spice
          spice-gtk
          spice-protocol
        ];

        networking.firewall.trustedInterfaces = [
          "virbr0"
        ];

        programs.virt-manager.enable = lib.mkDefault true;

        virtualisation.libvirtd = {
          enable = lib.mkDefault true;

          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;

            verbatimConfig = ''
              graphics_provider = "spice"
            '';

            vhostUserPackages = with pkgs; [ virtiofsd ];
          };
        };
      };
  };
}

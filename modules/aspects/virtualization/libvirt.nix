# Virtualization Libvirt / QEMU / Virt-Manager Leaf Aspect
{ den, ... }:
{
  den.aspects.virtualization.libvirt = {
    nixos =
      { lib, pkgs, ... }:
      {
        virtualisation.libvirtd = {
          enable = lib.mkDefault true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;
            vhostUserPackages = with pkgs; [ virtiofsd ];
            verbatimConfig = ''
              graphics_provider = "spice"
            '';
          };
        };

        programs.virt-manager.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          dnsmasq
          virt-viewer
          spice
          spice-gtk
          spice-protocol
        ];

        boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault 1;

        networking.firewall.trustedInterfaces = [
          "virbr0"
        ];
      };
  };
}

{
  /**

  Will not opt out for now choosing betweeen options

  - [systemd-boot](https://www.freedesktop.org/wiki/Software/systemd/systemd-boot/)
  - [lanzaboote](https://nix-community.github.io/lanzaboote/)
  - [liminse](https://github.com/Limine-Bootloader/Limine/blob/v12.x/INSTALL.md)
  - [grub](https://wiki.nixos.org/wiki/GNU_GRUB)

  */
}
# {inputs, ...}: {
#   flake-file.inputs = {
#     lanzaboote.url = "github:nix-community/lanzaboote/v0.4.3";
#     lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
#   };
#
#   den.ful.hardware.secureboot.nixos = {
#     imports = [
#       inputs.lanzaboote.nixosModules.lanzaboote
#     ];
#
#     boot.lanzaboote = {
#       enable = true;
#       pkiBundle = "/var/lib/sbctl";
#     };
#   };
# }

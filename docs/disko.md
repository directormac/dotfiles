# diskooo

disko is amazing because it is fundamentally declarative—it already acts exactly like an aspect! Because disks
are tied to hardware, the best strategy is to create reusable disk "layouts" that your hosts can inherit.

Here is the ideal strategy for disko in your architecture:

1. Add the Input:
   Add disko to your flake.nix inputs.
1. Make the Module Globally Available:
   Create a baseline aspect for all your NixOS hosts that includes the disko NixOS module so the system knows how
   to read disko.devices: # modules/aspects/host-baseline.nix

```nix
{ inputs, den, ... }: {
den.aspects.host-baseline = {

# This imports the Disko NixOS module into your system evaluation

nixos.imports = [ inputs.disko.nixosModules.default ];
};
}
```

3. Create Reusable Disk Layouts as Aspects:
   Instead of writing the disk layout directly in the host file, create reusable aspects for different types of
   layouts. # modules/aspects/disks/btrfs-luks.nix

```nix
{ den, ... }: {
den.aspects.disks.btrfs-luks = {

# Disko configuration natively goes under the `ixos` class

nixos.disko.devices = {
disk.main = { # ... your complex disk layout here ...
};
};
};
}
```

4. Assign the Layout to a Host:
   When you create a new future host, you simply include the baseline and the specific disk layout you want: # modules/hosts/my-laptop.nix

```nix

{ den, ... }: {
den.aspects.host.my-laptop = {
includes = [
den.aspects.host-baseline
den.aspects.disks.btrfs-luks
];

# ... other laptop-specific config ...

};
}
```

This keeps your host files incredibly clean, lets you share complex partitioning logic across multiple machines
safely, and perfectly utilizes the den aspect system!

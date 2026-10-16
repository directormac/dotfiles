# Hardware Graphics NVIDIA Prime Leaf Aspect
{ den, ... }:
{
  den.aspects.hardware.graphics.nvidia-prime = {
    includes = [
      den.aspects.hardware.graphics.nvidia
    ];

    nixos =
      { lib, ... }:
      {
        # Prime render offload helper command
        hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkDefault true;
      };
  };
}

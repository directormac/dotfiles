{ self, inputs, ...}: {

  
  flake.nixosModules.noctalia = { pkgs, lib, ... }: {
  	programs.noctalia = {
	   enable = true;
	};
  };

  # perSystem = { pkgs, ... }: {
  #
  #
  #
  # };
  
	#  perSystem = { pkgs, ... }: {
	#    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia.wrap {
	# inherit pkgs;
	# # settings = 
	# #     (builtins.fromTOML
	# # 	(builtins.readFile ./noctalia.toml));	
	# settings = {
	#
	#
	# };
	#    };
	#  };
}

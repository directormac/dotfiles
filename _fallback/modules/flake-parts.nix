{
  inputs,
  self,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.flakeModules.home-manager

    inputs.wrappers.flakeModules.wrappers
  ];

  systems = [
    "x86_64-linux"
  ];

  # This is your system configuration entry-point
  flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hardware
      self.nixosModules.nixosModule

      self.nixosModules.base
      self.nixosModules.core
      self.nixosModules.desktop
    ];
  };

  # This is your standalone home-manager configuration, meant to be used on non-nixos machines
  # with the home-manager command
  flake.homeConfigurations.home = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    modules = [
      self.homeModules.homeModule
      self.homeModules.git
      self.homeModules.lazyvim

      {
        home.username = config.preferences.user.name;
        home.homeDirectory = "/home/${config.preferences.user.name}";
      }
    ];
  };

  perSystem = { pkgs, ... }: {

    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        # vim

        ((vim-full.override { }).customize {
          name = "vim";
          # Install plugins for example for syntax highlighting of nix files
          vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
            start = [
              vim-nix
              vim-lastplace
            ];
            opt = [ ];
          };
          vimrcConfig.customRC =
            # vim
            ''
              " your custom vimrc
              filetype plugin indent on
              set expandtab
              set shiftwidth=4
              set softtabstop=4
              set tabstop=4
              set number
              set relativenumber
              set smartindent
              set showmatch
              set backspace=indent,eol,start
              syntax on
              " ...
            '';
        })

        yazi

        nixfmt
      ];
    };

  };

}

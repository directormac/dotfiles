{ config, pkgs, ...}:
{
	
	home.username = "artifex";
	home.homeDirectory = "/home/artifex";

	home.pointerCursor = {
	      name = "Adwaita";
	      package = pkgs.adwaita-icon-theme;
	      size = 24;
	      x11 = {
		enable = true;
		defaultCursor = "Adwaita";
	      };
	    };

	    home.sessionVariables = {
	    	EDITOR = "nvim";
	    };


	home.packages = with pkgs; [
		zip
		xz
		unzip
		curl
		# neovim
		ripgrep
		jq
		fzf
		lsd
		bat
		mtr
		dnsutils
		ldns
		aria2
		socat
		nmap
		which
		tree
		zstd
		gnupg
		btop
		iotop
		iftop
		zoxide
		starship

		alacritty

		firefox

		gh

		lazygit
		pavucontrol


		swaylock
		swayidle
		#swaync
		wl-clipboard
		mako
		grim
		slurp
		dmenu
		wlogout
		fuzzel
		fuzzel

		xfce.thunar
	];

	programs.neovim = {
	  enable = true;
	  vimAlias = true;
	  vimdiffAlias = true;
	  withNodeJs = true;
	};


	programs.git = {
		enable = true;
		userName = "Mark Asena";
		userEmail = "mac@mkra.dev";
	};

        programs.ssh = {
          enable = true;
          addKeysToAgent = "yes";  # This replaces startAgent which isn't available in home-manager
        };

	xsession.windowManager.i3 = {
	  enable = true;
	  config = {
	    modifier = "Mod4";
	  };
	};

	xdg.configFile.".config/sway/config".source = ".config/sway/config";

	
	wayland.windowManager.sway = {
	 enable = true;
	 wrapperFeatures.gtk = true;
	 # config = "${home.file.".config/sway/config".source}";
	# config = {
	# 	terminal = "wezterm";
	# 	modifier = "Mod4";
	# };
	};

	programs.waybar.enable = true;

	
	home.stateVersion = "24.11";
	programs.home-manager.enable = true;
}

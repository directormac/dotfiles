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


	home.packages = with pkgs; [
		zip
		xz
		unzip
		curl
		neovim
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
		wl-clipboard
		mako
		grim
		slurp
		dmenu

		xfce.thunar
	];


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

	
	wayland.windowManager.sway = {
	 enable = true;
	 wrapperFeatures.gtk = true;
	config = {
		terminal = "wezterm";
		modifier = "Mod4";
	};
	};

	programs.waybar.enable = true;

	
	home.stateVersion = "24.11";
	programs.home-manager.enable = true;
}

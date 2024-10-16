{ config, pkgs, lib, username, inputs, ...  }@args: let
  mkHMdir = username: let
    homeDirPrefix = if pkgs.stdenv.hostPlatform.isDarwin then "Users" else "home";
    homeDirectory = "/${homeDirPrefix}/${username}";
  in {
    inherit username homeDirectory;
  };
in {
  imports = [
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  # home.homeDirectory = lib.mkDefault (mkHMdir username).homeDirectory;
  
  nix.gc = {
    automatic = true;
    frequency = "weekly";
    options = "-d";
  };

  home.shellAliases = {
    autorepl = ''${pkgs.writeShellScript "autorepl" ''
      exec nix repl --show-trace --expr '{ pkgs = import ${inputs.nixpkgsNV.outPath} { system = "${pkgs.system}"; config.allowUnfree = true; }; }'
    ''}'';
    yolo = ''git add . && git commit -m "$(curl -fsSL https://whatthecommit.com/index.txt)" -m '(auto-msg whatthecommit.com)' -m "$(git status)" && git push'';
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    # XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    JAVA_HOME = "${pkgs.jdk}";
  };


  xdg.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (nerdfonts.override { fonts = [  "FiraMono" "Go-Mono" ]; })

  ];
  fonts.fontconfig.enable = true;
  # security.pam.enableSudoTouchIdAuth = true;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".config/nvim".source = .config/nvim
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Run chezmoi init
  home.activation.postActivation1 = ''
    #!/bin/bash
    echo "Running chezmoi init --apply Hadi Asemi..."
 ${pkgs.chezmoi}/bin/chezmoi init --force --apply Hadiasemi
  '';
  home.activation.postActivation = ''
    #!/bin/bash
    echo "Configuring Neovim..."
    if [ ! -d ~/.config/nvim ]; then
      git clone https://github.com/Hadiasemi/hadi-kickstart.nvim.git ~/.config/nvim
    else
      echo "Neovim is already configured."
    fi
  '';

  services.gpg-agent.enable = true;
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/birdee/etc/profile.d/hm-session-vars.sh
  #

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

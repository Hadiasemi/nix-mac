{
  description = "Hadi Darwin MacOS system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }: let
    configuration = { pkgs, config, ... }: {

      # Enable Unfree packages
      nixpkgs.config.allowUnfree = true;

      # System Packages
      environment.systemPackages = with pkgs; [
        openjdk21 gnupg pcsclite pcsc-tools pinentry_mac mkalias go rustc cargo cmake
        nodejs bat ripgrep eza chezmoi zellij starship curl wget fzf gnupg htop openssl
        sqlite tmux unzip vim neovim ranger yarn zsh zsh-autosuggestions ffmpeg
      ];

      # Homebrew Setup
      homebrew = {
        enable = true;
        brews = [];  # List of brew formulas (commented out in original)
        casks = [
          "bitwarden" "docker" "google-chrome" "brave-browser" "synology-drive"
          "private-internet-access" "iterm2" "slack" "discord" "telegram" "signal"
          "visual-studio-code" "vlc" "zoom"
        ];
        onActivation.cleanup = "zap";
      };

      # Fonts
      fonts.packages = with pkgs; [
        (pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/refs/heads/master/patched-fonts/Meslo/S/Regular/MesloLGSNerdFont-Regular.ttf";
          sha256 = "1h7xliswm2xf3aw1ml6d5pmc3hib8cwbgsacr9l4qsf585zm0s8p";
        })
      ];

      # System Activation Scripts
      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in pkgs.lib.mkForce ''
        echo "Setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read src; do
          app_name=$(basename "$src")
          echo "Copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
      '';

      # Run chezmoi init
      system.activationScripts.runChezMoiInit = ''
        echo "Running chezmoi init --apply Hadiasemi..."
        chezmoi init --apply Hadiasemi
      '';

      # Zsh Configuration
      programs.zsh = {
        enable = true;
        shellInit = ''
          # Zsh Autosuggestions
          source ${(pkgs.zsh-autosuggestions)}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        '';
      };

      # Environment Variables
      environment.variables = {
        JAVA_HOME = "${pkgs.openjdk21}/lib/openjdk";
      };

      # GPG Agent Configuration
      environment.etc."gnupg/gpg-agent.conf" = {
        text = ''
          pinentry-program /run/current-system/sw/bin/pinentry-mac
          enable-ssh-support
        '';
      };

      # Enable Nix Daemon
      services.nix-daemon.enable = true;

      # Enable Nix Experimental Features (flakes)
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # State version for backwards compatibility
      system.stateVersion = 5;

      # Host platform for the configuration
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    darwinConfigurations."cybersleuth" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;  # Apple Silicon
            user = "cybersleuth";
            autoMigrate = true;
          };
        }
      ];
    };

    # Expose package set, including overlays, for convenience
    darwinPackages = self.darwinConfigurations."cybersleuth".pkgs;
  };
}
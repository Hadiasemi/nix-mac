{
  description = "Hadi Darwin MacOS system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager  }: let
    username ="cybersleuth";
  in {
    darwinConfigurations.${username} = nix-darwin.lib.darwinSystem {
     specialArgs ={
	inherit self username inputs;
     };
      modules = [
      	
      	./configuration.nix	
	home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home.nix;
	  home-manager.extraSpecialArgs = {
	  	inherit username inputs;

	  };

        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;  # Apple Silicon
            user = username;
            autoMigrate = true;
          };
        }
      ];
    };

    # Expose package set, including overlays, for convenience
    darwinPackages = self.darwinConfigurations.${username}.pkgs;
  };
}

{
  description = "Total chaos when no one in the clan follows the rules";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # flake-parts input
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    clan-core = {
      url = "git+https://git.clan.lol/clan/clan-core";
      inputs.nixpkgs.follows = "nixpkgs"; # Needed if your configuration uses nixpkgs unstable.
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs @ {
    flake-parts,
    clan-core,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      self,
      pkgs,
      ...
    }: {
      # We define our own systems below. you can still use this to add system specific outputs to your flake.
      # See: https://flake.parts/getting-started
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # import clan-core modules
      imports = [
        clan-core.flakeModules.default
      ];
      # Define your clan
      # See: https://docs.clan.lol/reference/nix-api/buildclan/
      clan = {
        # Clan wide settings. (Required)
        meta.name = "ClanArchy"; # Ensure to choose a unique name.

        # Make flake available in modules
        specialArgs.self = {
          inherit (self) inputs nixosModules packages;
        };
        inherit self;

        machines = {
          # You can also specify additional machines here.
          # somemachine = {
          #  imports = [ ./some-machine/configuration.nix ];
        };
      };

      perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [inputs'.clan-core.packages.clan-cli];
      buildInputs = with pkgs; [
        # Development tools
        git
        nixpkgs-fmt
        nil # Nix LSP

        # Documentation tools
        nodejs
        ocrmypdf
        pnpm

        # Additional utilities
        ripgrep
        fd
      ];
    };
  };

    });
}

{
  pkgs,
  inputs',
  ...
}: {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    devShells.doc = pkgs.mkShell {
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
}

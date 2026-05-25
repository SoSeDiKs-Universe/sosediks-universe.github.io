{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        nativeDeps = with pkgs; [
        ];

        runtimeDeps = with pkgs; [
          ruby_4_0
          jekyll
          rubyPackages_4_0.eventmachine
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = nativeDeps;
          buildInputs = runtimeDeps;
          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath runtimeDeps}:$LD_LIBRARY_PATH
          '';
        };
      }
    );
}

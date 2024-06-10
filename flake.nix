{
  description = "Sample micropython build";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { system = system; };
        mpy = pkgs.callPackage ./firmware.nix { };
      in {
        packages = { firmware = mpy; };
        devShells.default = pkgs.mkShell { packages = [ mpy ]; };
      });
}

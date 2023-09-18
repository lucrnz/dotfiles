{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/master";
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      myPython = pkgs.python311.withPackages (ps: [ ps.requests ]);
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [ myPython ];
      };
    }
  );
}

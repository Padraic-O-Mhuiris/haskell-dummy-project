{ compiler ? "ghc865", nixpkgs ? import <nixpkgs> { } }:

let

  # This is from the nixos-20.03 branch
  pinnedPkgs = nixpkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "182f229ba7cc197768488972347e47044cd793fb";
    sha256 = "0x20m7czzyla2rd9vyn837wyc2hjnpad45idq823ixmdhyifx31s";
  };

  pkgs = import pinnedPkgs { };

  gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];

  myHaskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = hself: hsuper: {
      "haskell-dummy-project" =
        hself.callCabal2nix "haskell-dummy-project" (gitignore ./.) { };
    };
  };

  shell = myHaskellPackages.shellFor {
    packages = p: [ p."haskell-dummy-project" ];

    buildInputs = with pkgs.haskellPackages; [
      myHaskellPackages.cabal-install
      hlint
      brittany
      ghcid
    ];
    withHoogle = false;
  };

  exe = pkgs.haskell.lib.justStaticExecutables
    (myHaskellPackages."haskell-dummy-project");

in {
  inherit shell;
  inherit exe;
}

{
  description = "A framework for modularly defining program logics";

  inputs = {
    rocq-nix.url = "github:mbrcknl/rocq-nix";

    rocq-nix-stdpp.url = "github:mbrcknl/rocq-nix-stdpp";
    rocq-nix-stdpp.inputs.rocq-nix.follows = "rocq-nix";

    rocq-nix-iris.url = "github:mbrcknl/rocq-nix-iris";
    rocq-nix-iris.inputs.rocq-nix.follows = "rocq-nix";
    rocq-nix-iris.inputs.rocq-nix-stdpp.follows = "rocq-nix-stdpp";

    rocq-nix-paco.url = "github:mbrcknl/rocq-nix-paco";
    rocq-nix-paco.inputs.rocq-nix.follows = "rocq-nix";

    rocq-nix-itrees.url = "github:mbrcknl/rocq-nix-itrees";
    rocq-nix-itrees.inputs.rocq-nix.follows = "rocq-nix";
    rocq-nix-itrees.inputs.rocq-nix-paco.follows = "rocq-nix-paco";

    iris-itree.url = "github:mbrcknl/rocq-iris-itree/rocq-v9-support";
    iris-itree.flake = false;
  };

  outputs =
    inputs:
    inputs.rocq-nix.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        treefmt.programs.nixfmt.enable = true;

        rocq.dev.sources."iris-itree".input = "iris-itree";

        rocq.versions.default = "9.1.0";
        rocq.versions.supported = {
          "9.0.1" = true;
          "9.1.0" = true;
        };

        rocq.versions.foreach =
          {
            inputs',
            pkgs,
            rocq,
            ...
          }:
          let
            inherit (rocq.coqPackages)
              coq
              coq-elpi
              coq-record-update
              ExtLib
              stdlib
              ;
            inherit (inputs'.rocq-nix-stdpp.packages) stdpp stdpp-bitvector stdpp-unstable;
            inherit (inputs'.rocq-nix-iris.packages) iris iris-heap-lang;
            inherit (inputs'.rocq-nix-paco.packages) paco;
            inherit (inputs'.rocq-nix-itrees.packages) itrees;

            rocqpath = [
              coq
              coq-elpi
              coq-record-update
              ExtLib
              itrees
              iris
              iris-heap-lang
              paco
              stdlib
              stdpp
              stdpp-bitvector
              stdpp-unstable
            ];

            iris-itree = pkgs.stdenv.mkDerivation {
              name = "rocq${coq.coq-version}-iris-itree";
              src = inputs.iris-itree;
              buildInputs = rocqpath;
              COQLIBINSTALL = "$(out)/lib/coq/${coq.coq-version}/user-contrib";
              enableParallelBuilding = true;
              meta = {
                inherit (coq.meta) platforms;
                homepage = "https://gitlab.mpi-sws.org/iris/itree-program-logic";
                description = "A framework for modularly defining program logics";
                license = [
                  lib.licenses.bsd2
                  lib.licenses.bsd3
                ];
              };
            };
          in
          {
            packages = { inherit iris-itree; };
            dev.env.lib = rocqpath;
          };
      }
    );
}

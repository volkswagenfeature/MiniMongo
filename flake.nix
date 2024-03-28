{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      dbpath = "\\\$(${pkgs.git}/bin/git rev-parse --show-toplevel)/dbs/";
      wrapFlags = ''--add-flags "--handler=sqlite" \
                    --add-flags "--sqlite-url=\"file:${dbpath}\"" \
                    --add-flags "--state-dir=\"${dbpath}\""
                  '';

      
    in rec
    {
      quickstart = pkgs.symlinkJoin rec {
              name = "wrappedferret";
              paths = [ pkgs.ferretdb pkgs.git ];
              buildInputs = [pkgs.makeWrapper];
              postBuild = ''
                makeWrapper  ${pkgs.ferretdb}/bin/ferretdb \
                $out/bin/${name} ${wrapFlags}
                # echo src:$src self:${self} > $out/bin/paths
                          '';
            };

      packages.default = quickstart;

      apps.default = {
        type = "app"; 
        program = "${quickstart}/bin/wrappedferret";
      };

      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          ferretdb
          sqlite
          mongosh
          fish
        ];
        shellHook = "exec $SHELL";
      };
    }
  );
}

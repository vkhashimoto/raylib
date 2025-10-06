{
  description = "A simple and easy-to-use library to enjoy videogames programming";

  inputs = {
    nixpkgs.url = "github:nixOS/nixpkgs/release-25.05";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      # https://ayats.org/blog/no-flake-utils
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
        ] (system: function nixpkgs.legacyPackages.${system});

      name = "raylib";
      defaultBuildInputs = (
        {
          pkgs,
          additionalPkgs ? [ ],
        }:
        with pkgs;
        [
          gnumake42
          xorg.libX11
          xorg.libXrandr
          xorg.libXcursor
          xorg.libXinerama
          xorg.libXi
          #xorg.libX11.dev
          #libGL

        ]
        ++ additionalPkgs
      );
    in
    {

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          inherit name;
          buildInputs = defaultBuildInputs {
            inherit pkgs;
            additionalPkgs = with pkgs; [
              nixfmt-rfc-style
            ];
          };
          shellHook = ''
            echo "Entered development environment"
          '';
        };
      });
      packages = forAllSystems (pkgs: {
        default = pkgs.stdenv.mkDerivation {
          pname = name;
          version = "5.5";
          src = ./.;
          buildInputs = defaultBuildInputs {
            inherit pkgs;
          };

          buildPhase = ''
            cd src/
            make -j16
          '';

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.alsa-lib ];
          installPhase = ''
            mkdir -p $out/lib
            cp libraylib.a $out/lib
          '';
        };
      });
    };
}

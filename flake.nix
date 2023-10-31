{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    "nixos-23_05".url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.hercules-ci-effects.flakeModule
        inputs.pre-commit-hooks.flakeModule
      ];

      herculesCI.ciSystems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { config, self', pkgs, system, ... }: {

        # This set is for CI
        haskellProjects."nixos-23_05" = {
          basePackages = inputs.nixos-23_05.legacyPackages.${system}.haskellPackages;

          # dont bother checking availability of shell tools
          devShell.enable = false;
        };

        haskellProjects.default = {
          # The base package set representing a specific GHC version.
          # By default, this is pkgs.haskellPackages.
          # You may also create your own. See https://zero-to-flakes.com/haskell-flake/package-set
          # basePackages = pkgs.haskellPackages;

          # Extra package information. See https://zero-to-flakes.com/haskell-flake/dependency
          #
          # Note that local packages are automatically included in `packages`
          # (defined by `defaults.packages` option).
          #
          # packages = {
          #   aeson.source = "1.5.0.0"; # Hackage version override
          #   shower.source = inputs.shower;
          # };
          # settings = {
          #   aeson = {
          #     check = false;
          #   };
          #   relude = {
          #     haddock = false;
          #     broken = false;
          #   };
          # };

          devShell = {
            mkShellArgs.shellHook = ''
              ${config.pre-commit.installationScript}
            '';
            #
            #  # Programs you want to make available in the shell.
            #  # Default programs can be disabled by setting to 'null'
            #  tools = hp: { fourmolu = hp.fourmolu; ghcid = null; };
            #
            #  hlsCheck.enable = true;
            # };
          };
        };

        # haskell-flake doesn't set the default package, but you can do it here.
        packages.default = self'.packages.releaser;

        pre-commit.settings.hooks.nixpkgs-fmt.enable = true;
        pre-commit.settings.hooks.ormolu.enable = true;

        checks.missing-command = pkgs.runCommand "test-missing-command"
          {
            nativeBuildInputs = [ config.packages.default ];
          } ''
          echo "Checking releaser behavior. This may emit some error messages."
          set -euo pipefail
          (! releaser 2>&1) | tee /dev/stderr | grep "Command not found: git" >/dev/null
          touch $out
        '';
      };
    };
}

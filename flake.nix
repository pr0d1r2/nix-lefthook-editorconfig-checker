{
  description = "Lefthook-compatible editorconfig-checker check";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";

    set-and-setting.url = "github:pr0d1r2/set-and-setting";
  };

  outputs =
    {
      self,
      nixpkgs,
      set-and-setting,
      ...
    }:
    let
      sas = set-and-setting.inputs.set-and-setting;
      supportedSystems = (import "${set-and-setting}/flake/systems.nix" { inherit nixpkgs; }).supported;
      fragments = [
        "base"
        "nix"
        "shell"
        "ascii"
        "markdown"
        "yaml"
      ];
    in
    (import "${set-and-setting}/set/lib/mk-consumer-flake.nix" {
      inherit supportedSystems;
    })
      {
        inherit self nixpkgs fragments;
        set-and-setting = sas;
        src = ./.;
        extraPackages = pkgs: {
          default = pkgs.writeShellApplication {
            name = "lefthook-editorconfig-checker";
            runtimeInputs = [ pkgs.editorconfig-checker ];
            text = builtins.readFile ./lefthook-editorconfig-checker.sh;
          };
        };
        extraChecks = pkgs: {
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };
      };
}

{
  description = "Development environment for osc-k8s-rke-cluster";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [ terraform ansible ];
          shellHook = ''
              export LC_ALL=C.UTF-8 # needed for ansible. See https://github.com/NixOS/nixpkgs/issues/223151
          '';
        };
      });
    };
}
{
  description = "Polygen React Native WebAssembly module development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Used for shell.nix
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    ...
  } @ inputs: let
    overlays = [
      (final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (prev) system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
      })
    ];

    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {
          inherit overlays system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };
      in {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          name = "polygen-dev";
          nativeBuildInputs =
            [
              pkgs.jdk17 # JDK 17 for Android builds (JDK 24 has Gradle compatibility issues)

              pkgs.unstable.fnm
              pkgs.unstable.jq
              pkgs.unstable.ripgrep
              pkgs.unstable.watchman
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
              # iOS development tools (macOS only)
              pkgs.cocoapods
            ];

          shellHook =
            ''
              eval "$(fnm env --use-on-cd --corepack-enabled --shell bash)"

              # Set JAVA_HOME for Android builds
              export JAVA_HOME="${pkgs.jdk17}"

              echo "Polygen development environment loaded"
              echo "  java: $(java -version 2>&1 | head -1)"
              echo "  node: $(node --version 2>/dev/null || echo 'run: fnm install')"
            ''
            + (pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
              # On macOS, unset SDK env vars that Nix sets up because we rely on
              # system Xcode installation. Nix only provides macOS SDK, we need iOS too.
              unset SDKROOT
              unset DEVELOPER_DIR
              # Add system Xcode tools to PATH for react-native
              export PATH=/usr/bin:$PATH

              # Android SDK setup (if installed via Android Studio)
              if [ -d "$HOME/Library/Android/sdk" ]; then
                export ANDROID_HOME="$HOME/Library/Android/sdk"
                export ANDROID_SDK_ROOT="$ANDROID_HOME"
                export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
              fi
            '')
            + (pkgs.lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
              # Android SDK setup (if installed)
              if [ -d "$HOME/Android/Sdk" ]; then
                export ANDROID_HOME="$HOME/Android/Sdk"
                export ANDROID_SDK_ROOT="$ANDROID_HOME"
                export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"
              fi
            '');
        };

        # For compatibility with older versions of the `nix` binary
        devShell = self.devShells.${system}.default;
      }
    );
}

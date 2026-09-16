# Evaluate a minimal NixOS + home-manager system with the niri module (does not build it).
check:
	nix flake check --print-build-logs

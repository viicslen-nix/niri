# Check that the niri module evaluates correctly by building a minimal test configuration.
check:
	nix flake check --print-build-logs

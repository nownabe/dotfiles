# nixpkgs' claude-code wraps the binary with LD_LIBRARY_PATH pointing at Nix's
# alsa-lib (for sound notifications). The variable leaks into every subprocess
# Claude Code spawns, so non-Nix binaries — e.g. the system Chrome launched by
# the playwright / chrome-devtools MCP servers — load Nix libraries built
# against a newer glibc and crash with GLIBC_ABI_* version errors.
# Strip the LD_LIBRARY_PATH prefix from the wrapper.
{
  lib,
  alsa-lib,
  claude-code,
}:

claude-code.overrideAttrs (old: {
  installPhase =
    let
      alsaPrefix = "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ alsa-lib ]} \\\n";
      stripped = lib.replaceStrings [ alsaPrefix ] [ "" ] old.installPhase;
    in
    assert lib.assertMsg (stripped != old.installPhase)
      "claude-code: LD_LIBRARY_PATH prefix not found in installPhase; update packages/claude-code.nix";
    stripped;
})

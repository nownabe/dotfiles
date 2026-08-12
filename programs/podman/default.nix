{ pkgs, ... }:

{
  # Rootless Podman on non-NixOS.
  # Host prerequisites (provided by Ubuntu, not Nix):
  #   - setuid /usr/bin/newuidmap & newgidmap (uidmap package)
  #   - subuid/subgid entries for the user in /etc/subuid & /etc/subgid
  home.packages = [ pkgs.podman ];

  # Non-NixOS has no /etc/containers, so provide user-level config.
  # No registries.conf: always use fully qualified image names
  # (e.g. docker.io/library/ubuntu).
  xdg.configFile."containers/policy.json".text = builtins.toJSON {
    default = [ { type = "insecureAcceptAnything"; } ];
  };
}

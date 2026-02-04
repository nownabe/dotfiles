{ config, lib, pkgs, ... }:

let
  githubName = "nownabe";
  githubEmail = "1286807+nownabe@users.noreply.github.com";
in
{
  programs.git = {
    enable = true;

    ignores = [
      ".nownabe/"
      ".shogo/"
      ".claude/settings.local.json"
    ];

    settings = {
      user = {
        name = githubName;
        email = githubEmail;
      };

      alias = {
        l = "log --graph --oneline --all --decorate";
        co = "checkout";
        pp = "pull --prune";
        sw = "switch";
        s = "status";
        cp = "cherry-pick";
      };

      core.editor = "nvim";
      init.defaultBranch = "main";
      push.default = "simple";
      pull.rebase = true;
      rebase.autostash = true;
      diff.compactionHeuristic = true;
      gpg.program = "gpg";
      ghq.root = "~/src";
      commit.gpgsign = true;

      # GitHub credential helper
      credential = {
        "https://github.com".helper = "!gh auth git-credential";
        "https://gist.github.com".helper = "!gh auth git-credential";
      };

      # Include signing key (generated dynamically per machine)
      include.path = "~/.config/git/signing.local";
    };
  };

  # Generate GPG key and signing.local config file
  home.activation.generateGitGpgConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    config_file="${config.home.homeDirectory}/.config/git/signing.local"
    mkdir -p "$(dirname "$config_file")"

    # Generate GPG key if it doesn't exist
    if ! ${pkgs.gnupg}/bin/gpg --list-secret-keys "${githubEmail}" >/dev/null 2>&1; then
      echo "Generating GPG key for ${githubEmail}..."
      ${pkgs.gnupg}/bin/gpg \
        --batch \
        --pinentry-mode loopback \
        --passphrase "" \
        --quick-gen-key "${githubName} <${githubEmail}>" ed25519 default never
    fi

    # Get GPG signing key
    signing_key=$(${pkgs.gnupg}/bin/gpg --list-secret-keys --with-colons "${githubEmail}" 2>/dev/null | ${pkgs.gawk}/bin/awk -F: '/^fpr:/ {print $10; exit}')

    if [ -n "$signing_key" ]; then
      cat > "$config_file" << EOF
[user]
  signingkey = $signing_key
EOF
      echo "Generated $config_file with signing key: $signing_key"
    else
      echo "Error: Failed to get GPG signing key" >&2
    fi
  '';
}

if grep -qi "WSL2" /proc/version 2>/dev/null; then
  echo_info "Running inside WSL2"
  export IS_WSL="true"
  export GPG_TTY="$(tty)"
  export BROWSER="/usr/bin/wslview"
fi

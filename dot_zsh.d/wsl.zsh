if grep -qi "WSL2" /proc/version; then
  echo_info "🐧 Running inside WSL2"
  export IS_WSL="true"
  
  export GPG_TTY="$(tty)"
  export BROWSER="/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"
fi

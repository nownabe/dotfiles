if grep -qi "WSL2" /proc/version; then
  echo -e "\033[1;32m🐧 Running inside WSL2\033[0m"
  export IS_WSL="true"
  
  export GPG_TTY="$(tty)"
  export BROWSER="/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe"
fi

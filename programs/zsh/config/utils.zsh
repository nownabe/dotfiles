COLOR_RESET="\033[0m"
COLOR_INFO="\033[1;32m"
COLOR_WARN="\033[1;33m"
COLOR_ERROR="\033[1;31m"

echo_info() { echo -e "${COLOR_INFO}$*${COLOR_RESET}"; }
echo_warn() { echo -e "${COLOR_WARN}$*${COLOR_RESET}"; }
echo_error() { echo -e "${COLOR_ERROR}$*${COLOR_RESET}"; }

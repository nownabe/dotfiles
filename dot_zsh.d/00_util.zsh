# 色コード定義
COLOR_RESET="\033[0m"
COLOR_INFO="\033[1;32m"    # 明るい緑
COLOR_WARN="\033[1;33m"    # 明るい黄（オレンジに近い）
COLOR_ERROR="\033[1;31m"   # 明るい赤

# ログ関数定義
echo_info() {
  echo -e "${COLOR_INFO}$*${COLOR_RESET}"
}

echo_warn() {
  echo -e "${COLOR_WARN}$*${COLOR_RESET}"
}

echo_error() {
  echo -e "${COLOR_ERROR}$*${COLOR_RESET}"
}


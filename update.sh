#!/bin/bash
#
# 更新脚本 - Hide My Tracks
#

set -uo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[*] 检查 Hide My Tracks 更新...${NC}"

# 检查可能的安装位置
LOCATIONS=(
  "/usr/local/bin/hide_my_tracks"
  "/usr/bin/hide_my_tracks"
  "$HOME/bin/hide_my_tracks"
)

FOUND=0
INSTALL_PATH=""

for loc in "${LOCATIONS[@]}"; do
  if [ -f "$loc" ]; then
    FOUND=1
    INSTALL_PATH="$loc"
    echo -e "${GREEN}[*] 找到安装在: $loc${NC}"
    break
  fi
done

if [ $FOUND -eq 0 ]; then
  echo -e "${YELLOW}[!] 未找到 Hide My Tracks 的安装${NC}"
  echo -e "${YELLOW}[*] 是否要重新安装? [y/N] ${NC}"
  read -p "" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 确定安装路径
    if [ "$EUID" -eq 0 ]; then
      INSTALL_PATH="/usr/local/bin/hide_my_tracks"
    else
      INSTALL_PATH="$HOME/bin/hide_my_tracks"
      mkdir -p "$(dirname "$INSTALL_PATH")"
    fi
  else
    echo -e "${RED}[!] 更新已取消${NC}"
    exit 1
  fi
fi

# 检查是否有权限写入
if [ ! -w "$(dirname "$INSTALL_PATH")" ]; then
  echo -e "${RED}[!] 没有权限写入 $INSTALL_PATH${NC}"
  echo -e "${YELLOW}[*] 请尝试: sudo $0${NC}"
  exit 1
fi

# 下载最新版本
echo -e "${GREEN}[*] 下载最新版本...${NC}"
TMP_FILE=$(mktemp)
curl -fsSL -o "$TMP_FILE" https://raw.githubusercontent.com/6Kmfi6HP/hide_my_tracks/main/run.sh

# 检查下载是否成功
if [ $? -ne 0 ]; then
  echo -e "${RED}[!] 下载失败，请检查网络连接${NC}"
  rm -f "$TMP_FILE"
  exit 1
fi

# 获取当前版本和最新版本
CURRENT_VERSION=$(grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" "$INSTALL_PATH" 2>/dev/null || echo "未知版本")
NEW_VERSION=$(grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" "$TMP_FILE" 2>/dev/null || echo "未知版本")

# 安装新版本
mv "$TMP_FILE" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

echo -e "${GREEN}[+] 更新完成！${NC}"
echo -e "${GREEN}[+] 从 $CURRENT_VERSION 更新到 $NEW_VERSION${NC}"
echo -e "${GREEN}[+] 安装路径: $INSTALL_PATH${NC}" 
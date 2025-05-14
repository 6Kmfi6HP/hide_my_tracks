#!/bin/bash
#
# 卸载脚本 - Hide My Tracks
#

set -uo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[*] 准备卸载 Hide My Tracks...${NC}"

# 检查可能的安装位置
LOCATIONS=(
  "/usr/local/bin/hide_my_tracks"
  "/usr/bin/hide_my_tracks"
  "$HOME/bin/hide_my_tracks"
)

FOUND=0

for loc in "${LOCATIONS[@]}"; do
  if [ -f "$loc" ]; then
    FOUND=1
    echo -e "${GREEN}[*] 找到安装在: $loc${NC}"
    
    # 检查是否有权限删除
    if [ -w "$(dirname "$loc")" ]; then
      rm -f "$loc"
      echo -e "${GREEN}[+] 已删除: $loc${NC}"
    else
      echo -e "${RED}[!] 没有权限删除 $loc${NC}"
      echo -e "${YELLOW}[*] 请尝试: sudo $0${NC}"
      exit 1
    fi
  fi
done

if [ $FOUND -eq 0 ]; then
  echo -e "${YELLOW}[!] 未找到 Hide My Tracks 的安装${NC}"
  echo -e "${YELLOW}[*] 可能已经卸载或使用其他方式安装${NC}"
fi

# 清理 PATH 中的引用（如果是普通用户安装）
if [ -f "$HOME/.bashrc" ]; then
  sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' "$HOME/.bashrc" 2>/dev/null || true
fi

if [ -f "$HOME/.zshrc" ]; then
  sed -i '/export PATH="\$HOME\/bin:\$PATH"/d' "$HOME/.zshrc" 2>/dev/null || true
fi

echo -e "${GREEN}[+] 卸载完成！${NC}" 
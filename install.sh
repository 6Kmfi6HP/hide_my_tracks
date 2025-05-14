#!/bin/bash
#
# 安装脚本 - Hide My Tracks
#

set -uo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}提示: 建议以 root 权限运行安装程序${NC}"
  echo -e "${YELLOW}您可以使用: sudo $0${NC}"
  read -p "是否继续以当前用户安装? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}安装已取消${NC}"
    exit 1
  fi
fi

echo -e "${GREEN}[*] 开始安装 Hide My Tracks...${NC}"

# 安装目录
INSTALL_DIR="/usr/local/bin"
if [ "$EUID" -ne 0 ]; then
  INSTALL_DIR="$HOME/bin"
  mkdir -p "$INSTALL_DIR"
fi

# 下载脚本
echo -e "${GREEN}[*] 下载主程序...${NC}"
curl -fsSL -o "$INSTALL_DIR/hide_my_tracks" https://raw.githubusercontent.com/6Kmfi6HP/hide_my_tracks/main/run.sh

# 检查下载是否成功
if [ $? -ne 0 ]; then
  echo -e "${RED}[!] 下载失败，请检查网络连接${NC}"
  exit 1
fi

# 设置执行权限
chmod +x "$INSTALL_DIR/hide_my_tracks"

# 添加到 PATH (如果是普通用户安装)
if [ "$EUID" -ne 0 ] && [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  echo -e "${YELLOW}[*] 添加 $HOME/bin 到 PATH 环境变量${NC}"
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
  
  # 如果用户使用 zsh
  if [ -f "$HOME/.zshrc" ]; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.zshrc"
  fi
  
  echo -e "${YELLOW}[*] 请重新加载 shell 配置或重启终端以使 PATH 更改生效${NC}"
fi

echo -e "${GREEN}[+] 安装完成！${NC}"
echo -e "${GREEN}[+] 使用方法: sudo hide_my_tracks${NC}"

# 如果是普通用户安装，提示使用方法
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}注意: 由于您以普通用户身份安装，脚本已安装到 $INSTALL_DIR${NC}"
  echo -e "${YELLOW}运行时仍需要 root 权限: sudo hide_my_tracks${NC}"
fi 
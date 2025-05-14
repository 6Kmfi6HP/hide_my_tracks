#!/bin/bash
#
# hide_my_tracks.sh - v1.0.0
# 一键清理 SSH 登录记录、系统日志、shell 历史及常见审计日志
#
# 项目地址: https://github.com/6Kmfi6HP/hide_my_tracks
# 用法: sudo ./hide_my_tracks.sh
#
# 功能:
# - 清理常见文本日志文件（auth.log, secure, syslog 等）
# - 清理轮转与归档日志（*.1, *.gz, *.old）
# - 清理 systemd-journal 日志
# - 删除各用户 Shell 历史记录
# - 清理二进制登录/登出记录（utmp, wtmp, btmp, lastlog）
# - 清理 Docker 容器日志
# - 清理进程会计日志（acct）
#

# 使用 set -e 但允许部分命令失败
set -uo pipefail

# 1. 校验 root 权限
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 身份运行：sudo $0"
  exit 1
fi

echo "[*] 开始清理日志..."

# 2. 常见文本日志文件截断
LOG_FILES=(
  /var/log/auth.log        # Debian/Ubuntu SSH 登录
  /var/log/secure          # RHEL/CentOS SSH 登录
  /var/log/syslog          # 通用系统日志
  /var/log/messages        # 系统消息
  /var/log/cron            # cron 作业日志 (CentOS)
  /var/log/audit/audit.log # auditd 日志
)
for f in "${LOG_FILES[@]}"; do
  if [ -f "$f" ]; then
    : > "$f" 2>/dev/null || echo "[-] 无法清理 $f"
  fi
done
echo "[*] 文本日志清理完成"

# 3. 清理轮转与归档日志 (*.1, *.gz, *.old)
echo "[*] 清理轮转日志..."
find /var/log -type f \( -name "*.1" -o -name "*.gz" -o -name "*.old" \) -delete 2>/dev/null || echo "[-] 部分轮转日志清理失败"
echo "[*] 轮转日志清理完成"

# 4. 清理 systemd-journal
if command -v journalctl &>/dev/null; then
  echo "[*] 清理 systemd journal..."
  systemctl stop systemd-journald.service 2>/dev/null || true
  rm -rf /var/log/journal/*/*.journal 2>/dev/null || true
  journalctl --rotate 2>/dev/null || true
  journalctl --vacuum-time=1s 2>/dev/null || true
  systemctl start systemd-journald.service 2>/dev/null || true
  echo "[*] systemd journal 清理完成或跳过"
fi

# 5. 删除各用户 Shell 历史
echo "[*] 清理用户 Shell 历史..."
for home in /root /home/*; do
  [ -d "$home" ] || continue
  HIST_FILES=(
    "$home/.bash_history"
    "$home/.history"
    "$home/.zsh_history"
    "$home/.zhistory"
    "$home/.local/share/fish/fish_history"
  )
  for hf in "${HIST_FILES[@]}"; do
    mkdir -p "$(dirname "$hf")" 2>/dev/null || true
    : > "$hf" 2>/dev/null || true
    chown --reference="$home" "$hf" 2>/dev/null || true
  done
done
echo "[*] Shell 历史清理完成"

# 6. 清空当前 shell 会话历史并防止写回
export HISTFILE=/dev/null
history -c 2>/dev/null || true

# 7. 二进制登录/登出记录截断并修正权限
echo "[*] 清理登录记录..."
BIN_LOGS=(
  /var/run/utmp
  /var/log/wtmp
  /var/log/btmp
  /var/log/lastlog
)
for b in "${BIN_LOGS[@]}"; do
  touch "$b" 2>/dev/null || true
  : > "$b" 2>/dev/null || true
  chmod 664 "$b" 2>/dev/null || true
  chown root:utmp "$b" 2>/dev/null || true
done
echo "[*] 登录记录清理完成"

# 8. Docker 容器日志清理
if [ -d /var/lib/docker/containers ]; then
  echo "[*] 清理 Docker 容器日志..."
  find /var/lib/docker/containers/ -type f -name "*-json.log" -exec truncate -s 0 {} \; 2>/dev/null || echo "[-] 部分 Docker 日志清理失败"
  echo "[*] Docker 日志清理完成"
fi

# 9. 进程会计日志清理（acct）
if [ -f /var/log/account/pacct ]; then
  echo "[*] 清理进程会计日志..."
  : > /var/log/account/pacct 2>/dev/null || echo "[-] 无法清理进程会计日志"
  service acct restart 2>/dev/null || systemctl restart acct 2>/dev/null || true
  echo "[*] 进程会计日志清理完成"
fi

echo "[+] 完成！所有痕迹已清理。"

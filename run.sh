#!/bin/bash
#
# hide_my_tracks.sh
# 一键清理 SSH 登录记录、系统日志、shell 历史及常见审计日志
# 用法：sudo ./hide_my_tracks.sh
#

set -euo pipefail

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
  [ -f "$f" ] && : > "$f"
done

# 3. 清理轮转与归档日志 (*.1, *.gz, *.old)
find /var/log -type f \( -name "*.1" -o -name "*.gz" -o -name "*.old" \) -delete

# 4. 清理 systemd-journal
if command -v journalctl &>/dev/null; then
  echo "[*] 清理 systemd journal..."
  systemctl stop systemd-journald.service 2>/dev/null || true
  rm -rf /var/log/journal/*/*.journal
  journalctl --rotate
  journalctl --vacuum-time=1s
  systemctl start systemd-journald.service 2>/dev/null || true
fi

# 5. 删除各用户 Shell 历史
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
    mkdir -p "$(dirname "$hf")"
    : > "$hf"
    chown --reference="$home" "$hf" 2>/dev/null || true
  done
done

# 6. 清空当前 shell 会话历史并防止写回
export HISTFILE=/dev/null
history -c

# 7. 二进制登录/登出记录截断并修正权限
BIN_LOGS=(
  /var/run/utmp
  /var/log/wtmp
  /var/log/btmp
  /var/log/lastlog
)
for b in "${BIN_LOGS[@]}"; do
  touch "$b"
  : > "$b"
  chmod 664 "$b" 2>/dev/null || true
  chown root:utmp "$b" 2>/dev/null || true
done

# 8. Docker 容器日志清理
if [ -d /var/lib/docker/containers ]; then
  echo "[*] 清理 Docker 容器日志..."
  find /var/lib/docker/containers/ -type f -name "*-json.log" -exec truncate -s 0 {} \;
fi

# 9. 进程会计日志清理（acct）
if [ -f /var/log/account/pacct ]; then
  echo "[*] 清理进程会计日志..."
  : > /var/log/account/pacct
  service acct restart 2>/dev/null || true
fi

echo "[+] 完成！所有痕迹已清理。"

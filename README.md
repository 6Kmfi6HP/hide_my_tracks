## 脚本简介

**名称**: hide\_my\_tracks

**执行地址**: [https://raw.githubusercontent.com/6Kmfi6HP/hide\_my\_tracks/refs/heads/main/run.sh](https://raw.githubusercontent.com/6Kmfi6HP/hide_my_tracks/refs/heads/main/run.sh)

该脚本用于一键清理 Linux 系统中的 SSH 登录记录、shell 历史、系统日志、容器日志及审计日志等痕迹，帮助用户在测试或特殊场景中恢复“未登录、未操作”状态。

---

## 主要功能

1. **清空文本日志**：包括 SSH 登录日志（`auth.log`/`secure`）、系统日志（`syslog`/`messages`）、cron 日志、auditd 日志等。
2. **删除轮转与归档**：自动删除 `.1`、`.gz`、`.old` 等日志轮转文件。
3. **systemd Journal 清理**：停止 journal 服务，移除所有 journal 文件，并重新启动。
4. **Shell 历史清理**：支持 Bash、Zsh、Fish 等常见 shell 的历史文件，并立即清除当前会话历史，阻止写回。
5. **二进制登录记录截断**：清空 `utmp`、`wtmp`、`btmp`、`lastlog` 等文件，并修正文件权限。
6. **Docker 容器日志**：截断所有 Docker 容器的 JSON 日志文件。
7. **进程会计日志**：清理 `acct` 生成的 `/var/log/account/pacct` 并重启进程会计服务。

---

## 运行环境

* Linux 发行版（Debian/Ubuntu、RHEL/CentOS 等）
* 需具备 `root` 权限
* 若使用 systemd，需安装 `journalctl`
* 可选：Docker、`acct` 服务已安装

---

## 使用方法

1. **直接执行（推荐）**：

   ```bash
   curl -fsSL https://raw.githubusercontent.com/6Kmfi6HP/hide_my_tracks/refs/heads/main/run.sh \
     | sudo bash
   ```

2. **下载并执行**：

   ```bash
   curl -fsSL -o hide_my_tracks.sh https://raw.githubusercontent.com/6Kmfi6HP/hide_my_tracks/refs/heads/main/run.sh
   chmod +x hide_my_tracks.sh
   sudo ./hide_my_tracks.sh
   ```

---

## 注意事项

* **高风险操作**：脚本将彻底移除系统的大部分日志与审计数据，可能影响故障排查与安全审计。
* **备份建议**：在生产环境使用前，请先备份重要日志文件。
* **合法合规**：仅在合法且可控的场景下使用本脚本。

---

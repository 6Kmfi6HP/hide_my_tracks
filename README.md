# Hide My Tracks

一键清理 SSH 登录记录、系统日志、shell 历史及常见审计日志的工具。

## 功能特点

- 清理常见文本日志文件（auth.log, secure, syslog 等）
- 清理轮转与归档日志（*.1, *.gz, *.old）
- 清理 systemd-journal 日志
- 删除各用户 Shell 历史记录
- 清空当前 shell 会话历史
- 清理二进制登录/登出记录（utmp, wtmp, btmp, lastlog）
- 清理 Docker 容器日志
- 清理进程会计日志（acct）
- 错误处理机制，即使部分命令失败也能继续执行

## 使用方法

### 方法一：直接运行（推荐用于临时使用）

```bash
curl -fsSL https://raw.githubusercontent.com/6Kmfi6HP/hide_my_tracks/main/run.sh | sudo bash
```

### 方法二：下载后运行

```bash
# 下载脚本
curl -fsSL -o hide_my_tracks.sh https://raw.githubusercontent.com/6Kmfi6HP/hide_my_tracks/main/run.sh

# 添加执行权限
chmod +x hide_my_tracks.sh

# 以 root 权限运行
sudo ./hide_my_tracks.sh
```

## 支持的系统

- Debian/Ubuntu
- RHEL/CentOS/Rocky Linux/Alma Linux
- 其他基于 systemd 的 Linux 发行版

## 注意事项

- 本工具需要 root 权限运行
- 清理日志可能会影响系统管理和故障排查
- 某些环境可能需要重启相关服务才能完全生效
- 使用前请确保了解风险和后果

## 免责声明

本工具仅用于系统维护和安全研究目的，请勿用于非法活动。使用本工具清理系统日志可能违反某些组织的安全策略，请在使用前确认您有权限这样做。作者不对使用本工具导致的任何问题负责。

## 贡献

欢迎通过 Issues 和 Pull Requests 提交改进建议和代码贡献。

## 许可证

MIT

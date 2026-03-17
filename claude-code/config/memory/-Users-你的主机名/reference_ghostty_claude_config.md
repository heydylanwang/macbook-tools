<!-- ai-doc: 配置参考文档，调整时必须更新 -->

# Ghostty 终端中的 Claude Code 认证配置

## 文件位置
`~/.config/ghostty/config`

## 关键配置块

### Claude Code 账号登录（覆盖全局 launchctl API 配置）
```
# --- Claude Code: 账号登录（覆盖全局 launchctl API 配置）---
env = ANTHROPIC_API_KEY=
env = ANTHROPIC_BASE_URL=
```

**说明**：
- 清空 `ANTHROPIC_API_KEY` 和 `ANTHROPIC_BASE_URL` 环境变量
- 强制 Claude Code 在 ghostty 中使用 **OAuth 账号登录**，而不继承全局 launchctl 的代理 API 配置
- 这与 `~/.zshrc` 中的 ghostty 环境检测相配合：
  ```bash
  if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
    unset ANTHROPIC_BASE_URL
    unset ANTHROPIC_AUTH_TOKEN
  fi
  ```

## 相关文件
- `~/.zshrc` — ghostty 环境变量清理逻辑 + COLUMNS 动态设置
- `~/.claude/settings.json` — Claude Code 的全局设置
- `~/.claude/settings_api_proxy.json` — 第三方代理 API 配置（用于 VSCode）

## 调整时必须更新的位置
如果需要改变 Claude Code 在 ghostty 中的认证方式（OAuth ↔ 代理 API），**必须同时修改**：
1. ✅ `~/.config/ghostty/config` （ANTHROPIC_API_KEY / ANTHROPIC_BASE_URL）
2. ✅ `~/.zshrc` （if [[ "$TERM_PROGRAM" == "ghostty" ]] 块中的 unset 逻辑）
3. 可选：`~/.claude/settings.json` 或 `~/.claude/settings_api_proxy.json`

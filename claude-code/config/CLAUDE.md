# Claude Code 全局指令

用中文沟通。只改必要的代码，不顺便重构。信息不足时假设最可能的情况执行，需要时只问一个问题。

## 记忆系统（两套，禁止重复）

- **claude-mem**（MCP）= 记事实 → 按需 `search` / `get_observations` 查询。开始工作前先查记忆，记忆中已有分析结论则不重复 Read 文件
- **MEMORY.md** = 仅放指向性链接（≤5行），不存事实
- **项目 CLAUDE.md** = 静态架构和规则，每次自动注入

## Token 节省规则

- 先 Glob/Grep 定位，再精确 Read。优先 `smart_outline`（~200 tokens）而非 Read 全文（~2000+）
- 不读 .md 文档（README 等），除非用户要求。遵守 `.claudeignore`
- 并行执行独立操作，减少 API 轮次。回复只展示改动部分

## 终端工具规范

- **Python**：使用 `python3` 和 `pip3`（不用 `python` 或 `pip`）
- **路径**：用 `$HOME` 或 `~` 代替硬编码用户名
- **环境变量**：优先使用工具的完整路径或已配置的环境变量

## 新项目必须包含

1. **`.claudeignore`** — 排除 logs/cache/dist/build/node_modules/venv/docs/*.bak.*/.env*
2. **文档首行标记** — `<!-- ai-doc: 非代码，分析时跳过 -->`
3. **项目 CLAUDE.md** — 架构说明 + 编码约定 + 已完成优化清单

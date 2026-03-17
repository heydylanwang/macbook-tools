---
name: 查询优先级规则
description: 回答问题时的信息来源优先级，避免不必要的高token消耗
type: feedback
---

查询前必须按顺序检查，不得跳级：

1. 本地 `memory/` 文件 → 读 MEMORY.md 索引（~200 tokens）
2. 训练知识直接回答 → 通用知识无需查询
3. claude-mem 历史搜索 → 本项目过去的决策记录
4. 网络/agent 搜索 → 最后手段

**Why:** 用户发现 claude-code-guide agent 单次消耗 38k tokens 抓取网络文档，成本极高。

**How to apply:** 只有满足以下条件才升级到第4级：
- 用户明确要求查最新文档
- 问题涉及可能超出训练知识的最新版本信息
- 前三级均无法给出可信答案

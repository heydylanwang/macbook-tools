# 新项目模板使用指南
<!-- ai-doc: 本文件为文档，Claude Code 分析时可跳过 -->

## 创建新项目时复制以下文件结构

```
my-new-project/
├── .claudeignore              ← 排除非代码文件（必须）
├── .claude/
│   └── CLAUDE.md              ← 项目级 AI 指令（推荐）
├── src/                       ← 源代码
├── config.yaml                ← 配置文件
└── README.md                  ← 首行加 <!-- ai-doc --> 标记
```

## 各文件模板

### .claudeignore
```
# 数据和运行时
logs/
cache/
dist/
build/
node_modules/
__pycache__/
*.pyc
venv/

# 文档（除非明确要求分析）
docs/
*.bak.*

# 环境敏感
.env
.env.*
```

### .claude/CLAUDE.md
```markdown
# [项目名] 项目指令

## 架构概览
（在这里描述项目结构、关键文件、模块关系）

## 关键约定
- 配置统一从 config.yaml 读取
- （其他项目特定约定）

## 已完成的优化
（记录已做过的重构，防止 AI 重复工作）
```

### 文档首行标记
所有 AI 生成的文档必须在第一行包含：
```html
<!-- ai-doc: 本文件为文档，Claude Code 分析时可跳过 -->
```

## 设计原则

1. **配置集中** — 一个 config.yaml，一个读取模块
2. **工具层抽象** — 文本处理、时间处理等提取为共享模块
3. **LLM 调用统一** — 一个入口函数，多级降级
4. **.claudeignore 前置** — 项目创建第一步就配置，不是事后补
5. **项目 CLAUDE.md** — 写给 AI 看的架构文档，比 README 更高效

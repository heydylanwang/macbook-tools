# 目录结构

```
新机器配置/
├── README.md                    # 总览文档
├── install-all.sh              # 全量安装脚本
│
├── claude-code/                # Claude Code 配置
│   ├── README.md               # 使用文档
│   ├── skills-guide.md         # Skills 说明
│   ├── install.sh              # 安装脚本
│   └── config/
│       ├── CLAUDE.md           # 全局规则
│       ├── settings.json       # 权限配置
│       └── memory/
│           └── MEMORY.md       # 记忆模板
│
├── claude-mem/                 # claude-mem 配置
│   ├── README.md               # 使用文档
│   └── install.sh              # 安装脚本
│
├── zsh/                        # zsh 配置
│   ├── README.md               # 使用文档
│   ├── install.sh              # 安装脚本
│   └── config/
│       └── .zshrc              # zsh 配置文件
│
└── ghostty/                    # ghostty 配置
    ├── README.md               # 使用文档
    ├── yazi-guide.md           # yazi 使用指南
    ├── lazygit-guide.md        # lazygit 使用指南
    ├── install.sh              # 安装脚本
    └── config/
        └── ghostty-config      # ghostty 配置文件
```

## 使用说明

### 快速开始
```bash
cd 新机器配置
./install-all.sh
```

### 单独安装
```bash
cd <工具目录>
./install.sh
```

### 配置说明
- 所有配置文件在 `config/` 目录
- 安装脚本会自动备份现有配置
- 不迁移项目数据和仓库

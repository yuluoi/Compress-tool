#!/bin/bash

# ===================================================================
#             个人压缩工具 - 一键部署脚本 (最终优化版)
# ===================================================================

# --- 配置区 ---
# 1. 你的 GitHub 用户名
GITHUB_USER="yuluoi"

# 2. 你的项目仓库名
REPO_NAME="Compress-tool"

# 3. 你想在 Termux 里使用的最终命令名
COMMAND_NAME="yasuo"
# --- 配置结束 ---

# 构造脚本的下载地址
SCRIPT_URL="https://raw.githubusercontent.com/$GITHUB_USER/$REPO_NAME/main/compress.sh"

echo "======================================="
echo "   正在部署个人图片压缩工具..."
echo "======================================="

# 步骤 1: 安装核心依赖
echo ">> 正在安装 imagemagick..."
pkg install imagemagick -y
echo ""

# 步骤 2: 准备安装目录
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
echo ">> 准备安装目录: $INSTALL_DIR"
echo ""

# 步骤 3: 从 GitHub 下载最新的脚本
echo ">> 正在从你的 GitHub 仓库下载脚本..."
echo "   (来源: $SCRIPT_URL)"
curl -Ls "$SCRIPT_URL" -o "$INSTALL_DIR/$COMMAND_NAME"
if [ $? -ne 0 ]; then
    echo "❌ 错误：脚本下载失败！请检查网络或 GitHub 用户名/仓库名配置。" >&2
    exit 1
fi
echo "下载成功！"
echo ""

# 步骤 4: 赋予执行权限
chmod 755 "$INSTALL_DIR/$COMMAND_NAME"
echo ">> 已设置执行权限 (755)。"
echo ""

# 步骤 5: 确保 PATH 配置正确 (已优化)
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ">> 正在将安装目录添加到 Shell 配置中..."
    
    # 检测用户使用的 Shell 配置文件
    if [ -n "$BASH_VERSION" ]; then
        SHELL_CONFIG_FILE="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG_FILE="$HOME/.zshrc"
    else
        SHELL_CONFIG_FILE="$HOME/.profile"
    fi

    # 检查 PATH 是否已在文件中，避免重复添加
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_CONFIG_FILE"; then
        
        # 【关键优化】在追加内容前，先确保文件末尾有一个换行符！
        echo "" >> "$SHELL_CONFIG_FILE"
        
        # 现在再追加我们的 PATH 配置，确保它从新的一行开始
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG_FILE"

        echo "   已将 PATH 配置写入 $SHELL_CONFIG_FILE"
    fi
fi

echo "======================================================"
echo "✅ 部署成功！"
echo "请重启 Termux 会话，然后你就可以使用 '$COMMAND_NAME' 命令了！"
echo "======================================================"

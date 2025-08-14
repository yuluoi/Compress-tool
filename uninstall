#!/bin/bash

# ===================================================================
#             项目卸载与环境清理脚本 (带自毁功能)
#
# 作者: yuluoi
# 功能: 提供安全卸载和彻底清除两种模式。
# ===================================================================

# --- 配置区 ---
# 这是安装后在终端里输入的命令名
COMMAND_NAME="yasuo"
# --- 配置结束 ---


# --- 函数定义 ---

# 执行清理操作的函数
perform_cleanup() {
    local uninstall_pkg=$1 # 接收一个参数，决定是否卸载软件包

    echo ""
    echo "==> 开始执行清理..."

    # 1. 删除已安装的命令
    local COMMAND_PATH="$HOME/.local/bin/$COMMAND_NAME"
    echo -n ">> 正在删除命令 '$COMMAND_NAME'... "
    if [ -f "$COMMAND_PATH" ]; then
        rm -f "$COMMAND_PATH"
        echo "完成。"
    else
        echo "未找到，跳过。"
    fi

    # 2. 删除手机存储中的测试文件夹
    local TEST_DIR="$HOME/storage/shared/compress"
    echo -n ">> 正在删除手机存储中的文件夹 '$TEST_DIR'... "
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        echo "完成。"
    else
        echo "未找到，跳过。"
    fi
    
    # 3. 根据传入的参数决定是否卸载 imagemagick
    if [ "$uninstall_pkg" = true ]; then
        echo -n ">> 正在卸载软件包 'imagemagick'... "
        pkg uninstall imagemagick -y >/dev/null 2>&1
        echo "完成。"
    else
        echo ">> 已跳过卸载 'imagemagick'。"
    fi
    
    echo "✅ 清理操作执行完毕。"
}


# --- 主逻辑开始 ---

echo "======================================="
echo "      项目卸载与环境清理向导"
echo "======================================="
echo "请选择卸载模式："
echo ""
echo "  (a) 安全卸载"
echo "      - 删除 '$COMMAND_NAME' 命令"
echo "      - 删除 '~/storage/shared/compress' 文件夹"
echo "      - [保留] 'imagemagick' 软件包"
echo "      - [保留] 本项目文件夹 ('~/Compress-tool')"
echo ""
echo "  (b) 彻底清除 (包含自毁)"
echo "      - 执行以上所有清理"
echo "      - [卸载] 'imagemagick' 软件包"
echo "      - [删除] 本项目文件夹 ('~/Compress-tool')"
echo "      - [删除] 本卸载脚本自身"
echo ""
echo "  (q) 退出"
echo ""

while true; do
    read -p "请输入您的选择 (a/b/q): " choice
    case ${choice,,} in
        a)
            echo "您选择了 [安全卸载]。"
            read -p "确认执行？ (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                perform_cleanup false # false 表示不卸载软件包
                echo "======================================="
                echo "安全卸载完成。"
            else
                echo "操作已取消。"
            fi
            exit 0
            ;;
        b)
            echo "您选择了 [彻底清除]。"
            echo "⚠️ 警告：此操作不可逆，将删除包括项目源码和卸载脚本在内的所有相关内容！"
            read -p "真的要彻底清除吗？ (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                perform_cleanup true # true 表示卸载软件包

                # 删除项目文件夹
                local PROJECT_DIR="$HOME/Compress-tool" # <-- 已为你修改好
                echo -n ">> 正在删除项目文件夹 '$PROJECT_DIR'... "
                if [ -d "$PROJECT_DIR" ]; then
                    rm -rf "$PROJECT_DIR"
                    echo "完成。"
                else
                    echo "未找到，跳过。"
                fi

                echo "======================================="
                echo "彻底清除完成。本脚本将在退出后消失。"
                
                # 实现自毁
                (sleep 1 && rm -- "$0") &
                
                exit 0
            else
                echo "操作已取消。"
            fi
            exit 0
            ;;
        q)
            echo "操作已取消。"
            exit 0
            ;;
        *)
            echo "无效输入，请输入 a, b, 或 q。"
            ;;
    esac
done

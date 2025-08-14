#!/usr/bin/env bash

# ===================================================================
#                      个人交互式图片压缩脚本
#
# 作者: yuluoi
#
# 功能: 为个人使用定制的交互式图片压缩工具。
# ===================================================================

# --- 默认及预设配置 ---
DEFAULT_QUALITY=85
PRESET_A_RES="1920x1080>" # (a) 高清 - 适用于电脑查看
PRESET_B_RES="1280x720>"  # (b) 标准 - 适用于手机分享
PRESET_C_RES="800x600>"   # (c) 缩略图 - 适用于网页文章

# --- 脚本初始化 ---
# 从命令行参数获取根目录，如果未提供则使用内部存储
TARGET_DIR="${1:-$HOME/storage/shared}"

# 构造完整的输入和输出目录路径
COMPRESS_ROOT_DIR="${TARGET_DIR}/compress"
INPUT_DIR="${COMPRESS_ROOT_DIR}/compress_in"
OUTPUT_DIR="${COMPRESS_ROOT_DIR}/compress_out"

# --- 核心逻辑开始 ---

echo "======================================="
echo "  Termux 交互式图片批量压缩脚本"
echo "======================================="
echo "工作目录: $TARGET_DIR"
echo ""

# 步骤 1: 检查并创建目录 (包含首次运行引导)
IS_FIRST_RUN=false
if [ ! -d "$INPUT_DIR" ]; then
    echo ">> 检测到 'compress_in' 目录不存在，将为您进行首次设置..."
    IS_FIRST_RUN=true
    mkdir -p "$INPUT_DIR"
fi
mkdir -p "$OUTPUT_DIR"

if [ "$IS_FIRST_RUN" = true ]; then
    echo ""
    echo "✅ 目录结构创建成功！"
    echo "   - 输入目录: $INPUT_DIR"
    echo "   - 输出目录: $OUTPUT_DIR"
    echo ""
    echo "------------------ 操作指南 ------------------"
    echo "请将您想要压缩的图片放入 'compress_in' 文件夹中,"
    echo "然后再重新运行本脚本。"
    echo "--------------------------------------------"
    echo ""
    exit 0
fi

# 步骤 2: 使用最健壮的方式查找并过滤出新文件
echo "==> 正在扫描 'compress_in' 目录..."

declare -a files_to_process

while IFS= read -r file; do
    filename=$(basename "$file")
    output_path="$OUTPUT_DIR/$filename"
    if [ ! -f "$output_path" ]; then
        files_to_process+=("$file")
    fi
done < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

if [ ${#files_to_process[@]} -eq 0 ]; then
    echo "🔵 未在 'compress_in' 目录中找到需要处理的新图片。"
    exit 0
fi

# 步骤 3: 列出待处理文件并请求确认
echo "将处理以下 ${#files_to_process[@]} 个文件:"
for file in "${files_to_process[@]}"; do
    echo "  - $(basename "$file")"
done
echo ""

read -p "是否继续处理？ (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "操作已取消。"
    exit 0
fi
echo ""

# 步骤 4: 交互式设定压缩质量
while true; do
    read -p "请输入压缩质量 (1-100, 直接回车使用默认值 $DEFAULT_QUALITY): " quality_input
    if [ -z "$quality_input" ]; then
        QUALITY=$DEFAULT_QUALITY
        break
    fi
    # 注意：这里我们保留了正则表达式，因为我们已经确认了你的 Bash 版本支持它。
    if [[ "$quality_input" =~ ^[0-9]+$ && "$quality_input" -ge 1 && "$quality_input" -le 100 ]]; then
        QUALITY=$quality_input
        break
    else
        echo "无效输入！请输入 1 到 100 之间的数字。"
    fi
done
echo "压缩质量设定为: $QUALITY%"
echo ""

# 步骤 5: 交互式设定图片尺寸 (使用兼容性最好的通配符匹配)
echo "请选择图片尺寸:"
echo "  (a) 高清模式: $PRESET_A_RES (适用于电脑)"
echo "  (b) 标准模式: $PRESET_B_RES (适用于手机)"
echo "  (c) 缩略图模式: $PRESET_C_RES (适用于网页)"
echo "  或直接输入自定义尺寸，格式为 '宽x高>' (例如: 1024x768>)"
echo ""

while true; do
    read -p "请输入您的选择 (a/b/c 或 自定义尺寸): " resolution_input
    
    clean_input=$(echo "$resolution_input" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

    case "$clean_input" in
        a)
            RESOLUTION=$PRESET_A_RES
            break
            ;;
        b)
            RESOLUTION=$PRESET_B_RES
            break
            ;;
        c)
            RESOLUTION=$PRESET_C_RES
            break
            ;;
        [0-9]*x[0-9]*)
            RESOLUTION=$clean_input
            if [[ "$RESOLUTION" != *">" ]]; then
                RESOLUTION="${RESOLUTION}>"
            fi
            break
            ;;
        *)
            echo "无效输入！请输入 a, b, c, 或 '宽x高>' 格式的尺寸。"
            ;;
    esac
done
echo "最大分辨率设定为: $RESOLUTION"
echo ""

# 步骤 6: 开始执行压缩 (正式版，无调试信息)
echo "==> 开始执行压缩任务..."
file_count=0
for file in "${files_to_process[@]}"; do
    filename=$(basename "$file")
    output_path="$OUTPUT_DIR/$filename"

    echo ">> 正在处理: $filename"
    # 直接执行 convert 命令
    convert "$file" -resize "$RESOLUTION" -quality "$QUALITY" -strip "$output_path"
    file_count=$((file_count + 1))
done

echo ""
echo "🎉 成功处理了 $file_count 张图片！"
echo "所有成功压缩的图片已保存到:"
echo "$OUTPUT_DIR"
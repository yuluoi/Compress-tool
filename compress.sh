#!/usr/bin/env bash

# ===================================================================
#                      个人交互式图片处理工具箱
#
# 作者: yuluoi
#
# 功能: 提供图片压缩、清理目录、备份并清理目录等多种功能。
# ===================================================================

# --- 默认及预设配置 ---
DEFAULT_QUALITY=85
PRESET_A_RES="1920x1080>" # (a) 高清 - 适用于电脑查看
PRESET_B_RES="1280x720>"  # (b) 标准 - 适用于手机分享
PRESET_C_RES="800x600>"   # (c) 缩略图 - 适用于网页文章
PRESET_D_RES="1080x1080"  # (d) 正方形模式 - 最终尺寸

# --- 脚本初始化 ---
# 从命令行参数获取根目录，如果未提供则使用内部存储
TARGET_DIR="${1:-$HOME/storage/shared}"

# 构造核心工作目录路径
COMPRESS_ROOT_DIR="${TARGET_DIR}/compress"
INPUT_DIR="${COMPRESS_ROOT_DIR}/compress_in"
OUTPUT_DIR="${COMPRESS_ROOT_DIR}/compress_out"
BACKUP_DIR="$HOME/storage/shared/Download" # 备份目录硬编码为Download文件夹

# --- 函数定义 ---

# 清理目录的函数
cleanup_directory() {
    local dir_to_clean=$1
    local dir_name=$2
    local backup_mode=$3 # 第三个参数，'true' 表示备份模式

    echo "==> 准备操作目录: $dir_name"
    
    mapfile -t files_to_operate < <(find "$dir_to_clean" -maxdepth 1 -type f)
    
    if [ ${#files_to_operate[@]} -eq 0 ]; then
        echo "🔵 目录 '$dir_name' 为空，无需操作。"
        return
    fi

    if [ "$backup_mode" = true ]; then
        echo "将在 '$dir_name' 目录中【备份并清除】以下 ${#files_to_operate[@]} 个文件:"
    else
        echo "将在 '$dir_name' 目录中【直接清除】以下 ${#files_to_operate[@]} 个文件:"
    fi

    for file in "${files_to_operate[@]}"; do
        echo "  - $(basename "$file")"
    done
    echo ""

    read -p "⚠️ 警告：此操作不可逆！确认执行吗？ (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "操作已取消。"
        return
    fi

    if [ "$backup_mode" = true ]; then
        # 备份模式
        echo ">> 正在备份文件到 $BACKUP_DIR 并重命名..."
        for file in "${files_to_operate[@]}"; do
            filename=$(basename "$file")
            # 复制并重命名
            cp "$file" "$BACKUP_DIR/压缩图片$filename"
        done
        echo ">> 备份完成。正在清理原目录..."
    fi
    
    # 清理操作
    rm -f "${dir_to_clean}"/*
    echo "✅ 目录 '$dir_name' 已被清空。"
}


# --- 主逻辑开始 ---

# 确保核心目录存在
mkdir -p "$INPUT_DIR"
mkdir -p "$OUTPUT_DIR"
# 确保备份目录存在
mkdir -p "$BACKUP_DIR"

# 主菜单
echo "======================================="
echo "      个人图片处理工具箱"
echo "======================================="
echo "请选择要执行的操作:"
echo "  (1) 开始压缩图片"
echo ""
echo "--- 清理输入目录 (compress_in) ---"
echo "  (2) [直接清除] 输入目录"
echo "  (3) [备份并清除] 输入目录"
echo ""
echo "--- 清理输出目录 (compress_out) ---"
echo "  (4) [直接清除] 输出目录"
echo "  (5) [备份并清除] 输出目录"
echo ""
echo "  (q) 退出"
echo ""

read -p "请输入您的选择: " main_choice

case ${main_choice,,} in
    1)
        # --- 压缩图片的逻辑 ---
        echo "==> 开始执行图片压缩流程..."
        
        # 查找新文件
        declare -a files_to_process
        while IFS= read -r file; do
            filename=$(basename "$file")
            output_path="$OUTPUT_DIR/$filename"
            if [ ! -f "$output_path" ]; then files_to_process+=("$file"); fi
        done < <(find "$INPUT_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

        if [ ${#files_to_process[@]} -eq 0 ]; then echo "🔵 未在 'compress_in' 目录中找到需要处理的新图片。"; exit 0; fi

        # 列出文件并确认
        echo "将处理以下 ${#files_to_process[@]} 个文件:"
        for file in "${files_to_process[@]}"; do echo "  - $(basename "$file")"; done; echo ""
        read -p "是否继续处理？ (y/n): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then echo "操作已取消。"; exit 0; fi; echo ""

        # 设定质量
        while true; do
            read -p "请输入压缩质量 (1-100, 回车默认 $DEFAULT_QUALITY): " quality_input
            if [ -z "$quality_input" ]; then QUALITY=$DEFAULT_QUALITY; break; fi
            if [[ "$quality_input" =~ ^[0-9]+$ && "$quality_input" -ge 1 && "$quality_input" -le 100 ]]; then QUALITY=$quality_input; break; else echo "无效输入！"; fi
        done
        echo "压缩质量设定为: $QUALITY%"; echo ""

        # 设定尺寸 (包含正方形模式)
        echo "请选择图片尺寸:"
        echo "  (a) 高清: $PRESET_A_RES  (b) 标准: $PRESET_B_RES"
        echo "  (c) 缩略图: $PRESET_C_RES  (d) 正方形: $PRESET_D_RES"
        echo "  或输入自定义尺寸 (例如: 1024x768>)"
        
        CONVERT_PARAMS=""
        while true; do
            read -p "请输入选择 (a/b/c/d 或 自定义): " res_input
            clean_input=$(echo "$res_input"|tr -d '[:space:]'|tr '[:upper:]' '[:lower:]')
            case "$clean_input" in
                a) CONVERT_PARAMS="-resize '$PRESET_A_RES'"; echo "分辨率设为: $PRESET_A_RES"; break ;;
                b) CONVERT_PARAMS="-resize '$PRESET_B_RES'"; echo "分辨率设为: $PRESET_B_RES"; break ;;
                c) CONVERT_PARAMS="-resize '$PRESET_C_RES'"; echo "分辨率设为: $PRESET_C_RES"; break ;;
                d) CONVERT_PARAMS="SQUARE_MODE"; echo "已选正方形模式: $PRESET_D_RES"; break ;;
                [0-9]*x[0-9]*)
                    RES=$clean_input
                    if [[ "$RES" != *">" ]]; then RES="${RES}>"; fi
                    CONVERT_PARAMS="-resize '$RES'"; echo "分辨率设为: $RES"; break ;;
                *) echo "无效输入！" ;;
            esac
        done; echo ""

        # 开始执行压缩
        echo "==> 开始执行压缩任务..."
        file_count=0
        for file in "${files_to_process[@]}"; do
            filename=$(basename "$file")
            output_path="$OUTPUT_DIR/$filename"
            echo ">> 正在处理: $filename"
            if [ "$CONVERT_PARAMS" == "SQUARE_MODE" ]; then
                dims=$(identify -format "%wx%h" "$file")
                width=$(echo $dims|cut -d'x' -f1); height=$(echo $dims|cut -d'x' -f2)
                if [ $width -lt $height ]; then crop_size=${width}x${width}; else crop_size=${height}x${height}; fi
                convert "$file" -gravity Center -extent "$crop_size" -resize "$PRESET_D_RES" -quality "$QUALITY" -strip "$output_path"
            else
                eval "convert \"$file\" $CONVERT_PARAMS -quality \"$QUALITY\" -strip \"$output_path\""
            fi
            file_count=$((file_count + 1))
        done

        echo ""; echo "🎉 成功处理了 $file_count 张图片！"; echo "所有成功压缩的图片已保存到: $OUTPUT_DIR"
        ;;
    2)
        cleanup_directory "$INPUT_DIR" "compress_in" false
        ;;
    3)
        cleanup_directory "$INPUT_DIR" "compress_in" true
        ;;
    4)
        cleanup_directory "$OUTPUT_DIR" "compress_out" false
        ;;
    5)
        cleanup_directory "$OUTPUT_DIR" "compress_out" true
        ;;
    q)
        echo "已退出。"
        exit 0
        ;;
    *)
        echo "无效选择，脚本已退出。"
        exit 1
        ;;
esac

#!/bin/bash
# 该脚本用于批量对每个样本生成处理脚本

SAMPLE_LIST="sample.list"

if [[ ! -f "$SAMPLE_LIST" ]]; then
    echo "错误：未找到样本列表文件 $SAMPLE_LIST"
    exit 1
fi

echo "开始为 sample.list 中的每个样本生成处理脚本..."

while IFS= read -r sample_name || [[ -n "$sample_name" ]]; do
    [[ -z "$sample_name" ]] && continue
    [[ "$sample_name" =~ ^#.* ]] && continue

    if [[ -d "./$sample_name" ]]; then
        SCRIPT_PATH="./$sample_name/script.${sample_name}.sh" ## 替换脚本名称

        cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
# 替换脚本内容
EOF

        # 用 sed 替换 SAMPLE 占位符
        sed -i "s/SAMPLE/${sample_name}/g" "$SCRIPT_PATH"

        chmod +x "$SCRIPT_PATH"

	# 提交脚本
        cd "./$sample_name"
        nohup bash "script.${sample_name}.sh" > "script.${sample_name}.log" 2>&1 & ## 替换脚本名称
        cd ..

        echo "已生成并提交脚本： $SCRIPT_PATH"
    else
        echo "警告：样本目录 '$sample_name' 不存在，已跳过。"
    fi
done < "$SAMPLE_LIST"

echo "所有脚本生成完毕！"

import os
import re

# ================= 配置区域 =================
# 1. 设置操作模式: "add" (添加rect) 或 "remove" (移除rect)
MODE = "add" 

# 2. 设置目标路径 (可以是文件夹，也可以是单个 .md 文件路径)
# TARGET_PATH = r"C:\Users\Name\Obsidian\CS231n\lecture_17.md"  # 单文件
TARGET_PATH = r"./zk/zk/10-Algorithms/"                 # 文件夹
# ===========================================

def process_content(content, mode):
    """根据模式处理文本内容"""
    
    # 【添加模式】
    # 逻辑：匹配 .pdf#page=数字，且后面紧跟着闭括号 ) (即不存在 rect)，插入 rect
    if mode == "add":
        # Regex:
        # Group 1: ![...](...pdf#page=123
        # Negative Lookahead: (?!.*&rect=) 确保这一行后面没有 &rect=
        # Group 2: )
        pattern = re.compile(r'(!\[.*?\]\(.*?\.pdf#page=\d+)(?!.*&rect=)(.*?\))')
        replacement = r'\1&rect=0,0,960,540\2'
        return pattern.subn(replacement, content)

    # 【移除模式】（逆过程）
    # 逻辑：匹配 .pdf#page=数字，后面跟着 &rect=...，将其删除
    elif mode == "remove":
        # Regex:
        # Group 1: ![...](...pdf#page=123
        # Match: &rect=数字,数字,数字,数字 (非贪婪匹配)
        # Group 2: )
        pattern = re.compile(r'(!\[.*?\]\(.*?\.pdf#page=\d+)(&rect=[\d,]+)(.*?\))')
        # 替换为 Group 1 + Group 2 (即把中间的 rect 丢掉)
        replacement = r'\1\3'
        return pattern.subn(replacement, content)

def run_task():
    # 检查路径是否存在
    if not os.path.exists(TARGET_PATH):
        print(f"错误: 路径不存在 -> {TARGET_PATH}")
        return

    # 收集需要处理的文件列表
    files_to_process = []
    if os.path.isfile(TARGET_PATH):
        if TARGET_PATH.endswith(".md"):
            files_to_process.append(TARGET_PATH)
    else:
        for root, dirs, files in os.walk(TARGET_PATH):
            for file in files:
                if file.endswith(".md"):
                    files_to_process.append(os.path.join(root, file))

    total_changes = 0
    print(f"正在执行模式: [{MODE.upper()}] ...")

    for file_path in files_to_process:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            new_content, count = process_content(content, MODE)
            
            if count > 0:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f"  [修改 {count} 处] {os.path.basename(file_path)}")
                total_changes += count
        except Exception as e:
            print(f"  [出错] {file_path}: {e}")

    if total_changes == 0:
        print("未发现需要修改的地方。")
    else:
        print(f"完成！共修改了 {total_changes} 处链接。")

if __name__ == "__main__":
    run_task()

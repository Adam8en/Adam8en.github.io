#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

# ================= 配置区域 =================
# 目标目录
POSTS_DIR = r'D:\hexo\source\_posts'

# 你的样式后缀
SUFFIX = '?x-oss-process=style/blog'

# 阿里云域名关键词 (用于识别)
OSS_KEYWORD = 'aliyuncs.com'
# ===========================================

def process_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # --- 核心正则逻辑 ---
    # 解释：匹配 http(s)://...aliyuncs.com/... 
    # 直到遇到 空格、引号("或')、反括号)、逗号, 或 HTML标签结束符
    # 这样可以兼容 cover: url、{% image url, ... %}、![...](url) 等各种情况
    url_pattern = re.compile(r'(https?://[^\s"\'\),<]*' + re.escape(OSS_KEYWORD) + r'[^\s"\'\),<]*)')

    def replace_callback(match):
        url = match.group(1)
        
        # 1. 如果已经包含 style/blog，跳过
        if 'style/blog' in url:
            return url
            
        # 2. 如果包含旧的 x-oss-process 参数，替换掉
        if '?x-oss-process=' in url:
            # 找到参数开始的位置
            base_url = url.split('?x-oss-process=')[0]
            return base_url + SUFFIX
        
        # 3. 如果包含其他参数 (比如 ?token=...)，用 & 拼接 (虽然 OSS 公共读很少见这种情况)
        if '?' in url:
             return url + '&' + SUFFIX.replace('?', '')
             
        # 4. 纯净 URL，直接加后缀
        return url + SUFFIX

    new_content = url_pattern.sub(replace_callback, content)

    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed: {os.path.basename(file_path)}")
        return True
    else:
        return False

def main():
    print(f"Start scanning in: {POSTS_DIR}")
    print("Mode: Universal Link Fixer (cover, tags, markdown, html)")
    print("-" * 30)
    
    count = 0
    for root, dirs, files in os.walk(POSTS_DIR):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                if process_file(file_path):
                    count += 1
                    
    print("-" * 30)
    print(f"Done. Modified {count} files.")
    print("注意：由于修改了文件内容，Git 会检测到变动，'update.py' 可能会更新这些文章的时间戳。")
    print("这是为了修复图片链接所必须的，请接受这次变更。")

if __name__ == '__main__':
    main()
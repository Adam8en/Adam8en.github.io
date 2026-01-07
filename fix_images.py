#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

# ================= 配置区域 =================
# 1. 你的 OSS 域名关键词 (保持默认即可)
OSS_DOMAIN_KEYWORD = 'aliyuncs.com'

# 2. 你的样式后缀 (已改为你设置的 style/blog)
SUFFIX = '?x-oss-process=style/blog'

# 3. 文章目录
POSTS_DIR = r'D:\hexo\source\_posts'
# ===========================================

def process_file(file_path):
    # 【关键】先记录文件的原始时间，防止 Hexo 认为文章被更新了
    file_stat = os.stat(file_path)
    original_atime = file_stat.st_atime
    original_mtime = file_stat.st_mtime

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # --- 正则替换逻辑 ---
    
    # 1. 处理 Markdown 格式图片: ](http...aliyuncs.com/...)
    # 逻辑：找到阿里云链接，不管后面有没有旧参数，统统切掉，换成新的样式后缀
    def replace_md_link(match):
        clean_url = match.group(1) # 拿到纯净的 URL (不带问号后面的参数)
        return f']({clean_url}{SUFFIX})'

    # 正则：匹配 ](url) 结构，非贪婪匹配直到遇到问号或反括号
    # 这一行会精准提取 http://.../xxx.jpg 这一段
    pattern_md = re.compile(r'\]\((https?://[^\s)?]*' + re.escape(OSS_DOMAIN_KEYWORD) + r'[^\s)?]*)(?:\?[^\s)]*)?\)')
    new_content = pattern_md.sub(replace_md_link, content)
    
    # 2. 处理 HTML 格式图片: src="http..." (如果有的话)
    def replace_html_link(match):
        clean_url = match.group(1)
        return f'src="{clean_url}{SUFFIX}"'
        
    pattern_html = re.compile(r'src=[\'"](https?://[^\'"]*?' + re.escape(OSS_DOMAIN_KEYWORD) + r'[^\'"]*?)(?:\?[^\'"]*)?[\'"]')
    new_content = pattern_html.sub(replace_html_link, new_content)

    # --- 保存逻辑 ---
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        # 【关键】把时间改回去，实现“无感修改”
        os.utime(file_path, (original_atime, original_mtime))
        print(f"Fixed: {os.path.basename(file_path)}")
        return True
    else:
        return False

def main():
    print(f"Target: {POSTS_DIR}")
    print(f"Style:  {SUFFIX}")
    print("-" * 30)
    
    count = 0
    for root, dirs, files in os.walk(POSTS_DIR):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                if process_file(file_path):
                    count += 1
                    
    print("-" * 30)
    print(f"Done. Processed {count} files.")

if __name__ == '__main__':
    main()
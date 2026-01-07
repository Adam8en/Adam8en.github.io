#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

POSTS_DIR = r'D:\hexo\source\_posts'
KEYWORD = 'aliyun' # 放宽关键词，抓取所有包含 aliyun 的内容

def scan_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    found_in_file = False
    filename = os.path.basename(file_path)

    for i, line in enumerate(lines):
        if KEYWORD in line:
            # 排除掉已经被脚本处理过的（包含 style/blog 的）
            if 'style/blog' in line:
                continue
                
            found_in_file = True
            print(f"📄 文件: {filename} (第 {i+1} 行)")
            print(f"   原始内容: {line.strip()}")
            
            # 简单的格式分析
            if '](' in line and ')' in line:
                print("   -> 格式判断: 标准 Markdown 行内链接 (应该被捕获)")
            elif '<img' in line:
                print("   -> 格式判断: HTML 标签 (应该被捕获)")
            elif ']:' in line:
                print("   -> ⚠️ 格式判断: 引用式链接 (之前的脚本不支持！)")
            else:
                print("   -> ⚠️ 格式判断: 未知/纯文本链接 (之前的脚本不支持！)")
            print("-" * 20)

    return found_in_file

def main():
    print(f"正在诊断目录: {POSTS_DIR}")
    print("只显示包含 'aliyun' 但没有 'style/blog' 后缀的行...")
    print("=" * 40)
    
    count = 0
    for root, dirs, files in os.walk(POSTS_DIR):
        for file in files:
            if file.endswith('.md'):
                if scan_file(os.path.join(root, file)):
                    count += 1
    
    print("=" * 40)
    print(f"诊断完成。发现 {count} 个文件含有未处理的阿里云链接。")
    print("请查看上方日志，如果在 '⚠️' 标记处发现了大量链接，那就是漏掉的原因。")

if __name__ == '__main__':
    main()
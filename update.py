#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import time
import re
import subprocess

# 设定编码
file_encoding = 'utf-8'

def get_current_time():
    """获取当前系统时间"""
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

def get_git_modified_files(path):
    """
    利用 Git 命令获取当前被修改过的文件列表
    返回: 文件路径的 list
    """
    modified_files = []
    try:
        # 执行 git status -s 命令，获取简短状态
        # -s 输出格式例如: " M source/_posts/hello.md" 或 "?? source/_posts/new.md"
        result = subprocess.check_output(['git', 'status', '-s'], cwd=path).decode('utf-8')
        
        lines = result.splitlines()
        for line in lines:
            # 只有当文件状态包含 'M' (Modified) 或者 'A' (Added) 或者 '??' (Untracked) 时才处理
            # 这里我们主要关注 'M'，即内容被修改过的文件
            status = line[:2]
            file_rel_path = line[3:].strip() # 去掉前面的状态标识和空格
            
            # 只有 .md 文件才处理
            if file_rel_path.endswith('.md'):
                # 处理一下路径引用（去掉双引号，有些git版本中文路径会带引号）
                if file_rel_path.startswith('"') and file_rel_path.endswith('"'):
                    file_rel_path = file_rel_path[1:-1]
                
                # 拼接完整路径
                full_path = os.path.join(path, file_rel_path)
                
                # 再次确认文件存在
                if os.path.exists(full_path):
                    modified_files.append(full_path)
                    
    except subprocess.CalledProcessError:
        print("Error: Git command failed. Make sure this is a git repository.")
    except FileNotFoundError:
        print("Error: Git not installed or not found in PATH.")
        
    return modified_files

def update_file_timestamp(file_path):
    """读取文件并更新 updated 字段"""
    try:
        with open(file_path, 'r', encoding=file_encoding) as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return

    # 正则匹配 Front-matter
    front_matter_pattern = re.compile(r'^---\n(.*?)\n---', re.DOTALL)
    match = front_matter_pattern.search(content)

    if not match:
        print(f"Skipped (No Front-matter): {file_path}")
        return

    header_content = match.group(1)
    current_time = get_current_time()
    
    # 核心逻辑：查找 updated 字段
    if re.search(r'^updated:', header_content, re.MULTILINE):
        # 如果存在，替换为当前时间
        new_header = re.sub(r'^updated:.*$', f'updated: {current_time}', header_content, flags=re.MULTILINE)
        action = "Updated Time"
    else:
        # 如果不存在，在 date 后插入
        if re.search(r'^date:', header_content, re.MULTILINE):
            new_header = re.sub(r'(^date:.*$)', f'\\1\nupdated: {current_time}', header_content, flags=re.MULTILINE)
        else:
            new_header = header_content + f'\nupdated: {current_time}'
        action = "Added Time"

    # 如果内容没变（比如短时间内运行了两次），跳过写入
    if new_header == header_content:
        return

    new_content = content.replace(f'---\n{header_content}\n---', f'---\n{new_header}\n---', 1)

    with open(file_path, 'w', encoding=file_encoding) as f:
        f.write(new_content)
    
    print(f"===> [{action}]: {os.path.basename(file_path)} -> {current_time}")

def main():
    # 获取当前脚本所在目录（通常是博客根目录）
    # 或者你可以写死绝对路径，比如 blog_root = "D:\\hexo"
    blog_root = os.getcwd() 
    
    print(f"Checking git status in: {blog_root} ...")
    
    # 1. 问 Git：哪些文件被改了？
    target_files = get_git_modified_files(blog_root)
    
    if not target_files:
        print("No modified markdown files found in Git status.")
        return

    print(f"Found {len(target_files)} modified file(s). Updating timestamps...")

    # 2. 只处理这些文件
    for file_path in target_files:
        update_file_timestamp(file_path)
        
    print("Done.")

if __name__ == '__main__':
    main()
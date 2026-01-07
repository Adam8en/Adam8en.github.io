@echo off
cd D:\hexo
python update.py D:\hexo\source\_posts
hexo cl&&hexo generate&&hexo deploy
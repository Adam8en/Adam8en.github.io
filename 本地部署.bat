@echo off
:: 防止中文乱码
chcp 65001 >nul
title Hexo 本地预览模式

echo =======================================================
echo          正在启动 Hexo 本地预览 (Local Server)
echo =======================================================
echo.

:: 切换目录
cd /d D:\hexo

echo [1/3] 正在清理缓存...
call hexo clean

echo.
echo [2/3] 正在生成静态文件...
call hexo generate

echo.
echo [3/3] 启动本地服务器...
echo -------------------------------------------------------
echo 请在浏览器访问: http://localhost:4000
echo 按 Ctrl + C 可以停止服务器
echo -------------------------------------------------------
:: 使用 server 全称，更稳定
call hexo server

pause
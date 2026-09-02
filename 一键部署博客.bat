@echo off
setlocal
:: 设置编码为 UTF-8，防止中文乱码
chcp 65001 >nul
title Hexo 博客一键自动部署与备份

echo =======================================================
echo            Hexo 博客智能部署助手 v3.2 (豆瓣版)
echo =======================================================
echo.

:: [关键] 切换到博客根目录
cd /d D:\hexo
if errorlevel 1 goto :failed

:: ---------------------------------------------------------
:: 第 1 步：智能更新时间戳
:: ---------------------------------------------------------
echo [1/6] 正在调用 Python 检查文章变动...
python update.py
if errorlevel 1 goto :failed

:: ---------------------------------------------------------
:: 第 2 步：清理缓存
:: ---------------------------------------------------------
echo.
echo [2/6] 正在清理缓存...
call hexo clean
if errorlevel 1 goto :failed

:: ---------------------------------------------------------
:: 第 3 步：【新增】爬取豆瓣书单数据
:: ---------------------------------------------------------
echo.
echo [3/6] 正在同步豆瓣书单数据...
:: -b 表示只爬取书籍 (books)，如果你以后开了电影或游戏，可以去掉 -b 爬取所有
call hexo douban -b
if errorlevel 1 goto :failed

:: ---------------------------------------------------------
:: 第 4 步：生成静态网页
:: ---------------------------------------------------------
echo.
echo [4/6] 正在生成静态页面...
call hexo generate
if errorlevel 1 goto :failed

:: ---------------------------------------------------------
:: 第 5 步：部署到 GitHub Pages
:: ---------------------------------------------------------
echo.
echo [5/6] 正在部署网页到 GitHub Pages (master 分支)...
call hexo deploy
if errorlevel 1 goto :failed

:: ---------------------------------------------------------
:: 第 6 步：备份源代码
:: ---------------------------------------------------------
echo.
echo [6/6] 正在备份源代码到 GitHub (hexo 分支)...
git add --all
if errorlevel 1 goto :failed

git diff --cached --quiet
if errorlevel 2 goto :failed
if errorlevel 1 (
    git commit -m "Site Update (with Douban): %date% %time%"
    if errorlevel 1 goto :failed
) else (
    echo 没有新的源代码改动，跳过提交。
)

git push origin hexo
if errorlevel 1 goto :failed

echo.
echo =======================================================
echo  恭喜！博客更新、部署、备份全流程已完成！
echo =======================================================
echo.
pause
exit /b 0

:failed
echo.
echo =======================================================
echo  操作失败，流程已停止。请检查上方的错误信息。
echo =======================================================
echo.
pause
exit /b 1

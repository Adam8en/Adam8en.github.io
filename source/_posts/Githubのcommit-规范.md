---
title: Githubのcommit 规范
date: 2024-10-15 23:13:14
updated: 2024-10-15 23:13:14
tags: 
  - 杂谈
categories: 杂谈
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/4C04B4E3A66D79005E4BB402DFC0E397.jpg
description: 简要的阐述了github中提交代码的格式规范
---

> 本文转载于[Github提交规范 | WAHAHA's blog (gngtwhh.space)](https://gngtwhh.space/20248befcc09ef89/)

## 为什么要规定提交规范

团队协作开发时，每个人提交都会编写自己的`commit message`。

如果不加以规范，最终项目就会杂乱不堪,难以管理。

一般的大厂，大型开源项目的`commit message`格式是非常一致的，便于管理，提高效率。

## Git提交规范

为了方便使用，我们避免了过于复杂的规定，格式较为简单且不限制中英文：

~~~bash
<type>(<scope>): <subject>
// 注意冒号 : 后有空格
// 如 feat(miniprogram): 增加了小程序模板消息相关功能
~~~

{% bubble scope,"选填" ,"#868fd7" %}表示commit的作用范围，如数据层、视图层，也可以是目录名称。

{% bubble subject,"必填" ,"#868fd7" %}用于对commit进行简短的描述。

{% bubble type,"必填" ,"#868fd7" %}表示提交类型，值有以下几种：

- feat - 新功能 feature
- fix - 修复 bug
- docs - 文档注释
- style - 代码格式(不影响代码运行的变动)
- refactor - 重构、优化(既不增加新功能，也不是修复bug)
- perf - 性能优化
- test - 增加测试
- chore - 构建过程或辅助工具的变动
- revert - 回退
- build - 打包

---

![4C04B4E3A66D79005E4BB402DFC0E397](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/4C04B4E3A66D79005E4BB402DFC0E397.jpg)

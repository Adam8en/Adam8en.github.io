---
title: easy_md5のWP——SQL下的弱类型比较
tags:
  - SQL注入
  - CTF
  - Web
date: 2024-02-20 22:43:10
categories: CTF Write Up
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/AceAttorneyArtGallery.png?x-oss-process=style/blog
description: 关于MySQL中的“万能密码”和弱类型比较小记。
updated: 2024-02-20 23:04:30
---


于NSSCTF上刷到此题，觉得颇有几处新意，故整理一份WP，题目传送门如下：[(BJDCTF 2020\)easy_md5 | NSSCTF](https://www.nssctf.cn/problem/713)。

## 题解

话不多说开启容器。

![image-20240220222234112](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240220222234112.png?x-oss-process=style/blog)

可以看到的是，进入题目后只有一份提交文本框，没什么其他信息。随便提交一个数字，网页的URL引起了我的注意。

```plain text
http://node4.anna.nssctf.cn:28685/leveldo4.php?password=1
```

嗯，看起来像是个SQL注入。但是用sqlmap爆破无果，用BurpSuite抓包也没有得到什么有用的信息。但其实还是有信息的，如果你仔细观察响应报文，会发现文件头中出现了hint。

![image-20240220222555176](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240220222555176.png?x-oss-process=style/blog)

```plain text
hint: select * from 'admin' where password=md5($pass,true)
```

果然是一条经典的MySQL语句

接下来的问题就是怎么让这条语句成立然后给出我们想要的信息了。

经过查阅资料后得知MySQL中的“万能密码”`ffifdyop`。这串字符被md5函数编码后变成`276f722736c95d99e921722cf9ed621c`，随后再经过MySQL编码就变成了`'or'6xxx`。其中xxx的部分是无关字符串，但是由于该字符串以6开头而被MySQL认为是整形，再和前方的部分拼接在一起，整条语句就变成了如下形式。

```mysql
select * from 'admin' where password ''or'6xxx'
```

此时该SQL语句恒成立，成功执行后跳转到levels91.php，查看源代码。

![](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240220223615134.png?x-oss-process=style/blog)

接下来就是简单的PHP弱类型比较了，这里可以上传md5碰撞值，也可以上传数组变量a、b，还可以直接跳转到levell14.php。

跳转到levell14.php后出现以下代码。

![image-20240220223810982](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240220223810982.png?x-oss-process=style/blog)

同样的思路，由于是强类型比较所以上传碰撞值的方法失效，此时上传数组变量param1和param2即可。

## 总结

这题难度较为简单，但是关于万能密码**ffifdyop**的知识点也十分重要，有单独写一篇WP的必要，权当积累。

![AceAttorneyArtGallery](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/AceAttorneyArtGallery.png?x-oss-process=style/blog)

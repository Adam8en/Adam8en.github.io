---
title: 从零开始学Python（一）
date: 2023-09-04 14:20:36
tags: Python
categories: Python学习
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2082457624_p0.png?x-oss-process=style/blog
description: Python的起步，基本数据类型和列表
updated: 2023-10-17 23:48:01
---



零零散散更新一些Python随笔录，我用的书是《Python编程：从入门到实践》，主要是参照这本书写一些知识点。

----

# 一、起步

安装好环境以后就可以开始进行Python学习了，怎么安装环境不多赘述。

关于编辑器，我暂且用的是VsCode。本来想用Sublime Text的，但是懒得折腾了。

Pycharm和Visual Studio也是可以的，后者功能全面，但是太过笨重，比较适合新手使用。

# 二、变量和基本数据类型

## 变量

Python中的变量不需要实现声明其数据类型，这一点和C不同，即开即用，十分方便。

```python
name="Adam Ben"
```

## print函数

和C语言的printf函数有些类似，但是引用变量的方式有些许差异。

```c
char name[10]="Adam Ben";
printf("Hi,%s",name);//C语言打印名字
```

```python
name="Adam Ben"
print(f"Hi {name}")#Python打印名字
```

在前引号前加入f告诉编译器替换花括号中变量的值。

当然也可以不使用f语法，而是使用format()方法。

```python
name="Adam Ben"
print("{}".format(name))
```

## 其他相关输出函数

```python
name=" Adam Ben "
name.rstrip()#删除字符串末尾空白
name.lstrip()#删除字符串头部空白
name.strip()#删除字符串两边空白
name.title()#首字母大写
name.upper()#字符串大写
name.lower()#字符串小写
```

## 数

Python能够通过+、-、*、/进行四则运算。

其中//表示强制除法，取整而舍弃余数。

在除法运算中，得到的计算结果总为浮点数。在其他任何运算中（//例外），只要有一方是浮点数，那么结果总为浮点数。

在Python中，大数无位数限制，而C语言通常由它的数据类型决定（int、long……）。这就意味着Python可以进行大数运算。但是仍然存在小数位数强制截断的问题。

Python中可以给大数加入下划线进行分组，但是输出时Python不会将下划线打印出来。

Python可以同时给多个变量赋值。

```python
a,b,c=1,2.3,14_000_000_000
'''
c
>>>14000000000
'''
```

## 注释

Python使用井号#表示注释，编译器会自动忽略#后的内容。

或者使用'''xxx'''来插入跨行字符串用于注释。

而C语言则是使用双反斜杠用于注释 \\\\

## Python之禅

在Python中使用import this可查看。

```python
import this
'''
The Zen of Python, by Tim Peters

Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
'''
```

# 三、列表简介

## 什么是列表

一位唤作wahaha的贤者注释道，列表是“可扩容的动态数组”。我觉得还可以加几句，列表是“不限制数据类型可扩容的动态数组”。（相较于C来说）

如果在C中想要实现Python的列表，估计得手搓一个动态链表。

```python
example=['Adam','Ben','JJG']#列表元素之间使用逗号分隔
'''
print(example)
>>>['adam','Ben','JJG']
输出包括方括号
'''
```

当然，我们不想让Python输出方括号，所以我们使用索引，用法和C语言大致相同。

```python
print(example[0])
print(example[0].title())#也可以使用title函数
'''
>>>adam
Adam
'''
```

和C语言的区别是，Python对于列表可以采用负数索引，比如example[-1]就是输出'JJG'，也就是输出列表最后一个元素，同理采用-2作为索引即输出倒数第二个元素，以此类推。

这个特性非常有用，有时候我们并不知道列表长度，此时采用负数索引即可更为方便的输出列表后位元素。

## 修改、添加、删除列表元素

**修改**列表元素很简单，相当于对数组元素进行重新赋值，修改对应的索引对应值就好。

```python
example=['Adam','Ben','JJG']
example[0]='jjg'
'''
print(example[0])
>>>jjg
'''
```

在列表中**添加**元素要用到append函数。

```python
example=['Adam','Ben','JJG']
example.append()['jjg']
'''
print(example)
>>>['Adam','Ben','JJG','jjg']
'''
```

在列表中**插入**元素要用到insert函数。使用方法为insert(n,"xxx")，表示在第n个元素前插入"xxx"。

```python
example=['Adam','Ben','JJG']
example.insert(0,'jjg')
'''
pirnt(example)
['jjg','Adam','Ben','JJG']
'''
```

从列表中**删除**元素涉及到三个函数，分别是del，pop和remove。

del函数直接删除列表元素，而pop函数则是类似于“弹出”列表末尾元素让你能够接着使用它，而remove函数则是根据元素值而不是索引删除元素。

```python
example=['Adam','Ben','JJG']
del example[0]#删除第一个元素1
print(example)
J=example.pop()#删除末尾元素，并把值赋给变量J
#当pop(x)括号内有值时，可根据索引弹出任意列表元素值，否则默认弹出末尾值
print(example)
print(J)
example.remove(JJG)#总是从左往右删除第一个符合的值
#如果需要删除的值在列表中出现多次，那么就引入循环来确保值被删除
print(example)
'''
>>>['Ben','JJG']
['Ben']
'JJG'
[]
'''
```

## 组织列表

可以使用sort函数对列表进行永久性的排序，或者是sorted函数进行暂时性的排序，也就是仅对返回值进行排序。

排序方式是按照字母的大小顺序进行，也就是a-z。本质上是基于ASCII码进行的排序，也就是说sort函数会优先进行大写字母排序，而且大写字母将永远排在小写字母前。当首字母相同时，排序第二个字母，以此类推。

向sort函数传递参数reverse=True可以按照与字母排序相反的规则排序。

**注意sort函数和sorted函数的使用区别。**

```python
example=['Ben','Adam','JJG']
print(sorted(example))
example.sort(reverse=True)
print(example)
'''
>>>['Adam', 'Ben', 'JJG']
['JJG', 'Ben', 'Adam']
'''
```

还可以使用reverse函数对列表进行倒序排列。reverse函数并不是按字母倒序排列列表，而只是简单的反转了列表排列顺序。

虽然reverse函数会永久性改变列表排列顺序，但是想要恢复并不难，再使用一次reverse函数即可。

```python
example=['Ben','Adam','JJG']
example.reverse()
'''
print(example)
>>>['JJG', 'Adam', 'Ben']
'''
```

此外，还可以用len函数确定列表长度，这点类似于C语言中String.h头文件下的length()函数。

```python
example=['Ben','Adam','JJG']
print(len(example))
'''
>>>3
'''
```

除此之外，留意由于索引引发的错误，常见于引用一个列表中并不存在的元素。比如在example列表中要求输出example[3]，这将会引发IndexError。

遇到此类情况时，最好的办法是使用-1来作为索引，因为它永远只会打印出最后一个元素，除非列表元素为零。

当触发索引错误时，最好用len函数确定一下列表长度。

![复件 82457624_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2082457624_p0.png?x-oss-process=style/blog)

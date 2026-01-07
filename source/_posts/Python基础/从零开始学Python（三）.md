---
title: 从零开始学Python（三）
date: 2023-09-07 17:13:33
tags: Python
categories: Python学习
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2062059095_p0.jpg?x-oss-process=style/blog
description: 用户输入和函数
updated: 2023-10-17 23:44:09
---

紧接上文，在介绍完Python基础的数据类型后，我们这次来学习一下Python中的用户输入和while循环，重点在于函数和模块的讲解。

----

# 七、用户输入和while循环

## input函数

不同于C语言的scanf，gets等函数，Python使用input函数来与用户交互，用户可以通过input函数向计算机输入数据。一般情况下，默认输入的数据格式是字符串，即使输入数字也是如此。如果想要从用户的输入中获取整数，需要使用int函数。这一点类似于C语言中的强制类型转换。

可以向input函数传递字符串参数，作为用户输入的提示。

```python
name=input("Please input your name so I can greet you: ")
print("Hello! "+name)
'''
>>>Please input your name so I can greet you: 
Adam Ben
>>>Hello! Adam Ben
'''
```

## while函数

while函数在Python和C语言中用法大致相同。比如都有循环体，都要规定循环条件等。只有一点细微的差别，比如Python中while循环要加冒号且不需要将循环条件用括号括起来等。

除此之外，continue函数和break函数用法都与C语言相同，这里不再赘述。

### 操作

运用while函数可以很方便的对字典和列表进行操作。比如移动列表元素（pop），循环删除列表元素（remove），由用户循环输入字典（input）等。

```python
name=''
while name != 'no':
    name=input("What's your dream place? Tell me please"+"\n(enter no to quit)"+": ")
    if name!='no':
        print("Your dream place is "+name)
'''
>>>What's your dream place? Tell me please
(enter no to quit):chenzhou
>>>Your dream place is chenzhou
>>>What's your dream place? Tell me please
(enter no to quit): no
'''
```

# 八、函数

**函数**是有名字的代码块。

## 定义函数

在Python中，函数的定义需要使用关键字def，如下定义了一个简单的函数。

```python
def greet():
    '''显示问候语'''
    print("Hello!")
    
greet()
'''
>>>Hello!
'''
```

这一点与C语言有不同。在C语言中，定义函数的格式是：

- 函数返回值的数据类型
- 函数名
- 函数形参的数据类型
- 函数形参名
- 如果没有参数或者返回值为空需要注明void

```c
void greet(void)
{
    printf("Hello!");
    return 0;
}
```

而Python中的def又很容易让人想起C语言中的#define关键字，似乎在Python中的函数只不过是将函数名与代码块的简单替换。

## 传递参数

在Python中，我们可以向函数传递参数，我们传递的是**实际参数**，而函数中定义的是**形式参数**。形参又分为**位置形参**和**关键字形参**。

位置形参即一般的向函数传递参数，此时Python会自动将形参的位置与实参的位置关联，向形参传递一份实参的副本。因此在位置形参中，传递参数的顺序相当重要，否则可能会引发意想不到的错误。

关键字形参即在参数传递中直接指定形参名给它传递参数，应用关键字形参时，Python可以不用考虑参数传递顺序，因为Python已经知道该给哪个形参传递对应的值，但是要保证关键字形参的输入正确无误。

在函数中，还可以设定默认值，这样在函数调用中若没有参数传递，Python会自动使用已经设定好的默认值作为形参进行调用。

```python
def greet(weather,name,word='Hi! '):
    print(word+name+f" What a {weather} day!")

greet('Sunny',name='Ben')
'''
>>>Hi! Ben What a Sunny day!
'''
```

实际上我在编写上面这个代码时遇到不少小问题，一开始我的函数参数定义顺序是name、weather、word。但是这样传递参数我遇到了两个问题：

- 当传递参数的顺序为'Sunny',name='Ben'时，程序会报错提示变量name接收的多个参数
- 当传递参数顺序为,name='Ben'.'Sunny'时，程序也会报错提示位置变量不能在关键字变量之后

为了避免这些情况，在调用函数时尽量不要混用传参类型，或者注意参数传递顺序。

除了传递参数外，还可以使用return语句定义函数的返回值，返回值可以是普通的值，也可以是列表，字典等。

我们也可以向函数传递列表。但是不同于传递位置参数，一般形式的传递列表会让函数直接操作列表本身的值而并非是列表的副本。这一点和向C语言函数传递数组类似，不过在C语言中传递数组的本质是传递数组的指针。如果在Python中你并不想修改列表本身的值而只是想让函数操作列表的副本，可以利用切片的方法。

```python
example=['adam','ben','jjg']

def test(e):
    for i in e:
        print i

test(example)#传递列表本身
test(example[:])#传递列表副本
```

### 传递任意数量的实参

在定义函数时加上一个星号*，代表可以接受任意数量的实参，函数将创建一个列表接收数据。

```python
def greet(*name):
    for i in name:
        print("Hello! "+i)

greet('adam')
greet('ben','jjg')
'''
>>>Hello! adam
Hello! ben
Hello! jjg
'''
```

###  传递任意数量的关键字实参

有时候接收任意数量的实参，但是不知道传递给函数的是什么样的信息，这时候可以添加两个星号**表示接收任意数量的键值对。

```python
def build_profile(fname,lname,**user_info):
    '''创建一个字典储存关于用户的一切'''
    user_info['fname']=fname
    user_info['lname']=lname
    return user_info
user=build_profile('adam','ben',location='guangzhou',sexual='male')
print(user)
'''
>>>{'location': 'guangzhou', 'sexual': 'male', 'fname': 'adam', 'lname': 'ben'}
'''
```

## 将函数导入模块

正如C语言通过包含头文件来引入已经定义好的函数体一样，Python中也可以将函数写好储存在**模块**中。在编写代码时，我们可以使用import语句将模块**导入**进主程序中。通过将函数储存在独立的文件，可以隐藏代码的细节，将重点放在程序的高层逻辑上，为代码添加新一层抽象（A new level of abstraction）。通过导入函数还可以使用其他程序员编写的语言库。

导入模块有许多种方式，下面进行简单的介绍。

### 导入整个模块

**模块**是拓展名为.py的独立文件，该文件通常与主程序在同一个目录下，然后就可以通过import来导入模块。

比如一个文件名为greet.py的文件内容为：

```python
def greet(name):
    print("Hello! "+name)

def test():
    print("I'm a test function")
```

在greet.py的相同目录下创建一个新的文件作为主程序，我们给它命名为main.py：

```python
import greet.py

greet.greet('ben')
'''
>>>Hello! ben
'''
```

Python在读取import这一行时，会打开greet.py文件，并将其中所有的函数全部都复制到这个程序中，但是你看不到这些代码。你可以通过指定导入模块文件名和函数名称来使用模块中的函数，并用句点分隔。

### 导入特定的函数

有时候我们只需要导入模块中几个特定的函数而无须全部导入，只需要使用如下格式。

```python
from greet.py import greet,test

greet('ben')
'''
>>>Hello! ben
'''
```

通过这种语法导入的函数无须使用句点分隔文件名和函数名，直接使用函数名就可以了，并且可以通过逗号引入任意数量的函数。

### 使用as给函数指定别名

有时候导入模块中的函数名和主程序中的函数名有冲突，或者函数名太长，可以用as给导入的函数指定**别名**。导入的格式如下。

```python
from greet import greet as JJG

JJG('ben')
'''
>>>Hello! ben
'''
```

### 使用as给模块指定别名

除了给函数指定别名，还可以给模块指定别名，语法如下。

```python
import greet as g

g.greet('ben')
'''
>>>Hello! ben
'''
```

### 导入模块中的所有函数

使用星号*可以导入模块中的所有函数。

```python
from greet import *

greet('ben')
'''
>>>Hello! ben
'''
```

这样一来使用模块中的每一个函数都不需要加文件名和句点了，但是不推荐这么做，尤其是在编译大型程序时。因为这可能会导致模块中的函数名和主程序的函数名相冲突，进而引发意想不到的错误。

![复件 62059095_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2062059095_p0.jpg?x-oss-process=style/blog)

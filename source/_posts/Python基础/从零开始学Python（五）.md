---
title: 从零开始学Python（五）
date: 2023-09-10 22:54:32
tags: Python
categories: Python学习
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2068656793_p0.png
description: 如何操作文件、处理异常、调试程序
updated: 2023-10-17 23:47:43
---

关于Python基础知识的最后一章！完结撒花✿✿ヽ(°▽°)ノ✿。主要介绍了Python处理文件和调试的操作。

项目部分可能后续会随缘更新！

----



# 十、文件和异常

Python的文件读取和C语言有比较大的不同，下面来详细说说Python是怎么操作文件的。

## 读取整个文件

现在有一个文本文件pi.txt，文件中储存了精确到小数点后30位的圆周率。我们要如何用Python打开文件并输出文件内容呢？

下面的程序打开并读取这个文件，并将文件内容输出到屏幕上。

```python
with open('pi.txt') as file:
    contents=file.read()
    print(contents)
```

我们逐行分析这一串代码。首先我们调用了open函数打开文件pi.txt，Python会在当前执行文件的目录中寻找指定的文件，然后把打开的文件对象返回给变量file中。也就是说，open函数的作用就是打开文件并返回指定的文件对象。

关键字with的作用是在不需要访问文件后将文件关闭。当然我们也可以使用open函数和close函数来管理文件打开和关闭，但是这么做容易出错。比如出于某些原因close语句无法执行（文件无法关闭），或者调用了close函数后仍然对文件进行操作（文件无法访问），很容易出现严重的错误。所以我们将控制权交给Python来帮我们自动关闭文件。

然后我们再调用read方法来读取这个文件的全部内容，并将其作为一个字符串储存在contents中，这样通过打印contents的值，我们就可以显示出文件的内容。

对比C语言，C语言中操作文件则必须使用fopen和fclose函数进行操作，而且往往需要实现定义一个数据类型为FILE的文件指针变量来储存打开文件的位置。读取文件内容时更是麻烦，需要在C语言中指定一片空间来储存将要显示的文件数据，然后再调用fread函数将内容写入指定的区域。显然，Python比C语言操作更加简单且安全。

如果我要用C语言实现呢？

```c
#define _CRT_SECURE_NO_WARNINGS
#pragma warning(disable:6031)
#include<stdio.h>
#include<stdlib.h>

int main(void)
{
	FILE* p;
	p = fopen("pai.txt", "r");
	char space[30] = { 0 };

	if (p == NULL)
	{
		printf("Files does not exist");
		return(-1);
	}

	fread(space, sizeof(char), 20, p);
	printf("%s", space);
	fclose(p);

	return 0;
}
```

要红温力！！！

### 文件路径

一般来说，在Python中使用open函数打开文件时，都会在执行文件相同目录下寻找指定文件，如果没有找到指定文件则产生FileNotFoundError。倘若现在我们在该目录新建一个名为file的文件夹，再在该文件夹下储存要打开的文件。此时如果继续使用`with open('文件名') as file`的方法行不通。此时我们就要用到**相对路径**。也就是`with open('file\要打开的文件名') as file`。注意在Linux和OS X中反斜杠要替换为斜杠。

除了使用相对路径让Python去指定位置寻找文件，我们还可以使用**绝对位置**，也就是这个文件在设备中的具体位置。比如`with open('C:\Users\file\要打开的文件名') as file`。通常来说绝对路径的长度较长，我们一般把绝对路径赋值给变量后再传递给open函数。

同样的，在绝对路径中，Linux和OS X系统也要使用斜杠而非反斜杠。

### 逐行读取

有时候我们需要以每次一行的方法输出文件内容。对文件对象使用for循环即可。

```python
filename='pai.txt'

with open(filename) as file:
    for line in file:
        print(line.restrip())
```

但是这么做的话我们只能在with语句内使用文件内容，如果我们希望在文件关闭后继续操作文件内容，我们可以把文件内容以每行导出储存在一个列表中。这样在with代码块外，我们仍然可以继续使用这个变量。

```python
filename='pai.txt'

with open(filename) as file:
    lines=file.readlines()#使用readlines方法，将文件内容每行导出为列表中的一个元素
    
pai=''
for line in lines:
    pai+=line.strip()
    
print(pai)
```

## 写入文件

Python既然可以打开文件，那么当然也可以写入文件，这时我们就需要在open函数中传递第二个参数来指定打开方式。

```python
filename='pai.txt'

with open(filename,'w') as file:
    file.write("I love megumin!")
```

这个例子向open函数传递了两个实参，第一个函数是文件名称，第二个实参'w'即告诉Python要以写入模式打开这个文件。打开文件的部分模式总结如下。

| 符号 |                           打开模式                           |
| :--: | :----------------------------------------------------------: |
|  r   |                  读取模式，无参数时默认为r                   |
|  w   | 写入模式，当指定文件名已存在时会清空文件内容，不存在则新建文件 |
|  a   | 追加模式，当指定文件名已存在时继续向后方添加内容，不存在则新建文件 |

如果要向文件输入多行，除了使用额外的写入语句外，还需要手动添加换行符`\n`实现换行。

## 处理多个文件

我们只能像open函数传递一个文件名，如果我们要打开多个文件怎么办呢？答案是将要打开的文件名储存在一个列表中。

```python
file_names=['adam.txt','ben.txt','jjg.txt']
for filename in file_names:
    with open filename as file:
        result=file.read()
        print(result)
```

## 异常

Python使用称之为**异常**的特殊对象来管理程序执行期间发生的错误。每当发生错误，Python都会创建一个异常对象，如果你编写了处理该异常的代码，那么程序将继续运行；否则程序会停止且回显一个traceback，包含有关异常的报告。

Python使用try-except代码块来处理异常。

### try-except代码块

在try后编写可能会产生错误的代码块，在except后编写产生对应错误后执行的代码块。

```python
try:
    print(5/0)
except ZeroDivisionError:
    print("You can't divide by zero!")
'''
>>>You can't divide by zero!
'''
```

如果try-except代码块后还有其他代码，那么程序会接着运行。

### else代码块

else代码块紧接在try-except代码块后，依赖于try成功执行的代码都应该放到else代码块中。

下方是一个除法计算器。

```python
flag=True

while flag:
    print('Enter q to quit when type in number')
    a=input("Please enter the first number:")
    if a=='q':
        break
    b=input('Please enter the second number:')
    if b=='q':
        break
    try:
        answear=int(a)/int(b)
    except ZeroDivisionError:
        print("The second number can't be zero!")
    else:
        print(answear)

print("Good Bye!")
'''
>>>Enter q to quit when type in number
Please enter the first number:5
Please enter the second number:2
2.5
>>>Enter q to quit when type in number
Please enter the first number:6
Please enter the second number:0
The second number can't be zero!
>>>Enter q to quit when type in number
Please enter the first number:q
>>>Good Bye!
'''
```

### 决定报告哪些错误

有时候，我们可以选择在程序运行出现错误时不选择任何信息，即在用户的眼里，程序并没有出现任何异常。这个时候我们需要使用`pass`语句，它告诉Python什么都不要做。

```python
def count_words(filename):
    try:
        --snip--
    except FileNotFoundError:
        pass
    else:
        --snip--
```

以上代码块在遇到FileNotFoundError时什么都不会发生。

向用户显示他们不想看到的信息可能会降低程序的可用性，要与用户分享多少信息都由你决定。

## 存储数据

在打开文件、写入文件后，自然就是存储信息了。比如储存用户玩galgame时的选项或者RPG角色信息，每次关闭游戏时你几乎总得保存他们提供的信息。一种简单的方式是用json模块来储存数据。（文明6出列！）

模块json能让你将简单的Python数据转存到文件中，并在程序运行时加载该文件的数据，你还可以使用json在不同的Python程序间分享数据。更重要的是json数据并非Python专用的，故可以与其他语言的人分享数据，十分有用也易于学习。

### json.dump()和json.load()

函数jsom.dump()接收两个实参，要储存的数据以及用于储存的文件对象。

```python
import json
number=[2,3,5,7,9]

filename='number.json'
with open(filename,'w') as file:
    json.dump(number,file)
```

程序没有输出，我们打开json文件就会发现内容储存格式和Python一样。

再用json.load()将这个列表读取到内存中。

```python
import json

filename='number.json'
with open(filename) as file:
    numbers=json.load(file)
    
print(numbers)
'''
>>>[2,3,5,7,9]
'''
```

这是一种在程序间共享内存的简单方式。

#### 保护和读取用户生成的数据

对于用户的数据，使用json来保存他们是很有好处的，这样可以防止运行停止时的用户信息丢失。下面就是一个例子，当用户首次运行时被提示输入自己的名字，这样再次运行时程序就已经记住他了。

```python
import json

filename='username.json'
try:
    with open(filename) as file:
        username=json.load(file)
except FileNotFoundError:
    username=input("What's your name?")
    with open(filename,'w') as file:
        json.dump(username,file)
        print("We'll remember you when you come back, "+username+" !")
else:
    print("Welcome back, "+username+' !')
```

## 例题

***10-13** 验证用户：最后一个remember_me.py版本假设用户要么已输入其用户名，要么是首次运行该程序。我们应修改这个程序，以应对这样的情形：当前和最后一次 运行该程序的用户并非同一个人。* 

*为此，在greet_user() 中打印欢迎用户回来的消息前，先询问他用户名是否是对的。如果不对，就调用get_new_username() 让用户输入正确的用户名。*

```python
import json

def get_stored_username():
    filename='username.json'
    try:
        with open(filename) as file:
            username=json.load(file)
    except FileNotFoundError:
        return None
    else:
        return username
    
def greet_user():
    username=get_stored_username()
    if username:
        while True:
            flag=input("Is your name "+username+' ?(yes or no)')
            if flag=='yes':
                print("Welcome back, "+username+" !")
                break
            elif flag=='no':
                get_new_username()
                break
            else:
                print("Please enter only 'yes' or 'no' !")
    else: 
        username=input("What is your name?")
        filename='username.json'
        with open(filename,'w') as file:
            json.dump(username,file)
            print("We'll remember you when you come back, "+ username+" !")

def get_new_username():
    username=input("What is your name?")
    filename='username.json'
    with open(filename,'w') as file:
        json.dump(username,file)
        print("We'll remember you when you come back, "+ username+" !")

greet_user()
'''
>>>Is your name Adam Ben ?(yes or no)
666
>>>Please enter only 'yes' or 'no' !
Is your name Adam Ben ?(yes or no)
no
>>>What is your name?
JJG 
>>We'll remember you when you come back, JJG !
'''
'''
>>>Is your name JJG ?(yes or no)
yes
>>>Welcome back, JJG !
'''
```

# 十、测试代码

## 测试函数

我们先写一个简单的待测试函数，以供后续举例使用。

```python
def get_name(fname,lname):
    full_name=f"{fname} {lname}"
    return full_name.title()
```

现在我们要修改函数get_name，使其能够处理中间名，但是这样的修改有一定的风险。所以我们要对函数进行测试。

### 单元测试和测试用例

Python的标准库中的unittest库提供了代码测试工具。**单元测试**用于核实函数的某个方面没有问题；**测试用例**是一组单元测试，这些单元测试都符合要求。**全覆盖式测试**用例包含一整套单元测试。

要为函数编写测试用例，可先导入unittest模块以及要测试的函数，再创建一个继承unittest.TestCase的类，并编写一系列方法对函数行为的不同方面进行测试。

#### 一个成功的案例

下面是一个方法的测试用例，它检查函数get_name能否正常工作。

```python
import unittest

def get_name(fname,lname):
    full_name=f"{fname} {lname}"
    return full_name.title()

class NameTestCase(unittest.TestCase):
    def test_first_last_name(self):
        name=get_name('adam','ben')
        self.assertEqual(name,'Adam Ben')

unittest.main()
'''
>>>.
----------------------------------------------------------------------
Ran 1 test in 0.001s

OK
'''
```

首先，我们导入了`unittest`模块，并创建了一个名为`NameTestCase`的类，用于包含一系列针对`get_name`函数的单元测试。类名可以随意，但最好遵循驼峰命名法并且包含Test字样。类必须继承`unittest.TestCase`类，这样Python才知道怎么运行你编写的测试。

`NameTestCase`只包含一个方法，用于测试`get_name`函数的一个方面，我们将这个方法命名为`test_first_last_name`，因为我们要核实的只是姓名能否被正确的格式化。在运行主程序时，所有以test开头的方法都会被自动运行。在这个方法中，我们调用了测试的函数以及函数返回值。即使用'adam'、'ben'实参调用了`get_name`函数，并将运行结果储存在`name`中。

随后，我们使用了一个unittest类中最重要的功能之一：**断言**方法。断言方法用来核实我们得到的结果和期望是否一致。比如在这个例子里，我们调用unittest.assertEqual方法并向其传递`name`和'Adam Ben'。意思就是比较这两者是否相同，如果不同就告诉我一声。

而得到的输出也很耐人寻味。第一行的一个句点表示有一个测试通过了，接下来的一行指出Python运行了一个测试，且消耗时间为0.001秒。最后的OK表示所有单元测试都通过了。

以上我们就知道`get_name`函数能够正确处理数据，这样当我们修改`get_name`函数后，我们可以继续运行这个测试用例，如果测试通过，就表示函数能够正确处理adam ben这样的姓名。

#### 一个失败的案例

现在我们修改`get_name`函数，使其拥有处理中间名的功能，但是无法处理没有中间名的情况。

```python
def get_name(first,middle,last):
    full_name=first+' '+middle+' '+last
    return full_name.title()
```

这时再调用函数向其传递一个不含中间名的参数，肯定是无法正确处理的。而它的报错信息是：

```python
E
======================================================================
ERROR: test_first_last_name (__main__.NameTestCase.test_first_last_name)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "D:\Code\Python从入门到实践\11\11.1.2.py", line 13, in test_first_last_name
    name=get_name('adam','ben')
         ^^^^^^^^^^^^^^^^^^^^^^
TypeError: get_name() missing 1 required positional argument: 'last'  

----------------------------------------------------------------------
Ran 1 test in 0.005s

FAILED (errors=1)
```

第一行只有一个字母E，它指出测试用例中有一个单元测试导致了错误。接着我们看到详细的错误信息：是`NameTestCase`中的`test_first_last_name`导致了错误，然后给出了一个traceback，指出应该缺少了一个参数。

最后的信息提示运行了一个单元测试，整个测试未通过，因为运行测试时发生了一个错误。这条信息位于末尾，让你一眼就能知道发生了什么情况。

## 测试类

前面介绍了测试函数的方法，下面来编写针对类的测试。测试类的方法和测试函数的方法基本类似。通过测试类，就可以知道对类的改动有没有意外的破坏其原有行为。

### 各种断言方法

在开始介绍针对类的测试方法前，我们先简要的介绍一下断言的各种方法。

| 方法                   | 用途               |
| ---------------------- | ------------------ |
| assertEqual(a,b)       | 核实a==b           |
| assertNotEqual(a,b)    | 核实a!=b           |
| assertTrue(x)          | 核实x为True        |
| assertFalse(x)         | 核实x为False       |
| assertIn(item,list)    | 核实item在list中   |
| assertNotIn(item,list) | 核实item不在list中 |

### 一个要测试的类

以下我们定义了一个叫做`AnonymousSurvey`的类用于模拟一次匿名调查收集：

```python
class AnonymousSurvey():

    def __init__(self,question):
        self.question=question
        self.responses=[]#初始化回答为空列表

    def show_question(self):
        '''指定要提问的问题'''
        print(self.question)

    def store_response(self,new_response):
        '''储存回答到列表'''
        self.responses.append(new_response)

    def show_results(self):
        '''输出回答'''
        print("survey results:")
        for response in self.responses:
            print('- '+response)
```

现在我们编写一个程序来使用这个类。

```python
from survey import AnonymousSurvey

question="What language did you first learn to speak?"
my_survey=AnonymousSurvey(question)

my_survey.show_question()
print("Enter 'q' to quit at any time.\n")
while True:
    response=input("Language: ")
    if response=='q':
        break
    my_survey.store_response(response)

print("\nThank you to everyone who participate in our survey!")
my_survey.show_results()
'''
>>>What language did you first learn to speak?
Enter 'q' to quit at any time.

Language: Chinese
Language: English
Language: Japanese
Language: q

Thank you to everyone who participate in our survey!
survey results:
- Chinese
- English
- Japanese
'''
```

我们导入了`AnonymousSurvey`类并将my_survey实例化，向其输入问题和答案，最后将结果打印出来。

#### 测试`AnonymousSurvey`类

下面来编写一个测试，对`AnonymousSurvey`类的一个方法进行验：如果用户面对调查问题时只提供了一个答案，这个答案能够被妥善储存。使用`assertIn`来核实答案被储存在答案列表中。

```python
import unittest
from survey import AnonymousSurvey

class TestAnonymouseSurvey(unittest.TestCase):

    def test_store_single_response(self):
        question="What language did you first speak?"
        my_survey=AnonymousSurvey(question)#实例化my_survey
        my_survey.store_response("Chinese")#传入实参"Chinese"给方法

        self.assertIn("Chinese",my_survey.responses)#检验"Chinese"是否包含在列表中

unittest.main()
'''
>>>.
----------------------------------------------------------------------
Ran 1 test in 0.001s

OK
'''
```

只核实一个答案是否被存储的用处不大。下面用户提供三个答案时，数据也应该被妥善存储。为此，我们在`TestAnonYmousSurvey`中再添加一个方法。

```python
import unittest
from survey import AnonymousSurvey

class TestAnonymouseSurvey(unittest.TestCase):

    def test_store_single_response(self):
        question="What language did you first speak?"
        my_survey=AnonymousSurvey(question)
        my_survey.store_response("Chinese")

        self.assertIn("Chinese",my_survey.responses)

    def test_store_three_response(self):
        question="What language did you first speak?"
        my_survey=AnonymousSurvey(question)
        responses=['English','Spanish','Mandarin']
        for response in responses:
            my_survey.store_response(response)

        for response in responses:
            self.assertIn(response,my_survey.responses)

unittest.main()
'''
>>>..
----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
'''
```

两个测试都通过了。

### 方法setUp()

在进行对`AnonymousSurvey`的第二次测试中，我们在每个方法中都创建了一个`AnonymousSurvey`实例，并给出了答案。`unittest`模块中包含一个方法`setUp`，它可以让你只需要创建这些对象一次，然后直接调用即可。如果你在`TestCase`中包含了了方法`setUp`，Python会优先执行它，然后再运行其他test_开头的方法。

下面使用`setUp`方法来创建一个调查对象和一组答案。

```python
import unittest
from survey import AnonymousSurvey

class TestAnonymouseSurvey(unittest.TestCase):

    def setUp(self):
        question="What language did you first speak?"
        self.my_survey=AnonymousSurvey(question)
        self.responses=['English','Spanish','Mandarin']

    def test_store_single_response(self):
        self.my_survey.store_response(self.responses[0])
        self.assertIn(self.responses[0],self.my_survey.responses)

    def test_store_three_response(self):
        for response in self.responses:
            self.my_survey.store_response(response)
        for response in self.responses:
            self.assertIn(response,self.my_survey.responses)

unittest.main()
'''
>>>..
----------------------------------------------------------------------
Ran 2 tests in 0.001s

OK
'''
```

`setUp`方法做了两件事情，一是创建一个调查对象，二是创建一个答案列表，储存这两样东西的变量名前缀都包含self（存储在属性中），因此这两个变量可以在类的任意地方使用。这样让测试方法更加简单，而免去了重新创建对象和答案的麻烦。

在编写测试自己的类时，使用`setUp`方法让测试变得容易，可以在方法中创建一系列实例并设置其属性。再在测试方法中去调用这些实例。







至此，Python基础部分，堂堂完结！！！



![复件 68656793_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2068656793_p0.png)

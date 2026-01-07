---
title: 从零开始学Python（二）
date: 2023-09-05 23:25:16
tags: Python
categories: Python学习
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/55982257_p0.jpg
description: 如何操作列表，引入字典
updated: 2023-10-17 23:42:22
---

紧跟上文，这一篇主要讲了列表和字典，至此Python中基础的数据结构部分算是全部讲完了（撒花✿✿ヽ(°▽°)ノ✿）

----

# 四、操作列表

顾名思义，就是怎么**遍历并处理**列表元素，这里我们会用到for函数。

## for函数

我们先介绍在Python中for函数的用法。

```python
example=['Adam','Ben','JJG']
for i in example:
    print(i)
'''
>>>Adam
Ben
JJG
'''
```

这里将一个临时变量 i 与列表example中的元素相绑定并遍历整个列表。需要注意的是Python中的for函数和c语言的for函数用法截然不同。

```c
for (i=0; i++ ;i<10)//定义并初始化临时变量i，定义循环操作，定义循环结束条件
{
	//执行操作
}
```

然而在C++中支持for函数的两种用法。

既然在Python中for函数能做到遍历整个列表，那我们能做的也还不仅于此，我们可以统一的对列表所有元素进行操作，以下就是一个简单的例子。

```python
games=['to the moon','finding paradise','impostor factory']
for game in games:
    print(f"I really love {game.title()}")
print("Kan Gao is really a genius")
'''
>>>I really love To The Moon
I really love Finding Paradise      
I really love Impostor Factory      
Kan Gao is really a genius
'''
```

最后，Python是一门对缩进敏感的语言，在使用for循环时请务必注意缩进问题，否则很容易出现逻辑错误甚至语法错误。

## 创建数值列表

这里我们引入一个重要的函数，range函数。

range函数不难理解，一共可以向range传递三个参数，分别是起始值，结束值和步长。其中第三个参数是可选的，默认为1。需要注意的是range函数确定的范围实际上是一个左闭右开的区间，也就是说range(1,20)本身只包含1~19，20不被包含在内。

我们可以结合for函数和range函数进行许多操作，最简单的就是打印一串数字。

```python
for i in range(1,5):
    print(i)
'''
>>>1
2
3
4
'''
```

我们还可以结合list函数和range函数创建数字列表。

```python
number=list(range(1,6))
print(number)
'''
>>>[1,2,3,4,5]
'''
```

这里创建了1~5的数字列表，但如果要输出一个前五个数字平方的列表呢？

```python
example=[]
for i in range(1,6):
    example.append(i**2)
'''
print(example)
>>>[1,4,9,16,25]
print(min(example))
print(max(example))
print(sum(example))
>>>1
25
55
'''
```

此外，我们还可以用min函数，max函数和sum函数对列表进行简单的统计计算，用法如上。

最后就是**列表解析**，可以让你精简你的代码，用法如下。

```python
num=[i**2 for i in range(1,6)]
print(num)
'''
>>>[1,4,9,16,25]
'''
```

## 使用列表的一部分

在上一小节中，我们介绍了如何遍历整个列表并对其元素进行处理，这里我们只需要处理一部分列表元素。也就是**切片**

现在我有一个列表，但是我只想打印他们前三个成员，那么我们就需要切片。

```python
example=['Adam','Ben','JJG','Finding','Paradise']
for i in example[0:3]:
    print(i)
'''
>>>Adam
Ben
JJG
'''
```

我们仔细分析切片是如何使用的。和range函数类似，我们可以向切片传递三个参数example[x:y:z]。其中x代表起始元素索引，y代表结束元素索引，z代表步长且默认为1，而范围同样是左闭右开。

与range函数不同的一点是，索引可以是负值。比如example[-3:]就代表从example倒数第三个元素到末尾元素。

## 复制列表

学习完切片后，我们有必要介绍如何用切片来复制列表。下面是演示。

```python
eg1=['Adam','Ben','JJG']
eg2=[]
#正确的做法
eg2=eg1[:]
#错误的做法
eg2=eg1
```

上面演示了两种复制列表的方法，但只有第一种是正确的。因为只有使用切片复制才能实实在在的产生第二个内容相同的列表，而第二种方法只是将eg2关联到eg1。这一点类似C语言中的指针，从而导致还是只有一个列表，不过是都指向一个地方而已。

## 元组

元组和列表类似，以圆括号()构造，同样可以使用索引访问元素。但是元组的元素不可修改。也就是说如果想要创建一个在整个数据周期内内容不变的数据结构，最好使用元组。

如果你尝试着像修改列表一样去修改元组的元素，那么编译器会报错。

但是如果你想要更改元组，可以通过重新给元组赋值来实现。下面演示一下元组的使用。

```python
example=('Adam','Ben')
print(example[0],example[1])
example=('to the moon','finding paradise')#给元组重新赋值
print(example[0].title(),example[1].title())
'''
>>>Adam Ben
To The Moon Finding Paradise
'''
```

# 五、if语句

if语句比较简单，大部分和C共享一套逻辑。这里只简单谈谈和C语言有所区别的地方。

①Python中判断多个条件的’与‘和’或‘为and和or，更符合口语。但是C语言中分别为&&和||。

②Python中有一个比较特殊的判断in和其否定not in，即判断元素在不在所给范围内。

③if语句和Python中的for语句一样对缩进敏感，使用格式大致相仿。

④Python中执行多个判断时使用的是elif，而C语言中使用的是else if。

没了，以上。（确实就这么简单）

# 六、字典

Python中的字典是一种储存着键值对的列表，类似于C语言的枚举。但是C语言的枚举仅限于字符串和整数的映射，而字典可以进行字符串到字符串的映射，甚至是字符串到列表。事实上，Python中的所有对象都可作为字典中的值，相当于C语言中的超大型#define。（？）

下面演示一下字典的定义和用法。

```python
example={'fname':'adam','lname':'ben'}
print(example['fname'])
'''
>>>adam
'''
```

字典中键与值之间用冒号':'连接，不同的键值对之间用逗号','连接。字典中可以加入任意多的键值对。

## 字典的基本操作

### 添加键值对

字典是一种动态结构，想要添加字典，需要依次指定字典名、用**方括号**括起的键、**等号**和对应的值。

```python
example={'fname':'adam','lname':'ben'}
example['nick_name']='JJG'
print(example)
'''
>>>{'fname': 'adam', 'lname': 'ben', 'nick_name': 'JJG'}
'''
```

用字典来储存用户编写的数据或者自动编写储存大量的键值对时，通常我们会先定义一个空字典。

### 修改键值对

与修改列表类似，修改字典即直接把新值赋给原有的键值对，当然如果不存在对应的键，其结果相当于添加了一个新键值对。

```python
example={'fname':'adam','lname':'ben'}
example['fname']='JJG'
print(example)
'''
>>>{'fname': 'JJG', 'lname': 'ben'}
'''
```

### 删除键值对

格式与之前的操作类似，通过使用del函数以及字典名和对应的键来删除键值对。

```python
example={'fname':'adam','lname':'ben'}
del example['fname']
print(example)
'''
>>>{'lname': 'ben'}
'''
```

注意，一旦删除了键值对，那么该键值对就在字典里永久消失了。

### 遍历字典

使用for循环以及items方法来遍历字典中的键值对。

```python
example={
    'fname':'adam',
    'lname':'ben',
    'nname':'jjg',
    'game':'finding paradise',
}
for key,value in example.items():
    print(f"Key is {key} and value is {value}.")
'''
>>>Key is fname and value is adam.
Key is lname and value is ben.
Key is nname and value is jjg.
Key is game and value is finding paradise.
'''
```

items方法返回一个键值对列表，然后for再把键值对的值依次分配给两个值key和value。

#### 遍历所有的键

当然，你也可以选择只**遍历所有的键**，将方法items改为keys就可以了，不过遍历字典时会默认遍历所有的键，也就是说加不加keys方法所输出的结果都一样。但是显式的使用keys，可以提高你的代码可读性。

同样的，keys也和items一样，返回的是一个列表，前者只返回字典中所有键的值，而后者则是返回字典中所有的键值对。

值得注意的是Python并不关心你输入字典时的顺序，换而言之Python的字典排序并不是按照你输入的顺序排序的，如果你想要对输出的字典键值对排序，你需要调用sorted函数。

```python
example={
    'fname':'adam',
    'lname':'ben',
    'nname':'jjg',
    'game':'finding paradise',
}
for name in sorted(example.keys()):
    print(name.title()+", is very good!")
'''
>>>Fname, is very good!
Game, is very good!
Lname, is very good!
Nname, is very good!
'''
```

#### 遍历所有的值

除了遍历所有的键之外，你当然还可以**遍历所有的值**，通过调用values方法即可，用法同keys与items。

值得一提的是，当处理包含大量键值对的字典时，字典的值很有可能会有重复数据，但是使用values输出的值是不考虑重复的。如果你需要去除掉结果中重复的数据，你可以使用set**集合**。集合类似于列表，但每个元素都是独一无二的。

```python
example={
    'name1':'adam',
    'name2':'ben',
    'name3':'ben',
    'name4':'jjg',
}
for value in set(example.values()):
    print(value.title())
'''
>>>Ben
Jjg
Adam
'''
```

### 使用get方法来访问值

一般情况下，我们都是用方括号来访问字典中的值，但是如果方括号内的键名不存在，会在Python中引发键值错误（KeyError）

如果想避免发生这种错误，那么就使用get方法指定要访问的键名和键名不存在时的返回值。前者是必选的，而后者不存在时默认返回值为None。

```python
example={
    'name1':'adam',
    'name2':'ben',
    'name3':'ben',
    'name4':'jjg',
}
value=example.get('fname','No value assigned')
'''
print(value)
>>>No value assigned
'''
```

## 嵌套

有时候，需要将一系列字典存储在列表中，或将列表作为值存储在字典中，这称为**嵌套**。你可以在列表中嵌套字典、在字典中嵌套列表甚至在字典中嵌套字典。

### 字典列表/列表储存字典

顾名思义，就是创建一个列表，列表元素为字典。

```python
#创建一个空列表
student=[]

#创建30个学生
for student_number in range(0,30):
    new_student={
        'age':19,
        'school':'JUN',
        'sexual':'male',
    }
    student.append(new_student)
    
#显示前五个学生
for i in student[:5]:
    print(i)
print('...')
'''
>>>{'age': 19, 'school': 'JUN', 'sexual': 'male'}
{'age': 19, 'school': 'JUN', 'sexual': 'male'}
{'age': 19, 'school': 'JUN', 'sexual': 'male'}
{'age': 19, 'school': 'JUN', 'sexual': 'male'}
{'age': 19, 'school': 'JUN', 'sexual': 'male'}
'''
```

### 在字典中储存列表

有时候，需要把列表储存在字典中，比如储存一个披萨的配料列表什么的。当我们需要把字典中的一个键关联到多个值时，我们就可以采用字典嵌套列表的方法。

```python
author={
    'name':'adam ben',
    'sexual':'male',
    'games':['to the moon','finding paradise','impostor factory'],
}

print(f"The author's name is {author['name'].title()}")
for game in author['games']:
    print("And his favorite game is "+game.title())
'''
>>>The author's name is Adam Ben
And his favorite game is To The Moon
And his favorite game is Finding Paradise
And his favorite game is Impostor Factory
'''
```

不过，列表和字典的嵌套层数不宜过多，否则会降低代码可读性。一般来说如果使用了多层嵌套，往往有更简单的方法。

### 在字典中储存字典

字典嵌套字典，这么做可能会使代码快速变得复杂。这里照搬书上的一个例子加深理解，假如一个网站有多个用户，用户又有着独特的用户名，然后再利用每个用户的用户名储存三个关于他们的信息。

```python
users={
    'big_house_monkey':{
        'fname':'adam',
        'lname':'ben',
        'location':'chenzhou',
    },
    'panda':{
        'fname':'frank',
        'lname':'ken',
        'location':'nanchang',
    },
    'balloonfish':{
        'fname':'victory',
        'lname':'hippo',
        'location':'jinan',
    },
}

for username,user_info in users.items():
    print("\nUsername: "+username)
    full_name=user_info['fname']+' '+user_info['lname']
    location=user_info['location']
    
    print("\tFull name: "+full_name.title())
    print("\tLocation: "+location.title())
'''
>>>Username: big_house_monkey
        Full name: Adam Ben
        Location: Chenzhou

Username: panda
        Full name: Frank Ken
        Location: Nanchang

Username: balloonfish
        Full name: Victory Hippo
        Location: Jinan
'''
```

![img](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/55982257_p0.jpg?x-oss-process=style/blog)

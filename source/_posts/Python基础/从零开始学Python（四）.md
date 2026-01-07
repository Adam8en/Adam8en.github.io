---
title: 从零开始学Python（四）
date: 2023-09-10 11:39:39
tags: Python
categories: Python学习
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2086800272_p0%20(1?x-oss-process=style/blog).jpg
description: 详细介绍类以及类的继承
updated: 2023-10-17 23:46:03
---

C语言中不包含类这个概念，但是C++中有。不过遗憾的是我并没有系统的学完过C++，所以是第一次接触类这个概念。下面我来仔细分析一下什么是“类”。

（前排提醒本章内容较多，请备好凳子）

以下情景改编自https://zhuanlan.zhihu.com/p/102331478

----

# 九、类

## 情境导入

假如你知道一个三角形的三条边长，需要计算一个三角形的周长，面积，正弦值等。你可能会在Python中写几个不同的函数，分别计算所需要的三角形的数据。

```python
def ...:    # 参照公式把五个函数定义出来，就不详细写了
    ...
def ...:
    ...

# 然后调用定义好的函数，传入边长数据
angleA(6,7,8)  # 计算角A
->0.8127555613686607  # 注意返回值为弧度

angleB(6,7,8)  # 计算角B
->1.0107210205683146

angleC(6,7,8)  # 计算角C
->1.318116071652818

square(6,7,8)  # 计算面积
->20.33316256758894

circle(6,7,7)  # 计算周长，额，好像有个数字写错了
->20  # 计算结果当然也就错了
```

但是这样很麻烦，因为要获取这些数据，你需要传五次参数，万一某次参数传输错误就容易出现错误，往往这个错误还不容易被发现。

那么，有没有一个方法，我们只需要传递一次参数呢？

你也许会想，简单，我直接把所有的函数集成到一个函数里不就好了。

```python
def calculate(a,b,c):
    angleA = ...
    angleB = ...
    angleC = ...
    square = ...
    circle = ...
    return {'角A':angleA, '角B':angleB, '角C':angleC, '面积':square, '周长':circle}

result=calculate(6,7,8)

result['角A']
->0.8127555613686607

result['面积']
->20.33316256758894
```

这样做看上去解决了问题，但是假如我们并不需要返回全部的结果，比如只需要面积和周长呢？但是Python不会管这么多，它只会将所有数据结果都输出出来。处理规模小的数据可能没什么影响，但如果处理大批数据的话显然会严重影响Python的效率。

你也许会说，简单，我再传入一个参数d，在函数中国加几个if判断，来选择应用哪个函数不就好了。但是这样无疑把问题大大复杂化了，一个简单的问题非要实现的这么复杂，是多此一举的。

我们希望实现以下的效果。

```python
# 定义一个“大的东西”，名字就叫triangle
...
...
# 一番神奇的操作，然后

tr1=triangle(6,7,8)  # 把三条边长传给这个大的东西，然后就生成一个三角形赋给tr1
```

我们可以把triangle理解为一个**三角形生成器**，它通过我们传入的三条边长自动生成了一个**三角形**，并把这个三角形赋予变量tr1。

然后我们就可以对tr1进行操作。

```python
tr1.a
->6

tr1.b
->7

tr1.c
->8

tr1.angleA()
->0.8127555613686607

tr1.angleB()
->1.0107210205683146

tr1.angleC()
->1.318116071652818
```

于是，我们引入了**“类”**的概念。其实，我们在操作字符串、列表、字典等这些内置对象时用的方法，和我们现在看起来一样。只不过现在这个“三角形”，是我们自创的而已。所谓类，就是给我们提供了**自定义对象**的能力。

```python
import math  # 计算反三角函数要用到
 
class triangle:  # 定义类：三角形生成器
    def __init__(self,a,b,c):  # 成员函数，声明需要与外部交互的参数（类的属性）
        self.a=a  # 先看着
        self.b=b  # 这几个东西是干嘛的后面会讲
        self.c=c

    def angleA(self):  # 计算函数（类的方法）
        agA=math.acos((self.b**2+self.c**2-self.a**2)/(2*self.b*self.c))
        return agA

    def angleB(self):  # 公式看不懂的回去翻课本去
        agB=math.acos((self.c**2+self.a**2-self.b**2)/(2*self.a*self.c))
        return agB

    def angleC(self):
        agC=math.acos((self.a**2+self.b**2-self.c**2)/(2*self.a*self.b))
        return agC

    def square(self):
        p=(self.a+self.b+self.c)/2
        s=math.sqrt(p*(p-self.a)*(p-self.b)*(p-self.c))
        return s

    def circle(self):
        cz=self.a+self.b+self.c
        return cz
```

具体的写法也不难，无非就是先声明包含的参数，再写包含的函数就行。

使用的时候也很简单，类是自定级对象的规则，那么我们首先做的事就是先传入参数，生成具体的对象（也就是**实例化**）

```python
tr1=triangle(6,7,8)#这一步就是实例化
```

总结，所有的对象，不论是Python内置的，还是import第三方包里的，或者是我们自己用类定义然后实例化的，它们都由两部分构成。

- 一部分是像a、b、c这样的**数据**，他们决定这个对象**是什么**并将其实例化。
- 一部分是像angleA()、angleB()、angleC()这样的**函数**，它们表示用这些数据**做什么**

**在面向对象的编程中，一个对象的数据，称之为对象的属性；一个对象所拥有的函数，称之为对象的方法。**

以上简单的介绍了类的概念，然后可能还有一些小问题：

### 第一个函数def \_\_init()\_\_有什么作用？

顾名思义，init就是**初始化**（initiation）的意思，即初始化函数。也就是实例化类的时候自动运行的函数。比如我们实例化时传递了参数给类，那么参数就交由init函数来处理，指定传入的参数如何使用。当然，你也可以在init函数中加上任何你希望初始化时就执行完毕的函数，比如`print('实例化已完成')`什么的都是可以的。

但是大部分时候，我们在实例化时最希望做的事是把传入的数据传递给类的属性，即由init函数来指定参数如何使用。**大部分情况下，init函数都充当了构造函数的作用，它可以把传进的数据赋给某个变量，或者经过预处理后再赋予给某个变量。**

就例如在生成三角形中，我们是先给三角形传递了三条边长，而不是实例化完之后再依次tr1.a=6、tr1.b=7这样一个个赋值。所以我们在init函数中写明了数据的传递规则。

#### 给属性设定默认值

除此之外，我们还可以在init函数中设定默认值，这样我们就可以实现一个无须由形参定义的属性。

```python
class triangle:  
    def __init__(self,a,b,c): 
        --snip--
        self.d=0#我也不知道这是什么参数，只是为了告诉你可以指定默认值
```

#### 修改属性的值

在传入参数实例化之后，我们除了查看外，仍然可以再次修改传递的参数。

##### a.直接修改属性的值

```python
tr1.a
->6

tr1.a=7
tr1.a
->7
```

我们可以通过直接访问属性对其进行更新，但是我们还有其他方法。

##### b.通过方法修改属性的值

如果可以用方法更新属性的值，那么你可以无须访问属性的值而只需要将数据传递给方法来更新属性，这一点很有用。比如我们可以定义一个方法update_a()。

```python
class triangle:
    --snip--
    
    def updata_a(self,delta):
        self.a=delta
        
tr1=triangle(5,6,7)
tr1.update_a(6)
print(tr1.a)
'''
>>>6
'''
```

##### c.通过方法递增属性的值

这一点与b点大致相同，将`self.a=delta`修改为`self.a+=delta`即可达到目标。

### self有什么作用，为什么要写self.a等

我们在使用对象的属性时，格式是“对象名.属性名”。但是在定义类时，由于尚未实例化，我们还不知道对象的名称，所以要随便写一个（但是要求前后一致），一般都写self。

这里我们再加上书本上的练习来加深印象。

## 例题

***9-3** 用户 ：创建一个名为User 的类，其中包含属性first_name 和last_name ，还有用户简介通常会存储的其他几个属性。在类User 中定义一个名为describe_user() 的方法，它打印用户信息摘要；再定义一个名为greet_user() 的方法，它向用户发出个性化的问候。* 

*创建多个表示不同用户的实例，并对每个实例都调用上述两个方法。* 

***9-5** 尝试登录次数：在为完成练习9-3而编写的User 类中，添加一个名为login_attempts 的属性。编写一个名为increment_login_attempts() 的方法， 它将属性login_attempts 的值加1。再编写一个名为reset_login_attempts() 的方法，它将属性login_attempts 的值重置为0。* 

*根据User 类创建一个实例，再调用方法increment_login_attempts() 多次。打印属性login_attempts 的值，确认它被正确地递增；然后，调用方 法reset_login_attempts() ，并再次打印属性login_attempts 的值，确认它被重置为0。*

代码如下

```python
class User:
    def __init__(self,fname,lname,nname):
        self.first_name=fname
        self.last_name=lname
        self.nick_name=nname
        self.login_attempts=0

    def describe_user(self):
        print("User's first name is "+self.first_name.title())
        print("User's last name is "+self.last_name.title())
        print("User's nick name is "+self.nick_name.title())

    def greet_user(self):
        print("Hello! Mr "+self.first_name.title(),end='')
        print(" "+self.last_name.title()+'\n')
        
    def increment_login_attempts(self):
        self.login_attempts+=1
        
    def reset_login_attempts(self):
        self.login_attempts=0

user1=User('adam','ben','jjg')
user2=User('victory','V','globefish')
user3=User('frank','li','panda')

user1.describe_user()
user1.greet_user()

user2.describe_user()
user2.greet_user()

user3.describe_user()
user3.greet_user()

for i in range(0,5):
    user1.increment_login_attempts()
    
print(user1.login_attempts)
user1.reset_login_attempts()
print(user1.login_attempts)
'''
>>>User's first name is Adam
User's last name is Ben
User's nick name is Jjg
Hello! Mr Adam Ben

User's first name is Victory
User's last name is V
User's nick name is Globefish
Hello! Mr Victory V

User's first name is Frank
User's last name is Li
User's nick name is Panda
Hello! Mr Frank Li

5
0
'''
```



## 继承

编写类的时候，不一定每一次都必须要从空白开始。如果一个类要是用一个现有的类作为基础，那么你可以使用**“继承”**，一个类继承另一个类时，将自动获得另一个类的所有属性和方法。此时新类叫做**“子类”**，原有的类则称为**“父类”**。子类除了继承父类原有的属性和方法，还可以定义自己特有的属性和方法。

示例如下：

```python
class User:
    --snip--
    
class UserCn(User):
    def __init__(self,fname,lname,nname):
        super().__init__(self,fname,lname,nname)
        self.location='China'#定义子类独有的属性，在继承完后独立添加即可
        
user1=UserCn('adam','ben','jjg')
user1.greet_user()
'''
>>>Hello! Mr Adam Ben
'''
```

使用继承时要注意的几点：

- 继承时，父类必须与子类包含在同一文件中，且位于子类前面。
- 定义子类时，括号内必须指定要继承的父类名称，并在\_\_init\_\_方法中接收创建父类时要接受的信息。
- super是一个特殊的函数，它让你调用父类的方法。这行代码首先调用父类的\_\_init\_\_方法，让子类创建的实例包含这个方法的所有属性。因此父类也被称为**“超类”**。
- **再次总结一遍，在继承中子类的\_\_init\_\_方法用来继承父类的属性，super函数则用来调用父类的方法。**

- **不要去看多继承**

![](https://cdn.jsdelivr.net/gh/Adam8en/blogImage/images/20230910105940.png)

### 重写父类

对于父类的方法，如果其不符合子类模拟实物的行为，可以进行**重写**。为此，可以在子类中定义一个与父类同名的方法覆盖。

重写父类可以让子类只继承父类中的精华，而去其糟粕。

### 将实例作为属性

有时候，你会发现给一个类添加的细节越来越多，造成类的内容过于冗杂。这种情况下，可以将一些相对比较独立的类分离出来单独作为一个小类，而大类则由小类组成。

```python
class Name:
'''将name单独独立出来作为一个类'''
    def __init__(self,fname,lname,nname):
        self.first_name=fname
        self.last_name=lname
        self.nick_name=nname
        
    def print_name(self):
        print("My name is "+self.first_name.title()+' '+self.last_name.title())

class User:
    def __init__(self,fname,lname,nname):
        self.name=Name(fname,lname,nname)

    def greet_user(self):
        print("Hello! Mr "+self.name.first_name.title(),end='')
        print(" "+self.name.last_name.title()+'\n')

user1=User('adam','ben','jjg')
user1.name.print_name()
'''
>>>My name is Adam Ben
'''
```

## 导入类

导入类的方法和导入函数的方法相同。有时候我们定义的类太多导致文件内容太长，为了保持Python文件的简洁性，我们可以把类的定义单独储存在一个文件中，然后将该文件作为模块导入主程序。这样我们可以专心与研究代码的高级逻辑结构而无须注意更细节的底层逻辑。

假如我们将User和Name类的定义储存在user.py文件中，然后在主程序main.py中导入改模块，我们有以下几种导入方式。

1. `from user import User,Name`只将类导入文件，导入多个类可以用逗号分隔。
2. `import user`导入整个模块，但是在实例化和使用类时必须要加上文件名前缀。比如要将`user1`变量实例化，我们必须这么写`user1=user.User('adam','ben,'jjg')`。
3. `from user import *`导入所有类，不推荐这么写，可能会导致命名冲突。且这么做隐匿了导入类的名称，让程序员难以判断导入类的信息。

除此之外，还可以在模块中导入模块。比如再将Name类分离储存在name.py文件中，那么我们就需要在user.py中也是用import导入name.py中的类，否则主程序将会报错。

## 类编码风格

有关类的编码风格，我们有一些约定俗成的规矩。

- 类名应该采用**驼峰命名法**，即类名的每个单词首字母都大写而不使用下划线。
- 实例名和模块名都采用小写格式，并在每个单词之间加上下划线。
- 对于每个类，后面都应该紧跟一个文档字符串，用来简单的描述类的功能。每个模块亦是如此，用于描述该模块包含的类的作用。
- 可以使用空行来组织代码，但不能滥用。可以使用一个空行分隔不同的方法；在模块中，可以使用两个空行来分隔不同的类。
- 对于同时导入标准库中的模块和自定义模块时，都应该先编写标准库的import语句，再添加一个空行，随后再导入自己的自定义模块。这样能够更容易让人明白程序使用的各个模块都来自何处。

![复件 86800272_p0 (1)](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2086800272_p0%20(1?x-oss-process=style/blog).jpg)

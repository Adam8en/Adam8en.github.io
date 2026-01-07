---
title: CTFer的苦痛之路——SQL注入篇
date: 2023-09-18 16:33:20
tags: 
  - Web
  - SQL注入
  - CTF
categories: CTF苦痛之路
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2062841026_p0.png
description: "关于CTF的SQL的一些知识点"
updated: 2023-10-17 23:40:15
---

作为网安的学生，不系统的学习一下CTF比赛，真是有点愧对这个专业了。然而CTF这条路必定道阻且长，实践性极强而且门槛参差不齐，且缺乏系统的入门学习方法。过了一年了，从一开始的编程零基础到现在掌握了一些必要的编程技巧，终于打算仔细钻研一下CTF了。

我用的书本是《从0到1 CTFer成长之路》，不用说，听书名就觉得这劲度不下与苦痛之路口牙。总之姑且就先这么开干了，也许后续还会参考一些其他比赛或者靶场的题目以及CTF Wiki。

另外，由于个人原因，并不会按照书上的编排顺序进行学习。一是兴趣方向所需，二是有一些知识点暂时还理解不了……（比如git泄露我连git都还没学啊喂）（我是蒻笱）

那么 <font color="red"  size="10px">CTF 启动！！！</font>

----

如上文提到的，关于CTF的知识学习由我个人兴趣决定。那么我们就先来试试SQL注入。

SQL注入……理论上需要一定的PHP和MySQL基础，然而两个我都还没学（别骂了），所以注定是困难重重，学习效果如何也不敢保证。暑假的时候听了听学校夏令营，感觉有了点眉目，然而还是写不出来题目（SQL语句太长了记不住……）。无论如何，还是先开始吧。

## SQL注入基础

web应用开发中，为了内容快速更新，很多开发者把数据放在数据库中进行储存。但是由于开发者对用户数据传入的过滤不严格，可能将攻击载荷拼接到正常的SQL查询语句中，再将这些查询语句交由后端的数据库里执行，从而引发和预期功能不一致的语句，我们称之为**SQL注入**。这通常将导致数据库的信息泄露、篡改甚至删除。这里我们将介绍几种常见的SQL注入类型，包括**数字型注入、UNION注入/联合注入、字符型注入、布尔盲注、时间注入、报错注入和堆叠注入**。

### 数字型注入和UNION注入

借用书上的例题，我们先给出第一个例子的PHP代码。

```php
<?php
//连接本地MySQL,数据库为test
$conn = mysqli_ connect("127.0.0.1" "root" , "root" , "test");
//查询wp_news表的title、content字段，id为GET输入的值
$res = mlysqli. _query($conn, "SELECT title, content FROM wp_news WHERE id=" .$. GET['id']);
//说明:代码和命令对于SQL语句不区分大小写，书中为了让读者清晰表示，对于关键字采用大写形式
//将查询到的结果转化为数组
$row = mysqli _fetch. array($res);
echo "<center>";
//输出结果中的title字段值
echo "<h1>". $row['title']. "</h1>";
echo "<br>";
//输出结果中的content字段值
echo "<h1>". $row[ 'content']. "</h1>";
echo "</center>";
?>
```

数据库的表结构见图1-1，新闻表wp_news的内容见图1-2，用户wp_user的内容见图1-3。

![img](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/20230918142004.png)

<center>图1-1</center>

![img](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/20230918142133.png)

<center>图1-2</center>

![image-20231017233825699](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231017233825699.png)

<center>图1-3</center>

顺便给定一个目标网址`http://192.168.20.133/sql1.php`，然而这个网址是打不开的，我也不知道为什么。

那么本节的目标就是通过HTTP的GET函数来获取输入的id值，将本应该查询新闻表的功能转变为查询admin（通常是管理员）的账号和密码（密码通常是hash值，这里为了演示就变成明文this_is_the_admin_password）。获取管理员账户和密码后，入侵者可以通过它登录网站后台，从而控制整个网站内容。

首先我们访问`http://192.168.20.133/sql1.php?id=1`，结果如下图1-4。

![img](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/20230918143049.png)

<center>图1-4</center>

这里运用到了GET请求发送了一个id为1的参数，最后得到的结果与新闻表wp_news中第一行id为1的结果一致。事实上，PHP将GET方法传入的`id=1`与前面的SQl语句进行了拼接，原查询语句如下。

`$res = mysqli _query($conn, "SELECT title, content FROM wp_news WHERE id=".$_GET['id']);`

在收到`id=1`后，`.$_GET['id']`被赋值为1，最后传递给MySQL的查询语句如下。

`SELECT title, content FROM wp_news WHERE id = 1`

值得注意的是MySQL对大小写不敏感，这里将关键字大写是为了方便理解。

下面开始通过用户输入id参数来进行SQL注入攻击。

首先我们访问链接`http://192.168.20.133/sql1.php?id=2`，也就是传入`id=2`，得到结果如图1-5的id为2的记录，再传递参数`id=3-1`，仍然可以得到`id=2`的记录。说明MySQL对`3-1`的表达式进行了计算结果为2，然后查询id=2的记录。

![img](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/20230918150132.png)

<center>图1-5</center>

这个行为基本可以判断该注入点为**数字型注入**，表现为`$_GET['id']`附近没有引号包裹。这时我们可以直接输入SQL查询语句来干扰正常的查询。

`SELECT title, content FROM wp_news WHERE id = 1 UNION SELECT user, pwd FROM wp_user`

这个SQL语句的作用是查询新闻表中id=1时对应行的title和content字段的数据，并且联合查询用户表中的user、pwd。union关键字会对两个结果集进行并行查询。

我们通过网页访问时只需要输入id后面的内容，即访问链接`http://192.168.20.133/sql1.php?id=1 union select user, pwd from wp_user`。注意，在浏览器中空格会被转化为`%20`，这是空格的URL编码。

![img](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/20230918153720.png)

<center>图1-6</center>

但是如图1-6所示，网页并没有按照预期显示用户和密码的内容，事实上MySQL确实查询出了两条记录，但因为PHP限制该页面只能显示一条内容，所以我们需要将账号密码的记录显示在查询结果第一行。有几种实现方式，比如在原有数据后加上`limit 1,1`参数（显示查询结果后的第二条记录）。又或者指定`id=-1`或者一个很大的值，第一行记录无法被查询到，这样结果就可以只显示第二条记录了。

那么我们访问`http://192.168.20.133/sql1.php?id=-1 union select user, pwd from wp_user`成功得到了图1-7所示的用户表的账号和密码。

![img](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/20230918155116.png)

<center>图1-7</center>

以上这种通过UNION语句将数据显示到页面上的注入方法为**UNION注入/联合注入**。是最为简单也是最基础的注入方法，因为该数据库没有设置任何关于数据的过滤方式。我们后续学习的注入方法大多也基于这种思路，不过要尝试绕过所设置的过滤（也许是吧）。

但是以上的例子是默认我们已经知道了数据库结构，在测试情况下，我们要如何知道数据表的字段名pwd和表名wp_user呢？

答案是information_schema。MySQL5.0版本后，默认自带一个数据库information_schema，储存着MySQL的所有数据库名、表名、字段名。虽然引入这个库是方便数据库信息的查询，但是客观上却大大方便了SQL注入（乐）。

接下来演示实战的操作过程。

假设我们并不知道数据库的相关信息，首先通过`id=2`和`id=3-1`回显一致判断这存在一个数字型注入，然后通过联合查询，查到本数据库和其他所有表名。访问`http://192.168.20.133/sql1.php?id=-1 union select 1,group_concat(table_name) from information_schema.tables where table_schema=database()`。结果见图1-8。

![image-20231017233946704](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231017233946704.png)

<center>图1-8</center>

让我们看看这么长一串玩意到底执行了个啥。information_schema包含了MySQL中所有的数据库名、表名、字段名，其中的table表就是储存数据库所有表名的一个表，而table_name是table表的表名字段，后面跟所有表的名字。table表中还包含数据库名字段table_schema，database()函数返回的内容是当前数据库的名称，group_concat()函数则是用“,”来联合多行记录的函数。

也就是说，该语句可以查询数据库中所有表名并显示在一个字段中。如下图1-9所示。

![image-20231017233959278](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231017233959278.png)

<center>图1-9</center>

更详细的ChatGPT解释附在下方。

>当解释这条SQL语句中的关键字时，我会一一说明它们的作用：
>
>1. `union`: 在SQL中，`UNION`操作符用于合并两个或多个`SELECT`语句的结果集。它将多个查询的结果合并在一起，并以一个单一的结果集返回。
>2. `select`: `SELECT`关键字用于从数据库表中检索数据。在这种情况下，`SELECT`用于选择查询结果中需要显示的列。
>3. `1`: 这是一个常量值，表示第一个查询结果集中的一列。在这种情况下，它用作占位符，因为`UNION`操作要求所有查询具有相同数量和类型的列。
>4. `group_concat`: `GROUP_CONCAT`是MySQL中的聚合函数之一。它用于将多个行的某一列值连接成一个单独的字符串。在这里，它用于将`table_name`列中的表名连接成一个字符串。
>5. `table_name`: `table_name`是`information_schema.tables`视图中的一个列名。该列包含了数据库中的表名信息。
>6. `information_schema.tables`: `information_schema`是MySQL系统数据库之一，其中包含关于数据库、表、列和其他数据库对象的元数据信息。`tables`是`information_schema`中的一个表，包含有关数据库中表的信息。
>7. `where`: `WHERE`关键字用于指定查询的条件。在这种情况下，`where table_schema=database()`用于过滤只返回当前数据库中的表。
>
>通过结合使用这些关键字和语句，攻击者可以利用注入漏洞执行恶意查询，并从`information_schema.tables`表中提取表名信息。

同理，通过columns表中的column_name查询出的内容即为wp_user中的字段名，访问`http://192.168.20.133/sql1.php？id=-1 union select 1 ,group_concat (column_name) from information_schema.columns where table_name='wp_user'`，可以得到对应的字段名。见图1-10。

![image-20231017234009782](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231017234009782.png)

<center>图1-10</center>

至此，第一个例子结束。数字型注入的**关键**在于找到输入的参数点，然后通过加减乘除等运算判断参数附近有无引号包裹，再通过一些常见的攻击手段（比如联合注入，在此之前先尝试获得表名），获取数据库的敏感信息。

### 字符型注入和布尔盲注

----

（待更新……）

![复件 62841026_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E5%A4%8D%E4%BB%B6%2062841026_p0.png)

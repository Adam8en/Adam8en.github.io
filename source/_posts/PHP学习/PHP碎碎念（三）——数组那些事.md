---
title: PHP碎碎念（三）——数组那些事
tags: PHP
date: 2023-11-09 23:01:01
categories: PHP学习
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/57672472_p0.jpg?x-oss-process=style/blog
description: 这一章介绍了PHP的一些处理数组的有用函数，只节选了一部分，要阅读全部函数请翻阅PHP的在线手册。
updated: 2023-11-09 23:03:24
---


和其他语言一样，PHP也有数组。但是不同于C语言，PHP的数组更加灵活而且方法更加多样化，这一点类似于Python中的字典。主要是因为PHP的数组可以不局限于数字索引，也就是说数组允许自定义索引。

话不多说，进入正题。我们先从数字索引数组开始介绍，然后再讲自定义索引数组，最后介绍一些处理数组的方法。

## 数字索引数组

和大多数编程语言一样，在PHP中的数字数组索引也是从0开始的。当然，这一点可以更改。

### 初始化

PHP数组的初始化有以下几种方法

```php
$name=array('Adam','Ben','JJG');
$name=['Adam','Ben','JJG'];//PHP5.4版本后支持
$name=range(1,10);//储存1到10的数字
$name=range('a','z');//储存字符a到z
$name=file("outputs.txt");//从文件导入数组，每一行作为一个元素
```

后面几种声明数组的方式看起来有点像Python中的列表，但是要注意这两者并不是完全相同。比如range()函数，在PHP中`range(1,10)`是输出1到10，而Python则是输出1到9,10的边界是一个开集。

最后提到的从文件导入数组用到了第二章提到过的file()函数，详细内容可以回看一下第二章。

另外，PHP支持数组间等号的重载，如果你想把一个数组中的数据保存在另一个数组中，直接使用等号就行。

### 访问数组

这部分和C等其他语言的规则大致相同，不多赘述。你可以使用`$name[0]`来访问第一个元素，但是PHP也允许你用{}大括号来代替中括号。

另外，PHP的数组长度是动态的，和Python和C都不太一样。在C中你需要实现指定数组的长度，Python中添加元素需要调用列表的方法append()，但是在PHP中允许你直接声明一个新的元素。

```php
$name[4]='jjg'//这行代码会直接为$name数组添加第四个元素
```

如果下标相同，等同于更改原索引对应的数组值。如果这个数组一开始并不存在，PHP会创建一个只包含一个元素的新的数组。

#### 循环访问数组

我们之前提到了通过数组下标来访问数组，但是正如其他语言中一样，PHP也可以使用循环来访问数组，效率更高也更强大，下面介绍几个循环函数。

```php
for ($i = 0; $i<3; $i++){
    echo $name[$i]." ";
}//经典的for循环，和C语言一样的语法，但是不适用于自定义索引数组

foreach ($name as $n){
    echo $n." ";
}//foreach是PHP中的特性函数，允许$n表示数组中的每一个元素，减少了手工输入量，非常方便
```

## 自定义索引数组

正如我们前文提到的那样，PHP可以自定义索引，其创建方法类似于Python中的字典，也就是包含一个键名和对应的值。下面是自定义索引数组的创建方法.

```php
$names=array('fname'=>'Adam','lname'=>'Ben','nname'=>'jjg');
$names['nname']='JJG';
```

键和值之间的连接符号是`=>`，有点奇怪，挺象形的只能说。

由于数组的索引不再是整数，所以使用for循环访问数组元素的时候，就不能简单的使用经典的for循环，而要使用foreach循环或者each()和list()结构。

形式如下。

```php
foreach($names as $key=>$value){//这里用$key和$value分别代表数组中一个元素的键名和值
    echo $key." - ".$value."<br />";
}

while($e = each($names)){//each()函数会返回数组当前所指元素，然后指向下一个元素
    echo $e['key']." - ".$e['value'];
    echo "<br />";
}

reset($names);//数组会记得自己指向了哪个元素，如果想再次循环遍历该数组，需要使用reset()函数将数组指针重新指向首元素

while(list($a,$b)=each($names)){//比上面的方式更好，list()会把元素分离成两部分并将其储存在两个新变量中
    echo $a." - ".$b."<br />";
}
```

## 数组操作符

PHP有一组对数组的操作符，大多数这些操作符都有与之对应的标量操作符，将其整理如下。

| 操作符 | 名称   | 实例      | 结果                                                         |
| ------ | ------ | --------- | ------------------------------------------------------------ |
| +      | 联合   | \$a+\$b   | 数组a、b联合。将数组b中的元素添加到数组a中。如果键名冲突该元素将不会被添加。 |
| ==     | 等价   | \$a==\$b  | 如果数组a、b**包含相同元素**，返回true                       |
| ===    | 恒等   | \$a===\$b | 如果数组a、b**包含相同顺序和类型的元素**，返回true           |
| !=     | 不等价 | \$a!=\$b  | 不包含相同元素                                               |
| <>     | 不等价 | \$a<>\$b  | 和!=相同                                                     |
| !==    | 不恒等 | \$a!==\$b | 不恒等                                                       |

这些操作符也可以拿来比较标量，一般来说数组和标量无法比较，会抛出一个false。利用这一点可以在某些CTF的PHP代码审计中绕过一些判定方法，比如传入一个数组和某个非数组值进行比较。

## 多维数组

关于多维数组的部分不过多展开，一来这部分比较晦涩复杂，平时最多用到二维数组，极少用到三维数组；二是多维数组的概念和C等语言类似，没必要多开篇幅介绍。在PHP中多维数组就是简单的数组嵌套，用多个array()函数嵌套即可声明一个多维数组。

除了多维数组的概念，关于一些多维数组的操作（如排序）也将暂时跳过。

## 数组排序

在PHP中定义了许多有用的方法来对数组进行排序，而不用想C语言一样造轮子。

### sort()

sort()是一个功能强大的函数：无论是字符串数组还是数字数组，都将按照升序排列进行排序。其中字母排序区分字母大小写，大写字母永远在小写字母前面，即按照ASCII码进行排序。同理，数字永远排在字母前面。

```php
<?php
$names=['a','b','1a','2a','A','B'];
print_r($names);
sort($names);
print_r($names);
```

![image-20231109220142615](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231109220142615.png?x-oss-process=style/blog)

sort()函数的第二个参数是可选的。这些参数是SORT_REGULAR、SORT_NUMBERIC、SORT_STRING、SORT_LOCAL_STRING、SORT_NATURAL、SORT_FLAG_CASE。这些参数虽然很有用，但是实际上很少用到（至少在CTF从来没碰到过）。贴了一段别的大佬博客归纳。

>1. SORT_REGULAR：按照常规比较方式排序（不改变类型）
>2. SORT_NUMERIC：按照数值比较方式排序
>3. SORT_STRING：按照字符串比较方式排序
>4. SORT_LOCALE_STRING：按照本地化字符串比较方式排序
>5. SORT_NATURAL：按自然顺序对字符串进行排序(与SORT_STRING相同),同时不区分大小写
>6. SORT_FLAG_CASE：可以联合使用喜欢SORT_STRING或SORT_NATURAL，在进行字母的比较时不区分大小写

要实现降序排序也很简单，使用rsort()函数即可将元素按照降序顺序排列。

### asort()和ksort()

这两个函数作用机理和sort()函数相同，只是作用对象为自定义索引数组。如果你想根据键名来排序，选择ksort()，否则选择asort()来按照元素的值进行排序。如果想要按照降序排序也一样可以使用arsort()或者krsort()函数。

### usort()

usort()中的‘u’代表‘user’，意味着这是个由用户自定义的排序函数。在使用这个函数时，首先要自定义一个比较函数，比如我需要按照一个数组的第三项去进行排序，我可以编写如下代码。

```php
function compare($x,$y){
    if ($x[1]==$y[1]){
        return 0;
    }elseif ($x[1]<$y[1]){
        return -1;
    }
    else{
        return 1;
    }
}
usort($names,'compare');//传入待排序的数组和自定义比较函数名
```

调用usort()函数没有反向变体，但是你可以直接修改自定义比较函数的返回值达到反向排序的效果。

### shuffle()

向shuffle()函数传入数组，它会将数组元素顺序打乱随机排序。

### array_reverse()

array_reverse()函数会将数组按照与原来的排序相反的顺序进行排序，但是这个函数只返回排序后数组的副本，不会改变原数组。要改变原数组，将返回值赋予原数组就好。

## 其他数组操作

除了以上介绍的这些处理数组的函数，还有一些函数也很有用，这里就简要的介绍一下。

### explode()

向函数传递一个分隔符和字符串，可以将字符串根据分隔符分隔为不同的元素并作为数组返回。

### each()和next()和current()

在前文介绍了each()函数会返回数组当前所指值并指向下一个元素，而next()则是直接指向下一个元素再返回元素值。current()函数则是返回目前数组指向元素的值。

### reset()和end()

前文介绍过reset()函数会重置数组指针并返回第一个数组元素值，而end()函数则刚好相反：它直接指向最后一个元素并返回最后一个元素值。

### prev()和pos()

prev()函数和next()函数相反，它将指针回移一位并返回所指值。而pos()函数则是current()函数的别名。

### count()/sizeof()和array_count_values()

count()函数返回数组中元素的个数，sizeof()函数是它的一个别名。而array_count_values()则返回一个数组，内含传入数组元素的出现频率表，统计每个元素在该数组中出现的次数。

### extract()

这个函数很有意思，它会把数组中的关键字-值对转换成一系列标量变量。具体用法如下。

```php
$names=array('fname'=>'Adam','lname'=>'Ben','nname'=>'JJG');
$nname='jjg';
extract($names);
echo $fname."\n";
echo $lname."\n";
echo $nname."\n";
```

![image-20231109225232660](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20231109225232660.png?x-oss-process=style/blog)

值得注意的是，如果当前已经存在和数组关键字相同名称的变量，该变量值会被覆盖。也就是说通过extract()函数可以覆盖掉一些原本存在的变量值达到注入的效果。这一点在CTF的PHP代码审计中经常用到（划考点）。

不过extract()函数将元素转换为变量的前提是该元素的关键字必须符合PHP变量命名规范，也就是说以数字开头和包含空格的关键字将被跳过。

extract()函数还可以传递第二个参数extract_type，这里不多赘述，贴一段其他大佬的归纳总结。

>*extract_type* - 可选项。`extract()`函数检查无效变量名称和与现有变量名称的冲突。 此参数指定如何处理无效和碰撞名称。可能的值 -
>
>- *EXTR_OVERWRITE* - 默认。 碰撞时，现有变量被覆盖。
>- *EXTR_SKIP* - 碰撞时，现有的变量不会被覆盖
>- *EXTR_PREFIX_SAME* - 碰撞时，变量名将被赋予一个前缀。
>- *EXTR_PREFIX_ALL* - 所有的变量名都会被赋予一个前缀。
>- *EXTR_PREFIX_INVALID* - 只有无效或数字变量名称才会被赋予前缀。
>- *EXTR_IF_EXISTS* - 只覆盖当前符号表中的现有变量，否则什么都不做。
>- *EXTR_PREFIX_IF_EXISTS* - 如果当前符号表中存在相同的变量，则只向变量添加前缀。
>- *EXTR_REFS* - 提取变量作为参考。导入的变量仍然引用数组参数的值
>
>//更多请阅读：https://www.yiibai.com/php/php_function_extract.html 

![57672472_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/57672472_p0.jpg?x-oss-process=style/blog)

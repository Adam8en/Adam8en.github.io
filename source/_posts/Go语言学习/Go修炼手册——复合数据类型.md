---
title: Go修炼手册——复合数据类型
date: 2024-05-09 16:37:28
updated: 2024-05-09 16:37:28
tags:
  - Go
categories: Go!Go!Go!
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/f5c4c658c9623ef310f3d678caabff4c.jpeg
description: Go的复合数据类型讲解，主要讨论四种类型——数组、slice、map和结构体。后两章JSON和模板内容还涉及一点网络编程。
---

## **复合数据类型**

在本章，我们将讨论复合数据类型，它是以不同的方式组合基本类型而构造出来的复合数据类型。我们主要讨论四种类型——数组、slice、map和结构体

数组和结构体是聚合类型；它们的值由许多元素或成员字段的值组成。数组是由同构的元素组成——每个数组元素都是完全相同的类型；结构体则是由异构的元素组成的。数组和结构体都是有固定内存大小的数据结构。相比之下，slice和map则是动态的数据结构，它们将根据需要动态增长。

### 数组/array

数组是一个由**固定长度**的**特定类型**元素组成的序列，一个数组可以由零个或多个元素组成。因为数组的长度固定，所以在Go中很少使用数组，而**更多的使用长度动态的slice切片**。

默认情况下，数组的每个元素都被初始化为元素类型对应的零值。

在数组字面值中，如果在数组的长度位置出现的是“...”省略号，则表示数组的长度是根据初始化值的个数来计算。（在C中则是直接省略...）

```go
var q [3]int = [3]int{1,2,3}
q := [...]int{1,2,3}
```

数组的长度是数组类型的一个组成部分，因此[3]int和[4]int是两种不同的数组类型。数组的长度必须是常量或者常量表达式（C中也允许常量表达式，但新标准中也允许变量表达式，即变长数组），因为数组的长度需要在编译阶段确定。如果需要用到变量确定数组长度，应该选择长度动态的slice。

数组也可以用于比较。对数组可以使用`=`和`!=`，此时数组会逐个比较元素是否相等。

当调用一个函数的时候，函数的每个调用参数将会被赋值给函数内部的参数变量，所以函数参数变量接收的是一个复制的副本，并不是原始调用的变量。因为函数参数传递的机制导致传递大的数组类型将是低效的，并且对数组参数的任何的修改都是发生在复制的数组上，并不能直接修改调用时原始的数组变量。在这个方面，Go语言对待数组的方式和其它很多编程语言不同，**其它编程语言可能会隐式地将数组作为引用或指针对象传入被调用的函数**。

> Go语言中的数组是**值类型**，不是**引用类型**。这意味着当你把一个数组赋值给另一个数组或者将数组作为函数参数传递时，实际上是在复制整个数组。所以，如果你在函数内部修改了数组的元素，这些修改不会影响到原始数组。
>
> 这与C语言（以及许多其他语言）的行为不同，C语言中数组在函数调用时默认以指针的形式传递，所以函数内部对数组的修改会影响到原始数组。
>
> 如果你想在Go语言中实现类似的行为，你需要使用切片（slice）或者显式地传递数组的指针。切片在内部存储了对底层数组的引用，所以如果你修改了切片的元素，这些修改会影响到底层数组。例如：
>
> ```go
> func modifySlice(s []int) {
> s[0] = 100
> }
> 
> func main() {
> a := []int{1, 2, 3}
> modifySlice(a)
> fmt.Println(a) // 输出 [100 2 3]
> }
> ```
>
> 在上面的例子中，`modifySlice`函数修改了切片`s`的第一个元素。这个修改也影响到了原始切片`a`。

虽然通过指针来传递数组参数是高效的，而且也允许在函数内部修改数组的值，但是数组依然是僵化的类型，因为数组的类型包含了僵化的长度信息。上面的zero函数并不能接收指向[16]byte类型数组的指针，而且也没有任何添加或删除数组元素的方法。由于这些原因，除了像SHA256这类需要处理特定大小数组的特例外，数组依然很少用作函数参数；相反，我们一般使用slice来替代数组。

### 切片/slice

Slice（切片）代表变长的序列，序列中每个元素都有相同的类型。一个slice类型一般写作[]T，其中T代表slice中元素的类型；slice的语法和数组很像，只是没有固定长度而已。

slice是一个轻量级的数据结构，提供了访问数组子序列（或者全部）元素的功能，而且slice的底层确实引用一个数组对象。一个slice由三个部分构成：**指针、长度和容量**。指针指向第一个slice元素对应的底层数组元素的地址，要注意的是slice的第一个元素并不一定就是数组的第一个元素。长度对应slice中元素的数目；长度不能超过容量，容量一般是从slice的开始位置到底层数据的结尾位置。内置的len和cap函数分别返回slice的长度和容量。

当slice的长度超过容量时，Go会对切片进行扩容，一般来说可能会把底层数组的容量扩张到原来的两倍然后将元素复制过去。通过内存的预分配来减少内存管理的时间。

因为slice值包含指向第一个slice元素的指针，因此向函数传递slice将允许在函数内部修改底层数组的元素。换句话说，复制一个slice只是对底层的数组创建了一个新的slice别名。

要注意的是slice类型的变量s和数组类型的变量a的初始化语法的差异。slice和数组的字面值语法很类似，它们都是用花括弧包含一系列的初始化元素，但是对于slice并没有指明序列的长度。这会隐式地创建一个合适大小的数组，然后slice的指针指向底层的数组。

和数组不同的是，slice之间不能比较，因此我们不能使用==操作符来判断两个slice是否含有全部相等元素。不过标准库提供了高度优化的bytes.Equal函数来判断两个**字节型**slice是否相等（[]byte），但是对于其他类型的slice，我们必须自己展开每个元素进行比较：

```go
func equal(x, y []string) bool {
     if len(x) != len(y) {
     return false
 }
 for i := range x {
     if x[i] != y[i] {
     	return false
    	}
 	}
 	return true
}
```

slice唯一合法的比较是与`nil`进行比较。

一个零值的slice等于nil。一个nil值的slice并没有底层数组。一个nil值的slice的长度和容量都是0，但是也有非nil值的slice的长度和容量也是0的。

```go
var s []int // len(s) == 0, s == nil
s = nil // len(s) == 0, s == nil
s = []int(nil) // len(s) == 0, s == nil
s = []int{} // len(s) == 0, s != nil
//第一个和第四个切片的区别在于，第一个切片是一个零值切片，而第四个切片是一个空切片。
```

内置的make函数创建一个指定元素类型、长度和容量的slice。容量部分可以省略，在这种情况下，容量将等于长度。

```go
make([]T, len)
make([]T, len, cap) // same as make([]T, cap)[:len]
```

#### append函数

slice内置一个append函数管理切片，向切片添加元素。append函数底层管理slice的操作比较复杂，我们不知道append函数是否导致了内存的重新分配，也不知道新的slice是否和旧的slice共享一片内存空间。

append函数可以向切片追加一个或多个元素，甚至再追加一个slice。

```go
var x []int
x = append(x, 1)
x = append(x, 2, 3)
x = append(x, 4, 5, 6)
x = append(x, x...) // append the slice x
//这里的...代表展开x切片，否则意味着试图向切片中追加切片而不是切片的元素
fmt.Println(x) // "[1 2 3 4 5 6 1 2 3 4 5 6]"
```

需要记住尽管底层数组的元素是间接访问的，但是slice对应结构体本身的指针、长度和容量部分是直接访问的。要更新这些信息需要像上面例子那样一个显式的赋值操作。从这个角度看，slice并不是一个纯粹的引用类型，它实际上是一个类似下面结构体的聚合类型：

```go
type IntSlice struct {
 ptr *int
 len, cap int
}
```

#### slice的技巧

可以编写一个函数过滤slice中的空值。

```go
func nonempty(strings []string) []string {
     out := strings[:0] // zero-length slice of original
         for _, s := range strings {
             if s != "" {
                out = append(out, s)
             }
     }
     return out
}
```

这类算法可以用来实现对slice的过滤和相同项的合并。下面这个算法就实现了对slice相邻元素的合并。

```go
func merge(strings []string) []string {
     out := strings[:0] // zero-length slice of original
         for _, s := range strings {
             if len(out)==0 || s != out[len(out)-1] {
                out = append(out, s)
             }
     }
     return out
}
```

还可以用slice来模拟一个栈。

```go
stack := append(stack,v) // push v
top := stack[len(stack)-1] // top of stack
stack := stack[:len(stack-1)] // pop
stack := append(stack[:i],stack[i+1:]...) //remove stack[i] 虽然这好像不是栈的特性了
```

当然，你也可以很方便的实现一个队列。

```go
queue = append(queue, 1) // enqueue
front := queue[0] // front
queue = queue[1:] // dequeue
```

### 哈希表/Map

哈希表是一种巧妙并且实用的数据结构。它是一个无序的key/value对的集合，其中所有的key都是不同的，然后通过给定的key可以在常数时间复杂度内检索、更新或删除对应的value。 

很多现代语言都内置了哈希表，比如Python的`dict`，PHP的`array`（没错PHP的数组底层其实是哈希表），Java的`HashMap`等。

Go的map就是对一个哈希表的**引用**，其实可以简单的视为一个键值对的储存，也就是键名索引是任意数据类型的数组。但是键名Key对应的数据类型必须是可以用`==`比较的，因为这样才可以用测试key相等来判断键值对是否存在。

内置的make函数可以创建一个map，也可以用其他的方法显示声明。

```go
ages := make(map[string]int) // mapping from strings to ints

ages := map[string]int{
 "alice": 31,
 "charlie": 34, }

ages := make(map[string]int)
ages["alice"] = 31
ages["charlie"] = 34
```

使用内置的delete函数可以删除元素：

```go
delete(ages, "alice") // remove element ages["alice"]
```

这些操作是安全的，即使这些元素不在map中也没有关系；如果一个查找失败将返回value类型对应的零值。但是有时候可能需要知道对应的元素是否真的是在map之中。例如，如果元素类型是一个数字，你可能需要区分一个已经存在的0，和不存在而返回零值的0，可以像下面这样测试：

```go
age, ok := ages["bob"]
if !ok { /* "bob" is not a key in this map; age == 0. */ }

if age, ok := ages["bob"]; !ok { /* ... */ }
```

在这种场景下，map的下标语法将产生两个值；第二个是一个布尔值，用于报告元素是否真的存在。布尔变量一般命名为ok，特别适合马上用于if条件判断部分。

Map的迭代顺序是不确定的，并且不同的哈希函数实现可能导致不同的遍历顺序。在实践中，遍历的顺序是随机的，每一次遍历的顺序都不相同。这是故意的，每次都使用随机的遍历顺序可以强制要求程序不会依赖具体的哈希函数实现。如果要按顺序遍历key/value对，我们必须显式地对key进行排序，可以使用sort包的Strings函数对字符串slice进行排序。

```go
// 提取 map 的键
	keys := make([]string, 0, len(m))
	for k := range m {
		keys = append(keys, k)
	}

	// 对键进行排序
	sort.Strings(keys)

	// 按照排序后的键的顺序遍历 map
	for _, k := range keys {
		fmt.Printf("%s: %d\n", k, m[k])
	}
```

> Go 语言中的 `map` 类型的遍历顺序是不确定的，这是由 Go 的设计者有意为之的。这种设计有几个主要的原因：
>
> 1. **防止程序员依赖特定的遍历顺序**：如果 `map` 的遍历顺序是固定的，程序员可能会依赖这个特性来编写代码。然而，这种依赖是不安全的，因为 `map` 的实现可能会在未来的版本中改变，导致遍历顺序发生变化。通过使遍历顺序不确定，Go 的设计者强制程序员编写不依赖遍历顺序的代码。
> 2. **提高性能**：在某些情况下，随机的遍历顺序可以提高 `map` 的性能。例如，如果所有的键都被插入到同一个哈希桶中，固定的遍历顺序可能会导致性能下降。通过使遍历顺序随机，可以避免这种情况。
> 3. **避免安全问题**：在某些情况下，固定的遍历顺序可能会导致安全问题。例如，攻击者可能会利用固定的遍历顺序来预测哈希函数的行为，从而进行哈希碰撞攻击。通过使遍历顺序随机，可以防止这种攻击。

map类型的零值是nil，也就是没有引用任何哈希表。

map上的大部分操作，包括查找、删除、len和range循环都可以安全工作在nil值的map上，它们的行为和一个空的map类似。但是向一个nil值的map存入元素将导致一个panic异常。在向map存数据前必须先创建map。

有时候我们需要一个map或set的key是slice类型，但是map的key必须是可比较的类型，但是slice并不满足这个条件。不过，我们可以通过两个步骤绕过这个限制。第一步，定义一个辅助函数k， 将slice转为map对应的string类型的key，确保只有x和y相等时k(x) == k(y)才成立。然后创建一个key为string类型的map，在每次对map操作时先用k辅助函数将slice转化为string类型。

下面的例子演示了如何使用map来记录提交相同的字符串列表的次数。它使用了`fmt.Sprintf`函数将字符串列表转换为一个字符串以用于map的key，通过%q参数忠实地记录每个字符串元素的信息：

```go
var m = make(map[string]int)
func k(list []string) string { return fmt.Sprintf("%q", list) }
func Add(list []string) { m[k(list)]++ }
func Count(list []string) int { return m[k(list)] }
```

同样的技术可以处理其他不可比较的key类型，比如结构体等；也可以拿来自定义key比较，比如比较字符串时忽略key的大小写。

Map的value也可以是一些聚合类型，比如slice或者map，利用这一点我们可以实现一些小技巧：比如嵌套哈希表实现图的存储。

```go
var graph = make(map[string]map[string]bool)
    
func addEdge(from, to string) {
     edges := graph[from]
     if edges == nil { //如果顶点不存在则创建新顶点
         edges = make(map[string]bool)
         graph[from] = edges
     }
     edges[to] = true
}
func hasEdge(from, to string) bool {
 	return graph[from][to]
}
```

其中`addEdge`函数**惰性初始化**map是一个惯用方式，也就是说在每个值首次作为key时才初始化。`hasEdge`函数显示了如何让map的零值也能正常工作；即使from到to的边不存在，graph\[from\]\[to\]依然可以返回一个有意义的结果

### 结构体

结构体是一种聚合的数据类型，是由零个或多个任意类型的值聚合成的实体。每个值称为结构体的成员。结构体把多个信息绑定到一个实体中，使其可以作为一个整体的单元被复制、作为函数的参数或返回值，亦或是被储存到数组中等。结构体是一个更加自由的数据类型，允许你定义多个变量成员。

换句话说，Go中的结构体只是一个多个变量成员的集合体，类似于Python中类的属性，C语言的结构体。因为Go中并没有类的概念，所以可以通过使用结构体和方法来实现面向对象编程的某些特性。

例如，你可以定义一个名为 `Circle` 的结构体，然后为 `Circle` 定义一个名为 `Area` 的方法：

```go
type Circle struct {
    Radius float64
}

func (c Circle) Area() float64 {
    return math.Pi * c.Radius * c.Radius
}//这里定义了一个方法，c Circle作为一个接收者

//如果你想定义一个函数，应该写成如下形式
func Area (c Circle) float64{
    return math.Pi * c.Radius * c.Radius
}//函数没有接收者，形式上来讲只是把方法名移至参数前作为函数名
```

在这个例子中，`Circle` 是一个结构体，它有一个 `Radius` 字段。`Area` 是一个方法，它计算并返回圆的面积。你可以像这样使用它：

```go
c := Circle{Radius: 5} //显式声明
var c Circle //隐式声明
c.Radius = 5 //可以通过点号来访问结构体成员
fmt.Println(c.Area())  // 输出 "78.53981633974483"
```

值得一提的是，点操作符也可以和指向结构体的指针一起工作，这点不同于C语言中需要用`->`来访问结构体指针指向的结构体内成员。

结构体成员的输入顺序也有重要的意义。我们也可以将Position成员合并（因为也是字符串类型），或者是交换Name和Address出现的先后顺序，那样的话就是定义了不同的结构体类型。（C语言也有类似的性质）

如果结构体成员名字是以大写字母开头的，那么该成员就是导出的；这点有些类似于Python、C++、PHP中的private私有属性，但是也有不同：前者是基于包的私有性，而后三者是基于类的私有性。也就是说，Go的结构体成员变量是否导出只是决定了在包外能否访问，而在包内的代码可以访问所有的成员变量。

可以把结构体作为函数的参数或者返回值，但要注意传递结构体时都是传递结构体的拷贝而不是本身。如果你想提高传输效率或者修改结构体成员的值，那么你就需要传递结构体的指针。

结构体的成员如果都是可比较的类型，那么就可以用`==`或者`!=`来进行结构体之间的比较。同样的，可比较的结构体也可以作为map的键名。

#### 匿名成员

在Go结构体中可以通过定义匿名成员变量的方式来优化访问成员的机制。

比如我们有如下代码。

```go
type Point struct {
     X, Y int
}
type Circle struct {
     Center Point
     Radius int
}
type Wheel struct {
     Circle Circle
     Spokes int
}
```

这样相当于Circle嵌套了Point，而Wheel又嵌套了Circle。这么做会让结构体的类型变得清晰，同时也会导致访问结构体成员的步骤变得繁琐。

```go
var w Wheel
w.Circle.Center.X = 8
w.Circle.Center.Y = 8
w.Circle.Radius = 5
w.Spokes = 20
```

但如果我们通过定义匿名成员变量，就可以简化这一步骤：我们只声明一个成员对应的数据类型而不指名成员的名字。匿名成员的数据类型必须是命名的类型或指向一个命名的类型的指针

```go
type Circle struct {
     Point
     Radius int
}
type Wheel struct {
     Circle
     Spokes int
}
```

这样我们可以直接访问叶子属性而不需要给出完整的路径：

```go
var w Wheel
w.X = 8 // equivalent to w.Circle.Point.X = 8
w.Y = 8 // equivalent to w.Circle.Point.Y = 8
w.Radius = 5 // equivalent to w.Circle.Radius = 5
w.Spokes = 20
```

在右边的注释中给出的显式形式访问这些叶子成员的语法依然有效，因此匿名成员并不是真的无法访问了。所以说匿名变量只是可选的，你仍然可以通过传统的方法访问原有变量，但我们更倾向于直接省略。**匿名成员变量的作用其实类似于直接把嵌套的结构成员直接复制到了当前结构体，便于你直接访问**。

因为匿名成员也有一个隐式的名字，因此不能同时包含两个类型相同的匿名成员，这会导致名字冲突。同时，因为成员的名字是由其类型隐式地决定的，所以匿名成员也有可见性的规则约束。

到目前为止，我们看到匿名成员特性只是**对访问嵌套成员的点运算符提供了简短的语法糖。**稍后，我们将会看到匿名成员并不要求是结构体类型；其实**任何命名的类型**都可以作为结构体的匿名成员。但是为什么要嵌入一个没有任何子成员类型的匿名成员类型呢？

答案是匿名类型的**方法集**。简短的点运算符语法可以用于选择匿名成员嵌套的成员，**也可以用于访问它们的方法。**实际上，外层的结构体不仅仅是获得了匿名成员类型的所有成员，而且**也获得了该类型导出的全部的方法。这**个机制可以用于将一些有简单行为的对象组合成有复杂行为的对象。组合是Go语言中面向对象编程的核心，我们将在后续专门讨论。

### JSON

> JavaScript对象表示法（JSON）是一种用于发送和接收结构化信息的标准协议。在类似的协议中，JSON并不是唯一的一个标准协议。 XML（§7.14）、ASN.1和Google的Protocol Buffers都是类似的协议，并且有各自的特色，但是由于简洁性、可读性和流行程度等原因，JSON是应用最广泛的一个。

我们将对重要的encoding/json包的用法做个概述。

比如有代码如下：

```go
type Movie struct {
     Title string
     Year int `json:"released"`
     Color bool `json:"color,omitempty"`
     Actors []string
}
var movies = []Movie{
     {Title: "Casablanca", Year: 1942, Color: false,
     Actors: []string{"Humphrey Bogart", "Ingrid Bergman"}},
     {Title: "Cool Hand Luke", Year: 1967, Color: true,
     Actors: []string{"Paul Newman"}},
     {Title: "Bullitt", Year: 1968, Color: true,
     Actors: []string{"Steve McQueen", "Jacqueline Bisset"}},
     // ...
}
```

这种数据结构就很适合JSON格式。将一个Go语言中类似movies的结构体slice转为JSON的过程叫编组（marshaling）。编组通过调用`json.Marshal`函数完成

```go
data, err := json.Marshal(movies)
if err != nil {
     log.Fatalf("JSON marshaling failed: %s", err)
}
fmt.Printf("%s\n", data)
```

Marshal函数返回一个编码后的字节slice，包含很长的字符串，并且没有空白缩进；

```go
[{"Title":"Casablanca","released":1942,"Actors":["Humphrey Bogart","Ingr
id Bergman"]},{"Title":"Cool Hand Luke","released":1967,"color":true,"Ac
tors":["Paul Newman"]},{"Title":"Bullitt","released":1968,"color":true,"
Actors":["Steve McQueen","Jacqueline Bisset"]}]
```

`json.MarshalIndent`函数将产生整齐缩进的输出。该函数有两个额外的字符串参数用于表示每一行输出的前缀和每一个层级的缩进：

```go
data, err := json.MarshalIndent(movies, "", " ")
if err != nil {
 	log.Fatalf("JSON marshaling failed: %s", err)
}
fmt.Printf("%s\n", data)
```

输出如下

```go
[
     {
         "Title": "Casablanca",
         "released": 1942,
         "Actors": [
             "Humphrey Bogart",
             "Ingrid Bergman"
         ]
     },
     {
         "Title": "Cool Hand Luke",
         "released": 1967,
         "color": true,
         "Actors": [
         	"Paul Newman"
         ]
     },
     {
         "Title": "Bullitt",
         "released": 1968,
         "color": true,
         "Actors": [
             "Steve McQueen",
             "Jacqueline Bisset"
         ]
     } 
]
```

在编码时，默认使用Go语言结构体的成员名字作为JSON的对象。其中Year名字的成员在编码后变成了released，还有Color成员编码后变成了小写字母开头的color。这是因为结构体成员**Tag**所导致的。**一个结构体成员Tag是和在编译阶段关联到该成员的元信息字符串。**标签是一种元信息，可以被反射机制读取。例如，你可以使用标签来指定一个字段在 JSON 中的名字：

```go
Year int `json:"released"`
Color bool `json:"color,omitempty"`
```

json开头键名对应的值用于控制encoding/json包的编码和解码的行为，并且encoding/...下面其它的包也遵循这个约定。成员Tag中json对应值的第一部分用于指定JSON对象的名字。Color成员的Tag还带了一个额外的omitempty选项，表示当Go语言结构体成员为空或零值时不生成该JSON对象（这里false为零值）。

编码的逆操作是解码，对应将JSON数据解码为Go语言的数据结构，Go语言中一般叫unmarshaling，通过`json.Unmarshal`函数完成。下面的代码将JSON格式的电影数据解码为一个结构体slice，结构体中只有Title成员。

通过定义合适的Go语言数据结构，我们可以选择性地解码JSON中感兴趣的成员。当Unmarshal函数调用返回，slice将被只含有Title信息的值填充，其它JSON成员将被忽略。

```go
var titles []struct{ Title string }
if err := json.Unmarshal(data, &titles); err != nil {
     log.Fatalf("JSON unmarshaling failed: %s", err)
}
fmt.Println(titles) // "[{Casablanca} {Cool Hand Luke} {Bullitt}]"
```

### 文本和HTML模板

Go 语言的 `text/template` 和 `html/template` 包提供了数据驱动的模板，用于生成文本和 HTML 格式的输出。

一个模板是一个字符串或一个文件，里面包含了一个或多个由双花括号包含的 `{{action}}` 对象。大部分的字符串只是按字面值打印，但是对于actions部分将触发其它的行为。每个actions都包含了一个用模板语言书写的表达式，一个action虽然简短但是可以输出复杂的打印值，模板语言包含通过选择结构体的成员、调用函数或方法、表达式控制流if-else语句和range循环语句，还有其它实例化模板等诸多特性。

#### text/template

`text/template` 包提供了一种机制，让你可以使用文本模板生成任何类型的文本，包括 HTML、XML 或者其他文本文档。你可以在模板中使用数据和控制结构（如循环和条件判断）来动态生成文本。

下面是一个简单的例子：

```go
package main

import (
    "text/template"
    "os"
)

type Person struct {
    Name string
    Age  int
}

func daysAgo(t time.Time) int {
     return int(time.Since(t).Hours() / 24) }

func main() {
    t := template.New("person template")

    t, _ = t.Parse("Name: {{.Name}}, Age: {{.Age}}\n")
    p := Person{Name: "John Doe", Age: 50}

    t.Execute(os.Stdout, p)
}
```

在这个例子中，我们定义了一个 `Person` 结构体，并创建了一个模板，该模板使用 `{{.Name}}` 和 `{{.Age}}` 来引用 `Person` 结构体的字段。然后我们创建了一个 `Person` 对象，并将其传递给模板的 `Execute` 方法，最后将结果输出到标准输出。

`.` 是一个特殊的符号，它代表当前的上下文或"当前值"。这个上下文是动态的，会随着模板的执行而改变。在这个例子中，模板被调用时的参数是一个 `Person` 类型的变量。因此，当模板系统看到 `{{.Name}}` 时，它会从 `Person` 类型的变量中取出 `Name` 这个字段的值。

这种动态的上下文管理方式使得 Go 语言模板系统在处理复杂的数据结构时非常方便和强大。

生成模板的输出需要两个处理步骤。第一步是要分析模板并转为内部表示，然后基于指定的输入执行模板。分析模板部分一般只需要执行一次。下面的代码创建并分析上面定义的模板templ。注意方法调用链的顺序：template.New先创建并返回一个模板；Funcs方法将daysAgo等自定义函数注册到模板中，并返回模板；最后调用Parse函数分析模板。

```go
report, err := template.New("report").
     Funcs(template.FuncMap{"daysAgo": daysAgo}).
     Parse(templ)
if err != nil {
 	log.Fatal(err)
}
```

因为模板通常在编译时就测试好了，如果模板解析失败将是一个致命的错误。template.Must辅助函数可以简化这个致命错误的处理：它接受一个模板和一个error类型的参数，检测error是否为nil（如果不是nil则发出panic异常），然后返回传入的模板。

```go
var report = template.Must(template.New("issuelist").
 	Funcs(template.FuncMap{"daysAgo": daysAgo}).
 	Parse(templ))
```

#### html/template

`html/template` 包的功能与 `text/template` 非常相似，但它提供了一些额外的功能，特别是自动的、上下文敏感的 HTML 和 JavaScript 转义，这对于防止跨站脚本（XSS）攻击非常有用。

下面是一个简单的例子：

```go
package main

import (
    "html/template"
    "os"
)

type Person struct {
    Name string
    Age  int
}

func main() {
    t := template.New("person template")

    t, _ = t.Parse("<p>Name: {{.Name}}, Age: {{.Age}}</p>\n")
    p := Person{Name: "John Doe", Age: 50}

    t.Execute(os.Stdout, p)
}
```

这个例子与之前的 `text/template` 例子非常相似，只是我们使用的是 `html/template` 包，而且模板是 HTML 格式的。

在这两个包中，你都可以使用一些内置的函数，例如 `range`（用于循环）、`if`（用于条件判断）以及许多其他函数。你也可以定义自己的函数，并在模板中使用它们。

模板中可以包含多种动作，包括：

- `{{.}}`：表示当前的值。
- `{{.Field}}`：表示当前值的 `Field` 字段。
- `{{range .}}...{{end}}`：遍历当前的值（必须是数组、切片或映射）。
- `{{if .}}...{{end}}`：如果当前的值为真，则输出 `...`。

模板支持函数，你可以在模板中使用预定义的函数，也可以添加自定义的函数。

```go
// 使用预定义的函数
const tpl = `{{len .}}`

// 添加自定义的函数
funcMap := template.FuncMap{
    "lower": strings.ToLower,
}
t := template.New("test").Funcs(funcMap)
t, err := t.Parse(`{{lower .}}`)
```

这一部分内容先不展开过多，更具体的内容可以查阅文档。

### 总结

在编程中，数据类型通常被分为两种主要的类别：值类型和引用类型。这两种类型的主要区别在于它们的赋值和比较行为。

1. 值类型：当我们创建一个值类型的变量时，变量直接存储的是值，而不是值的引用。因此，当我们将一个值类型的变量赋值给另一个变量时，实际上是在复制整个值。如果我们修改一个变量，不会影响到另一个变量。在Go语言中，基本类型（如int, float, bool, string等）、数组和结构体都是值类型。
2. 引用类型：与值类型不同，引用类型的变量存储的是值的地址，也就是引用，而不是值本身。因此，当我们将一个引用类型的变量赋值给另一个变量时，实际上是在复制引用，这两个变量会指向同一个值。如果我们修改一个变量，会影响到所有指向同一个值的变量。在Go语言中，slice, map, channel, interface, function等都是引用类型。

所以，当我们说Go语言中的数组是值类型，意思就是数组在赋值和函数传参时，会进行整个数组的复制，修改一个数组不会影响到另一个数组。这与引用类型的行为不同，引用类型在赋值和函数传参时，只会复制引用，多个变量可以共享同一个值。

反观C语言，C语言中没有直接对应于"值类型"和"引用类型"的概念，但是有相似的行为模式。

在C语言中，所有的变量默认都是值类型，也就是说，当你把一个变量赋值给另一个变量时，你实际上是在复制那个值。如果你修改了一个变量，这不会影响到其他的变量。这包括C语言中的所有基本类型，比如`int`，`char`，`float`，`double`等。

然而，C语言也提供了指针类型，这可以用来模拟类似引用类型的行为。指针是一个变量，它的值是另一个变量的内存地址。如果你有一个指针指向一个变量，然后通过这个指针修改那个变量的值，那么所有的指向那个同一变量的指针都会"看到"这个改变。

---

![f5c4c658c9623ef310f3d678caabff4c](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/f5c4c658c9623ef310f3d678caabff4c.jpeg?x-oss-process=style/blog)

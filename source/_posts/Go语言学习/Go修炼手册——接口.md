---
title: Go修炼手册——接口
date: 2024-10-12 15:14:46
updated: 2024-10-12 15:14:46
tags:
  - Go
categories: Go!Go!Go!
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/2FAA1B2C149C8C4BFF45431A929E653C.jpg
description: 介绍了Go语言中接口的用法，详细的列举了接口的概念到运用实现。
---


本章我们来学习Go语言中接口的概念。单论接口的使用来说，学习它并不困难。但更重要的是理解Go语言中接口的设计哲学，即“面向接口编程”和“面向对象编程”背后的底层逻辑。倘若不好好弄清楚接口的设计理念，那么在实际业务中也难以派上用场。

首先我们来介绍接口的定义，之后单独抽一小节来阐述接口的设计理念，最后详细介绍Go语言中接口的使用方法。

## 接口约定

接口类型是一种抽象的类型。它不会暴露出它所代表的对象的内部值的结构和这个对象支持的基础操作的集合；它们只会表现出它们自己的方法。

要定义一个接口，使用`type`关键字即可。我们以中的io.Writer接口为例：
```go
package io

// Writer is the interface that wraps the basic Write method.
type Writer interface {
    // Write writes len(p) bytes from p to the underlying data stream.
    // It returns the number of bytes written from p (0 <= n <= len(p))
    // and any error encountered that caused the write to stop early.
    // Write must return a non-nil error if it returns n < len(p).
    // Write must not modify the slice data, even temporarily.
    //
    // Implementations must not retain p.
	Write(p []byte) (n int, err error)
}
```

可以看到，声明一个接口的方法很简单，只需要`type`+接口名+`interface`即可。

同时展示接口的使用方法，我们给出Fprintf函数的定义，它调用了io.Writer接口。

```go
package fmt

func Fprintf(w io.Writer, format string, args ...interface{}) (int, error)
```

io.Writer类型定义了函数Fprintf和这个函数调用者之间的约定。一方面这个约定需要调用者提供具体类型的值就像`*os.File`和`*bytes.Buffer`，这些类型都有一个特定签名和行为的Write的函数；另一方面这个约定保证了Fprintf接受任何满足io.Writer接口的值都可以工作。Fprintf函数没有假定写入的是一个文件或是一段内存，而是写入一个可以调用Write函数的值。

我们可以定义一个新的类型进行校验，下面`*ByteCounter`类型的Write方法，仅仅在丢弃写向它的字节前统计它的长度。

```go
type ByteCounter int

func (c *ByteCounter) Write(p []byte) (int, error) {
    *c += ByteCounter(len(p)) // convert int to ByteCounter
    return len(p), nil
}
```

但是由于`*ByteCounter`满足io.Writer的约定，我们可以把它传入Fprintf函数中；Fprintf函数执行字符串格式化的过程不会去关注ByteCounter正确的累加结果的长度。

```go
var c ByteCounter
c.Write([]byte("hello"))
fmt.Println(c) // "5", = len("hello")
c = 0 // reset the counter
var name = "Dolly"
fmt.Fprintf(&c, "hello, %s", name)
fmt.Println(c) // "12", = len("hello, Dolly")
```

通过以上的例子，我们已经掌握了接口的基本用法。接着我们来说说接口为什么要这么做，或者说，这么做是为了什么。

## 接口的设计哲学

已单独整理成一篇文章：[番外：Go 接口的设计哲学 | Adam8en の 8log (adamben.top)](https://adamben.top/posts/7a99acb03ff0/)

## 接口类型

接口类型具体描述了一系列方法的集合，一个实现了这些方法的具体类型是这个接口类型的实例。也就是说，实现接口是隐式的，并不需要“implement”关键字来显示实现。

接口类型可以直接在定义中写明方法，也可以通过组合已有的接口来定义新的接口类型：

```go
package io
type Reader interface{
    Read(p []byte) (n int, err error)
}

type Closer interface{
    Close() error
}

type ReadWriter interface{
    Reader
    Writer
}

type ReadWriteCloser interface{
    Reader
    Writer
    Closer
}
```

上面用到的语法和结构内嵌相似，我们可以用这种方式以一个简写命名一个接口，而不用声明它所有的方法。这种方式称为**接口内嵌**。当然，在接口里不使用内嵌而重写定义也是可以的，甚至使用混合风格都没有问题。

```go
type ReadWriter interface {
    Read(p []byte) (n int, err error)
    Write(p []byte) (n int, err error)
}

type ReadWriter interface {
    Read(p []byte) (n int, err error)
    Writer
}
```

## 实现接口的条件

接口指定的规则非常简单：表达一个类型属于某个接口只要这个类型实现这个接口。这个规则甚至适用于等式右边本身也是一个接口类型。

~~~go
var w io.Writer
w = os.Stdout // OK: *os.File has Write method
w = new(bytes.Buffer) // OK: *bytes.Buffer has Write method
w = time.Second // compile error: time.Duration lacks Write method

w = rwc // OK: io.ReadWriteCloser has Write method
rwc = w // compile error: io.Writer lacks Close method
~~~

接下来讲解几个细节：

### 指针的接口与语法糖

在介绍结构体的章节中，对于每一个命名过的具体类型T；它的一些方法的接收者是类型T本身，另一些方法的接受者则是一个 *T 的指针。然而，在T类型的参数上调用一个 *T 的方法是合法的，这是一个语法糖：只要这个参数是一个变量，编译器就会隐式的获取它的地址，然后调用接受者为 \*T 的方法。这也意味着另一件事：T类型的值不拥有所有 *T 指针的方法，它可能只实现了更少的接口。

举例来说，IntSet类型的String方法的接收者是一个指针类型，我们可以在一个IntSet变量上调用这个方法，但我们不能在一个不能寻址的IntSet值上调用这个方法。

~~~go
type IntSet struct { /* ... */ }
func (*IntSet) String() string
var _ = IntSet{}.String() // compile error: String requires *IntSet receiver

var s IntSet
var _ = s.String() // OK: s is a variable and &s has a String method
~~~

因此，由于只有` *IntSet `类型有String方法，所以也只有` *IntSet `类型实现了fmt.Stringer接口。

```go
var _ fmt.Stringer = &s // OK
var _ fmt.Stringer = s // compile error: IntSet lacks String method
```

这个小细节只要平时注意使用变量，不调用无地址的方法，基本不会遇到bug。

### 接口类型封装

就像信封封装和隐藏起信件来一样，接口类型封装和隐藏具体类型和它的值。即使具体类型有其它的方法，也只有接口类型暴露出来的方法会被调用到。

```go
os.Stdout.Write([]byte("hello")) // OK: *os.File has Write method
os.Stdout.Close() // OK: *os.File has Close method
var w io.Writer
w = os.Stdout
w.Write([]byte("hello")) // OK: io.Writer has Write method
w.Close() // compile error: io.Writer lacks Close method
```

也就是说，要表达接口必须要实现接口定义的所有方法，是**一个大于或等于的关系**。接口只强求你实现它规定的方法，至于数据类型如果还拥有其他接口未定义的方法，也依然不会报错。只是在调用接口时，你只能调用接口暴露的方法，而不能调用接口隐藏而数据类型持有的其他方法。

换句话来说，我们可以用接口来实现对数据类型的封装。

### 空接口的妙用

一个有更多方法的接口类型，比如io.ReadWriter，和少一些方法的接口类型例如io.Reader，进行对比；更多方法的接口类型会告诉我们更多关于它的值持有的信息，并且对实现它的类型要求更加严格。那么关于interface{}类型，它没有任何方法，请讲出哪些具体的类型实现了它？

这看上去好像没有用，但实际上interface{}被称为空接口类型是不可或缺的。因为空接口类型对实现它的类型没有要求，所以我们可以将任意一个值赋给空接口类型。

~~~go
var any interface{}
any = true
any = 12.34
any = "hello"
any = map[string]int{"one": 1}
any = new(bytes.Buffer)
~~~

对于创建的一个interface{}值持有一个boolean，float，string，map，pointer，或者任意其它的类型；我们当然不能直接对它持有的值做操作，因为interface{}没有任何方法。后续我们会学习用类型断言来获取取interface{}中值的方法。

### 接口类型实现的不同情况

非空的接口类型比如io.Writer经常被指针类型实现，尤其当一个或多个接口方法像Write方法那样隐式的给接收者带来变化的时候。一个结构体的指针是非常常见的承载方法的类型，毕竟传递结构体的指针比传递结构体本身要有效率得多。

~~~go
type Counter struct {
    count int
}

func (c *Counter) Write(p []byte) (n int, err error) {
    c.count += len(p)
    return len(p), nil
}

var w io.Writer = &Counter{}
~~~

尽管指针类型是常见的实现方式，但并不是唯一的，其他引用类型（如切片和映射）也可以实现接口。从本质上来说，引用类型实现接口和指针实现接口是一样的。

~~~go
// 切片实现
type Counter struct {
    count int
}

func (c *Counter) Write(p []byte) (n int, err error) {
    c.count += len(p)
    return len(p), nil
}

var w io.Writer = &Counter{}

// 映射实现
type Values map[string][]string

func (v Values) Write(b []byte) (n int, err error) {
    // 自定义实现
    return len(b), nil
}

var w io.Writer = Values{}
~~~

此外，基本类型（如`time.Duration`）也可以实现某些接口。

~~~go
type MyDuration time.Duration

func (d MyDuration) String() string {
    return time.Duration(d).String()
}

var s fmt.Stringer = MyDuration(10 * time.Second)
~~~

## flag.Value接口

学习掌握了一些关于接口的知识，接下来我们来学习Go语言的flag标准库是如何借助接口来帮助命令行标记定义新的符号的。

首先我们来学习`flag.value`接口的用法，他有两个方法：

~~~go
package flag
// Value is the interface to the value stored in a flag.
type Value interface {
    Set(string) error
    String() string
}
~~~

1. `Set(string) error`：将标志的值解析为相应的类型。传入参数就是我们从命令行输入的数据，所以接口规定传入参数必须是字符串类型。
2. `String() string`：返回该标志的当前值，作为字符串表示。即将当前标志的值回显出来，由于回显到命令行给用户查看，所以返回值必须是字符串形式。

稍微细心一点的读者可能就注意到了，`flag.value`接口定义的两个方法是相反的。`Set()`方法要求将传入的字符串进行处理内化为标志的值，而`String()`方法则要求返回标志的值，并将其重新回显为字符串。

下面是一个示例，展示如何自定义一个 `flag.Value` 类型来处理复杂类型（例如，一个以逗号为标志分隔的列表）：

~~~go
package main

import (
	"flag"
	"fmt"
	"strings"
)

// 定义一个类型，用于存储逗号分隔的字符串列表
type CSV []string

// 实现 flag.Value 接口中的 Set 方法
func (c *CSV) Set(value string) error {
	*c = strings.Split(value, ",") // 将输入的字符串按逗号分割，并存入 CSV 类型
	return nil
}

// 实现 flag.Value 接口中的 String 方法
func (c *CSV) String() string {
	return strings.Join(*c, ",") // 将列表转为逗号分隔的字符串
}

func main() {
	var csvFlag CSV
	// 使用 flag.Var 函数，传入自定义类型的指针，并定义标志
	flag.Var(&csvFlag, "csv", "Comma-separated list")

	// 解析命令行标志
	flag.Parse()

	// 输出解析后的值
	fmt.Println("Parsed CSV flag:", csvFlag)
}
~~~

在这个例子中：

- 首先定义了一个类型 `CSV`，用来存储解析后的字符串列表。

- 通过实现 `Set` 和 `String` 方法，让 `CSV` 满足 `flag.Value` 接口的要求。

- 使用 `flag.Var` 函数将 `CSV` 类型与命令行标志 `-csv` 绑定，这样可以通过命令行输入类似 `-csv=a,b,c` 的参数，它会自动解析成一个字符串切片 `["a", "b", "c"]`。

  `"Comma-separated list"`是这个标志的描述，告诉用户该标志接受一个用逗号分隔的字符串列表。当用户在命令行输入 `go run main.go -h` 时，程序会输出类似如下的信息：

  ~~~bash
  Usage of ./main:
    -csv Comma-separated list
      	Comma-separated list
  ~~~

- `flag.Parse()`: 这行代码会解析命令行输入的标志。如果用户在命令行中使用了 `-csv`，这个函数会根据用户输入的值对标志进行解析和赋值。在对flag变量进行定义后，必须调用一次`flag.Parse()`来解析标志。

执行程序时，如果输入如下命令：

~~~bash
go run main.go -csv=a,b,c
~~~

将输出：

~~~less
Parsed CSV flag: [a b c]
~~~

通过这种方式，我们可以自定义更复杂的命令行标志解析逻辑。

## 接口值

一个接口的值，接口值，由两个部分组成，一个具体的类型和那个类型的值。它们被称为接口的动态类型和动态值。

下面4个语句中，变量w得到了3个不同的值。（开始和最后的值是相同的）

~~~go
var w io.Writer
w = os.Stdout
w = new(bytes.Buffer)
w = nil
~~~

第一个语句`var w io.Writer`定义了变量w。

在Go语言中，变量总是被一个定义明确的值初始化，即使接口类型也不例外。对于一个接口的零值就是它的类型和值的部分都是nil。

![image-20241011171355457](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241011171355457.png?x-oss-process=style/blog)

一个接口值基于{% bubble 它的动态类型被描述为空或非空,"即当且仅当动态类型为空才会被判定为空接口。若动态值为空而动态类型不为空，该接口仍不为空" ,"#868fd7" %}，所以这是一个空的接口值。你可以通过使用 w==nil或者w!=nil来判断接口值是否为空。调用一个空接口值上的任意方法都会产生{% bubble panic,"w.Write([]byte("hello")) // panic: nil pointer dereference" ,"#868fd7" %}。

第二个语句`w = os.Stdout`将一个 `*os.File` 类型的值赋给变量w。这个接口值的动态类型被设为 *os.File 指针的类型描述符，它的动态值持有os.Stdout的拷贝。

![image-20241011171553532](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241011171553532.png?x-oss-process=style/blog)

调用一个包含 `*os.File` 类型指针的接口值的`Write`方法，使得 `(*os.File).Write` 方法被调用。这个调用输出“hello”。

~~~go
w.Write([]byte("hello")) // "hello"
~~~

> 通常在编译期，我们不知道接口值的动态类型是什么，所以一个接口上的调用必须使用动态分配。因为不是直接进行调用，所以编译器必须把代码生成在类型描述符的方法Write上，然后间接调用那个地址。这个调用的接收者是一个接口动态值的拷贝，os.Stdout。效果和下面这个直接调用一样：
>
> ```go
> os.Stdout.Write([]byte("hello")) // "hello"
> ```

第三个语句`w = new(bytes.Buffer)`给接口值赋了一个`*bytes.Buffer`类型的值。现在动态类型是*bytes.Buffer并且动态值是一个指向新分配的缓冲区的指针。

![image-20241011172349067](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241011172349067.png?x-oss-process=style/blog)

最后，第四个语句`w = nil`将nil赋给了接口值。这个重置将它所有的部分都设为nil值，把变量w恢复到和它之前定义时相同的状态。

接口值可以使用`==`和`!＝`来进行比较。两个接口值相等仅当它们都是nil值，或者它们的动态类型相同并且动态值也根据这个动态类型的`==`操作相等。因为接口值是可比较的，所以它们可以用在 map的键或者作为switch语句的操作数。 

然而，如果两个接口值的动态类型相同，但是这个动态类型是不可比较的（比如切片），将它们 行比较就会失败并且panic。

考虑到这点，接口类型是非常与众不同的。其它类型要么是安全的可比较类型（如基本类型和指针）要么是完全不可比较的类型（如切片，映射类型，和函数），但是在比较接口值或者包含了接口值的聚合类型时，我们必须要意识到潜在的panic。同样的风险也存在于使用接口作为map的键或者switch的操作数。只能比较你非常确定它们的动态值是可比较类型的接口值。

{% span red, 再次强调！！！ %}

**一个不包含任何值的nil接口值和一个刚好包含nil指针的接口值是不同的**。

思考下面的程序。当debug变量设置为true时，main函数会将f函数的输出收集到一个bytes.Buffer类型中。

~~~go
const debug = true
func main() {
    var buf *bytes.Buffer
    if debug {
    	buf = new(bytes.Buffer) // enable collection of output
    }
    f(buf) // NOTE: subtly incorrect!
    if debug {
    	// ...use buf...
    }
}
// If out is non-nil, output will be written to it.
func f(out io.Writer) {
    // ...do something...
    if out != nil {
    	out.Write([]byte("done!\n"))
    }
}
~~~

我们可能会预计当把变量debug设置为false时可以禁止对输出的收集，但是实际上在out.Write方法调用时程序发生了panic：

~~~go
if out != nil {
     out.Write([]byte("done!\n")) // panic: nil pointer dereference
}
~~~

当main函数调用函数f时，它给f函数的out参数赋了一个`*bytes.Buffer`的空指针，所以out的动态 值是nil。然而，它的动态类型是`*bytes.Buffer`，意思就是out变量是一个包含空指针值的**非空接口**。所以防御性检查`out!=nil`的结果依然是true。

## error接口

我们继续介绍error类型。很早开始我们就已经在使用error类型，其实他就是interface类型，这个类型有一个返回错误信息的单一方法：

~~~go
type error interface {
    Error() string
}
~~~

创建一个error最简单的方法就是调用errors.New函数，它会根据传入的错误信息返回一个新的error。整个errors包仅只有4行：

~~~go
package errors

func New(text string) error { return &errorString{text} }

type errorString struct { text string }

func (e *errorString) Error() string { return e.text }
~~~

承载errorString的类型是一个结构体而非一个字符串，这是为了保护它表示的错误。我们也不想要重要的error例如 io.EOF和一个刚好有相同错误消息的error比较后相等。

调用errors.New函数是非常稀少的，因为有一个方便的封装函数fmt.Errorf，它还会处理字符串格式化。

~~~go
package fmt

import "errors"

func Errorf(format string, args ...interface{}) error {
    return errors.New(Sprintf(format, args...))
}
~~~

## 类型断言

类型断言是一个使用在接口值上的操作。语法是 `x.(T)`，其中 `x` 是接口类型，`T` 是要检查的目标类型。如果 `x` 的实际类型与 `T` 匹配，断言成功，返回 `x` 的值，类型为 `T`；如果不匹配，程序会抛出 `panic`。简而言之，类型断言用于确保接口的值可以安全地转换为某种具体类型。如果断言操作的对象是一个nil接口值，那么不论被断言的类型是什么这个类型断言都会失败。

第二个结果通常赋值给一个命名为ok的变量。如果这个操作失败了，那么ok就是false值，第一个结果等于被断言类型的零值。这个ok结果经常立即用于决定程序下面做什么。if语句的扩展格式让这个变的很简洁：

~~~go
if f, ok := w.(*os.File); ok {
    // ...use f...
}
~~~

### 基于类型断言区别错误类型

有了类型断言这个强力的工具，我们就可以轻松的判断错误类型。

对于给定的三个错误原因：文件已经存在（对于创建操作），找不到文件（对于读取操作），和权限拒绝。

~~~go
package os
func IsExist(err error) bool
func IsNotExist(err error) bool
func IsPermission(err error) bool
~~~

对这些判断的一个缺乏经验的实现可能会去检查错误消息是否包含了特定的子字符串：

~~~go
func IsNotExist(err error) bool {
    // NOTE: not robust!
    return strings.Contains(err.Error(), "file does not exist")
}
~~~

但是处理I/O的逻辑在不同的平台上并不一定一样，所以这种方案缺乏健壮性。一个更可靠的方式是使用一个专门的类型来描述结构化的错误。实际上os标准库里也是这么实现的。

~~~go
package os
// PathError records an error and the operation and file path that caused it.
type PathError struct {
    Op string
    Path string
    Err error
}
func (e *PathError) Error() string {
    return e.Op + " " + e.Path + ": " + e.Err.Error()
}
~~~

下面展示的IsNotExist，它会报出是否一个错误和 syscall.ENOENT或者和os.ErrNotExist相等，用于判断文件或目录是否不存在。

~~~go
import (
    "errors"
    "syscall"
)
var ErrNotExist = errors.New("file does not exist")
// IsNotExist returns a boolean indicating whether the error is known to
// report that a file or directory does not exist. It is satisfied by
// ErrNotExist as well as some syscall errors.
func IsNotExist(err error) bool {
    if pe, ok := err.(*PathError); ok {
    	err = pe.Err //提取内部的真实错误原因
    }
    return err == syscall.ENOENT || err == ErrNotExist
}
~~~

实际调用如下：

~~~go
_, err := os.Open("/no/such/file")
fmt.Println(os.IsNotExist(err)) // "true"
~~~

> Q：为什么不直接比较 err 是否等于 syscall.ENOENT 或 ErrNotExist？
>
> A：在 Go 中，错误经常被“包装”起来。例如，`PathError` 就是一种错误包装，它不仅包含了底层的系统错误，还附带了文件路径和操作类型的信息。
>
> ~~~Go
> &os.PathError{
>     Op:   "open",
>     Path: "/invalid/path",
>     Err:  syscall.ENOENT,
> }
> ~~~
>
> 在这种情况下，err 是 *PathError，而不是 syscall.ENOENT。直接比较 err == syscall.ENOENT 是不会成功的，因为 err 包装了更多的上下文信息，而不是简单的 syscall.ENOENT。
> 通过类型断言，IsNotExist 函数可以提取 PathError 内部的真正错误 (pe.Err)，然后再比较底层的错误。这就是为什么需要先检查 err 是否是 *PathError 类型，并提取内部的 Err 进行判断的原因。

### 基于类型断言询问行为

有了类型断言，我们可以判断传入的变量是否满足特定类型的要求，从而实施不同的操作。

假设一个情形：我们需要向web服务器写入HTTP头字段。io.Writer接口类型的变量w代表HTTP响应；写入它的字节最终被发送到某个人的web浏览器上。

~~~go
func writeHeader(w io.Writer, contentType string) error {
    if _, err := w.Write([]byte("Content-Type: ")); err != nil {
    	return err
    }
    if _, err := w.Write([]byte(contentType)); err != nil {
    	return err
    }
    // ...
}
~~~

因为Write方法需要传入一个byte切片而我们希望写入的值是一个字符串，所以我们需要使用`[]byte(...)`进行转换。这个转换会消耗额外的性能，并且会使得服务器的速度变慢。能否优化掉这个类型转换呢？

如果我们回顾net/http包中的内幕，我们知道在这个程序中的w变量持有的动态类型也有一个允许字符串高效写入的`WriteString`方法；这个方法会避免去分配一个临时的拷贝。所以我们可以直接调用`WriteString`方法来优化掉原先的方法。

但是这里存在一个问题，我们不能对任意io.Writer类型的变量w，假设它也拥有`WriteString`方法。但是我们可以定义一个只有这个方法的新接口并且使用类型断言来检测是否w的动态类型满足这个新接口。

~~~go
// writeString writes s to w.
// If w has a WriteString method, it is invoked instead of w.Write.
func writeString(w io.Writer, s string) (n int, err error) {
    type stringWriter interface {
    	WriteString(string) (n int, err error)
    }
    if sw, ok := w.(stringWriter); ok {
    	return sw.WriteString(s) // avoid a copy
    }
    return w.Write([]byte(s)) // allocate temporary copy
}

func writeHeader(w io.Writer, contentType string) error {
    if _, err := writeString(w, "Content-Type: "); err != nil {
    	return err
    }
    if _, err := writeString(w, contentType); err != nil {
    	return err
    }
    // ...
}
~~~

上面的writeString函数使用一个类型断言来获知一个普遍接口类型的值是否满足一个更加具体的接口类型；并且如果满足，它会使用这个更具体接口的行为。这个技术可以被很好的使用，不论这个被询问的接口是一个标准如io.ReadWriter，或者用户定义的如stringWriter接口。

### 类型分支

基于断言区别error类型也好，质询行为也罢，本质上都是通过类型断言的结果来执行不同的操作。在类型分支这一小节，本质是不变的，我们来看看如果类型断言的分支较多时如何处理。假设我们使用Go语言查询一个SQL数据库，Go调用的API会干净地将查询中固定的部分和变化的部分分开。一个调用的例子可能看起来像这样：

~~~go
import "database/sql"
func listTracks(db sql.DB, artist string, minYear, maxYear int) {
    result, err := db.Exec(
    "SELECT * FROM tracks WHERE artist = ? AND ? <= year AND year <= ?",
    artist, minYear, maxYear)
    // ...
}
~~~

Exec方法使用SQL字面量替换在查询字符串中的每个'?'；SQL字面量表示相应参数的值，它有可能是一个布尔值，一个数字，一个字符串，或者nil空值。用这种方式构造查询可以帮助避免SQL注入攻击。在Exec函数内部可能会找到像下面这样的一个函数，它会将每一个参数值转换成它的SQL字面量符号：

~~~go
func sqlQuote(x interface{}) string {
    if x == nil {
    	return "NULL"
    } else if _, ok := x.(int); ok {
    	return fmt.Sprintf("%d", x)
    } else if _, ok := x.(uint); ok {
    	return fmt.Sprintf("%d", x)
    } else if b, ok := x.(bool); ok {
        if b {
            return "TRUE"
        }
    	return "FALSE"
    } else if s, ok := x.(string); ok {
    	return sqlQuoteString(s) // (not shown)
    } else {
    	panic(fmt.Sprintf("unexpected type %T: %v", x, x))
    }
}
~~~

switch语句可以简化if-else链，如果这个if-else链对一连串值做相等测试。一个相似的type switch（类型分支）可以简化类型断言的if-else链。

~~~go
switch x.(type) {
case nil: // ...
case int, uint: // ...
case bool: // ...
case string: // ...
default: // ...
}
~~~

一个类型分支像普通的switch语句一样，它的运算对象是x.(type)——它使用了关键词字面量type——并且每个case有一到多个类型。一个类型分支基于这个接口值的动态类型使一个多路分支有效。和普通switch语句一样，每一个case会被顺序的进行考虑，并且当一个匹配找到时，这个case中的内容会被执行。当一个或多个case类型是接口时，case的顺序就会变得很重要，因为可能会有两个case同时匹配的情况。

使用类型分支的扩展形式来重写sqlQuote函数会让这个函数更加的清晰：

~~~go
func sqlQuote(x interface{}) string {
    switch x := x.(type) {
    case nil:
    	return "NULL"
    case int, uint:
    	return fmt.Sprintf("%d", x) // x has type interface{} here.
    case bool:
        if x {
        	return "TRUE"
        }
    	return "FALSE"
    case string:
    	return sqlQuoteString(x) // (not shown)
    default:
    	panic(fmt.Sprintf("unexpected type %T: %v", x, x))
    }
}
~~~

尽管sqlQuote接受一个任意类型的参数，但是这个函数只会在它的参数匹配类型分支中的一个case时运行到结束；其它情况的它会panic出“unexpected type”消息。虽然x的类型是interface{}，但是我们把它认为是一个int，uint，bool，string，和nil值的discriminated union（可识别联合）

## 最后

一般来说，接口被以两种不同的方式使用。

第一种方式是{% span red, 以方法为核心的接口 %}。典型例子是`io.Reader`、`io.Writer`、`fmt.Stringer`、`sort.Interface`、`http.Handler` 和 `error`。在这种方式下，**接口的方法**定义了多个实现该接口的具体类型之间的相似性。**重点**在于接口所定义的方法，而不是具体的实现类型。实现该接口的类型只要实现了接口规定的方法即可，具体的类型细节是隐藏的。例如，`io.Writer` 接口定义了一个写入功能，不管它是写入文件、网络、内存还是其他地方，只要它实现了 `Write` 方法，它就可以被当作 `io.Writer` 使用。

第二种方式是{% span red, 以类型为核心的接口 %}。在这种方式下，接口的作用类似于一个可以持有不同具体类型的“容器”。**重点**在于具体的类型，而不是接口的方法本身。接口值可以持有各种不同的具体类型，程序员可以使用**类型断言**或类型判断，来区别接口持有的不同类型，并对每个类型执行不同的操作。不像第一种方式，类型的细节并没有被隐藏，接口只是起到了一种“包裹”不同类型的作用。这种方式类似于“联合类型”或“可辨识联合”，编译器或程序可以根据实际类型的不同做出不同的处理。

在设计新包时，Go的新手程序员往往会先定义一套接口，然后再去实现一些具体类型来满足这些接口。这种做法的结果是产生了许多接口，而每个接口可能只有一个实现。这其实是多余的抽象，同时也带来了运行时的性能开销。你可以通过导出的机制来控制类型的方法或结构体字段是否在包外可见。接口只有在需要让两个或更多具体类型以相同方式处理时才有必要引入。

当然，也有一个例外。如果一个具体类型由于依赖关系无法与接口在同一个包中实现，这时引入接口有助于解耦两个包，避免相互依赖。

在Go中，接口设计的一个核心原则就是简化：接口应该足够小，仅包含所需的方法。更小的接口意味着更少的方法，像 `io.Writer` 或 `fmt.Stringer` 这样的接口通常只包含一个方法。这样的设计不仅使得接口更容易被新的类型实现，也符合“只要你需要的东西”这一设计哲学。

至此，我们对Go的方法和接口进行了总结。虽然Go对面向对象编程提供了良好的支持，但这并不意味着你必须一切都用面向对象风格来解决。并非所有事物都需要当作对象来处理。独立的函数、未封装的数据结构在许多场景中同样有用。你可以回顾一下前几章的例子，像 `input.Scan` 这样的方法使用的次数不到二十次，而像 `fmt.Printf` 这样的函数被频繁调用，展示了函数和非对象化设计在Go中的仍然占有一席之地。

---

![2FAA1B2C149C8C4BFF45431A929E653C](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/2FAA1B2C149C8C4BFF45431A929E653C.jpg?x-oss-process=style/blog)

---
title: Go修炼手册——函数
date: 2024-05-16 10:20:43
updated: 2024-05-16 10:20:43
tags:
  - Go
categories: Go!Go!Go!
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/CE22E4EE388D674AB24D5CE15D445580.jpg
description: 本章主要介绍了Go中函数的特性。
---

## 函数

我们已经见过许多函数了。本章借助于《Go语言圣经》上的资料，以一个网络爬虫为帮助，去理解Go语言中的函数特性。

### 函数声明

函数声明包括函数名、形式参数列表、返回值列表（可省略）以及函数体。

```go
func name(parameter-list) (result-list) {
	body
}
```

如果函数没有返回值，可以省略返回值列表。如果有多个返回值，需要声明在返回值列表中。Go可以返回多个值，这与其他语言很不一样。

在参数列表中，如果想强调某个参数未使用，可以用`_`来表示。

```go
func first(x int,_ int) int {return x}
```

函数的类型被称为函数的**签名**。如果两个函数形式参数列表和返回值列表中的变量类型一一对应，那么这两个函数被认为有相同的类型或签名。

实参通过值的方式传递，因此函数的形参是实参的拷贝。对形参进行修改不会影响实参。但是，如果实参包括引用类型，如指针，slice(切片)、map、function、channel等类型，实参可能会由于函数的间接引用被修改。

### 递归

大部分编程语言使用固定大小的函数调用栈，常见的大小从64KB到2MB不等。固定大小栈会限制递归的深度，当你用递归处理大量数据时，需要避免栈溢出；除此之外，还会导致安全性问题。与此相反，Go语言使用可变栈，栈的大小按需增加（初始时很小）。这使得我们使用递归时不必考虑溢出和安全问题。

### 多返回值

在Go语言中，函数可以返回多个值。常见的用法即返回一个函数正常调用的返回值和错误信息`err`指示函数是否被正常调用。

```go
func findLinks(url string) ([]string, error) {
     resp, err := http.Get(url)
     if err != nil {
         return nil, err
     }
     if resp.StatusCode != http.StatusOK {
         resp.Body.Close()
         return nil, fmt.Errorf("getting %s: %s", url, resp.Status)
     }
     doc, err := html.Parse(resp.Body)
     resp.Body.Close()
     if err != nil {
         return nil, fmt.Errorf("parsing %s as HTML: %v", url, err)
     }
     return visit(nil, doc), nil
}
```

> 虽然Go的垃圾回收机制会回收不被使用的内存，但是这不包括操作系统层面的资源，比如打开的文件、网络连接。因此我们必须显式的释放这些资源。

如果某个值不被使用，可以将其分配给blank identifier`_`。

如果一个函数所有的返回值都有显式的变量名，那么该函数的return语句可以省略操作数。这称之为**bare return**。

```go
// CountWordsAndImages does an HTTP GET request for the HTML
// document url and returns the number of words and images in it.
func CountWordsAndImages(url string) (words, images int, err error) {
     resp, err := http.Get(url)
     if err != nil {
     	return
     }
     doc, err := html.Parse(resp.Body)
     resp.Body.Close()
     if err != nil {
         err = fmt.Errorf("parsing HTML: %s", err)
         return
     }
     words, images = countWordsAndImages(doc)
     return
}
func countWordsAndImages(n *html.Node) (words, images int) { /* ... */ }
```

`CountWordsAndImages`函数的`return`等价于。

```go
return words, images, err
```

当一个函数有多处return语句以及许多返回值时，bare return 可以减少代码的重复，但是使得代码难以被理解。不宜过度使用bare return。

### 错误

在Go的错误处理中，错误是软件包API和应用程序用户界面的一个重要组成部分，程序运行失败仅被认为是几个预期的结果之一

在Go中，函数运行失败时会返回错误信息，这些错误信息被认为是一种预期的值而非异常（exception），这使得Go有别于那些将函数运行失败看作是异常的语言。虽然Go有各种异常机制，但这些机制仅被使用在处理那些未被预料到的错误，即bug，而不是那些在健壮程序中应该被避免的程序错误。

Go这样设计的原因是由于对于某个应该在控制流程中处理的错误而言，将这个错误以异常的形式抛出会混乱对错误的描述，这通常会导致一些糟糕的后果。当某个程序错误被当作异常处理后，这个错误会将堆栈跟踪信息返回给终端用户，这些信息复杂且无用，无法帮助定位错误。

（这可太甜蜜的真实了）

正因此，Go使用控制流机制（如if和return）处理错误，这使得编码人员能更多的关注错误处理。

（但是冗杂的一批）

#### 错误处理机制

最常用的方法是传播错误，这意味着函数中某个子程序的失败，会变成该函数的失败。

```go
func findLinks(url string){
    //...
    resp, err := http.Get(url)
    if err != nil{
    	return nil, err
    }
    //...
}
```

fmt.Errorf函数使用fmt.Sprintf格式化错误信息并返回。

```go
doc, err := html.Parse(resp.Body)
resp.Body.Close()
if err != nil {
     return nil, fmt.Errorf("parsing %s as HTML: %v", url,err)
}
```

第二种策略是：如果错误的发生是偶然性的，或由不可预知的问题导致的。一个明智的选择是重新尝试失败的操作。在重试时，我们需要限制重试的时间间隔或重试的次数，防止无限制的重试。

```go
// WaitForServer attempts to contact the server of a URL.
// It tries for one minute using exponential back-off.
// It reports an error if all attempts fail.
func WaitForServer(url string) error {
    const timeout = 1 * time.Minute
    deadline := time.Now().Add(timeout)
    for tries := 0; time.Now().Before(deadline); tries++ {
        _, err := http.Head(url)
        if err == nil {
            return nil // success
        }
        log.Printf("server not responding (%s);retrying…", err)
        time.Sleep(time.Second << uint(tries)) // exponential back-off
    }
    return fmt.Errorf("server %s failed to respond after %s", url, timeout)
}

```

如果错误发生后，程序无法继续运行，我们就可以采用第三种策略：输出错误信息并结束程序。需要注意的是，这种策略只应在main中执行。对库函数而言，应仅向上传播错误，除非该错误意味着程序内部包含不一致性，即遇到了bug，才能在库函数中结束程序。

```go
// (In function main.)
if err := WaitForServer(url); err != nil {
     fmt.Fprintf(os.Stderr, "Site is down: %v\n", err)
     os.Exit(1) 
}

//or replace with code below to achieve the same effect
if err := WaitForServer(url); err != nil {
    log.Fatalf("Site is down: %v\n", err)
}
```

第四种策略：有时，我们只需要输出错误信息就足够了，不需要中断程序的运行。我们可以通过log包提供函数，或者标准错误流输出错误信息。

```go
if err := Ping(); err != nil {
	log.Printf("ping failed: %v; networking disabled",err)
}

if err := Ping(); err != nil {
	fmt.Fprintf(os.Stderr, "ping failed: %v; networking disabled\n", err)
}
```

第五种，也是最后一种策略：我们可以直接忽略掉错误。

```go
dir, err := ioutil.TempDir("", "scratch")
if err != nil {
     return fmt.Errorf("failed to create temp dir: %v",err)
}
// ...use temp dir…
os.RemoveAll(dir) // ignore errors; $TMPDIR is cleaned periodically
```

在Go中，错误处理有一套独特的编码风格。检查某个子函数是否失败后，我们通常将处理失败的逻辑代码放在处理成功的代码之前。如果某个错误会导致函数返回，那么成功时的逻辑代码不应放在else语句块中，而应直接放在函数体中。Go中大部分函数的代码结构几乎相同，首先是一系列的初始检查，防止错误发生，之后是函数的实际逻辑。（也导致令人诟病的“调用一个函数要写四行”的麻烦）

### 函数值

在Go中，函数被看作第一类值（first-class values）：函数像其他值一样，拥有类型，可以被赋值给其他变量，传递给函数，从函数返回。对函数值（function value）的调用类似函数调用。

### 匿名函数

拥有函数名的函数只能在包级语法块中被声明，通过函数字面量（function literal），我们可绕过这一限制，在任何表达式中表示一个函数值。函数字面量允许我们在使用函数时，再定义它。

更为重要的是，通过这种方式定义的函数可以访问完整的词法环境（lexical environment），这意味着在函数中定义的内部函数可以引用该函数的变量。如下例所示：

```go
func solveNQueens(n int) [][]string {
	var res [][]string
	var board [][]byte
	for i := 0; i < n; i++ {
		board = append(board, make([]byte, n))
		for j := 0; j < n; j++ {
			board[i][j] = '.'
		}
	} //初始化棋盘为全'.'，即空
	var backtrack func(row int) //定义匿名函数
	backtrack = func(row int) {
		if row == n { //结束条件
			var tmp []string
			for i := 0; i < n; i++ {
				tmp = append(tmp, string(board[i]))
			}
			res = append(res, tmp) //找到一个解，将解加入结果集
			return
		}
		for col := 0; col < n; col++ {
			if !isValid(board, row, col) { //剪枝
				continue
			}
			board[row][col] = 'Q' //进行选择
			backtrack(row + 1)    //递归
			board[row][col] = '.' //撤销选择
		}
	}
	backtrack(0)
	return res
}
```

例子证明，函数值不仅仅是一串代码，还记录了状态。在`solveNQueens`中定义的匿名内部函数可以访问和更新`solveNQueens`中的局部变量，这意味着匿名函数和`solveNQueens`中，存在变量引用。这就是函数值属于引用类型和函数值不可比较的原因。Go使用**闭包（closures）**技术实现函数值，Go程序员也把函数值叫做**闭包**。

通过这个例子，我们看到变量的生命周期不由它的作用域决定：`solveNQueens`返回后，变量`res`仍然隐式的存在于`solveNQueens`中（前提是main函数还引用着变量）。

#### 警告：捕获迭代变量

阅读以下代码，这是一个Go词法作用域的陷阱。

```go
	var rmdirs []func()
	for _, d := range tempDirs() {
		dir := d // NOTE: necessary!
		os.MkdirAll(dir, 0755) // creates parent directories too
		rmdirs = append(rmdirs, func() {
			os.RemoveAll(dir)
		})
	}
	// ...do some work…
	for _, rmdir := range rmdirs {
		rmdir() // clean up
	}
```

```go
//code below is wrong
	var rmdirs []func()
	for _, dir := range tempDirs() {
		os.MkdirAll(dir, 0755)
		rmdirs = append(rmdirs, func() {
			os.RemoveAll(dir) // NOTE: incorrect!
		})
	}
```

问题的原因在于循环变量的作用域。在上面的程序中，for循环语句引入了新的词法块，循环变量dir在这个词法块中被声明。在该循环中生成的所有函数值都共享相同的循环变量。需要注意，函数值中记录的是循环变量的内存地址，而不是循环变量某一时刻的值。以dir为例，后续的迭代会不断更新dir的值，当删除操作执行时，for循环已完成，dir中存储的值等于最后一次迭代的值。这意味着，每次对os.RemoveAll的调用删除的都是相同的目录。

为了解决这个问题，我们会引入一个与循环变量同名的局部变量，作为循环变量的副本。虽然这看起来很奇怪，但却很有用。

```go
	for _, dir := range tempDirs() {
		dir := dir // declares inner dir, initialized to outer dir
		// ...
	}
```

### 可变参数

参数数量可变的函数称为可变参数函数。典型的例子就是fmt.Printf和类似函数。Printf首先接收一个必备的参数，之后接收任意个数的后续参数。

在声明可变参数函数时，需要在参数列表的最后一个参数类型之前加上省略符号“...”，这表示该函数会接收任意数量的该类型参数。

```go
func sum(vals ...int) int {
     total := 0
     for _, val := range vals {
     	total += val
     }
     return total
}
```

sum函数返回任意个int型参数的和。在函数体中，vals被看作是类型为[] int的切片。

可变参数函数经常被用于格式化字符串。下面的errorf函数构造了一个以行号开头的，经过格式化的错误信息。函数名的后缀f是一种通用的命名规范，代表该可变参数函数可以接收Printf风格的格式化字符串。

```go
func errorf(linenum int, format string, args ...interface{}) {
     fmt.Fprintf(os.Stderr, "Line %d: ", linenum)
     fmt.Fprintf(os.Stderr, format, args...)
     fmt.Fprintln(os.Stderr)
}
linenum, name := 12, "count"
errorf(linenum, "undefined: %s", name) // "Line 12: undefined: count"
```

### Deferred函数

只需要在调用普通函数或方法前加上关键字defer，就完成了defer所需要的语法。当执行到该条语句时，函数和参数表达式得到计算，但直到**包含该defer语句的函数**执行完毕时，defer后的函数才会被执行，不论包含defer语句的函数是通过return正常结束，还是由于panic导致的异常结束。你可以在一个函数中执行多条defer语句，它们的执行顺序与声明顺序相反。

defer语句经常被用于处理成对的操作，如打开、关闭、连接、断开连接、加锁、释放锁。通过defer机制，不论函数逻辑多复杂，都能保证在任何执行路径下，资源被释放。释放资源的defer应该直接跟在请求资源的语句后。

比如对文件的操作：

```go
package ioutil
func ReadFile(filename string) ([]byte, error) {
     f, err := os.Open(filename)
     if err != nil {
     	return nil, err
     }
     defer f.Close()
     return ReadAll(f)
}
```

`f.Close()`方法会在`ReadFile`函数即将`return`或者产生`Panic`前执行，大大减小了Go函数的维护成本。

本质上`defer`就是延迟函数直到包含其的“大函数”执行完毕后再执行被延迟的语句，不管该“大函数”是通过`return`正常返回还是`Panic`异常退出。通过使用`defer`，可以很方便的维护一些对资源的开闭操作处理。但有时候`defer`也会导致一些意想不到的错误，此时还是需要用传统的`f.Close`方法来维护。

### Panic异常

Go的类型系统会在编译时捕获很多错误，但有些错误只能在运行时检查，如数组访问越界、空指针引用等。这些运行时错误会引起panic异常。

一般而言，当panic异常发生时，程序会中断运行，并立即执行在该**goroutine**（可以先理解成线程，在第8章会详细介绍）中被延迟的函数（defer 机制）。随后，程序崩溃并输出日志信息。日志信息包括panic value和函数调用的堆栈跟踪信息。panic value通常是某种错误信息。对于每个goroutine，日志信息中都会有与之相对的，发生panic时的函数调用堆栈跟踪信息。通常，我们不需要再次运行程序去定位问题，日志信息已经提供了足够的诊断依据。因此，在我们填写问题报告时，一般会将panic异常和日志信息一并记录。

直接调用内置的panic函数也会引发panic异常；panic函数接受任何值作为参数。当某些不应该发生的场景发生时，我们就应该调用panic。比如，当程序到达了某条逻辑上不可能到达的路径：

```go
switch s := suit(drawCard()); s {
    case "Spades": // ...
    case "Hearts": // ...
    case "Diamonds": // ...
    case "Clubs": // ...
    default:
     	panic(fmt.Sprintf("invalid suit %q", s)) // Joker?
}
```

由于panic会引起程序的崩溃，因此panic一般用于严重错误，如程序内部的逻辑不一致。所以对于大部分漏洞，我们应该使用Go提供的错误机制，而不是panic，尽量避免程序的崩溃。在健壮的程序中，任何可以预料到的错误，如不正确的输入、错误的配置或是失败的I/O操作都应该被优雅的处理，最好的处理方式，就是使用Go的错误机制。

### Recover捕获异常

通常来说，不应该对panic异常做任何处理，但有时，也许我们可以从异常中恢复，至少我们可以在程序崩溃前，做一些操作。举个例子，当web服务器遇到不可预料的严重问题时，在崩溃前应该将所有的连接关闭；如果不做任何处理，会使得客户端一直处于等待状态。如果web服务器还在开发阶段，服务器甚至可以将异常信息反馈到客户端，帮助调试。

如果在deferred函数中调用了内置函数recover，并且定义该defer语句的函数发生了panic异常，recover会使程序从panic中恢复，并返回panic value。导致panic异常的函数不会继续运行，但能正常返回。在未发生panic时调用recover，recover会返回nil。

一个示例程序如下

```go
func Parse(input string) (s *Syntax, err error) {
     defer func() {
         if p := recover(); p != nil {
            err = fmt.Errorf("internal error: %v", p)
         }
     }()
     // ...parser...
}
```

安全的做法是有选择性的recover。换句话说，只恢复应该被恢复的panic异常，此外，这些异常所占的比例应该尽可能的低。为了标识某个panic是否应该被恢复，我们可以将panicvalue设置成特殊类型。在recover时对panic value进行检查，如果发现panic value是特殊类型，就将这个panic作为error处理，如果不是，则按照正常的panic进行处理。

```go
type bailout struct{}
 defer func() {
     switch p := recover(); p {
         case nil: // no panic
         case bailout{}: // "expected" panic
         err = fmt.Errorf("multiple title elements")
         default:
         panic(p) // unexpected panic; carry on panicking
     }
 }()
```



不加区分的恢复是危险的，因为无法保证包级变量的状态和我们预期的一致。

有些情况下，我们无法恢复。某些致命错误会导致Go在运行时终止程序，如内存不足。

---

![CE22E4EE388D674AB24D5CE15D445580](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/CE22E4EE388D674AB24D5CE15D445580.jpg?x-oss-process=style/blog)

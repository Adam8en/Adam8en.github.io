---
title: OS Lab
date: 2024-10-10 19:11:27
updated: 2024-11-5 19:50:37
tags: 
  - OS
  - 操作系统
categories: 课堂随笔
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/64495434_p0.jpg?x-oss-process=style/blog
description: A document explaining the experimental code for the operating system, along with the debugging process and test inputs.
---

{% span center logo large, OS Lab %}

{% span center small, Archive of operating system experiments %}

此博客用于归纳操作系统实验中的代码，充当说明文档。着重于讲解代码调试过程与原理，附带一些参考资料。

你可以在这里找到我的所有实验代码：

{% ghcard Adam8en/OS-experiment-archive, theme=algolia %}

需要注意的是，本代码是基于WSL平台开发测试的，如果你是在Windows操作系统上编写代码，将无法复现本博客的实验并将代码编译成可执行文件。

最后，祝阅读愉快。

## Lab01

进程和线程是现代操作系统中最重要的概念，通过多线程程序设计，操作系统能够充分利用计算机系统中的各种硬件资源，极大的提高系统效率。本实验主要考查对多线程概念的理论，以及利用C/C++语言编程实现多线程程序，学会创建进程，掌握信号量的使用，以实现多线程的同步。

### Q1

> 编写程序，在程序中根据用户输入的可执行程序名称，创建一个进程来运行该可执行程序。

在linux系统中，可以通过{% bubble fork(),"fork函数将运行着的程序分成2个（几乎）完全一样的进程，每个进程都启动一个从代码的同一位置开始执行的线程。这两个进程中的线程继续执行，就像是两个用户同时启动了该应用程序的两个副本。" ,"#868fd7" %}函数创建一个新的进程，并且返回子进程的pid。我们可以先获取要执行的程序名，然后在子进程中用{% bubble execlp(),"一旦执行完execlp函数，立刻会去执行新的程序。新的程序会替换当前程序、代码段、数据段、堆、栈。经常与多进程组合使用，用一个子进程单独执行execlp程序" ,"#868fd7" %}函数执行程序，父进程只需等待子进程结束即可。

可以通过pid来辨别父进程和子进程。由于子进程pid为0，所以可以很方便的构造出一个if-else语句根据当前运行进程的pid来判断该执行子进程操作还是父进程操作。

以下是第一问的源代码：

{% folding cyan, 查看完整代码 %}

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

char path[256];
char programeName[256];

int main() {
    getcwd(path,sizeof(path));
    strcat(path, "/");
    printf("Enter the name of executable file\n");
    scanf("%s",programeName);
    strcat(path,programeName);
    //获取程序名并且和路径拼接

    pid_t pid = fork();

    if (pid<0){
        //fork failed
        perror("fork failed");
        exit(1);
    }else if(pid==0){
        //子进程执行操作
        execlp(path,programeName,(char*)NULL);
        // execlp函数执行成功后将不会返回，若返回说明执行失败，所以需要exit(1)
        perror("execlp failed");
        exit(1);
    } else{
        //父进程执行操作
        wait(NULL);
        printf("over.\n");
    }

    return 0;
}

```

{% endfolding %}

话说回来，这道题最开始做的时候我还看错了，以为是要用**线程**而非**进程**实现这个操作，所以还搓了一个线程版本。

用线程实现的话，就不宜继续用`execlp()`函数了。使用线程的方式调用 `execlp()`，这通常不太常见，因为线程替换映像可能会导致复杂性。一般来说，调用外部程序通常是在独立的进程中进行。所以可以通过**线程执行一个外部程序**的方式来模拟`fork()` 的效果，即使用 `system()` 调用外部程序，而不是用 `execlp()`，这样不会替换进程映像。

之后，主线程使用 `pthread_join()` 来等待子线程执行完毕。

源代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>

char path[256];
char programeName[256];

void* myFunc(void*){
    // 使用 system() 来执行外部程序，保持主线程的控制权
    int ret = system(path);
    if (ret == -1) {
        perror("system() failed");
    }
    return NULL;
}

int main() {
    pthread_t myThread;

    getcwd(path,sizeof(path));
    strcat(path, "/");
    printf("Enter the name of executable file\n");
    scanf("%s",programeName);
    strcat(path,programeName);
    
    if (pthread_create(&myThread, NULL, myFunc, NULL) != 0) {
        perror("Failed to create thread");
        return 1;
    }


    pthread_join(myThread,NULL);

    return 0;
}

~~~

{% endfolding %}

运行结果如下图所示：

![image-20241010230224284](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241010230224284.png?x-oss-process=style/blog)

### Q2

> 假设有四个线程，第一个线程输出字符串 “This”，第二个线程输出字符串 “is”, 第三个线程输出字符串“Jinan”, 第四个线程输出字符串 “University！”。编制C/C++程序，在主程序main函数中创建四个线程并依次启动，设计信号量(Semaphore)同步机制，当主程序运行时，屏幕输出的结果是字符串“This is Jinan University!” 

要实现这个功能，可以使用四个信号量，分别控制每个线程的执行顺序。每个线程在输出其字符串之前需要等待对应的信号量信号，然后输出字符串并释放下一个线程的信号量。在创建线程后，我们可以在主函数中先启动第一个线程，然后依次通过信号量控制后续线程的执行。

源代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h> 

sem_t sem_arr[4];

void* Func_1(void*){
    sem_wait(&sem_arr[0]);
    printf("This ");
    sem_post(&sem_arr[1]);
    return NULL;
}
void* Func_2(void*){
    sem_wait(&sem_arr[1]);
    printf("is ");
    sem_post(&sem_arr[2]);
    return NULL;
}
void* Func_3(void*){
    sem_wait(&sem_arr[2]);
    printf("Jinan ");
    sem_post(&sem_arr[3]);
    return NULL;
}
void* Func_4(void*){
    sem_wait(&sem_arr[3]);
    printf("University!\n");
    return NULL;
}
int main() {
    pthread_t threads[4];

    sem_init(&sem_arr[0],0,1);
    sem_init(&sem_arr[1],0,0);
    sem_init(&sem_arr[2],0,0);
    sem_init(&sem_arr[3],0,0);

    pthread_create(&threads[0],NULL,Func_1,NULL);
    pthread_create(&threads[1],NULL,Func_2,NULL);
    pthread_create(&threads[2],NULL,Func_3,NULL);
    pthread_create(&threads[3],NULL,Func_4,NULL);

    for (int i=0;i<4;i++){
        pthread_join(threads[i],NULL);
    }

    for (int i=0;i<4;i++){
        sem_destroy(&sem_arr[i]);
    }
    
    return 0;
}

~~~

{% endfolding %}

运行结果如下图所示：

![image-20241010230244574](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241010230244574.png?x-oss-process=style/blog)

### Q3

> 本题基于实验题目2。在主函数中依次启动四个线程，修改主程序，使得给定用户任意输入的整数n，程序输出n个同样的字符串“This is Jinan University!”

一个很简单的基于（2）的变体。在（2）的基础上，只需要提前获取输入的n并且创建一个循环即可。需要注意的是，每次循环都要重新初始化信号量，保证线程之间的有序执行。 

源代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdio.h>
#include <pthread.h>
#include <semaphore.h> 

sem_t sem_arr[4];

void* Func_1(void*){
    sem_wait(&sem_arr[0]);
    printf("This ");
    sem_post(&sem_arr[1]);
    return NULL;
}
void* Func_2(void*){
    sem_wait(&sem_arr[1]);
    printf("is ");
    sem_post(&sem_arr[2]);
    return NULL;
}
void* Func_3(void*){
    sem_wait(&sem_arr[2]);
    printf("Jinan ");
    sem_post(&sem_arr[3]);
    return NULL;
}
void* Func_4(void*){
    sem_wait(&sem_arr[3]);
    printf("University!\n");
    return NULL;
}
int main() {
    pthread_t threads[4];
    int n;

    sem_init(&sem_arr[0],0,1);
    sem_init(&sem_arr[1],0,0);
    sem_init(&sem_arr[2],0,0);
    sem_init(&sem_arr[3],0,0);

    printf("Enter a number to loop execute threads\n");
    scanf("%d",&n);

    while (n--){
        pthread_create(&threads[0],NULL,Func_1,NULL);
        pthread_create(&threads[1],NULL,Func_2,NULL);
        pthread_create(&threads[2],NULL,Func_3,NULL);
        pthread_create(&threads[3],NULL,Func_4,NULL);

        for (int i=0;i<4;i++){
            pthread_join(threads[i],NULL);
        }

        sem_init(&sem_arr[0],0,1);
        sem_init(&sem_arr[1],0,0);
        sem_init(&sem_arr[2],0,0);
        sem_init(&sem_arr[3],0,0);
    }

    for (int i=0;i<4;i++){
        sem_destroy(&sem_arr[i]);
    }
    
    return 0;
}

~~~

{% endfolding %}

运行结果如下图所示：

![image-20241010230257569](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241010230257569.png?x-oss-process=style/blog)

## Lab02

多线程是现代操作系统的核心概念，是能够保障操作系统正常运转的基础。Windows、Linux等操作系统向用户提供了多线程、信号量等函数接口，使用户可以通过C/C++、JAVA等主流编程语言来访问调用，以实现用户级线程的创建、运行、管理等功能。本次实验的目标如下：

1. 掌握Windows、Linux系统中多线程、信号量等的相关C函数使用；初步掌握多线程编程。
2. 理解多线程的运行和调度原理；学会设计临界区/信号量来实现多个线程之间的互斥。

### Q1

> Mary和Sally是亲姐妹，她们有一个共同的银行账户，她们可以分别到ATM机取款；爸爸，妈妈，奶奶，爷爷，舅舅也可以分别到ATM机给银行账户存钱。设账户的初始余额为10元。爸爸，妈妈，奶奶，爷爷，舅舅每次分别存入10，20，30，40，50元，每个人分别存款2次。Mary和Sally每次分别取50和100元，每个人分别取款2次。存款和取款的顺序是随机的。假设Mary和Sally的银行账户是可借记的，即当余额少于取款额时，仍旧能够取款成功。利用临界区(Windows系统)或者mutex信号量(Linux系统)编制程序来模拟上述存取款过程，在主程序结束时将账户的最后余额输出，并人工验证一下是否正确。
>
> 实验要求：只能建立一个存款函数Deposit()和一个取款函数Withdraw()；每个家长在每次存款时都要创建1个存款线程，以Deposit()作为线程函数，将家长的称呼和存款金额传递给存款线程，以完成存款操作。同样的，Mary和Sally每人每次在取款时都要创建1个取款线程，以Withdraw()作为线程函数，将取款人的称呼和取款金额传递给取款线程，以完成取款操作。假设Mary和Sally的银行账户是可借记的，即当余额少于取款额时，仍旧能够取款成功。
>
> 实验提示：用srand()来设定随机数种子；用rand()函数来产生每次存款/取款的家长/取款人。定义一个结构体数组，用来保存每个存款/取款人的称呼和存款/取款金额，然后在创建线程时将相应的结构体作为参数传递给线程。
>
> 银行账户是公共变量，对它的操作需要用临界区来进行保护。 

本题的重点在于临界区保护，也就是说要用到临界区/互斥锁。可以大致把本体分为三个部分实现：

1. 实现线程函数Deposit和Withdraw
2. 随机生成操作人员对银行账户进行操作
3. 向对应的线程函数传递操作人员的信息

#### 实现线程函数

两个函数的实现逻辑不难。注意银行帐户是共享变量，在多线程并发操作时必须要加锁来避免条件竞争。

~~~c
void* Deposit(void* arg) {
    // 存款线程，传入参数为操作人员，在对银行账户进行操作时加锁
    Member* operator = (Member*)arg;

    pthread_mutex_lock(&Lock);
    bank_account += operator->op_amount;
    printf("%s deposited %d, now the bank account has %d\n",
           operator->name, operator->op_amount, bank_account);
    pthread_mutex_unlock(&Lock);

    //释放操作人员指向的姓名和本身的内存空间
    free(operator->name);
    free(operator);
    return NULL;
}
~~~

#### 随机生成操作人员

用`rand()`函数生成随机数，同时限定每一个随机数的出现次数，因为每个家庭成员只有两次操作机会。

~~~c
while (operate_num > 0) {
        // 保证启动操作数量个线程
        // 取随机数生成随机的操作人员，如果该人员的操作次数已经用尽，就跳过该人员
        int rand_guy = rand() % num;
        if (members[rand_guy].op_times == 0) {
            continue;
        }
        members[rand_guy].op_times--;
    
    // ...
    }
~~~

这里我们给操作人员一个`op_times`属性，代表该家庭成员剩余的操作次数，当操作次数为0时代表该家庭成员已经没有操作机会。所以在对操作人员进一步操作时需要先检查该成员是否还有操作机会，如果没有机会就跳过后续操作随机生成下一个操作人员。

操作人员的身份（rand_guy）确定后，需要对预备传递给线程的操作人员信息进行填充，于是编写一个`load_operator()`函数进行处理。这里主要是填充操作人员的姓名、存取款状态、操作钱款。

注意为operator填充姓名时并没有直接指向家庭成员的姓名，而是用{% bubble strdup函数,"strdup( ) 函数是c语言中常用的一种字符串拷贝库函数，一般和 free( ) 函数成对出现。","#ec5830" %}拷贝了一份家庭成员姓名字符串。后续需要用`free()`释放掉姓名空间。

~~~c
void load_operator(Member* rand_operator, int rand_guy) { 
    //处理向线程发送的数据，即填充操作人员的姓名、存取款状态、操作钱款
    rand_operator->name = strdup(members[rand_guy].name); // 填充操作人员的姓名
    if (rand_operator->name == NULL) {
        perror("strdup failed");
        exit(EXIT_FAILURE);
    }
    
    if (rand_guy <= 4) { // 根据随机到的人员编号判断该成员是存款还是取款
        rand_operator->is_withdraw = 0;
        rand_operator->op_amount = deposit_num[rand_guy]; // 操作钱款对应操作人员的编号
    } else {
        rand_operator->is_withdraw = 1;
        rand_operator->op_amount = withdraw_num[rand_guy - 5];
    }
}
~~~

#### 向线程函数传递操作人员信息

首先要判断操作成员是取款还是存款，接着传递操作人员的信息给对应的线程函数。注意线程函数只能接受指针作为传入参数，在线程开始时会去读取指针指向地址的数据。所以需要为传递的操作人员动态分配一片内存空间。

~~~c
Member* operator = malloc(sizeof(Member));
        if (operator == NULL) {
            perror("malloc failed for operator");
            exit(EXIT_FAILURE);
        }

        load_operator(operator, rand_guy); // 装载操作人员的信息

        if (operator->is_withdraw) { // 根据操作人员的信息决定调用存款还是取款线程
            pthread_create(&threads[thread_index++], NULL, Withdraw, operator);
        } else {
            pthread_create(&threads[thread_index++], NULL, Deposit, operator);
        }
        operate_num--;
    }
~~~

这里说一下线程函数的传递参数机制。线程函数的定义是：

~~~c
void * myFunc(void *)
{
   my code here to do something…
   return NULL;
}
~~~

可以看到线程函数的接收值和返回值都是`void*`类型，即空指针类型。pthread调用的函数要求入参是一个`void*`的指针，必须将数据强转成这个指针用来传递参数。在函数内部，必须要再手动转换回原来的参数类型来使用这个参数。这种做法叫做{% span yellow, 类型擦除 %}，跟go的interface{}有着异曲同工之妙，C的泛型编程基本上都是用的`void*`这样的方法来传递参数。

所以我们在线程函数调用时传递了operator的操作人员信息后，在线程函数内部要手动将指针转换回它的数据类型：
~~~c
void* Deposit(void* arg) {
    // 存款线程，传入参数为操作人员，在对银行账户进行操作时加锁
    Member* operator = (Member*)arg;
    // ...
}
~~~

至于为什么要为operator动态分配内存而不使用临时变量，是因为对临时变量的值的更新只是在同一片内存空间的位置上进行迭代。这样调用线程函数时传递的指针指向的都是同一片空间，多线程读取操作人员信息时就会出现{% span red, 条件竞争 %}。所以必须使用动态内存分配来存储操作人员信息，并在线程内对操作人员的内存空间进行释放。

~~~c
void* Deposit(void* arg) {
    // ...

    //释放操作人员指向的姓名和本身的内存空间
    free(operator->name);
    free(operator);
    return NULL;
}
~~~

完整的代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <time.h>

typedef struct {
    char* name; // 家庭成员姓名
    int op_amount; // 操作人员操作的钱款
    int op_times; // 剩余的操作次数，每人默认2次
    int is_withdraw; // 1代表为退款操作，0是储蓄操作
} Member;

Member members[] = {
    {"Dad", 0, 2},
    {"Mom", 0, 2},
    {"Grandma", 0, 2},
    {"Grandpa", 0, 2},
    {"Uncle", 0, 2},
    {"Mary", 0, 2},
    {"Sally", 0, 2},
};

int deposit_num[] = {10, 20, 30, 40, 50};
int withdraw_num[] = {50, 100};
int bank_account = 10;
pthread_mutex_t Lock;

void* Deposit(void* arg) {
    // 存款线程，传入参数为操作人员，在对银行账户进行操作时加锁
    Member* operator = (Member*)arg;

    pthread_mutex_lock(&Lock);
    bank_account += operator->op_amount;
    printf("%s deposited %d, now the bank account has %d\n",
           operator->name, operator->op_amount, bank_account);
    pthread_mutex_unlock(&Lock);

    //释放操作人员指向的姓名和本身的内存空间
    free(operator->name);
    free(operator);
    return NULL;
}

void* Withdraw(void* arg) {
    // 取款线程，传入参数为操作人员，在对银行账户进行操作时加锁
    Member* operator = (Member*)arg;

    pthread_mutex_lock(&Lock);
    bank_account -= operator->op_amount;
    printf("%s withdrew %d, now the bank account has %d\n",
           operator->name, operator->op_amount, bank_account);
    pthread_mutex_unlock(&Lock);

    //释放操作人员指向的姓名和本身的内存空间
    free(operator->name);
    free(operator);
    return NULL;
}

void load_operator(Member* rand_operator, int rand_guy) { 
    //处理向线程发送的数据，即填充操作人员的姓名、存取款状态、操作钱款
    rand_operator->name = strdup(members[rand_guy].name); // 填充操作人员的姓名
    if (rand_operator->name == NULL) {
        perror("strdup failed");
        exit(EXIT_FAILURE);
    }
    
    if (rand_guy <= 4) { // 根据随机到的人员编号判断该成员是存款还是取款
        rand_operator->is_withdraw = 0;
        rand_operator->op_amount = deposit_num[rand_guy]; // 操作钱款对应操作人员的编号
    } else {
        rand_operator->is_withdraw = 1;
        rand_operator->op_amount = withdraw_num[rand_guy - 5];
    }
}

void operate(void) {
    // 操作主体函数，处理随机存取逻辑并启动多线程
    int num = sizeof(members) / sizeof(members[0]); //成员数量
    int operate_num = 0; // 操作次数，即存取款次数之和，本体应为2*7=14
    int thread_index = 0; // 线程计数下标
    srand((unsigned int)time(NULL)); // 初始化随机数种子

    for (int i = 0; i < num; i++) {
        // 计算操作次数
        operate_num += members[i].op_times;
    }

    pthread_t* threads = malloc(operate_num * sizeof(pthread_t)); // 为操作总数动态分配相同个数的线程
    if (threads == NULL) {
        perror("malloc failed for threads");
        exit(EXIT_FAILURE);
    }

    while (operate_num > 0) {
        // 保证启动操作数量个线程
        // 取随机数生成随机的操作人员，如果该人员的操作次数已经用尽，就跳过该人员
        int rand_guy = rand() % num;
        if (members[rand_guy].op_times == 0) {
            continue;
        }
        members[rand_guy].op_times--;

        /*
        因为向线程传递的参数必须是一个指向特定地址的指针，线程启动后将向该地址读取数据
        所以必须用动态内存分配一个新的内存空间储存操作人员信息，并将该指针传递给线程
        如果用临时变量，操作人员的信息将只在一片相同的地址空间上进行迭代
        多线程读取数据时就会出现条件竞争
        故而此处必须使用动态内存分配，并在线程操作执行结束时由线程对分配的内存进行释放
        */
        Member* operator = malloc(sizeof(Member));
        if (operator == NULL) {
            perror("malloc failed for operator");
            exit(EXIT_FAILURE);
        }

        load_operator(operator, rand_guy); // 装载操作人员的信息

        if (operator->is_withdraw) { // 根据操作人员的信息决定调用存款还是取款线程
            pthread_create(&threads[thread_index++], NULL, Withdraw, operator);
        } else {
            pthread_create(&threads[thread_index++], NULL, Deposit, operator);
        }
        operate_num--;
    }

    for (int i = 0; i < thread_index; i++) { // 在多线程并发结束后等待多线程结束
        pthread_join(threads[i], NULL);
    }

    free(threads); // 操作结束，释放对线程分配的内存
}

int main() {
    pthread_mutex_init(&Lock, NULL); // 初始化互斥锁

    operate(); // 进行操作

    printf("Final bank account: %d\n", bank_account); // 回显最后银行账户的信息

    pthread_mutex_destroy(&Lock); // 销毁互斥锁

    return 0;
}

~~~

{% endfolding %}

运行结果如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241013143021163.png?x-oss-process=style/blog" alt="image-20241013143021163" style="zoom:80%;" />

### Q2

> 本题的要求跟题目一的要求一样，唯一区别是：在本题中假设Mary和Sally的银行账户是不可借记的，即当余额少于取款额时，不能取款，取款线程需要阻塞等待直到账户有足够的钱。

为了满足题目的新要求，即 **Mary 和 Sally 的银行账户在余额不足时无法取款，取款线程需要阻塞等待**，需要对取款操作做一些修改。我们可以使用条件变量 (`pthread_cond_t`) 来实现线程阻塞和唤醒的机制：[【C语言】条件变量(pthread_cond_t)_c语言条件变量-CSDN博客](https://blog.csdn.net/eidolon_foot/article/details/134509797)

1. **添加条件变量**：使用条件变量 `pthread_cond_t` 来实现取款线程的阻塞和唤醒。当余额不足时，取款线程会进入等待状态，直到有足够的钱进行取款。
2. **取款操作检测是否阻塞**：在取款时检查余额。如果余额不足，则阻塞线程等待条件变量的信号。
3. **存款操作唤醒取款线程**：每当有存款时，需要唤醒所有等待中的取款线程，检查是否现在可以取款。
4. **线程同步**：由于涉及到多线程的等待和唤醒操作，所有操作仍需保证线程安全，继续使用互斥锁 `pthread_mutex_t`。

所以只需要对`Deposit()`和`Withdraw()`这两个线程函数进行修改即可：
~~~c
void* Deposit(void* arg) {
    // 新增特性：存款时将尝试唤醒所有条件变量，以恢复阻塞的取款线程
    
	// 存款操作...
    pthread_cond_broadcast(&Cond); // 存款后，唤醒所有条件变量，再次尝试取款
    
    // ...
}

void* Withdraw(void* arg) {
    // 新增特性：若取款后余额将为负数，则阻塞线程并释放锁
    // ...
    while(bank_account<operator->op_amount){
        // 若此时银行余额小于取款操作钱款，则阻塞线程，释放锁。
        printf("%s is waiting to withdraw %d, but only %d is available, operation blockage.\n",
        operator->name,operator->op_amount,bank_account);
        pthread_cond_wait(&Cond,&Lock);
    }

    //取款 ...
}
~~~

完整的代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <time.h>

typedef struct {
    char* name; 
    int op_amount; 
    int op_times; 
    int is_withdraw; 
} Member;

Member members[] = {
    {"Dad", 0, 2},
    {"Mom", 0, 2},
    {"Grandma", 0, 2},
    {"Grandpa", 0, 2},
    {"Uncle", 0, 2},
    {"Mary", 0, 2},
    {"Sally", 0, 2},
};

int deposit_num[] = {10, 20, 30, 40, 50};
int withdraw_num[] = {50, 100};
int bank_account = 10;
pthread_mutex_t Lock;
pthread_cond_t Cond;

void* Deposit(void* arg) {
    // 新增特性：存款时将尝试唤醒所有条件变量，以恢复阻塞的取款线程
    Member* operator = (Member*)arg;

    pthread_mutex_lock(&Lock);
    bank_account += operator->op_amount;
    printf("%s deposited %d, now the bank account has %d\n",
           operator->name, operator->op_amount, bank_account);
    pthread_cond_broadcast(&Cond); // 存款后，唤醒所有条件变量，再次尝试取款
    pthread_mutex_unlock(&Lock);

    free(operator->name);
    free(operator);
    return NULL;
}

void* Withdraw(void* arg) {
    // 新增特性：若取款后余额将为负数，则阻塞线程并释放锁
    Member* operator = (Member*)arg;

    pthread_mutex_lock(&Lock);

    while(bank_account<operator->op_amount){
        // 若此时银行余额小于取款操作钱款，则阻塞线程，释放锁。
        printf("%s is waiting to withdraw %d, but only %d is available, operation blockage.\n",
        operator->name,operator->op_amount,bank_account);
        pthread_cond_wait(&Cond,&Lock);
    }

    bank_account -= operator->op_amount;
    printf("%s withdrew %d, now the bank account has %d\n",
           operator->name, operator->op_amount, bank_account);

    pthread_mutex_unlock(&Lock);

    free(operator->name);
    free(operator);
    return NULL;
}

void load_operator(Member* rand_operator, int rand_guy) { 
    rand_operator->name = strdup(members[rand_guy].name); 
    if (rand_operator->name == NULL) {
        perror("strdup failed");
        exit(EXIT_FAILURE);
    }
    
    if (rand_guy <= 4) { 
        rand_operator->is_withdraw = 0;
        rand_operator->op_amount = deposit_num[rand_guy];
    } else {
        rand_operator->is_withdraw = 1;
        rand_operator->op_amount = withdraw_num[rand_guy - 5];
    }
}

void operate(void) {
    int num = sizeof(members) / sizeof(members[0]); 
    int operate_num = 0; 
    int thread_index = 0; 
    srand((unsigned int)time(NULL));

    for (int i = 0; i < num; i++) {
        operate_num += members[i].op_times;
    }

    pthread_t* threads = malloc(operate_num * sizeof(pthread_t)); 
    if (threads == NULL) {
        perror("malloc failed for threads");
        exit(EXIT_FAILURE);
    }

    while (operate_num > 0) {
        int rand_guy = rand() % num;
        if (members[rand_guy].op_times == 0) {
            continue;
        }
        members[rand_guy].op_times--;

        Member* operator = malloc(sizeof(Member));
        if (operator == NULL) {
            perror("malloc failed for operator");
            exit(EXIT_FAILURE);
        }

        load_operator(operator, rand_guy); 

        if (operator->is_withdraw) { 
            pthread_create(&threads[thread_index++], NULL, Withdraw, operator);
        } else {
            pthread_create(&threads[thread_index++], NULL, Deposit, operator);
        }
        operate_num--;
    }

    for (int i = 0; i < thread_index; i++) {
        pthread_join(threads[i], NULL);
    }

    free(threads); 
}

int main() {
    pthread_mutex_init(&Lock, NULL); 
    pthread_cond_init(&Cond,NULL); // 初始化条件变量

    operate(); 

    printf("Final bank account: %d\n", bank_account); 

    pthread_mutex_destroy(&Lock); 
    pthread_cond_destroy(&Cond); // 销毁条件变量

    return 0;
}

~~~

{% endfolding %}

运行结果如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241013143933424.png?x-oss-process=style/blog" alt="image-20241013143933424" style="zoom:50%;" />

思考：假如已经有两个或多个取款线程进入阻塞，然后存款线程调用`pthread_cond_broadcast`唤醒所有阻塞的线程。此时会不会出现竞争？哪个被唤醒的线程会获得锁？

当存款线程通过 `pthread_cond_broadcast` 唤醒多个阻塞的取款线程时，**确实可能发生竞争**，但竞争的结果是受互斥锁保护的。每次只有一个线程能够获得锁并执行操作，其他线程会阻塞在锁上，直到锁被释放。

唤醒的线程是以一种不确定的顺序重新争夺锁的，具体哪个线程会优先获得锁取决于操作系统的调度策略。常见的调度策略可能是**先唤醒的线程**优先获得锁，但这并不是严格保证的，取决于内核调度器的实现。

如果只希望唤醒一个线程，可以用 `pthread_cond_signal` 代替 `pthread_cond_broadcast`，这只会唤醒一个等待的线程。不更改也没有关系，因为多线程争夺互斥锁对于共享变量是安全的，这种随机性不会对程序造成危害。

## Lab03

进程调度是现代操作系统中最核心的部分，它是现代操作系统能够实现多用户、多任务功能的根本保障。早期的批处理系统、不同版本的Windows、Linux等操作系统分别采用了不同的进程调度机制，例如，FCFS调度算法、SJF调度算法、HRRN调度算法、RR调度算法、多级反馈队列调度算法等。本次实验的目标如下：

1. 掌握Windows、Linux操作系统中进程调度机制及其原理。
2. 学会用高级语言来模拟实现一些常用的非抢占式(Non-preemptive)进程调度算法。

### Q1

> 假设有10个进程，每个进程的到达时间(1-20之间的整数)、需要的运行时间(10-5之间的整数)都是随机生产。模拟实现短作业优先调度算法SJF，结果输出这10个进程的执行顺序，并计算输出每个进程的等待时间以及总的平均等待时间。 
>
> 实验提示：**本次实验不需要使用线程**。另外，**本次实验中的两种调度算法都是非抢占式(Non-preemptive)调度算法**，即一个进程获得CPU后将一直执行到结束。要求实现一个排队器函数，用于产生下一个将获得CPU的进程。首先，生成10个进程(它们的到达时间、需要运行的时间、优先级由随机数产生)，然后由排队器来决定进程获得CPU的顺序。由于本次实验中的两种算法都是非抢占式，因此一个进程执行完成后，由排队器来产生下一个获得CPU的进程。对于HRRN算法，需要为每一个进程设置一个变量，用来记录其动态优先级。

SJF(Shortest Job First )算法，即最短作业优先调度法。是以进入系统的作业所要求的CPU时间为标准，对短作业或者短进程优先调度的算法，将每个进程与其估计运行时间进行关联，选取估计计算时间最短的作业投入运行。

SJF调度算法是被证明了的最佳调度算法，这是因为对于给定的一组进程，SJF算法的平均周转时间最小。通过将短进程移到长进程之前，短进程等待时间的减少大于长进程等特时间的增加，因此，平均等待时间减少了。

但在实际运用中，SJF算法是达不到理论上的最佳效果的。因为实现SJF调度算法需要知道作业所需运行时间，否则调度就没有依据，要精确知道一个作业的运行时间是办不到的。而且还会出现{% bubble 饥饿,"进程饥饿，即为Starvation，指当等待时间给进程推进和响应带来明显影响称为进程饥饿。当饥饿到一定程度的进程在等待到即使完成也无实际意义的时候称为饥饿死亡。","#ec5830" %}现象。

要模拟实现SFJ其实并不难。在现实情况中，由于进程的到达时间并不确定，所以是一个动态的排序算法。但是在模拟中实现，我们可以预先用随机数生成好进程的抵达时间、运行时间等各种信息，然后用排队器函数提前处理好。

~~~c
qsort(processes, NUM_PROCESSES, sizeof(struct PCB), compare);
~~~

至于排队器函数的处理逻辑实现也很简单：根据进程的运行时间进行排序，运行时间短的优先级更高；如果运行时间相同，则比较哪个进程的抵达时间更早。

~~~c
int compare(const void *a, const void *b) {
    struct PCB *p1 = (struct PCB *)a;
    struct PCB *p2 = (struct PCB *)b;

    // 优先比较需要用时，如果时间相同则比较到达时间
    if (p1->neededTime == p2->neededTime)
        return p1->arrivalTime - p2->arrivalTime;
    return p1->neededTime - p2->neededTime;
}
~~~

用排队器对进程队列进行排序处理后，我们就可以依次遍历每个处理好的有序进程，计算并打印它们的信息即可。

完整代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define NUM_PROCESSES 10

struct PCB {
    char pid[64];
    char state;
    int priority;
    int neededTime;
    int totalWaitTime;
    int arrivalTime;
    struct PCB *next; // 实际上并没用到指针，用数组代替了
};

// 随机生成进程
void generateProcesses(struct PCB processes[]) {
    srand(time(0));  
    for (int i = 0; i < NUM_PROCESSES; i++) {
        snprintf(processes[i].pid, sizeof(processes[i].pid), "P%d", i + 1);
        processes[i].state = 'w';
        processes[i].priority = 0;
        processes[i].neededTime = (rand() % 41) + 10;  // 随机生成需要的时间1~50
        processes[i].arrivalTime = (rand() % 20) + 1;  // 随机生成抵达时间1~20
        processes[i].totalWaitTime = 0;
    }
}

// 撰写SFJ排序器的比较逻辑
int compare(const void *a, const void *b) {
    struct PCB *p1 = (struct PCB *)a;
    struct PCB *p2 = (struct PCB *)b;

    // 优先比较需要用时，如果时间相同则比较到达时间
    if (p1->neededTime == p2->neededTime)
        return p1->arrivalTime - p2->arrivalTime;
    return p1->neededTime - p2->neededTime;
}

// 模拟SFJ调度排序器
void SJF(struct PCB processes[]) {
    // 对进程进行排序，运行时间少、抵达时间早的优先
    qsort(processes, NUM_PROCESSES, sizeof(struct PCB), compare);

    int currentTime = 0;
    int totalWaitTime = 0;

    printf("Execution Order:\n");

    for (int i = 0; i < NUM_PROCESSES; i++) {
        // 如果第一个进程的抵达时间晚于现在的时间，则等待第一个进程开始
        if (currentTime < processes[i].arrivalTime) {
            currentTime = processes[i].arrivalTime;
        }

        // 计算进程等待时间：当前的时间 - 抵达的时间
        processes[i].totalWaitTime = currentTime - processes[i].arrivalTime;
        // 计算等待总时间
        totalWaitTime += processes[i].totalWaitTime;

        printf("Process %s - Arrival Time: %d, Needed Time: %d, Wait Time: %d\n",
               processes[i].pid, processes[i].arrivalTime, processes[i].neededTime, processes[i].totalWaitTime);

        // 更新当前的时间
        currentTime += processes[i].neededTime;
    }

    // 计算等待平均时间
    double avgWaitTime = (double)totalWaitTime / NUM_PROCESSES;
    printf("Total Wait Time: %d\n", totalWaitTime);
    printf("Average Wait Time: %.2f\n", avgWaitTime);
}

int main() {
    struct PCB processes[NUM_PROCESSES];
    
    generateProcesses(processes);

    SJF(processes);

    return 0;
}

~~~

{% endfolding %}

运行结果如下：

![image-20241014215208267](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241014215208267.png?x-oss-process=style/blog)

### Q2

> 假设有10个进程，每个进程的到达时间(1-20之间的整数)、需要的运行时间(10-50之间的整数)都是随机生产。模拟实现最高响应比优先调度算法HRRN，结果输出这10个进程的执行顺序，并计算输出每个进程的等待时间以及总的平均等待时间。

高响应比优先调度算法（Highest Response Ratio Next）是一种对CPU中央控制器响应比的分配的一种算法。HRRN是介于FCFS（先来先服务算法）与SJF（短作业优先算法）之间的折中算法，既考虑作业等待时间又考虑作业运行时间，既照顾短作业又不使长作业等待时间过长，改进了调度性能。它解决了SFJ中长作业时间进程的饥饿问题，但是付出了更多的资源去计算响应比，提升了系统开销。

实际上就是以{% span red, 响应比 %}来代替{% span yellow, 作业时间 %}作为排序标准，响应比的计算公式如下：

$response\_ratio=(waiting\_time+runtime)/(runtime)$

其中等待时间是不断变化的，所以响应比也是不断变化的。对SFJ算法的进程处理方法已经不适用，因为此时进程之间的优先级是动态的。所以我们的处理逻辑也需要改变：对于每个时间单位，计算一次响应比并对进程列表进行排序，选择优先级最高的进程分配CPU资源执行。

~~~c
calculateResponseRatio(processes,currentTime); // 计算响应比

index=findHighestResponseProcess(processes,currentTime); // 寻找响应值最大的进程下标
~~~

完整的代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define NUM_PROCESSES 10

struct PCB {
    char pid[64];
    char state;
    int hasFinished;
    int priority;
    int neededTime;
    int totalWaitTime;
    int arrivalTime;
    double responseRatio;

    struct PCB *next; 
};

// 随机生成进程
void generateProcesses(struct PCB processes[]) {
    srand(time(0));  
    for (int i = 0; i < NUM_PROCESSES; i++) {
        snprintf(processes[i].pid, sizeof(processes[i].pid), "P%d", i + 1);
        processes[i].state = 'w';
        processes[i].hasFinished=0;
        processes[i].priority = 0;
        processes[i].neededTime = (rand() % 41) + 10;  // 随机生成需要的时间1~50
        processes[i].arrivalTime = (rand() % 20) + 1;  // 随机生成抵达时间1~20
        processes[i].totalWaitTime = 0;
        processes[i].responseRatio = 0;
    }
}

// 计算响应比
void calculateResponseRatio(struct PCB processes[], int currentTime){
    int waitTime=0;
    for (int i=0;i<NUM_PROCESSES;i++){
        if (processes[i].hasFinished!=1&&processes[i].arrivalTime <= currentTime){
            waitTime=currentTime-processes[i].arrivalTime;
            // 计算公式：响应比 =（等待时间+运行时间）/运行时间
            processes[i].responseRatio=(waitTime+(double)processes[i].neededTime)/processes[i].neededTime;
        }
    }
    return;
}

// 寻找响应比最大的进程
int findHighestResponseProcess(struct PCB processes[],int currentTime){
    int index=-1;
    double highestRatio=-1;

    for (int i=0;i<NUM_PROCESSES;i++){
        if (processes[i].hasFinished!=1 && processes[i].responseRatio>highestRatio &&processes[i].arrivalTime<=currentTime){
            index=i;
            highestRatio=processes[i].responseRatio;
        }
    }

    return index;
}

// 模拟HRRN调度排序器
void HRRN(struct PCB processes[]) {
    int totalWaitTime=0;
    int currentTime=0;
    int finishedProcesses=0;
    int index=0;

    printf("Execution Order:\n");

    while(finishedProcesses<NUM_PROCESSES){

        calculateResponseRatio(processes,currentTime); // 计算响应比

        index=findHighestResponseProcess(processes,currentTime); // 寻找响应值最大的进程下标
        if (index==-1)
        {
            currentTime++;
            continue;
        }

        struct PCB* tmp=&processes[index];
        printf("Process %s - Arrival Time: %d, Needed Time: %d, Wait Time: %d\n",
        tmp->pid, tmp->arrivalTime, tmp->neededTime,
        currentTime-tmp->arrivalTime);

        // 计算总共等待的时间
        tmp->totalWaitTime=currentTime-tmp->arrivalTime;
        totalWaitTime+=tmp->totalWaitTime;
        
        // 更新进程状态和时间
        tmp->hasFinished=1;
        currentTime+=tmp->neededTime;
        finishedProcesses++;
    }

    // 计算等待平均时间
    double avgWaitTime = (double)totalWaitTime / NUM_PROCESSES;
    printf("Total Wait Time: %d\n", totalWaitTime);
    printf("Average Wait Time: %.2f\n", avgWaitTime);
}

int main() {
    struct PCB processes[NUM_PROCESSES];
    
    generateProcesses(processes);

    HRRN(processes);

    return 0;
}

~~~

{% endfolding %}

运行结果如下：

![image-20241014215235225](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241014215235225.png?x-oss-process=style/blog)

## Lab04

进程调度是现代操作系统中最核心的部分，它是现代操作系统能够实现多用户、多任务功能的根本保障。早期的批处理系统、不同版本的Windows、Linux等操作系统分别采用了不同的进程调度机制，例如，FCFS调度算法、SJF调度算法、HRRN调度算法、RR调度算法、多级反馈队列调度算法等。本次实验的目标如下：

1. 掌握Windows、Linux操作系统中进程调度机制及其原理。
2. 学会用高级语言来模拟实现一些常用的非抢占式(Non-preemptive)进程调度算法。

### Q1

> （一） 题目：多级反馈队列调度算法
>
> 假设有5个运行队列，它们的优先级分别为1，2，3，4，5，它们的时间片长度分别为10ms,20ms,40ms,80ms,160ms，即第i个队列的优先级比第i-1个队列要低一级，但是时间片比第i-1个队列的要长一倍。多级反馈队列调度算法包括四个部分：主程序main，进程产生器generator，进程调度器函数Scheduler，进程运行器函数executor。结果输出：在进程创建、插入队列、执行时的相关信息，并计算输出总的平均等待时间。其中，generator用线程来实现，每隔一个随机时间(例如在[1,100]ms之间)产生一个新的进程PCB，并插入到第1个队列的进程链表尾部。Scheduler依次探测每个队列，寻找进程链表不为空的队列，然后调用Executor, executor把该队列进程链表首部的进程取出来执行。要设置1个互斥信号量来实现对第1个队列的互斥访问，因为generator和executor有可能同时对第1个队列进行操作。 同时要设置1个同步信号量，用于generator和Scheduler的同步：generator每产生1个新进程，就signal一次这个同步信号量；只有所有队列不为空时，Scheduler才会运行，否则Scheduler要等待这个同步信号量。当所有进程运行完毕后，Scheduler退出，主程序结束。 

实验提示较长，单独放在下文：

{% folding cyan, 查看实验提示 %}

> 多级反馈队列(Multi-leveled feedback queue)调度算法
>
> 按以下要求实现多级反馈队列调度算法：假设有5个就绪队列，它们的优先级分别为1，2，3，4，5，它们的时间片长度分别为10ms,20ms,40ms,80ms,160ms，即第i个队列的优先级比第i-1个队列要低一级，但是时间片比第i-1个队列的要长一倍。调度算法包括四个部分：主程序main，进程产生器generator，进程调度器函数Scheduler，进程运行器函数executor。 
>
> （1）主程序：设置好多级队列以及它们的优先级、时间片等信息；创建两个信号量，一个用于generator和executor互斥的访问第1个运行队列(因为产生的新进程都是先放到第1个队列等待执行)，另一个用于generator和Scheduler的同步(即，仅当多级队列中还有进程等待运行时，Scheduler才能开始执行调度)。创建进程产生器线程，然后调用进程调度器。
>
>  （2）进程产生器generator：用线程来实现进程产生器。每隔一个随机的时间段，例如[1,100]ms之间的一个随机数，就产生一个新的进程，创建PCB并填上所有的信息。注意，每个进程所需要运行的时间neededTime在一定范围内(假设为[2,200]ms)内由随机数产生，初始优先级为1。PCB创建完毕后，将其插入到第1个队列进程链表的尾部（要用到互斥信号量，因为executor有可能正好从第1个队列中取出排在队列首的进程来运行）。插入完毕后，generator调用Sleep函数卡睡眠等待随机的一个时间间隔(例如在[1，100]范围产生的1个随机数)，然后再进入下一轮新进程的产生。当创建的进程数量达到预先设定的个数，例如20个，generator就执行完毕退出。
>
> （3）进程调度器函数Scheduler：在该函数中，依次从第1个队列一直探测到第5个队列，如果第1个队列不为空，则调用执行器executor来执行排在该队列首部的进程。仅当第i号队列为空时，才去调度第i+1个队列的进程。如果时间片用完了但是执行的进程还没有完成（即usedTime<neededTime），则调度器把该进程移动到下一级队列的尾部。当所有的进程都执行完毕，调度器退出，返回主程序。
>
> （4）进程执行器executor：根据Scheduler传递的队列序号，将该队列进程链表首部的PCB取出，分配该队列对应的时间片给它运行(我们用Sleep函数，睡眠时间长度为该时间片，以模拟该进程得到CPU后的运行期间)。睡眠结束后，所有队列中的进程的等待时间都要加上该时间片。注意，在访问第1个队列时，要使用互斥信号量，以免跟进程产生器generator发生访问冲突。 

{% endfolding %}

多级反馈队列调度（Multilevel Feedback Queue Scheduling）是一种CPU调度算法，它结合了时间片轮转调度和优先级调度的特点，以适应不同类型进程的需要。这种算法特别适用于那些对响应时间有较高要求的交互式系统，同时也能够处理需要较长时间运行的进程。

在编程模拟实现中，对应多级反馈队列调度的部分主要是Scheduler，即进程调度器的行为。因此，实现好Scheduler，就实现了多级反馈队列调度。

#### Scheduler

我们先来看看多级反馈队列调度的行为特征：

1. 在系统中设置多个就绪队列，并未每个队列赋予不同的优先级。第一个队列的优先级最高，第二个次之，其余的优先级逐个降低。该算法为不同的队列中的进程所赋予的执行时间片的大小也各不相同，在优先级愈高的队列中，其时间片就愈小。
2. 每个队列都采用FCFS算法。
3. 按队列优先级调度。

从以上三点，我们可以总结出Scheduler最核心的两个状态：

- {% span red, 当没有新进程出现时，Scheduler的执行逻辑 %}
- 当出现新进程时，Scheduler的执行逻辑

##### 没有新进程出现时

如果没有新进程出现，Scheduler将持续运行，直到多级队列为空。那么，运行时的具体逻辑又是怎么样的呢？

按照多级队列和优先级调度的原则，Scheduler将优先对优先级最高的队列，也就是第一个队列进行调度。处理队列时依照的是FCFS原则，即Scheduler总会优先处理第一个到达的进程，并给他分配队列对应的时间片，调用CPU资源执行进程。

倘若该进程在经过一个时间片后执行完毕，那么该进程将直接被释放（移出等待队列）；倘若没有执行完毕，则该进程会被Scheduler调入下一级优先队列。Scheduler总是会优先处理优先级高的队列直到队列为空，此时才会开始处理下一个优先级的队列。

我们把这个处理逻辑从第一层队列扩展至多级队列，简要概括一下：

- Begin：对于第i级队列，首先检查第一个队列是否为空
  1. 若非空，则调用Scheduler执行队首进程。并依情况判断是否交到下一个优先级队列，回到Begin
  2. 若为空，则开始调度第i+1层队列

对应的代码如下：

~~~c
for (int i=0;i<QUEUE_COUNT;i++){
    while (!IsEmptyQueue(&queues[i]))
        {
            // 当前队列不为空，调用executor
            // 传递队列编号给executor，executor将把进程取出进行处理，由scheduler决定进程是继续入队还是释放
            struct PCB *tmp = queues[i].list;
            executor(i);
            // 判断该进程如何调度
            if (tmp->usedTime < tmp->neededTime)
            {...}
        }
}        
~~~

如此，Scheduler将依照这个逻辑持续运行。最终在多级队列内等待的进程要么被执行完毕释放进程；要么是抵达了等待队列底层仍然没有结束运行，我们在模拟程序中可以认为该程序发生了死循环或者死锁，也直接释放掉进程，防止耗尽系统资源（现实中的处理策略可能要复杂的多）。

无论如何，Scheduler持续运行的结果最终一定会排空多级队列，此时Scheduler将进入休眠，等待新进程的进入。在模拟程序中，对应Generator是否向Scheduler发送了同步信号量。

##### 出现新进程时

由于新进程总是进入第一层优先队列，也就是说新进程拥有最高优先级，而Scheduler的处理逻辑是优先级调度。所以无论Scheduler在休眠或者是在处理其他队列的调度，一旦新的进程进入了优先队列，Scheduler总是会立即转到第一层级的优先队列，重头开始执行调度逻辑。

这一点可以用非堵塞的信号量来实现，Scheduler在每次执行调度逻辑前，都要检测Generator是否发送了同步信号量，以检测是否有新进程到达。

~~~c
begin:
for (int i=0;i<QUEUE_COUNT;i++){
    while (!IsEmptyQueue(&queues[i]))
        {
            //while循环将重复处理当前队列直到队列排空为止，处理过程中需要留意是否接受到generator信号量
            if (sem_trywait(&semaphore_scheduler) == 0) {
                // 如果信号量被设置，立即退出循环，回到进程处理逻辑外部从第一个队列重新开始。
                goto begin;
         }
        ...
}
~~~

总的来说，一旦出现新进程，Scheduler应立即跳转到第一层队列，并重新开始处理。

#### Generator与Executor

Generator要求实现一个线程函数，独立于主程序随机生成进程，在生成进程后应该向Scheduler发送信号提醒Scheduler有新进程到达。这点可以用一个Generator和Scheduler共享的信号量来实现：每次Generator从休眠中苏醒创建好新进程并加入等待队列后，都应该设置信号量+1；而Scheduler在每次进行调度操作前，都应该检查共享信号量是否被设置，或者Scheduler进入休眠后，将持续等待共享变量的设置来决定自己是否被唤醒。这样做，我们就实现了Generator和Scheduler的同步。

Generator还有一个重要的一点就是应该和Executor实现互斥访问第一级队列：因为Generator始终只会对第一优先级队列进行入队操作，而Executor可能也会对第一优先级进行出队操作（对应处理进程），这里存在并发操作共享变量，有条件竞争的风险。因此，应该也用一个共享信号量实现Generator和Executor对第一队列的互斥访问。

这里我没有用共享变量，而是选择了{% span red, 对所有优先队列进行加锁处理 %}。诚然，对所有优先队列加锁相对于只互斥访问第一级队列一定会降低处理效率，但是题目还要求打印队列状态，涉及到对队列数据的遍历访问。显然，这部分操作也会涉及到对第一行队列的读取，所以我干脆把所有涉及队列的操作全部加锁处理了。其实这部分是没有必要的，有心人如果想要优化可以从这里入手处理。

Executor的处理也很简单，在接受到Scheduler传递的队列编号后，只需要将对应的队列做出队处理就可以拿到待执行的进程。值得注意的是，Executor除了要更新被处理的进程信息，还应该更新所有等待队列中的进程的等待时间（实际中Executor当然不用处理这个，但是我们在模拟程序中需要手动对进程的时间信息进行管理，所以放在Executor这里进行更新是再好不过的）。处理完毕后，Executor应该返回被处理进程的指针给Scheduler，让Scheduler决定该进程是否被释放。

完整的代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include "stdlib.h" //包含随机数产生函数
#include "stdio.h"  //标准输入输出函数库
#include "time.h"   //与时间有关的函数头文件
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

struct PCB
{
    char pid[64]; // 进程标识符，即进程的名字

    // 以下部分为用于进程调度的信息
    char state;        // ‘r’: 运行状态；‘w’:就绪状态
                       // ‘b’:阻塞状态
    int priority;      // 进程优先级
    int arrivalTime;   // 进程的创建时间(到达时间)
    int neededTime;    // 进程需要的运行时间
    int usedTime;      // 进程已累计运行的时间
    int totalWaitTime; // 进程已等待的CPU时间总和

    // 以下部分为进程的控制信息
    struct PCB *next; // 指向下一个PCB的链表指针
};

struct queue
{
    int priority;     // 该队列的优先级
    int timeSlice;    // 该队列的时间片长度
    struct PCB *list; // 指向该队列中进程PCB链表的头部
};

#define QUEUE_COUNT 5 // 设置队列长度为5
#define PROCESS_COUNT 20 // 设置进程总数为20
struct queue queues[QUEUE_COUNT];
int Time = 0; // 初始化全局时间为0，用于记录进程执行时消耗的时间
double TotalWatingTime = 0; // 初始化全局总等待时间为0
// sem_t semaphore_generator;
sem_t semaphore_scheduler;
pthread_mutex_t mutex;

void init(); // 初始化函数
void quit(); // 退出函数，销毁变量
void initQueues(); // 初始化队列
void *generateProcess(void *arg); // 产生进程的线程函数，生成器
void scheduler(); // 调度器
void executor(int queueIndex); // 执行器
void updatePCB(int sleepTime); // 更新PCB的数据，用于在睡眠后更新所有队列中进程的等待时间
int IsEmptyQueue(struct queue *q); // 检测队列是否为空
void EnQueue(struct queue *q, struct PCB *p); // 入队操作
struct PCB *DeQueue(struct queue *q); // 出队操作
void DeleteQueue(struct queue *q); // 删除队列操作
void DisplayQueue(); // 打印队列所有元素操作

int main(void)
{
    init();
    pthread_t generated_thread;
    pthread_create(&generated_thread, NULL, generateProcess, NULL); // 调用生成器线程函数

    scheduler(); // 执行调度器
    printf("The average of total wating time is: %g\n",TotalWatingTime/PROCESS_COUNT);

    pthread_join(generated_thread, NULL); // 等待生成器函数线程完成

    quit();
    return 0;
}

void init()
{
    srand((unsigned)time(NULL));
    initQueues();

    // sem_init(&semaphore_generator, 0, 1);
    sem_init(&semaphore_scheduler, 0, 0);
    pthread_mutex_init(&mutex, NULL);
}

void quit()
{
    // sem_destroy(&semaphore_generator);
    sem_destroy(&semaphore_scheduler);
    pthread_mutex_destroy(&mutex);

    for (int i = 0; i < QUEUE_COUNT; i++)
    {
        DeleteQueue(&queues[i]);
    }
}

void initQueues()
{
    for (int i = 0; i < QUEUE_COUNT; i++)
    {
        queues[i].list = NULL;
        queues[i].priority = i + 1;
        queues[i].timeSlice = 10 * (1 << i); // 10,20,40,80,160ms
    }
}

void *generateProcess(void *arg)
{
    // 每次生成新进程时，都要用信号量通知scheduler同步处理新产生的进程
    // sem_wait(&semaphore_generator);
    for (int i = 0; i < PROCESS_COUNT; i++)
    {
        usleep((rand() % 100000) + 1000);
        struct PCB *newProcess = (struct PCB *)malloc(sizeof(struct PCB));
        snprintf(newProcess->pid, sizeof(newProcess->pid), "P%d", i); // 生成 PID
        newProcess->neededTime = (rand() % 199) + 2;
        newProcess->priority = 1;
        newProcess->next = NULL;
        newProcess->state = 'w';
        newProcess->totalWaitTime = 0;
        newProcess->arrivalTime = Time; // 当前的时间为抵达时间
        newProcess->usedTime = 0;

        // printf("the sem is comming!\n");

        pthread_mutex_lock(&mutex); 
        // printf("generator get the lock!\n");
        EnQueue(&queues[0], newProcess);
        // printf("generator get rid of the lock!\n");

        printf("Generator: Process %s is generated, neededTime = %d, arrivalTime = %d\n",
               newProcess->pid, newProcess->neededTime, newProcess->arrivalTime);
        pthread_mutex_unlock(&mutex);
        
        // printf("generator Post to scheduler\n");
        sem_post(&semaphore_scheduler);
        // sem_post(&semaphore_generator);
        // 一共会发送PROCESS_COUNT个信号量
    }
    return NULL;
}

void scheduler(){
    //scheduler的逻辑是执行多优先级队列，
    //如果收到generator发来的信号说明第一优先级队列出现新进程
    //所以需要立即转到第一队列进行处理。
    //用信号量控制scheduler是否重启执行逻辑，一个执行逻辑即从第一个队列开始依次往下调度
    //假设scheduler一直收不到generator的信号量，scheduler最终将会把所有在优先级队列中的进程释放
    /*
    a:首先检查第一个队列是否为空：
        1.若非空，则调用执行器执行队首进程。并依情况判断是否交到下一个优先级队列，回到a
        2.若为空，则开始调度下一个队列
    */

   // 这个变量统计已经接受到的进程信号量，当processCount=PROCESSCOUNT时，说明进程已经全部执行完毕，调度器退出。
   int processCount=0;

   sem_wait(&semaphore_scheduler);
   /*
   这里processCount递增有两种情况：
    1.scheduler第一次被调用时会递增一次计数
    2.假如队列内全部进程执行完毕，但是generator还在工作（处于睡眠状态没来得及产生新的进程），scheduler会在这里等待信号量。
   */
   processCount++;

   while(processCount<PROCESS_COUNT){
    // 从此处开始，由第一个优先级队列开始调度。
    // 所以下面的进程处理逻辑在检测到信号量时，应该退出for循环。
    begin:
    for (int i=0;i<QUEUE_COUNT;i++){
        // 一个进程处理逻辑，若没有信号量打断将会处理所有进程
        // 所以需要建立scheduler退出机制，保证接受到信号量后退出循环。
        // 依次处理所有队列，每调用一次executor对应CPU执行了对应时间片的任务
        // 在时间片结束后：1.对该进程的情况进行调度 2.检查信号量，是否有新的进程抵达第一级优先队列
        while (!IsEmptyQueue(&queues[i]))
            {
                //while循环将重复处理当前队列直到队列排空为止，处理过程中需要留意是否接受到generator信号量
                if (sem_trywait(&semaphore_scheduler) == 0) {
                    // 如果信号量被设置，立即退出循环，回到进程处理逻辑外部从第一个队列重新开始。
                    // 这里processCount递增代表着又有一个新的进程加入到了队列中
                    // 有一个问题：如果generator短时间内插入了多个进程，会导致scheduler <空转一次>，但是不影响计数正常使用 
                    processCount++;
                    goto begin;
                }
                pthread_mutex_lock(&mutex);
                // 当前队列不为空，调用executor
                // 传递队列编号给executor，executor将把进程取出/出队进行处理，由scheduler决定进程是继续入队还是释放
                struct PCB *tmp = queues[i].list;

                pthread_mutex_unlock(&mutex);

                executor(i);

                pthread_mutex_lock(&mutex);

                // 判断该进程如何调度
                if (tmp->usedTime < tmp->neededTime)
                {
                    // 如果执行进程还未结束，则将之下放一级队列
                    if (tmp->priority < QUEUE_COUNT)
                    {
                        // 如果进程还可以继续往下放置
                        //  pthread_mutex_lock(&mutex);
                        tmp->priority++;
                        EnQueue(&queues[i + 1], tmp);
                        printf("Scheduler: Process %s is moved to queue %d, priority = %d\n",
                               tmp->pid, i + 2, tmp->priority);
                        DisplayQueue(); // 加锁移动至函数内部
                    }
                    else
                    {
                        // 如果队列已经无法下移，为了确保系统正确运行，则直接丢弃/释放进程。
                        printf("Scheduler: Process %s is running overtime, total waiting time = %d, aborted.\n",
                               tmp->pid, tmp->totalWaitTime);
                        TotalWatingTime+=tmp->totalWaitTime;
                        free(tmp);
                        DisplayQueue();
                    }
                }
                else
                {
                    // 进程执行完毕，释放进程
                    printf("Scheduler: Process %s finished, total waiting time = %d\n",
                           tmp->pid, tmp->totalWaitTime);
                    TotalWatingTime+=tmp->totalWaitTime;
                    DisplayQueue();
                    free(tmp);
                }
                pthread_mutex_unlock(&mutex);
            }
            // 对队伍进程进行调度到这里为止

    // 这里是执行逻辑的末尾，说明整个多优先级任务队列中已经没有等待的任务
    // scheduler应该进入休眠状态等待generator的信号量，或者结束调度退出程序
    }
   }
}

void executor(int queueIndex)
{
    pthread_mutex_lock(&mutex);
    // printf("executor get the lock!\n");
    struct PCB *tmp = DeQueue(&queues[queueIndex]);
    // printf("executor get the %s!\n",tmp->pid);

    int timeSlice = queues[queueIndex].timeSlice;
    int sleepTime = (timeSlice+tmp->usedTime > tmp->neededTime) ? tmp->neededTime-tmp->usedTime : timeSlice;

    usleep(sleepTime * 1000);
    Time += sleepTime;
    // printf("executor is trying to update all PCB.\n");
    updatePCB(sleepTime);

    tmp->usedTime += sleepTime;
    // printf("executor is going to release lock.\n");
    pthread_mutex_unlock(&mutex);
    // printf("executor release lock!\n");

    printf("Executor: Process %s in queue %d consumes %d ms\n",
           tmp->pid, queueIndex + 1, sleepTime);
}

void updatePCB(int sleepTime)
{
    // 更新队列中所有进程的等待时间
    struct PCB *tmp;
    struct PCB *tempQueue[PROCESS_COUNT]; // 临时队列数组
    int count = 0; // 临时队列计数

    for (int i = 0; i < QUEUE_COUNT; i++)
    {
        while (!IsEmptyQueue(&queues[i]))
        {
            // 这里对队列进行操作，但是父函数executor已经锁住临界区，所以可以不用加锁。
            // printf("queue%d is not empty,update it!\n",i+1);
            tmp = DeQueue(&queues[i]);
            // printf("trying to update %s\n",tmp->pid);

            tmp->totalWaitTime += sleepTime; 

            // 将更新后的进程存入临时队列
            tempQueue[count++] = tmp;
        }

        for (int j = 0; j < count; j++)
        {
            EnQueue(&queues[i], tempQueue[j]);
        }
        count = 0; // 重置计数器
    }
    // printf("PCB finished updating!\n");
}


int IsEmptyQueue(struct queue *q)
{
    return (q->list == NULL);
}

void EnQueue(struct queue *q, struct PCB *p)
{
    if (q->list == NULL)
    {
        q->list = p;
    }
    else
    {
        struct PCB *tmp;
        tmp = q->list;
        while (tmp->next != NULL)
        {
            tmp = tmp->next;
        }
        tmp->next = p;
    }
}

struct PCB *DeQueue(struct queue *q)
{
    // printf("trying to dequeue queue%d\n",q->priority);
    if (IsEmptyQueue(q))
    {
        // printf("The Queue is empty!\n");
        return NULL;
    }
    else
    {
        struct PCB *p;
        p = q->list;
        q->list = q->list->next;
        p->next=NULL; //切断出队元素与原队列之间的黏连
        return p;
    }
}

void DeleteQueue(struct queue *q)
{
    struct PCB *p;
    while (q->list)
    {
        p = q->list;
        q->list = q->list->next;
        free(p);
    }
}

void DisplayQueue()
{
    // pthread_mutex_lock(&mutex);
    struct PCB *tmp;
    struct PCB *tempQueue[PROCESS_COUNT]; // 临时队列数组
    int count;

    for (int i = 0; i < QUEUE_COUNT; i++)
    {
        printf("Queue %d: ", i + 1);
        count = 0; // 重置计数器
        
        while (!IsEmptyQueue(&queues[i]))
        {
            tmp = DeQueue(&queues[i]);
            if (tmp == NULL)
                break; // 安全处理

            printf("%s ", tmp->pid); // 打印进程 PID
            tempQueue[count++] = tmp; // 存储进程到临时队列
        }
        printf("\n");

        // 将临时队列中的进程重新入队
        for (int j = 0; j < count; j++)
        {
            EnQueue(&queues[i], tempQueue[j]);
        }
    }
    // pthread_mutex_unlock(&mutex);
}

~~~

{% endfolding %}

运行部分结果如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241025162031480.png?x-oss-process=style/blog" alt="image-20241025162031480" style="zoom:50%;" />

![image-20241025162102590](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241025162102590.png?x-oss-process=style/blog)

## Lab05

计算机系统中有的资源是需要互斥访问的。当多个进程竞争使用这些互斥资源时，如果进程申请和释放互斥资源的顺序不当，就容易造成系统的死锁。目前应对死锁问题的办法有：死锁的预防、死锁的避免、死锁的检测和解除。银行家算法(Banker’s Algorithm)是避免死锁的有效方法。本次实验的目标如下：

1. 理解银行家算法的原理。
2. 能够用高级语言来实现银行家算法。

### Q1

> **实验内容：**
>
> 假设系统中有n=5个进程和m=3种资源。这m种资源每一种资源的最大可用数量Available[i],i=1,…,m，用随机数生成，取值范围为[1,10]。每个进程i对资源j的最大需求Max[i,j],i=1,…,n,j=1,…m，也用随机数生成，其取值范围为从1到Available[j]。初始分配矩阵Allocation[i,j]也用随机数生成，其中，有50%的概率Allocation[i,j]取值为0，有50%的概率Allocation[i,j]随机从1到Max[i,j]中取值。如果在给第i个进程生成初始分配矩阵Allocation后，发现某种资源j的最大可用数量已经分配光了，那么从第i+1个进程开始所有的进程都分配不到该资源j，也就是说Allocation[k,j]=0,k=i+1,…,n。
>
> **实验要求：**
>
> 编程实现银行家算法，检测从初始分配开始，是否存在安全分配序列。如果存在，刚输出该安全分配序列，否则输出“Deadlock”。

实验提示中给出了需要用到的数据结构，单独放在下文：

{% folding cyan, 查看实验提示 %}

> **数据结构：**
>
> （1） 可用资源向量Available,这是一个一维数组Available[j],j=1,…m，表示第j种资源的可用数量，其中m为资源的种类个数
>
> （2） 最大资源需求矩阵Max,这是一个n*m的二维数组，其中n为进程个数。单元Max[i,j]存储的数值表示第i个进程最多需要多少第j种资源
>
> （3） 分配矩阵Allocation，这是一个n*m的二维数组。单元Allocation[i,j]存储的是已经分配给第i个进程的第j种资源的数量
>
> （4） 需求矩阵Need，这也是一个n*m的矩阵，单元Need[i,j]存储的数值表示进程i还需要多少第j种资源的数量才能完成退出。

{% endfolding %}

我们先来看看什么是银行家算法。

{% note info simple %}

银行家算法（Banker's Algorithm）是一种用于避免死锁的**资源**分配和**安全**性算法，主要应用于操作系统中管理多个**进程**对资源的请求。它由艾兹赫尔·戴克斯特拉（Edsger Dijkstra）在1970年提出。

{% endnote %}

关于算法定义中几个重要的概念，有必要阐明如下：

1. 资源：即系统中可以被多个进程共享的资源，如 CPU 时间、内存、I/O 设备等，题目中往往以A、B等字母代指。
2. 进程：在系统中执行的任务，每个进程可能需要一定数量的资源。
3. 安全状态：如果系统能分配资源给所有进程，使得每个进程都能在有限时间内完成执行，则称系统处于安全状态，可以保证安全状态的系统不会发生死锁。
4. 不安全状态：如果无法为所有进程找到一种资源分配方式，使其完成，则系统处于不安全状态，可能会导致死锁。

银行家算法通过模拟资源分配的过程来判断是否能够安全地满足进程的请求。它的核心思想是：{% span red, 在每次资源请求时，算法会检查请求后的系统状态是否仍然安全 %}。

具体来说，它的主要步骤如下。注意，在阅读银行家算法的内容时，确保你已经熟悉了该算法所用到的四种数据结构。你可以在该题的实验提示中找到详细内容。

#### 主要步骤

当进程向系统请求资源时：

- 首先，系统会检查该请求是否小于或等于其最大需求与当前可用资源。如果结果为否，说明进程请求了超出其需求的资源，或者当前可用资源不足以分配给该进程，撤销请求；否则，继续第二步。
- 第二，系统将进行试探性分配。即暂时分配资源，并更新系统的{% bubble 可用资源,"Available" ,"#868fd7" %}、{% bubble 分配矩阵,"Allocation" ,"#868fd7" %}和{% bubble 需求矩阵,"Need" ,"#868fd7" %}。
- 第三，进行安全性检查。系统将使用安全性算法检查系统是否仍然处于安全状态，安全性算法将找到一个安全序列，按照该序列的顺序来执行进程，将使得所有进程都能够进行完成。
- 最后，系统将决定是否分配资源。如果系统仍然处于安全状态，则实际分配资源给该进程；如果系统不安全，则拒绝该请求，进程需要等待。

总的来说，银行家算法的核心步骤就是**试探**，通过校验分配资源后的系统是否仍然处于安全状态，来保证系统始终在安全状态，以达到彻底预防死锁的目的。试探的核心在于检验，这依赖于安全性算法。安全性算法的介绍如下。

#### 安全性算法

这里我直接引用《操作系统概念(原书第9版)》书中的定义，我觉得原书中给出的定义非常清晰，有条件的读者可以直接阅读原本。安全性算法的描述如下：

{% note info simple %}

约定：当且仅当对所有的$i=1,2,...,n$，有$X[i]≤Y[i]$，则我们称$X≤Y$。

{% endnote %}

1. 令 Work 和 Finish 分别为长度m和n的向量。对于$i=0,1,…,n-1$，初始化 Work = Available 和 Finish[i] = false。

2. 查找这样的 i 使其满足

   - Finish[i] == false
   - Need~i~ ≤ Work

   如果没有这样的 i 存在，那么就转到第4步。

3. Work = Work + Allocation~i~
   Finish[i] = true
   返回到第2步。

4. 如果对所有 i，Finish[i] = true，那么系统处于安全状态

这个算法可能需要$m\times n^2$数量级的操作，以确定系统状态是否安全。这个数量级还是比较大的，在进程和资源比较多的情形下检测死锁的费用将不可接受。所以银行家算法往往只能运用在小型系统上。

#### 资源请求算法

事实上，题目只要求实现了安全型算法检验，但完整的银行家算法包含了安全型算法和资源请求算法。为了知识完整性，这里给出资源请求算法的拓展资料。

![image-20241105194209274](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241105194209274.png?x-oss-process=style/blog)

完整的代码如下：

{% folding cyan, 查看完整代码 %}

~~~c
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#define PROCESS_NUM 5 // n
#define RESOURCE_NUM 3 // m

int Available[RESOURCE_NUM];
int Max[PROCESS_NUM][RESOURCE_NUM];
int Allocation[PROCESS_NUM][RESOURCE_NUM];
int Need[PROCESS_NUM][RESOURCE_NUM];
int SafeSequence[PROCESS_NUM];

void init(void);
int is_safe(void);
void banker(void);

int main(void){
    init();

    banker();

    return 0;
}

void init(void){
    srand((unsigned)time(NULL));

    // Generate available resources
    printf("Initial available:\n");
    for (int i=0;i<RESOURCE_NUM;i++){
        Available[i] = rand()%10+1;
        printf("%d ",Available[i]);
    }
    printf("\n\n");

    // Generate max need of each process
    printf("Max:\n");
    for (int i=0;i<PROCESS_NUM;i++){
        printf("P%d: ",i);
        for (int j=0;j<RESOURCE_NUM;j++){
            Max[i][j]=rand()%Available[j]+1;
            printf("%d ",Max[i][j]);
        }
        printf("\n");
    }
    printf("\n");

    // Generate initial allocated matrix
    printf("Allocated:\n");
    int tmp_allocated[RESOURCE_NUM]={0};
    for(int i=0;i<PROCESS_NUM;i++){
        printf("P%d: ",i);
        for (int j=0;j<RESOURCE_NUM;j++){
            if (tmp_allocated[j]<Available[j]){
                int rand_num=rand()%2;
                if (rand_num==1){
                    int allocated_resource = rand()%Max[i][j]+1;
                    while (tmp_allocated[j]+allocated_resource>Available[j])
                        allocated_resource--;
                    Allocation[i][j]=allocated_resource;
                    tmp_allocated[j]+=allocated_resource;
                }else Allocation[i][j]=0;
            }else{
                Allocation[i][j]=0;
            }
            printf("%d ",Allocation[i][j]);
        }
        printf("\n");
    }

    // Generate Need matrix
    for (int i=0;i<PROCESS_NUM;i++){
        for (int j=0;j<RESOURCE_NUM;j++){
            Need[i][j]=Max[i][j]-Allocation[i][j];
        }
    }

    // Calculate Available
    printf("Available:\n");
    for (int i=0;i<RESOURCE_NUM;i++){
        Available[i]-=tmp_allocated[i];
        printf("%d ",Available[i]);
    }
    printf("\n\n");
}

int is_safe(void){
    int Work[RESOURCE_NUM];
    int Finish[PROCESS_NUM]={0};
    int index=0;

    // Load and Display Work
    printf("Work:\n");
    for (int i=0;i<RESOURCE_NUM;i++){
        Work[i]=Available[i];
        printf("%d ",Work[i]);
    }
    printf("\n\n");

    //Dispaly Need
    printf("Need:\n");
    for (int i=0;i<PROCESS_NUM;i++){
        printf("P%d: ",i);
        for (int j=0;j<RESOURCE_NUM;j++){
            printf("%d ",Need[i][j]);
        }
        printf("\n");
    }
    printf("\n");

    int found_process = 0;
    while(found_process!=PROCESS_NUM){
        /*
        try to find a process which satisfy:
            a. Finish[i] == false
            b. Need_i <= Work 
        */
        found_process = 0;
        for (int i=0;i<PROCESS_NUM;i++){
            // check if Finish[i] == false
            if(Finish[i]==0){
                // check if Work < Need
                int NeedBiggerThanWork = 0;
                for (int j=0;j<RESOURCE_NUM;j++){
                    if (Need[i][j]>Work[j]){
                        NeedBiggerThanWork++;
                    }
                }
                if (NeedBiggerThanWork){
                    // Need_i > Work, continue finding
                    found_process++;
                    continue;
                }else{
                    // Work = Work + Allocation_i
                    for (int j=0;j<RESOURCE_NUM;j++){
                        Work[j]+=Allocation[i][j];
                    }

                    Finish[i]=1;
                    SafeSequence[index++]=i;
                    // return to find process
                    break;
                }
            }else{
                // Finish[i] == true
                found_process++;
            }
        }
    }

    // Check Finish
    int finish=0;
    for (int i=0;i<PROCESS_NUM;i++){
        if(Finish[i]==0) finish++;
    }
    if(finish==0)
        return 1; // is safe
    else
        return 0; // not safe
}

void banker(void){
    if (is_safe()){
        printf("Safe Sequence: ");
        for (int i=0;i<PROCESS_NUM;i++){
            printf("P%d ",SafeSequence[i]);
        }
        printf("\n");
    }else{
        printf("Deadlock!\n");
    }
}
~~~

{% endfolding %}

运行部分结果如下：

{% tabs deadlock %}

<!-- tab 输出安全序列 -->

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241105194812979.png?x-oss-process=style/blog" alt="image-20241105194812979" style="zoom:80%;" />

<!-- endtab -->

<!-- tab 死锁 -->

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241105194837814.png?x-oss-process=style/blog" alt="image-20241105194837814" style="zoom:80%;" />

<!-- endtab -->

{% endtabs %}

## Ex-Lab

主存储器是计算机系统中最核心的部件之一，它是系统程序、应用程序、数据等的物理存储场所。而内存管理是现代操作系统中最核心的功能，它负责为需要运行的系统程序、应用程序来分配物理存储空间，以及当程序结束时回收存储空间。早期的操作系统采用动态连续分区方法来进行内存分配，目前操作系统都采用离散分区分配方式。伙伴系统(Buddy System)是比较流行的内存分区分配算法，它的优点是产生的内存碎片少，方便了内存的管理，因此被大部分的主流操作系统采用。虚拟存储器管理是计算机系统中最核心的功能，而请求分页式系统是虚拟存储器管理中用得最多的内存管理方式，涉及请求分页机制、缺页中断处理机制、页面置换机制等。其中，页面转换策略的好坏直接影响了操作系统的性能和系统的运行效率。本次课程设计的目的如下：

1. 理解连续动态分区分配方法的原理。
2. 能够用高级程序语言来实现动态分区分配的FF算法、NF算法
3. 理解和掌握伙伴系统(Buddy System)的工作原理。
4. 用高级程序语言实现伙伴系统(Buddy System)，进行内存分区分配。
5. 理解和掌握最常用的LRU页面置换算法的工作原理。
6. 能够使用高级程序语言实现LRU页面置换算法。

### Q1

> **设计任务：**
>
> 假设内存总大小为1024，开始地址为0，结束地址为1023。有10个进程，它们所需要的内存大小随机在[100,200]之间产生。从第1个进程开始，使用指定的分区分配算法来依次为进程分配内存分区；如果还有足够大的空闲分区，则给该进程进行分配，并更新空闲分区链表。当对一块空闲分区进行划分时，在这块空闲分区的地址范围内随机产生一个划分的开始位置，然后划分出当前进程大小的分区。如果没有足够大的空闲分区，则提示内存分配失败，然后继续为下一个进程分配空闲内存分区，直到10个进程都处理完毕。
>
> 10个进程处理完内存分配后，执行内存回收过程。依次从第1个成功分配了内存分区的进程开始，回收其占用的内存分区，直到所有被占用的分区都回收完毕。具体要完成的设计任务包括：
>
> 1. 实现动态分区分配的首次适应算法(FF)
> 2. 实现动态分区分配的循环首次适应算法(NF)
>
> **要求：**
>
> 1. 在内存分配过程中，输出每一次内存分配结果：即成功还是失败，还有空闲/占用分区块情况；
> 2. 在内存回收过程中，输出每一次内存回收后的结果：即空闲/占用分区块情况。

动态分区分配是非常简单与基础的内存分配思想。它没有什么花里胡哨的关系和定义，只是简单的找到一个足够大的空闲分区然后将其分配给进程。它的缺点也相当明显：动态分区分配会产生相当多的内存碎片，从而造成严重的内存浪费。所以现在基本没人使用它。

我们直接来介绍{% bubble 首次适应算法,"First Fit Algorithm","#ec5830" %}和{% bubble 循环首次适应算法,"Next Fit Algorithm","#ec5830" %}吧。

#### FF

FF算法的实现很简单，即每次从空闲内存块链表的头部出发进行遍历，找到一个足够大的空闲分区后将其分配给进程。然而这里也有一些细节需要注意，它的详细过程如下：

1. 从空闲分区链表的第一项开始往后遍历，找到一个足够大的空闲分区
2. 如果没找到，则提示内存分配失败，接着继续为下一个进程分配内存
3. 如果找到了，则给该进程分配，并更新空闲分区链表
4. 当对一块空闲分区进行划分时，
    在这块空闲分区的地址范围内随机产生一个划分的开始位置，
    然后划分出当前进程大小的分区
    划分空闲分区会产生三个或两个块（当划分开始位置是空闲块起始位置或者终止位置与空闲块终止位置重合时）。

要实现FF算法逻辑的代码很简单，实现如下：

~~~c
void FF(PCB* pcb){
    Block* current = freeList;

    while (current)
    {
        if (current->status && current->size >= pcb->neededMem){
            allocate_memory(pcb,current);
            return;
        }
        current = current->next;
    }
    printf("Cannot allocate memory for process #%d\n",pcb->pid);
}
~~~

这里`allocate_memory(pcb,current)`函数代表对给定的进程块和内存块进行内存划分，它的具体实现我们在后面介绍。

#### NF

NF的实现也不难，它和FF的区别只在于：每次不是从头开始检索空闲内存块，而是从上一次分配的地方开始检索。

要实现这个特性，我们需要记录上一次划分内存块的位置，并且每次都从这里出发进行检索。在编程中，可以借助一个悬挂的指针变量来实现。代码如下：

~~~c
void NF(PCB* pcb){
    static Block* lastAllocated = NULL;
    Block* current = lastAllocated ? lastAllocated->next : freeList;

    if(!current) current = freeList;

    for (int i = 0; i<PROCESS_NUM; i++){
        if (current->status && current->size >= pcb->neededMem){
            allocate_memory(pcb,current);
            lastAllocated = current;
            return;
        }
        current = current->next;
        if(!current) current = freeList;
    }
    printf("Cannot allocate memory for process #%d\n",pcb->pid);
}
~~~

#### allocate_memory

在这个问题中最复杂的部分反而是内存划分函数，因为根据划分位置的不同，最后有可能产生两个或三个块，需要具体分情况讨论；并且最终产生的多个块中，需要仔细更新其指针关系，以维护空闲内存分区双向链表地点数据结构。

这里我们定义三个指针`leftBlock`、`middleBlock`、`rightBlock`，分别对应位于分配内存块左边的块、分配给进程的内存块与位于分配内存块右边的内存块。

具体实现如下：

~~~c
void allocate_memory(PCB* pcb, Block* block){
    Block* leftBlock = NULL; // 指向被划分内存块的左侧
    Block* middleBlock = NULL; // 指向被划分的内存块
    Block* rightBlock = NULL; // 指向被划分内存块的右侧
    int startAddr = block->startAddr + rand() % (block->size - pcb->neededMem + 1); // 随机选择的起始地址

    pcb->blockID = block->id;
    pcb->status = 1;

    printf("Allocate free memory block for process #%d\n",pcb->pid);

    // 从空闲块头部开始划分
    if (startAddr == block->startAddr){
        rightBlock = create_block(block->size - pcb->neededMem, startAddr,
                                  true,-1);

        middleBlock = block;
        middleBlock->pid = pcb->pid;
        middleBlock->status = false;
        middleBlock->size = pcb->neededMem;
    } // 从空闲块尾部开始划分
    else if (startAddr + pcb->neededMem == block->startAddr + block->size){
        leftBlock = block;
        middleBlock = create_block(pcb->neededMem, startAddr,false,pcb->pid);

        leftBlock->size = block->size - pcb->neededMem;
    } // 从空闲块中部开始划分
    else {
        leftBlock = block;
        middleBlock = create_block(pcb->neededMem,startAddr,false,pcb->pid);
        rightBlock = create_block(block->startAddr + block->size - startAddr - pcb->neededMem,
                                  startAddr + pcb->neededMem,true,-1);

        leftBlock->size = startAddr - block->startAddr;
    }

    if (!leftBlock && rightBlock){
        rightBlock->prev = middleBlock;
        rightBlock->next = middleBlock->next;
        middleBlock->next = rightBlock;
    }else if (leftBlock && !rightBlock){
        middleBlock->prev = leftBlock;
        middleBlock->next = leftBlock->next;

        if (leftBlock->next) leftBlock->next->prev = rightBlock;
        leftBlock->next = middleBlock;
    }else if (leftBlock && rightBlock){
        middleBlock->prev = leftBlock;
        middleBlock->next = rightBlock;
        rightBlock->prev = middleBlock;
        rightBlock->next = leftBlock->next;

        if (leftBlock->next) leftBlock->next->prev = rightBlock;
        leftBlock->next = middleBlock;
    }

    print_memory_state();
}
~~~

#### merge_memory

与第二问一样，动态分区分配在进程结束后也需要对分配的内存块进行回收与合并，最后重新变为一块大内存块。

合并内存块的逻辑很简单，对于给定的内存释放区域，分别检测其左右内存块是否空闲，然后按照**从右到左**的顺序进行合并。注意：针对内存的合并必须要有一个确定的顺序，一般都是从右到左进行合并，以确保最后得到的内存块ID最小。如果合并顺序紊乱（比如笔者最开始是释放中间的块），就会导致指针关系混乱，空闲内存块双向链表结构被破坏。

代码实现如下：

~~~c
void merge_memory(Block* block) {
    Block* leftBlock = block->prev;
    Block* rightBlock = block->next;

    // 合并右侧空闲块
    if (rightBlock && rightBlock->status) {
        printf("Combine block id:%d (size: %d) with id:%d (size: %d)\n",
               block->id, block->size, rightBlock->id, rightBlock->size);

        block->size += rightBlock->size;
        block->next = rightBlock->next;

        if (rightBlock->next) {
            rightBlock->next->prev = block;
        }

        free(rightBlock);
    }

    // 合并左侧空闲块
    if (leftBlock && leftBlock->status) {
        printf("Combine block id:%d (size: %d) with id:%d (size: %d)\n",
               leftBlock->id, leftBlock->size, block->id, block->size);

        leftBlock->size += block->size;
        leftBlock->next = block->next;

        if (block->next) {
            block->next->prev = leftBlock;
        }

        free(block);
    }
}
~~~

#### Dynamic partition allocation

最终实现完整版代码如下：

{% folding cyan, 查看完整代码 %}

{% tabs Dynamic_partition_allocation,3 %}
<!-- tab 头文件q1.h -->

```c
# ifndef Q1_H
# define Q1_H

# include <stdio.h>
# include <stdlib.h>
# include <stdbool.h>
# include <time.h>
# define MEMORY_SIZE 1024
# define PROCESS_NUM 10

typedef struct Block {
    int id;               // 分区序号
    int size;            // 分区大小
    int startAddr;        // 分区起始地址
    bool status;          // true为空闲，false为占用
    int pid;              // 占用进程id, -1表示空闲
    struct Block *prev;   // 指向前一块内存分区
    struct Block *next;   // 指向后一块内存分区
} Block;

typedef struct PCB {
    int pid;              // 进程序号
    int neededMem;        // 需要的内存分区大小（2^neededMem）
    int status;           // 1：成功；-1：失败
    int blockID;          // 占用分区id，-1表示失败
    struct PCB *next;     // 指向下一个PCB
} PCB;

typedef struct PCBQueue {
    PCB* front;
    PCB* rear;
} PCBQueue;

Block* create_block(int size, int startAddr, bool status, int pid);
PCB* create_pcb(int pid, int neededMem);
PCBQueue* create_pcb_queue(void);
void initialize_memory(void);
void initialize_process(void);
void print_memory_state(void);
void print_pcb_queue(void);
void FF(PCB* pcb);
void NF(PCB* pcb);
void allocate_memory(PCB* pcb, Block* block);
void merge_memory(Block* block);
void free_memory(int pid);
int is_empty_queue(PCBQueue *Q);
void enqueue(PCBQueue* Q, PCB* pcb);
PCB* dequeue(PCBQueue* Q);
void delete_memory(void);
void delete_queue(PCBQueue* Q);
void test_case_a(void);
void test_case_b(void);

# endif
```

<!-- endtab -->

<!-- tab 函数定义q1f.c -->

```c
# include "q1.h"

Block *freeList = NULL;
PCBQueue *pcbQueue = NULL;
int global_block_id = 1; // 全局id计数器

/*创建一个内存块，确定内存块的：
    1.id 根据全局id计数器分配得到一个唯一id
    2.size 内存块的大小
    3.startAddr 由父内存块的地址加上size得到
    4.status 刚创建时默认为空闲，即true
    5.pid 初始时默认为空闲，即-1
    6.prev 指向前一块内存块
    7.next 指向后一块内存块
*/
Block* create_block(int size, int startAddr, bool status, int pid){
    Block* new_block = (Block*)malloc(sizeof(Block));
    new_block->id = global_block_id++;
    new_block->size = size;
    new_block->startAddr = startAddr;
    new_block->status = status;
    new_block->pid = pid;
    new_block->prev = NULL;
    new_block->next = NULL;

    return new_block;
}

/*
创建一个进程，确定进程的：
    1.pid 进程的序号
    2.neededMem 进程所需要的内存空间大小
    3.status 进程的状态，刚创建时默认未分配内存，即-1
    4.blockID 表示进程占用的内存块序号，初始化为未占用，即-1
    5.next 指向下一个进程，初始化为NULL
*/
PCB* create_pcb(int pid, int neededMem){
    PCB* new_pcb = (PCB*)malloc(sizeof(PCB));
    new_pcb->pid = pid;
    new_pcb->neededMem = neededMem;
    new_pcb->status = -1;
    new_pcb->blockID = -1;
    new_pcb->next = NULL;

    return new_pcb;
}

/*
创建pcb队列
*/
PCBQueue* create_pcb_queue(void){
    PCBQueue* Q = (PCBQueue*)malloc(sizeof(PCBQueue));

    Q->front = Q->rear =NULL;
    return Q;
}

/*
初始化内存块为一块大内存，容量为1024kb
*/
void initialize_memory(void){
    freeList = create_block(MEMORY_SIZE, 0, true, -1);
    freeList->prev = freeList->next = NULL;
}

/*
初始化进程，创建PROCESS_NUM个进程并加入PCB进程队列
*/
void initialize_process(void){
    PCB* temp;
    int random_memory;
    for (int i = 1; i <= PROCESS_NUM; i++){
        random_memory = rand() % 101 + 100;
        temp = create_pcb(i,random_memory);
        enqueue(pcbQueue,temp);
    }
}

/*
打印内存状态
*/
void print_memory_state(void){
    Block* current = freeList;
    while(current){
        if (current->status) {
            printf("free block id: %d, size: %d, startAddr: %d\n",
                   current->id,current->size,current->startAddr);
        }else {
            printf("used block id: %d, size: %d, startAddr: %d, pid: %d\n",
                   current->id,current->size,current->startAddr,current->pid);
        }
        current = current->next;
    }
    printf("\n");
}

/*
打印进程状态
*/
void print_pcb_queue(void){
    PCB* current = pcbQueue->front;

    printf("PCB Queue State:\n");
    while (current){
        printf("#%d neededMem:%d\n",current->pid,current->neededMem);
        current = current->next;
    }
    printf("\n");
}

/*
用首次适应算法为给定的进程分配内存：
    1. 从空闲分区链表的第一项开始往后遍历，找到一个足够大的空闲分区
    2. 如果没找到，则提示内存分配失败，接着继续为下一个进程分配内存
    3. 如果找到了，则给该进程分配，并更新空闲分区链表
    4. 当对一块空闲分区进行划分时，
       在这块空闲分区的地址范围内随机产生一个划分的开始位置，
       然后划分出当前进程大小的分区
划分空闲分区会产生三个或两个块（当划分开始位置是空闲块起始位置或者终止位置与空闲块终止位置重合时）。
*/
void FF(PCB* pcb){
    Block* current = freeList;

    while (current)
    {
        if (current->status && current->size >= pcb->neededMem){
            allocate_memory(pcb,current);
            return;
        }
        current = current->next;
    }
    printf("Cannot allocate memory for process #%d\n",pcb->pid);
}

/*
用循环首次适应算法为给定的进程分配内存
区别在于，每次不是从头开始检索空闲内存块，而是从上一次分配的地方开始检索
*/
void NF(PCB* pcb){
    static Block* lastAllocated = NULL;
    Block* current = lastAllocated ? lastAllocated->next : freeList;

    if(!current) current = freeList;

    for (int i = 0; i<PROCESS_NUM; i++){
        if (current->status && current->size >= pcb->neededMem){
            allocate_memory(pcb,current);
            lastAllocated = current;
            return;
        }
        current = current->next;
        if(!current) current = freeList;
    }
    printf("Cannot allocate memory for process #%d\n",pcb->pid);
}

/*
给定进程块和要分配的blockID，将在该空闲内存块上划分内存分配给进程；
并且更新内存块和PCB的信息
*/
void allocate_memory(PCB* pcb, Block* block){
    Block* leftBlock = NULL; // 指向被划分内存块的左侧
    Block* middleBlock = NULL; // 指向被划分的内存块
    Block* rightBlock = NULL; // 指向被划分内存块的右侧
    int startAddr = block->startAddr + rand() % (block->size - pcb->neededMem + 1); // 随机选择的起始地址

    pcb->blockID = block->id;
    pcb->status = 1;

    printf("Allocate free memory block for process #%d\n",pcb->pid);

    // 从空闲块头部开始划分
    if (startAddr == block->startAddr){
        rightBlock = create_block(block->size - pcb->neededMem, startAddr,
                                  true,-1);

        middleBlock = block;
        middleBlock->pid = pcb->pid;
        middleBlock->status = false;
        middleBlock->size = pcb->neededMem;
    } // 从空闲块尾部开始划分
    else if (startAddr + pcb->neededMem == block->startAddr + block->size){
        leftBlock = block;
        middleBlock = create_block(pcb->neededMem, startAddr,false,pcb->pid);

        leftBlock->size = block->size - pcb->neededMem;
    } // 从空闲块中部开始划分
    else {
        leftBlock = block;
        middleBlock = create_block(pcb->neededMem,startAddr,false,pcb->pid);
        rightBlock = create_block(block->startAddr + block->size - startAddr - pcb->neededMem,
                                  startAddr + pcb->neededMem,true,-1);

        leftBlock->size = startAddr - block->startAddr;
    }

    if (!leftBlock && rightBlock){
        rightBlock->prev = middleBlock;
        rightBlock->next = middleBlock->next;
        middleBlock->next = rightBlock;
    }else if (leftBlock && !rightBlock){
        middleBlock->prev = leftBlock;
        middleBlock->next = leftBlock->next;

        if (leftBlock->next) leftBlock->next->prev = rightBlock;
        leftBlock->next = middleBlock;
    }else if (leftBlock && rightBlock){
        middleBlock->prev = leftBlock;
        middleBlock->next = rightBlock;
        rightBlock->prev = middleBlock;
        rightBlock->next = leftBlock->next;

        if (leftBlock->next) leftBlock->next->prev = rightBlock;
        leftBlock->next = middleBlock;
    }

    print_memory_state();
}

/*
合并空闲的内存:
    1. 检查其左右内存块是否可以用于合并
    2. 对于空闲的左内存块，更改其sizeK
    3. 对于空闲的右内存块，更改其startAddr与sizeK
    4. 更改指针关系
    5. 释放内存
*/
void merge_memory(Block* block) {
    Block* leftBlock = block->prev;
    Block* rightBlock = block->next;

    // 合并右侧空闲块
    if (rightBlock && rightBlock->status) {
        printf("Combine block id:%d (size: %d) with id:%d (size: %d)\n",
               block->id, block->size, rightBlock->id, rightBlock->size);

        block->size += rightBlock->size;
        block->next = rightBlock->next;

        if (rightBlock->next) {
            rightBlock->next->prev = block;
        }

        free(rightBlock);
    }

    // 合并左侧空闲块
    if (leftBlock && leftBlock->status) {
        printf("Combine block id:%d (size: %d) with id:%d (size: %d)\n",
               leftBlock->id, leftBlock->size, block->id, block->size);

        leftBlock->size += block->size;
        leftBlock->next = block->next;

        if (block->next) {
            block->next->prev = leftBlock;
        }

        free(block);
    }
}


/*
给定进程的pid，释放该进程及分配给它的内存块。
    对于进程：不变
    对于内存块：更改status、pid属性，并调用合并内存块
*/
void free_memory(int pid){
    Block* current = freeList;

    while (current)
    {
        if (current->pid == pid){
            current->status = true;
            current->pid = -1;
            printf("Recycle used memory block for process #%d of size %d...\n",
                   pid,current->size);
            merge_memory(current);
            print_memory_state();
            return;
        }
        current = current->next;
    }
    printf("Cannot free memory for process #%d\n",pid);
}

/*
判断当前进程队列是否为空
*/
int is_empty_queue(PCBQueue *Q){
    return Q->front==NULL;
}

/*
将进程加入进程队列
*/
void enqueue(PCBQueue* Q, PCB* pcb){
    if (Q->rear) Q->rear->next = pcb;

    Q->rear = pcb;

    if (Q->front == NULL) Q->front = Q->rear;
}

/*
将进程从队列中出队
*/
PCB* dequeue(PCBQueue* Q){
    if (is_empty_queue(Q)){
        printf("PCB Queue is Empty!\n");
        return NULL;
    }else{
        PCB* temp = Q->front;
        Q->front = Q->front->next;
        return temp;
    }
}

/*
测试函数，用于测试FF算法。
*/
void test_case_a(void){
    pcbQueue = create_pcb_queue();
    initialize_memory();
    initialize_process();
    srand(time(NULL));

    print_pcb_queue();

    while(!is_empty_queue(pcbQueue)){
        PCB* pcb = dequeue(pcbQueue);
        FF(pcb);
        free(pcb);
    }

    for (int i = 1; i <= PROCESS_NUM; i++)
    {
        free_memory(i);
    }

    delete_memory();
    delete_queue(pcbQueue);
}

/*
测试函数，用于测试NF算法。
*/
void test_case_b(void){
    pcbQueue = create_pcb_queue();
    initialize_memory();
    initialize_process();
    srand(time(NULL));

    print_pcb_queue();

    while(!is_empty_queue(pcbQueue)){
        PCB* pcb = dequeue(pcbQueue);
        NF(pcb);
        free(pcb);
    }

    for (int i = 1; i <= PROCESS_NUM; i++)
    {
        free_memory(i);
    }

    delete_memory();
    delete_queue(pcbQueue);
}

/*
删除内存分配的空间
*/
void delete_memory(void){
    Block *temp = freeList;
    freeList->next = NULL;
    free(temp);
}

/*
删除PCB进程队列
*/
void delete_queue(PCBQueue* Q){
    PCB* temp;
    while (Q->front){
        temp = Q->front;
        Q->front = Q->front->next;
        free(temp);
    }
    free(Q);
}
```

<!-- endtab -->

<!-- tab 主函数q1.c -->

```c
# include "q1.h"

/*
运行test_case_a()即FF算法
运行test_case_b()即NF算法
*/
int main(void){
    test_case_a();
    // test_case_b();

    return 0;
}
```

<!-- endtab -->
{% endtabs %}

{% endfolding %}

最终运行部分结果如下：

{% tabs Dynamic_partition_allocation_result %} 

<!-- tab 内存分配 -->

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241127102405420.png?x-oss-process=style/blog" alt="image-20241127102405420" style="zoom: 67%;" />

<!-- endtab -->

<!-- tab 内存回收 -->

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241127102443532.png?x-oss-process=style/blog" alt="image-20241127102443532" style="zoom: 67%;" />

<!-- endtab -->

{% endtabs %}

值得注意的是，由于动态分区分配法产生的内存碎片过多，经多次测试大约会有一半的进程根本无法分配到内存。上图中我展示的测试用例是有三个进程未能得到内存分配，其实已经算运气非常好了。

### Q2

> **设计任务：**
>
> 假设内存总大小为2^10^=1024，开始地址为0，结束地址为1023,在系统初始时，整个内存是1块空闲内存分区，大小为2^10^=1024。有n个进程需要分配内存空间。使用伙伴系统(Buddy System)算法来依次为这n个进程分配内存。当内存分配完毕之后，再将分配的这n个空闲分区块进行合并回收，最后得到1整块大的空闲分区，其大小为2^10^=1024。具体要完成的设计任务为编程实现Buddy System算法来完成以下两个内存分配和回收问题：
>
> 1. 假设n=3,即有3个进程，第1个进程申请的内存大小为2^7^,第2个进程申请的内存大小为2^4^，第3个进程申请的内存大小为2^8^；
> 2. 假设有n=8个进程，每个进程所申请的内存块大小为2^k^，其中k为随机整数，在[3,8]间产生。
>
> **要求：**
>
> 1. 在内存分配过程中，输出每一次内存分配结果，即空闲/占用分区块情况；
> 2. 在内存回收过程中，输出每一次内存回收后的结果：即空闲/占用分区块情况；
> 3. 在每一次对分区块进行划分/合并的时候，输出相应的划分/合并信息。

我们首先来简单的介绍一下什么是伙伴系统，其实它的原理相当简单。

伙伴系统是一种基于**二进制划分**的内存分配算法。它将内存划分成大小为 2 的幂次的块（如 1KB、2KB、4KB 等）。当需要分配内存时，系统会找到一个合适大小的块，将其分配给请求方；如果需要的块比当前块小，系统会将块对半拆分，直到满足需求为止。

它的具体工作原理如下：

1. 初始化：
   - 假设内存大小为 2^n^，系统将内存看作一个整体的大块。这块内存可以被不断对半分裂，形成伙伴块（即大小相等的两块）
2. 分配内存：
   - 进程请求内存，伙伴系统会根据进程所请求的内存大小，找到**最小的满足请求的内存块**。
   - 如果该内存块过大，则对其进行分裂，直到块大小接近但不小于请求大小。
   - 被分配的块标记为“已使用”。这样，下一个进程请求内存时，伙伴系统将不会把被标记为已使用的内存块分配给它。
3. 释放内存：
   - 当内存块被释放时，系统尝试找到该块的伙伴块（大小相等且地址连续的块）。
   - 如果伙伴块也未被使用，两者会合并成更大的块，形成新的伙伴关系。
   - 合并操作会递归进行，直到无法再合并为止。

伙伴系统概念图如下所示：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%E4%BC%99%E4%BC%B4%E7%B3%BB%E7%BB%9F%E6%A6%82%E5%BF%B5%E5%9B%BE.drawio.png?x-oss-process=style/blog" alt="伙伴系统概念图.drawio" style="zoom:67%;" />

简单来说，可以把伙伴系统划分为两个过程：

- 分配内存时，首先找到一块内存比进程要求的大小更大的内存块，然后对它切切切，直到二分到**再分一次就不足以满足进程要求为止**，也就是处于所谓的“临界区”。切割内存的过程中，分出的另一个双胞胎内存块就是它的**伙伴**。最后，把这一个满足要求的最小内存块分配给进程。
- 释放内存时，检查该内存的伙伴块是否也是空闲状态。如果是空闲状态，则一路向上合体，**直到另一个伙伴此时正在忙或者没有伙伴与自己合并，即还原成初始的一块大内存块**时停止合并。

这个过程说起来很简单，但还需要注意一些细节。我们把过程当中的几个关键部分抽象出来编写成函数，然后再完善一下其他的逻辑就可以完成本次实验了。经过整理，我们大致可以把伙伴系统的实现抽象成以下这么几个函数：

- `find_free_block` 为给定的进程找到一块合适的内存块，只需要该内存块的内存大小大于进程的要求即可。
- `split_block` 分割内存块，直到形成满足要求的最小内存块。
- `merge_blocks` 合并内存块，递归向上合并直到无法合并为止。

大体来说，伙伴系统的实现就依赖于这上面的三个函数操作：寻找内存块、分割内存块、合并内存块。我们详细介绍这三个函数的实现，伙伴系统便描述的差不多了。

#### find_free_block

寻找合适的内存块很好实现，我们只需要遍历存储内存块的**双向链表**，找到满足内存大于进程请求内存以及未被分配的内存块即可。

实现的代码如下：

~~~c
Block* find_free_block(int sizeK){
    Block* current = freeList;
    while(current){
        if (current->sizeK >= sizeK && current->status) return current;
        else current = current->next;
    }

    return NULL;
}
~~~

#### split_block

切割内存块，即将给定的内存块分割为两个新的内存块，大小为原内存块的一半。这个过程中，会产生左伙伴和右伙伴（想象一下把一个矩形分为两半，左伙伴就是左边的那个新矩形，右伙伴就是右边那个）。

在这里我们要做两件事，一是额外创建一个内存块结构体用于保存新产生的右伙伴（左伙伴可以沿用分割前的原内存块）；二是更改存储内存块的双向链表的指针连接方式，将新产生的右伙伴加入到链表中。

维护一个新的结构体保存左右伙伴信息很简单，左伙伴的原数据可以直接继承父内存块，只需要将内存减半即可；右伙伴除了需要改动内存大小，起始地址也需要改变，即左伙伴的起始地址加上左伙伴的内存大小。

将新产生的右伙伴加入到双向链表中，本质上就是链表的插入问题，这里不多赘述。

实现的代码如下：

~~~c
void split_block(Block* block){
    Block* new_block;
    int half_sizeK = block->sizeK - 1;
    new_block = create_block(half_sizeK,
                             block->startAddr + (1 << half_sizeK),
                             true, -1);
    new_block->prev = block;
    new_block->next = block->next;

    if (block->next){
        block->next->prev = new_block;
    }
    block->sizeK = half_sizeK;
    block->next = new_block;
    printf("Split block id: %d, size: 2^%d, startAddr: %d\n",
           block->id,block->sizeK,block->startAddr);
}
~~~

#### merge_blocks

合并内存块的操作也许是伙伴系统中最为复杂的部分了，不过也不难。详细来说，合并内存块主要有两个步骤：

1. 找到内存块的伙伴，这里假设我们有一个函数`find_buddy`能够找到指定内存块的伙伴。
2. 向上合并直到无法合并为止。

合并操作几乎是切割操作的逆向，我们把内存块的内存扩大一倍，然后释放掉其伙伴，就完成了合并操作。但是这么做的前提是：{% span red,我们默认操作的总是左伙伴块 %}。道理很简单，因为左伙伴块的起始地址更低，我们扩大内存时不需要改动其起始地址；倘若操作的是右伙伴块，则还需要重新计算其起始地址，更加麻烦。所以，我们默认操作的都是左伙伴块。

至于**向上合并直到无法合并为止**：本质上就是每执行一次合并操作，立即退回到内存块双向链表的头部重新开始遍历内存块，检测是否可以进行合并操作。这部分用递归或者迭代实现都可以。用递归实现有容易栈溢出的风险，但是写起来很简单；用迭代实现，则需要额外加一个变量来记录当前循环中是否发生了合并操作作为退出迭代的条件。这里采用递归实现：

~~~c
void merge_blocks(void){
    Block* current = freeList;
    while(current){
        Block* buddy = find_buddy(current);
        // 确保伙伴存在、伙伴为空闲、当前块为空闲，方可进行合并
        if (!buddy || !buddy->status || !current->status){
            current = current->next;
            continue;
        }

        // 如果找到的伙伴块是左伙伴块，则交换指针指向的对象，确保释放的一直是右伙伴块
        if (current->startAddr > buddy->startAddr){
            Block* temp = current;
            current = buddy;
            buddy = temp;
        }

        current->sizeK++;
        current->next = buddy->next;
        if (buddy->next) buddy->next->prev = current;
        free(buddy); // 释放伙伴块
        merge_blocks(); // 递归，尝试向上合并
        return; // 防止链表结构变化后指针失效，直接返回。
    }
}
~~~

接下来我们讲讲如何实现`find_buddy`函数，这部分很有意思。

##### find_buddy

**伙伴**的定义是和当前内存块大小相同且地址连续的内存块，当然，最重要的是内存块和其伙伴是由同一个父内存块划分而来。所以，左右伙伴的起始地址之间存在一个计算公式。
$$
startAddr_{\text{右伙伴}}=startAddr_{\text{左伙伴}} + sizeK_{\text{左伙伴}}
$$
所以，给定一个内存块，我们可以通过计算其伙伴块的地址，来定位到它的伙伴块。

但是这里有一个问题：我们怎么知道，内存块的伙伴是左伙伴还是右伙伴呢？在伙伴关系不确定的前提下，我们根本不知道是用当前伙伴块的地址加上其内存大小还是减去其内存大小。

这一点可以用**异或**运算来巧妙地解决。
$$
startAddr_{\text{伙伴}}=startAddr_{\text{当前内存块}} \oplus (1 \ll sizeK_{\text{当前内存块}})
$$
假设块大小为 `sizeK`，那么 `1 << sizeK` 对应的是一个二进制数，其第 `sizeK` 位是 `1`，低于 `sizeK` 的位是 `0`。

异或（`^`）操作会把第 `sizeK` 位翻转：

- 如果 `startAddr` 是块对的前半部分地址（低位块），翻转后就变成后半部分地址（高位块）。
- 如果 `startAddr` 是块对的后半部分地址（高位块），翻转后就变成前半部分地址（低位块）。

XOR 操作具有对称性：`a ^ b ^ b = a`，因此不管当前块是前半部分还是后半部分，用 XOR 都能得到正确的伙伴地址。

所以我们的`find_buddy`函数可以实现如下：

~~~c
Block* find_buddy(Block* block){
    int buddy_start = block->startAddr ^ (1 << block->sizeK);
    Block* current = freeList;
    while (current)
    {
        if (current->startAddr == buddy_start && current->sizeK == block->sizeK) return current;
        current = current->next;
    }

    return NULL;
}
~~~

#### buddy system

综上所述，伙伴系统的实现全部代码如下。

{% folding cyan, 查看完整代码 %}

{% tabs buddy_system,3 %}
<!-- tab 头文件q2.h -->

```c
// 2.h
# ifndef Q2_H
# define Q2_H

# include <stdio.h>
# include <stdlib.h>
# include <stdbool.h>
# include <time.h>
# define MEMORY_SIZE 10
# define PROCESS_NUM 8

typedef struct Block {
    int id;               // 分区序号
    int sizeK;            // 分区大小，以2^sizeK表示
    int startAddr;        // 分区起始地址
    bool status;          // true为空闲，false为占用
    int pid;              // 占用进程id, -1表示空闲
    struct Block *prev;   // 指向前一块内存分区
    struct Block *next;   // 指向后一块内存分区
} Block;

// 定义进程PCB结构体
typedef struct PCB {
    int pid;              // 进程序号
    int neededMem;        // 需要的内存分区大小（2^neededMem）
    int status;           // 1：成功；-1：失败
    int blockID;          // 占用分区id，-1表示失败
    struct PCB *next;     // 指向下一个PCB
} PCB;

typedef struct PCBQueue {
    PCB* front;
    PCB* rear;
} PCBQueue;

Block* create_block(int sizeK, int startAddr, bool status, int pid);
PCB* create_pcb(int pid, int neededMem);
PCBQueue* create_pcb_queue(void);
void initialize_memory(void);
void print_memory_state(void);
void print_pcb_queue(void);
Block* find_free_block(int sizeK);
Block* find_buddy(Block* block);
void split_block(Block* block);
void allocate_memory(PCB* pcb);
void merge_blocks(void);
void free_memory(int pid);
int is_empty_queue(PCBQueue *Q);
void enqueue(PCBQueue* Q, PCB* pcb);
PCB* dequeue(PCBQueue* Q);
void test_case_a(void);
void test_case_b(void);
void delete_memory(void);
void delete_queue(PCBQueue* Q);

# endif
```

<!-- endtab -->

<!-- tab 函数定义q2f.c -->

```c
// 2f.c
# include "q2.h"

Block *freeList = NULL;
PCBQueue *pcbQueue = NULL;
int global_block_id = 1; // 全局id计数器

/*创建一个内存块，确定内存块的：
    1.id 根据全局id计数器分配得到一个唯一id
    2.sizeK 由划分的父内存块大小右移一位得到
    3.startAddr 由父内存块的地址加上sizeK得到
    4.status 刚创建时默认为空闲，即true
    5.pid 初始时默认为空闲，即-1
    6.prev 指向前一块内存块
    7.next 指向后一块内存块
*/
Block* create_block(int sizeK, int startAddr, bool status, int pid){
    Block* new_block = (Block*)malloc(sizeof(Block));
    new_block->id = global_block_id++;
    new_block->sizeK = sizeK;
    new_block->startAddr = startAddr;
    new_block->status = status;
    new_block->pid = pid;
    new_block->prev = NULL;
    new_block->next = NULL;

    return new_block;
}

/*
创建一个进程，确定进程的：
    1.pid 进程的序号
    2.neededMem 进程所需要的内存空间大小
    3.status 进程的状态，刚创建时默认未分配内存，即-1
    4.blockID 表示进程占用的内存块序号，初始化为未占用，即-1
    5.next 指向下一个进程，初始化为NULL
*/
PCB* create_pcb(int pid, int neededMem){
    PCB* new_pcb = (PCB*)malloc(sizeof(PCB));
    new_pcb->pid = pid;
    new_pcb->neededMem = neededMem;
    new_pcb->status = -1;
    new_pcb->blockID = -1;
    new_pcb->next = NULL;

    return new_pcb;
}

/*
创建pcb队列
*/
PCBQueue* create_pcb_queue(void){
    PCBQueue* Q = (PCBQueue*)malloc(sizeof(PCBQueue));

    Q->front = Q->rear =NULL;
    return Q;
}

/*
初始化内存块为一块大内存，容量为1024kb
*/
void initialize_memory(void){
    freeList = create_block(MEMORY_SIZE, 0, true, -1);
    freeList->prev = freeList->next = NULL;
}

/*
打印内存状态
*/
void print_memory_state(void){
    Block* current = freeList;
    while(current){
        if (current->status) {
            printf("free block id: %d, size: 2^%d, startAddr: %d\n",
                   current->id,current->sizeK,current->startAddr);
        }else {
            printf("used block id: %d, size: 2^%d, startAddr: %d, pid: %d\n",
                   current->id,current->sizeK,current->startAddr,current->pid);
        }
        current = current->next;
    }
    printf("\n");
}

/*
打印进程状态
*/
void print_pcb_queue(void){
    PCB* current = pcbQueue->front;

    printf("PCB Queue State:\n");
    while (current){
        printf("#%d neededMem:%d\n",current->pid,current->neededMem);
        current = current->next;
    }
    printf("\n");
}

/*
找到一个空闲的内存块，要求内存块的大小大于给定的sizeK
*/
Block* find_free_block(int sizeK){
    Block* current = freeList;
    while(current){
        if (current->sizeK >= sizeK && current->status) return current;
        else current = current->next;
    }

    return NULL;
}

/*
给定一个内存块，找到其对应的伙伴内存块。
由于伙伴块的划分是通过对原内存块的2次幂划分得到，即存在新startAddr = 原startAddr + half_sizeK
故可由原startAddr + half_sizeK来定位其伙伴块。
由于伙伴系统的特性，这个地址可以由位运算得到
即 伙伴startAddr = 当前块startAddr ^ (1 << 当前块sizeK)
*/
Block* find_buddy(Block* block){
    int buddy_start = block->startAddr ^ (1 << block->sizeK);
    Block* current = freeList;
    while (current)
    {
        if (current->startAddr == buddy_start && current->sizeK == block->sizeK) return current;
        current = current->next;
    }

    return NULL;
}

/*
切分内存块，按照2的幂分配器对内存块进行划分
划分后的原内存块：
    1.id 原内存块的id不变
    2.sizeK 内存块大小需右移一位，即减半
    3.startAddr 父内存块的地址不变
    4.status 状态不变，由于被划分的内存块一定是空闲内存块所以一般为true
    5.pid pid不变，同上，一般为-1
    6.prev 不变
    7.next 指向被划分后的子内存块
划分后的新内存块：
    1.id 由原内存块的id+1得到
    2.sizeK 内存块大小右移一位，即减半
    3.startAddr 父内存块的地址+新的sizeK
    4.status 刚被创建属于空闲状态，故status为true
    5.pid 同上，一般为-1
    6.prev 指向被划分的原内存块
    7.next 只想原内存块的原next指向的对象
注意，如果原内存块的next对象存在，则也需要修改原next指向的对象的prev属性
使其指向新划分的内存块
*/
void split_block(Block* block){
    Block* new_block;
    int half_sizeK = block->sizeK - 1;
    new_block = create_block(half_sizeK,
                             block->startAddr + (1 << half_sizeK),
                             true, -1);
    new_block->prev = block;
    new_block->next = block->next;

    if (block->next){
        block->next->prev = new_block;
    }
    block->sizeK = half_sizeK;
    block->next = new_block;
    printf("Split block id: %d, size: 2^%d, startAddr: %d\n",
           block->id,block->sizeK,block->startAddr);
}

/*
为给定的进程分配内存，遵循伙伴系统的规则：
    1. 首先找到一块合适的内存块，要求内存块的内存大小比进程要求的内存大小大即可
    2. 然后不断地对内存块进行划分，直到内存块的大小刚好大于等于进程所要求的内存大小
        即若继续对内存进行一次划分，内存大小将不符合进程所要求的内存大小，刚好处于临界区
    3. 将该内存块分配给进程
        对于内存块： 更改其status和pid
        对于进程： 更改其status和blockID
*/
void allocate_memory(PCB* pcb){
    Block* block = find_free_block(pcb->neededMem);
    if (block){
        printf("Allocate free memory block for process #%d\n",pcb->pid);
        while(block->sizeK - 1 >= pcb->neededMem){
            split_block(block);
        }
        block->status = false;
        block->pid = pcb->pid;
        pcb->status = 1;
        pcb->blockID = block->id;
        print_memory_state();
    }else{
        printf("Cannot allocate a memory block for process %d\n",pcb->pid);
        return;
    }
}

/*
合并内存块，遵循伙伴系统的规则：
    1. 一个内存块被回收时，先找到其对应的伙伴块
    2. 然后探测其对应的伙伴情况是否空闲
    3. 如果伙伴空闲，则合并空闲伙伴向上递归
       如果伙伴不空闲，则停止合并，等待伙伴空闲
*/
void merge_blocks(void){
    Block* current = freeList;
    while(current){
        Block* buddy = find_buddy(current);
        // 确保伙伴存在、伙伴为空闲、当前块为空闲，方可进行合并
        if (!buddy || !buddy->status || !current->status){
            current = current->next;
            continue;
        }

        printf("Combine block id:%d and id:%d of size 2^%d\n",
               current->id,buddy->id,current->sizeK);

        // 如果找到的伙伴块是左伙伴块，则交换指针指向的对象，确保释放的一直是右伙伴块
        if (current->startAddr > buddy->startAddr){
            Block* temp = current;
            current = buddy;
            buddy = temp;
        }

        current->sizeK++;
        current->next = buddy->next;
        if (buddy->next) buddy->next->prev = current;
        free(buddy); // 释放伙伴块
        merge_blocks(); // 递归，尝试向上合并
        return; // 防止链表结构变化后指针失效，直接返回。
    }
}

/*
给定进程的pid，释放该进程及分配给它的内存块。
    对于进程：不变
    对于内存块：更改status、pid属性，并调用合并内存块
*/
void free_memory(int pid){
    Block* current = freeList;

    while (current)
    {
        if (current->pid == pid){
            current->status = true;
            current->pid = -1;
            printf("Recycle used memory block for process #%d of size 2^%d...\n",
                   pid,current->sizeK);
            merge_blocks();
            print_memory_state();
            return;
        }else current = current->next;
    }

    printf("Cannot find process %d\n",pid);
    return;
}

/*
判断当前进程队列是否为空
*/
int is_empty_queue(PCBQueue *Q){
    return Q->front==NULL;
}

/*
将进程加入进程队列
*/
void enqueue(PCBQueue* Q, PCB* pcb){
    if (Q->rear) Q->rear->next = pcb;

    Q->rear = pcb;

    if (Q->front == NULL) Q->front = Q->rear;
}

/*
将进程从队列中出队
*/
PCB* dequeue(PCBQueue* Q){
    if (is_empty_queue(Q)){
        printf("PCB Queue is Empty!\n");
        return NULL;
    }else{
        PCB* temp = Q->front;
        Q->front = Q->front->next;
        return temp;
    }
}

/*
测试函数a：
    1. 初始化内存
    2. 创建进程
    3. 分配进程内存
    4. 释放进程内存
    5. 销毁内存和进程
假设n=3,即有3个进程，第1个进程申请的内存大小为2^7,第2个进程申请的内存大小为2^4，第3个进程申请的内存大小为2^8；
*/
void test_case_a(void){
    initialize_memory();
    pcbQueue = create_pcb_queue();

    // PCB *pcb1 = create_pcb(1, 7); // 2^7
    // PCB *pcb2 = create_pcb(2, 4); // 2^4
    // PCB *pcb3 = create_pcb(3, 8); // 2^8
    enqueue(pcbQueue,create_pcb(1, 7));
    enqueue(pcbQueue,create_pcb(2, 4));
    enqueue(pcbQueue,create_pcb(3, 8));
    print_pcb_queue();

    // allocate_memory(pcb1);
    // allocate_memory(pcb2);
    // allocate_memory(pcb3);

    while(!is_empty_queue(pcbQueue)){
        PCB* pcb = dequeue(pcbQueue);
        allocate_memory(pcb);
        free(pcb);
    }


    free_memory(1);
    free_memory(2);
    free_memory(3);

    delete_memory();
    delete_queue(pcbQueue);
}

/*
测试函数b：
假设有n=8个进程，每个进程所申请的内存块大小为2^k，其中k为随机整数，在[3,8]间产生。
*/
void test_case_b(void){
    initialize_memory();
    pcbQueue = create_pcb_queue();
    srand(time(NULL));

    for (int i = 1; i <= PROCESS_NUM; i++)
    {
        int neededMem = rand() % 6 + 3; // [3,8]
        enqueue(pcbQueue,create_pcb(i,neededMem));
    }
    print_pcb_queue();

    while(!is_empty_queue(pcbQueue)){
        PCB* pcb = dequeue(pcbQueue);
        allocate_memory(pcb);
        free(pcb);
    }

    for (int i = 1; i <= PROCESS_NUM; i++)
    {
        free_memory(i);
    }

    delete_memory();
    delete_queue(pcbQueue);
}

/*
删除内存分配的空间
*/
void delete_memory(void){
    Block *temp = freeList;
    freeList->next = NULL;
    free(temp);
}

/*
删除PCB进程队列
*/
void delete_queue(PCBQueue* Q){
    PCB* temp;
    while (Q->front){
        temp = Q->front;
        Q->front = Q->front->next;
        free(temp);
    }
    free(Q);
}
```

<!-- endtab -->

<!-- tab 主函数q2.c -->

```c
// 2.c
# include "q2.h"

/*
运行test_case_a()即样例一
运行test_case_b()即样例二
*/
int main(void){
    // test_case_a();
    test_case_b();

    return 0;
}
```

<!-- endtab -->
{% endtabs %}

{% endfolding %}

最终部分运行结果如下：

{% tabs buddy_system_result %}

 <!-- tab 内存分配 -->

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241127103017596.png?x-oss-process=style/blog" alt="image-20241127103017596" style="zoom:67%;" />

<!-- endtab -->

<!-- tab 内存回收 -->

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241127103038317.png?x-oss-process=style/blog" alt="image-20241127103038317" style="zoom:67%;" />

<!-- endtab -->

{% endtabs %}

### Q3

> **设计任务：**
>
> 假设系统中有1个进程，其大小总共有n=10页，而操作系统仅分配了m=3个页面的物理内存空间供其运行。用随机函数随机产生包含有k=20个页面的访问序列。具体要完成的设计任务为：编程实现LRU页面置换算法，为该进程做页面置换，计算缺页率。
>
> **要求：**
>
> 1. 输出每处理页面访问序列中的1个页面请求时，操作系统分配给该进程的m=3个页面空间的被占用情况；
> 2. 最后输出命中次数，缺页次数，以及缺页率。
>
> **需要使用到的数据结构：**
>
> 1. 保存页面访问序列的一维数组：`Sequence[MaxSequenceLen]`, `MaxSequenceLen`是页面访问序列长度 
>
> 2. 记录页面访问时间的一维数组：`PageAccessTime[MaxNumOfPages]`, `MaxNumOfPages`是最大页面数 
>
> 3.  系统分配给进程的页面一维数组`PageArray[NumAllocatedPages]`, `NumAllocatedPages`是OS分配给进程的最大页面数；当发生缺页时，需要从PageArray中选出一页进行置换
>

LRU算法，即**最近最少使用算法/Least-Recent-Used Algorithm**。

在页面置换算法中，最优的策略是采用**最优页面置换算法/Optimal page-replacement algorithm**，简单来说就是：置换最长时间不会使用的页面。但是在实际运用中，想要预测一个进程将来会使用多久是不可能做到的事情。如果最优算法不可行，那么最优算法的近似或许成为可能。

如果我们使用过去作为不远将来的近似，那么可以选择置换最长时间没有使用的页，这种方法就是LRU置换。

#### LRU

LRU算法有很多实现的方法，比如计数器法、堆栈法、额外引用位等。要用到题给的数据结构，本质上是计数器法。按照《操作系统概论》这本书给出的定义，这里将计数器法的详细表述引用如下：

{% note info simple %}

在最简单的情况下，为每个页表条目关联一个使用时间域，并为CPU添加一个逻辑时钟或计数器。每次内存引用都会递增时钟。每当进行页面引用时，时钟寄存器的内容会复制到相应页面的页表条目的使用时间域。这样，我们总是有每个页面的最后引用的“时间”。我们置换具有最小时间的页面。这种方案需要搜索页表以查找LRU页面，而且每次内存访问都要写到内存(到页表的使用时间域)。当页表更改时(由于CPU调度)，还必须保留时间。时钟溢出也要考虑。

{% endnote %}

在这里，我们用一个数组`PageAccessTime[MaxNumOfPages]`作为关联的时间域，用于记录每个页面最后被访问的时间戳。

我将LRU在编程中实现的思路归纳如下：

1. 维护一个全局变量`currentTime`，用于模拟时间。
2. `Sequence[MaxSequenceLen]`存储随机生成的访问页面序列, `MaxSequenceLen`在本题中取20。
3. `PageArray[NumAllocatedPages]`即工作集, `NumAllocatedPages`在本题中取3。初始化时每个元素均为-1。
4. `PageAccessTime[MaxNumOfPages]`即记录每个页面被访问的时间, `MaxNumOfPages`在本题中取10。这个数据结构是LRU置换的核心部分，每次访问一个页面，就在该页面序号对应的元素记录其时间`currentTime`。
5. 依次从`Sequence[MaxSequenceLen]`中读取页面序列填充进入`PageArray[NumAllocatedPages]`，并且在`PageAccessTime[MaxNumOfPages]`中维护页面被访问的时间戳。
6. 关于`PageArray[NumAllocatedPages]`中被置换的逻辑，即LRU的实现，具体描述如下：
   - 首先按照顺序置换掉所有的-1值，因为-1代表空闲页面。
   - 如果没有-1页面，代表所有的页面均已被分配。此时要添加新的页面，需要对已分配的页面进行检索，检查该页面是否已经在工作集中。
   - 若在，则发生hit，说明OS无需从内存中调入新的页面，更新碰撞页面的使用时间，这将使其被置换的优先级降低。
   - 若不在，意味着必须要置换出一个老页面，而置换顺序遵循LRU规则。即比较在`Sequence[MaxSequenceLen]`中页面在`PageArray[NumAllocatedPages]`中对应的值，访问时间越小的说明它过去被使用的时间越短，应该被优先置换。

也就是说，LRU算法的精髓在于发生{% span red,“hit” %}，也就是碰撞。发生碰撞后，OS无需从内存中调入页面进行读写操作，但是却需要更新碰撞页面的使用时间，这一操作使该页面更不容易被置换出去；倘若没有发生碰撞，此时LRU便退化为FIFO算法，只是简单的根据页面进入的顺序进行置换。

具体代码实现如下：

~~~c
int LRU(int pageID) {
    int isHit = 0;
    int replacePointer = -1;
    int minTime = currentTime;

    // 检查页面是否已经在工作集中
    for (int i = 0; i < NumAllocatedPages; i++) {
        if (PageArray[i] == pageID) {
            isHit = 1;  // 页面命中
            PageAccessTime[pageID] = currentTime;  // 更新访问时间
            break;
        }
    }

    if (isHit) {
        PageAccessTime[pageID] = currentTime;  // 更新访问时间
        return isHit;  // 如果是命中，直接返回
    }

    // 如果没有命中，发生缺页错误，找到最久未使用的页面进行置换
    for (int i = 0; i < NumAllocatedPages; i++) {
        if (PageArray[i] == -1) {
            PageArray[i] = pageID;  // 直接填充空闲页面
            PageAccessTime[pageID] = currentTime;
            return 0;
        }
    }

    // 如果所有页面已满，找到最久未使用的页面进行替换
    for (int i = 0; i < NumAllocatedPages; i++) {
        if (PageAccessTime[PageArray[i]] < minTime) {
            minTime = PageAccessTime[PageArray[i]];
            replacePointer = i;
        }
    }

    // 进行替换
    PageArray[replacePointer] = pageID;
    PageAccessTime[pageID] = currentTime;
    return 0;
}
~~~

#### Virtual memory page replacement

最终实现完整版代码如下：

{% folding cyan, 查看完整代码 %}

{% tabs Virtual_memory_page_replacement,3 %}
<!-- tab 头文件q3.h -->

```c
# ifndef Q3_H
# define Q3_H

# include <stdio.h>
# include <stdlib.h>
# include <time.h>
# define MaxSequenceLen 20 // 随机生成的访问序列长度
# define MaxNumOfPages 10 // 进程所需要的最大页面数
# define NumAllocatedPages 3 // OS给该进程分配的页面空间大小

void initialize(void);
void generateSequence(void);
void allocatePages(void);
int LRU(int pageID);
void print_result(int hit);

# endif
```

<!-- endtab -->

<!-- tab 函数定义q3f.c -->

```c
# include "q3.h"

int Sequence[MaxSequenceLen] = {0};
int PageAccessTime[MaxNumOfPages] = {0};
int PageArray[NumAllocatedPages] = {0};
int currentTime = 0;

/*
初始化操作
*/
void initialize(void){
    srand(time(NULL));
    generateSequence();
    for (int i = 0; i < NumAllocatedPages; i++){
        PageArray[i] = -1;
    }
}

/*
产生随机的访问页面序列，初始化Sequence
*/
void generateSequence(void){
    for (int i = 0; i < MaxSequenceLen; i++){
        Sequence[i] = rand() % MaxNumOfPages;
    }
}

/*
开始运行页面分配
*/
void allocatePages(void){
    int hit = 0;
    int isHit;

    printf("    SeqID        Working Set\n");
    for (int i = 0; i < MaxSequenceLen; i++){
        isHit = LRU(Sequence[i]);
        currentTime++;

        printf("%8d%12d%3d%3d",
               i + 1, PageArray[0], PageArray[1], PageArray[2]);

        if (isHit){
            printf("    *hit*\n");
            hit++;
        } else {
            printf("\n");
        }
    }
    print_result(hit);
}


/*
LRU算法：
    1. 首先按照顺序置换掉所有的-1值，因为-1代表空闲页面。
    2. 如果没有-1页面，代表所有的页面均已被分配。
       此时要添加新的页面，先检查该页面是否已经在工作集中：
        · 若在，则发生hit，说明OS无需从内存中调入新的页面，更新碰撞页面的使用时间，这将使其被置换的优先级降低
        · 若不在，意味着发生缺页错误。必须要置换出一个老页面，而置换顺序遵循LRU规则。
          即比较在Sequence[MaxSequenceLen]中页面在PageArray[NumAllocatedPages]中对应的值，
          访问时间越小的说明它过去被使用的时间越短，应该被优先置换
    3. 如果所有页面的使用时间相同，则按照FIFO的顺序对页面进行置换。
*/
int LRU(int pageID) {
    int isHit = 0;
    int replacePointer = -1;
    int minTime = currentTime;

    // 检查页面是否已经在工作集中
    for (int i = 0; i < NumAllocatedPages; i++) {
        if (PageArray[i] == pageID) {
            isHit = 1;  // 页面命中
            PageAccessTime[pageID] = currentTime;  // 更新访问时间
            break;
        }
    }

    if (isHit) {
        PageAccessTime[pageID] = currentTime;  // 更新访问时间
        return isHit;  // 如果是命中，直接返回
    }

    // 如果没有命中，发生缺页错误，找到最久未使用的页面进行置换
    for (int i = 0; i < NumAllocatedPages; i++) {
        if (PageArray[i] == -1) {
            PageArray[i] = pageID;  // 直接填充空闲页面
            PageAccessTime[pageID] = currentTime;
            return 0;
        }
    }

    // 如果所有页面已满，找到最久未使用的页面进行替换
    for (int i = 0; i < NumAllocatedPages; i++) {
        if (PageAccessTime[PageArray[i]] < minTime) {
            minTime = PageAccessTime[PageArray[i]];
            replacePointer = i;
        }
    }

    // 进行替换
    PageArray[replacePointer] = pageID;
    PageAccessTime[pageID] = currentTime;
    return 0;
}

/*
计算并打印缺页率
*/
void print_result(int hit){
    int miss = MaxSequenceLen - hit;
    double rate = (double)miss / (double)(hit + miss);

    printf("Hit = %d, Miss = %d\n",hit,miss);
    printf("Page fault Rate = %d/%d = %lf\n",miss,MaxSequenceLen,rate);
}
```

<!-- endtab -->

<!-- tab 主函数q3.c -->

```c
# include "q3.h"

int main(void){
    initialize();
    allocatePages();

    return 0;
}
```

<!-- endtab -->
{% endtabs %}

{% endfolding %}

最终部分运行结果如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241127103137171.png?x-oss-process=style/blog" alt="image-20241127103137171" style="zoom:67%;" />

堂堂完结！撒花\~✿✿ヽ(°▽°)ノ✿

觉得有用的老铁在评论区扣个6:heart:

---

![64495434_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/64495434_p0.jpg?x-oss-process=style/blog)

---
title: Coursera-ML-AndrewNg-Notes-Week5
tags:
  - Neural Network
date: 2024-11-14 15:31:56
updated: 2026-01-07 15:56:22
categories: Machine-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/D2C62FCE46B76B7B3305529FD6BBCE3D.jpg?x-oss-process=style/blog
description: Learn more about neural network, introducing how to choose proper activation function and advanced optimization.
---


{% span center logo large, Coursera-ML-AndrewNg-Notes-Week5 %}

{% span center small, My machine learning notes %}

这里是吴恩达机器学习第五周:white_flower:

这周我们继续进行神经网络的学习。

上周我们学习了神经网络的基本架构，算是一个小小的入门。这周将从在Python中部署神经网络开始，了解代码底层的细节原理。之后，我们将学习如何在神经网络中选择恰当的激活函数。最后，我们将快速的过一遍对神经网络的高级优化，以及了解额外的层类型。

视频链接在下方：

{% btn 'https://www.bilibili.com/video/BV1Bq421A74G?spm_id_from=333.788.videopod.episodes&vd_source=5e421b52b9103cce8e012430aa932553',Machine Learning Specialization,far fa-hand-point-right,block center larger %}

## Neural Network Training

### TensorFlow Implementation

我们从一个情景假设导入学习的内容。

> 假如我们现在要识别一个手写数字是0还是1，搭建神经网络来完成目标。

我们把包含数字的灰度图作为输入数据，并搭建一个神经网络模型，它大概长的如下图所示：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241113134408233.png?x-oss-process=style/blog" alt="image-20241113134408233" style="zoom:50%;" />

可以看到，我们的模型包含三个层。第一个隐藏层有25个激活单元，第二个隐藏层有15个激活单元，第三个输出层只有一个激活单元，最后输出一个预测结果。那么，我们该如何把这个模型部署到代码中呢？

~~~python
import tensorflow as tf
from tensorflow.python.keras.models import Sequential
from tensorflow.python.keras.layers import Dense
from tensorflow.python.keras.losses import BinaryCrossentropy

model = Sequential([
    Dense(units=25,activation='sigmoid'),
    Dense(units=15,activation='sigmoid'),
    Dense(units=1,activation='sigmoid')
]) # 指定模型

model.compile(loss=BinaryCrossentropy()) # 编译模型，指定损失函数为二元交叉熵损失函数

model.fit(X,Y,epochs=100) # 训练模型，epochs代表模型迭代训练轮数
~~~

接下来我们来详细介绍这段代码背后的奥秘所在。

回顾一下我们之前提到过的训练模型三步走：

- 定义模型，给出模型应该如何处理输入$X$与参数$\theta$。
- 给出损失函数$\text{LOSS}$与代价函数$J$。
- 训练模型，计算$J_{min}(\theta)$时的参数$\theta$。

在逻辑回归中，我们是这么实现的：

```python
# define model
z = np.dot(w,x) + b
f_x = 1/(1+np.exp(-z))

# specify loss and cost
loss = -y * np.log(f_x) - (1-y) * np.log(1-f_x)

# Train on data to minimize J
w = w - alpha * dj_dw
b = b - alpha * dj_db
```

这些代码是对逻辑回归的数学公式最简单的实现逻辑，所幸TensorFlow已经帮我们把这些都处理好了，这使得我们可以不必花时间去编写底层代码，而只需要调用现成的函数就好了。回到之前给出的代码，我们来逐一解释代码的细节。

~~~python
model = Sequential([
    Dense(units=25,activation='sigmoid'),
    Dense(units=15,activation='sigmoid'),
    Dense(units=1,activation='sigmoid')
]) # 指定模型
~~~

这一段代码定义了模型为一个具有三层的神经网络。在每一层的定义中，只需要给出激活单元的个数与激活函数就好。在这里，我们仍然用$Sigmoid$函数作为激活函数，其实这里还有其他的激活函数可供选择来帮助我们进一步优化模型，这里留到后文细说。

~~~python
model.compile(loss=BinaryCrossentropy()) # 编译模型，指定损失函数为二元交叉熵损失函数
~~~

这一步我们定义了模型的损失函数，之后模型将按照这个损失函数来定义代价函数，从而去运用梯度下降法去求得最小参数值来优化模型拟合数据集。这里我们指定损失函数为`BinaryCrossentropy()`，BinaryCrossentropy是二元交叉熵损失函数，其实就是逻辑回归的损失函数的别名。

当然还有其他损失函数。比如如果你想要搭建一个线性回归模型，那么损失函数就得采用均方误差函数，即`MeanSquaredError()`。

~~~python
model.fit(X,Y,epochs=100) # 训练模型，epochs代表模型迭代训练轮数
~~~

这行代码即指示计算机训练模型，并给定了训练的轮数`epochs`。这个`epochs`是机器学习的专有名词，也可以理解为训练时间，或者是梯度下降中的下降步数。TensorFlow会帮我们完成所有梯度下降中的细节，并且比我们自己用循环处理时运算地更快。这是因为在`model.fit()`中会自动调用**反向传播算法**来帮助我们更快的计算。

{% note info simple %}

什么是反向传播算法？参见：[通俗易懂举栗子--怎么理解反向传播算法？ - 知乎](https://zhuanlan.zhihu.com/p/395323930)

{% endnote %}

## Activation Functions

话不多说，我们直接引入三个神经网络最常用的激活函数，分别是：

- Linear Activation function，线性激活函数
- Sigmoid，S型函数
- ReLU，修正线性单元激活函数（名字很拗口，也不用特地去记）

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241113153416154.png?x-oss-process=style/blog" alt="image-20241113153416154" style="zoom:50%;" />

Linear Activation function是最简单的激活函数，如果你的输出层预测结果可正可负，那么就可以采用这个激活函数作为输出层的激活函数。对于隐藏层，当有很多人说他们“没有采用任何激活函数”时，实际上就是说采用了线性激活函数。因为$g(z)=z$，可以视为函数$g()$根本不存在。可以证明，{% span red,在神经网络的隐藏层中运用线性激活函数，将完全无法发挥神经网络的作用，效果等同于运用线性回归模型 %}。道理也很简单：线性函数的复合结果仍然是线性函数。所以一般不建议在神经网络的隐藏层中运用线性激活函数。

Sigmoid函数，也就是我们目前在所有神经元中采用的函数。如果你的输出层预测结果要求具备二元分类的性质，那么就可以采用这个函数。对于隐藏层来说，我们一般也并不采用这个函数作为隐藏层函数，绝大部分情况下，我们都是采用ReLU函数作为神经网络隐藏层的激活函数。

ReLU函数，其实就是$g(z)=max(0,z)$，它对于正值部分保持线性，而对小于0的部分截断为0。所以，它的输出值永远大于0，并且在隐藏层中运用ReLU函数要比Sigmoid函数的效果更好。那么紧接着问题来了，为什么ReLU函数的效果更好呢？原因有以下几点：

- **非线性行为：** 由于 ReLU 会将负值截断为零，这就引入了非线性特性，使得网络能够捕捉到复杂的非线性关系。这样，通过堆叠多层使用 ReLU 的神经网络，网络能够学习到更复杂的映射。
- **稀疏激活：** 由于 ReLU 将负数部分的输出置为 0，只有正值部分的神经元会被激活。这导致了“稀疏激活”的现象——不是每个神经元都会在每次输入中都被激活，这有助于避免过拟合，同时减少计算量。
- **梯度传递：** ReLU 在正数区间的梯度为 1，这意味着在反向传播时梯度能够较好地传递。这解决了传统 sigmoid 或 tanh 激活函数中可能遇到的 **梯度消失问题**，使得网络能够更有效地训练。
- **速度更快**：ReLU仅仅在函数左侧有“平坦”部分，而Sigmoid函数在函数两端都含有“平坦部分”。这导致Sigmoid函数在反向传播中梯度会趋于0，而ReLU 能有效地缓解梯度消失问题（虽然在负区间有死区，但不会像 sigmoid 那样在整个区间都消失）。且ReLU函数在正数区间的导数恒为1，在梯度下降方面要比Sigmoid函数更快。

所以总结：{% span blue,一般情况下，神经网络的隐藏层都推荐使用ReLU函数，而输出层使用什么激活函数，取决于模型的用途 %}。当然，也有其他函数，在某些情况下使用时，性能提升会比使用ReLU函数更好一点点，但是绝大部分情况下用ReLU就够了。

## Multiclass Classification

回到手写数字识别的情景假设，现在我们对其继续拓展：

> 假如我们现在要识别一个手写数字从0\~9，搭建神经网络来完成目标。

很明显，这是多分类问题。我们先前在逻辑回归的学习中已经介绍过一种方法来处理这种问题，那就是构建多个分类器对数据集进行处理，最后选择预测可能性最高的那个预测结果作为输出。

然而，这本质上是建立了多个模型对同一批数据集进行训练，这是十分低效的。我们如何在神经网络里实现一步到位呢？这就是我们接下来要引入的一个新的专门用于处理多分类问题的激活函数——Softmax函数。

### Softmax

Softmax函数是逻辑回归函数的泛化。

为了更好的理解Softmax函数，我们先给出逻辑回归函数的定义以供参考：
$$
z=w\times x+b\\
a_1=g(z)=\frac{1}{1+e^{-z}}=P(y=1|x)\\
a_2=1-g(z)=p(y=0|x)
$$
对于二元分类问题，Sigmoid函数将输出输入预测结果为$y=1$时的概率$a_1$，对于$y=0$时的概率$a_2$可以通过用$1-a_1$得到。

现在加入我们的输出结果有四个类别$a_1,a_2,a_3,a_4$，Softmax函数要怎么处理呢？公式如下：
$$
a_1 = \frac{e^{z_1}}{e^{z_1} + e^{z_2} + e^{z_3} + e^{z_4}} = P(y = 1|\vec{x})\  \\

a_2 = \frac{e^{z_2}}{e^{z_1} + e^{z_2} + e^{z_3} + e^{z_4}} = P(y = 2|\vec{x})\  \\

a_3 = \frac{e^{z_3}}{e^{z_1} + e^{z_2} + e^{z_3} + e^{z_4}} = P(y = 3|\vec{x})\  \\

a_4 = \frac{e^{z_4}}{e^{z_1} + e^{z_2} + e^{z_3} + e^{z_4}} = P(y = 4|\vec{x})\ 
$$
对于$N$个可能的输出，归纳公式：
$$
z_j = \vec{w}_j \cdot \vec{x} + b_j\quad j = 1, \ldots, N\\

a_j = \frac{e^{z_j}}{\sum_{k=1}^{N} e^{z_k}} = P(y = j \mid \vec{x})
$$
如果只有二分类，那么Softmax会简化为逻辑回归模型，这就是为什么说Softmax函数是逻辑回归函数的泛化。

对于Softmax的损失函数，我们定义如下。
$$
\text{loss}(a_1, \ldots, a_n, y) = 
\begin{cases} 
-\log a_1 & \text{if } y = 1 \\
-\log a_2 & \text{if } y = 2 \\
\vdots \\
-\log a_n & \text{if } y = N 
\end{cases}
$$
其实，这就是逻辑函数的损失函数的泛化版本。对于简化前的二元交叉熵损失函数，有：
$$
\operatorname{L}(h_{\theta}(x), y) = 
\begin{cases}
-\log(h_{\theta}(x)) & \text{if } y=1 \\
-\log(1-h_{\theta}(x)) & \text{if } y=0
\end{cases}
$$
可以看到这两个函数的展开其实形式完全一致，原理也与逻辑回归函数相同。

### Neural Network with Softmax Output

如果要在神经网络中引入Softmax作为输出层的激活函数，我们需要稍微修改一下我们的模型：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241113163726678.png?x-oss-process=style/blog" alt="image-20241113163726678" style="zoom:50%;" />

因为最终Softmax输出的激活向量将包含10个激活值，所以输出层中要有10个激活单元。

那么，在代码中如何实现呢？按照模型三步走的策略：建立模型、指定损失函数与代价函数、训练模型匹配数据集，即可。实际上只需要稍微改动一下之前代码就行，阅读以下代码：

~~~python
import tensorflow as tf
from tensorflow.python.keras.models import Sequential
from tensorflow.python.keras.layers import Dense
from tensorflow.python.keras.losses import BinaryCrossentropy

model = Sequential([
    Dense(units=25,activation='sigmoid'),
    Dense(units=15,activation='sigmoid'),
    Dense(units=10,activation='softmax') # 这里改动了激活单元和激活函数
])

model.compile(loss=SparseCategoricalCrossentropy()) # 改动损失函数为稀疏分类交叉熵

model.fit(X,Y,epochs=100)
~~~

这段代码能够正常工作，但是**Don't use the version.** 一会儿我们就会给出它的优化版本。

我们都知道计算机中储存数据的位数是有限的，所以计算时有时候会出现浮点数误差。

~~~cmd
>>> 1+2/10000
1.0002
>>> 1+(1/10000)-(1-1/10000)
0.00019999999999997797
~~~

回到之前的代码：

~~~python
model = Sequential([
    Dense(units=25,activation='sigmoid'),
    Dense(units=15,activation='sigmoid'),
    Dense(units=10,activation='softmax') 
])
model.compile(loss=SparseCategoricalCrossentropy()) 
model.fit(X,Y,epochs=100)
~~~

这里代码的处理流程实际上是先将输入经过神经网络处理，输出一个中间值$a_1$，然后再对$a_1$代入损失函数计算损失。这一步过程中会损失精度，我们要做的，就是去除掉这个中间值$a_1$。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241113165619027.png?x-oss-process=style/blog" alt="image-20241113165619027" style="zoom:50%;" />

比起直接传递$a_1$给损失函数，不如直接把激活函数代入损失函数的计算中。TensorFlow会自动排列计算项，从而使得损失计算更精确。这个损失平时很小，如果输出层的激活函数是Sigmoid倒也无所谓，但如果采用Softmax，这个损失就有点无法忽略了。

所以我们要对代码进行修改：

~~~python
model = Sequential([
    Dense(units=25,activation='sigmoid'),
    Dense(units=15,activation='sigmoid'),
    Dense(units=10,activation='linear') # 这里选择linear作为激活函数
])
model.compile(loss=SparseCategoricalCrossentropy(from_logits=True)) # 这里引入了新的参数 
model.fit(X,Y,epochs=100)
~~~

这段代码的作用在于，修改输出层的激活函数为线性激活函数，这样最终输出的结果就是$z_1,z_2\cdots z_9$，而非$a_1,a_2\cdots a_9$。`from_logits=True`这个参数指定模型的输出（logits）是未经softmax激活函数处理的原始分数（也称为logits）。在这种情况下，`SparseCategoricalCrossentropy` 损失函数内部会应用Softmax函数，将logits转换为概率分布，然后再计算交叉熵损失。这样优化后的代码，结果将更为可靠。

## Optional: Multi-label Classification

一个很容易混淆的问题就是人们往往会区分不开多分类问题与多标签分类问题。

多分类问题和多标签分类问题在任务性质和输出要求上有显著区别。多分类问题是指一个样本只能被分到一个类别中，也就是说每个样本在分类后只会有一个标签。例如，在图像分类中，如果图片内容是猫、狗或鸟，每张图片只能被归入其中一个类别，因此属于单一标签的分类。这类问题通常采用交叉熵损失函数，通过最大化正确类别的概率来训练模型。

相比之下，多标签分类问题允许一个样本同时属于多个类别，也就是说每个样本可以有多个标签。比如在文本分类中，一篇文章可能既属于"体育"类别，也属于"科技"类别。因此，模型的输出不是单一类别的概率，而是多个类别的概率值，每个类别的预测结果独立存在。多标签分类通常采用二元交叉熵损失函数，因为每个类别都是独立的二分类任务，目标是分别预测每个类别的概率。

对于神经网络来说，主要体现在最后一层的输出层的差别。多分类问题使用Softmax作为激活函数，而多标签分类问题用Sigmoid作为激活函数。当然，其对应的损失函数也需要被修改。

## Additional Neural Network Concepts

### Advanced Optimization

我们来介绍一种运用在神经网络中的高级优化算法：{% bubble Adam算法,"Adaptive Moment Estimation，自适应矩估计","#ec5830" %}。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241114131359896.png?x-oss-process=style/blog" alt="image-20241114131359896" style="zoom:50%;" />

简而言之，Adam算法的作用就是**自适应学习率**。在传统的机器学习算法中，如果学习率$\alpha$过小，那么梯度下降的速度将变得缓慢；如果学习率$\alpha$过大，又容易出现“反复横跳”的情况。Adam算法，能够对每个参数动态的调整它们的学习率从而一定程度上优化模型。

如果要从直觉上理解Adam算法，它做的就是在上图中：

- 如果一个参数一直在向一个方向移动，那么就增大学习率$\alpha$，使其更快的前进。
- 如果一个参数出现“反复横跳”的情况，就减小学习率$\alpha$，从而使其梯度正常下降。

Adam算法在数学上的实现比较复杂，这里不做讨论。

{% note danger simple %}

Q：有了Adam算法根据各个参数自动调整其学习率，我们是否就不需要进行**特征缩放**了呢？

A：的确，在很多情况下，Adam 算法已经比传统的梯度下降方法更能够适应特征尺度的不同。特征缩放对于Adam算法在某种程度上来说并不是必要的。然而，**特征缩放仍然是推荐的预处理步骤**，对数据进行标准化或者归一化，仍然可以加速收敛，且提高系统稳定性。

所以，虽然特征缩放的效果不如在没有运用Adam算法的情况时那么显著，对数据集进行特征缩放预处理仍然是推荐的。

{% endnote %}

### Additional Layer Types

在之前的学习中，对于神经网络的架构，我们都默认神经网络的某一层可以访问前一层的所有数据，这种连接方式叫做**全连接层**。然而神经网络也不仅仅局限于全连接层，事实上还存在着其他形式的神经网络层，比如我们接下来将介绍的**卷积层**。

卷积层，即Convolutional Layer，和全连接层的区别在于：卷积层对于前一层的数据是部分可见的。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241114134257634.png?x-oss-process=style/blog" alt="image-20241114134257634" style="zoom:50%;" />

为什么采用卷积层呢？主要有两个优点：

- 更快的运算速度。因为卷积层相比全连接层来说可见数据更为有限，所以它的计算量更小，运算速度也就更快。
- 只需要更少的训练数据，可以有效防止过拟合。

使用卷积层时，人们又更多的架构选择。比如神经元应该查看多大的输入窗口？每层应该有多少个神经元等。这无疑给模型带来了更多复杂性，更好地模拟人脑对数据进行拟合。

除了卷积层，还有Transformer、LSTM、注意力模型等其他架构的高级神经层，可以课后搜索了解。

Coursera的这门课并没有对卷积神经网络及其他架构的神经层展开过多介绍，毕竟这门课只是一门作为入门的基础课。如果想要了解更多神经网络的内容，可以看看吴恩达开的另外一门专门 focus on CNN 的课，不过笔者截止到本文编撰的当前也还没有看过就是了。



以上就是第五周的全部学习内容！下周见~

---

![D2C62FCE46B76B7B3305529FD6BBCE3D](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/D2C62FCE46B76B7B3305529FD6BBCE3D.jpg?x-oss-process=style/blog)

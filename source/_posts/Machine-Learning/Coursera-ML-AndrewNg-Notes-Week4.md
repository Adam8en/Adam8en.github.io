---
title: Coursera-ML-AndrewNg-Notes-Week4
tags:
  - Neural Network
date: 2024-11-12 21:18:13
updated: 2024-11-12 21:18:13
categories: Machine-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/123363067_p0.jpg
description: Starting to learn about neural network of its architecture, with implementation in Python.
---


{% span center logo large, Coursera-ML-AndrewNg-Notes-Week4 %}

{% span center small, My machine learning notes %}

欢迎来到吴恩达机器学习课程第四周~

本周的主题是神经网络。我们要花四周的时间在这个知识点上，所以这一周我们的任务就是入门神经网络，以及对模型有一个基本的架构认知。

视频链接在下方：

{% btn 'https://www.bilibili.com/video/BV1Bq421A74G?spm_id_from=333.788.videopod.episodes&vd_source=5e421b52b9103cce8e012430aa932553',Machine Learning Specialization,far fa-hand-point-right,block center larger %}

## Neural Networks

### Neurons and the Brain

神经网络是一种很古老的算法，它最初产生的目的是制造能模拟大脑的机器。神经网络逐渐兴起于二十世纪八九十年代，应用得非常广泛。但由于各种原因，在90年代的后期应用减少了。但是最近，神经网络又东山再起了。原因有二：

- 神经网络是一个需要大量算力的算法。随着近些年计算机硬件的不断发展，人们已经能够逐渐负担得起搭建大规模神经网络的开销。
- 随着计算机技术的不断普及，各行各业都开始引入计算机，产生了大量的数据。而神经网络能够最大程度的利用庞大的数据集为自己训练，以达到最好的学习效果。

要理解神经网络模型的原理，我们得先讲讲大脑——毕竟，神经网络一开始就是为了模拟大脑而诞生的算法。大脑的神经元如图所示：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241110192627351.png" alt="image-20241110192627351" style="zoom:67%;" />

相信学过初中生物的人都不会对此感到陌生。神经元由树突接收信息，然后产生神经冲动，通过轴突传递给下一个神经元，这就是一个大大简化的神经元模型。让我们再来看看神经网络：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241110193136096.png" alt="image-20241110193136096" style="zoom:67%;" />

同样的，神经网络的工作原理也是接收一个输入，然后由多个神经元（学习模型）对输入进行计算，产生一个或多个特征值，作为下一个神经元（学习模型）的输入，这样经过迭代计算后得到的结果就是神经网络的输出。同样的，这也是一个经过大大简化的神经网络模型。

### Neural Network Model

让我们用一个例子对神经网络的工作方式进行具体说明。

> 假如我们有一件衬衫，我们的任务是预测这件衬衫是否能够成为畅销品，于是我们搜集大量衬衫的信息尝试对其进行建模。假如我们有两个信息：衬衫的价格$x$与是否畅销$y$。

绘制出训练集的二维图像如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241110194035621.png" style="zoom:67%;" />

对于是否畅销这种输出明显带有0/1特征的二元分类问题，一般使用逻辑回归中的$Sigmoid$函数进行拟合。此时，我们有：
$$
x=price\\
a=f(x)=\frac{1}{1+e^{\theta x}}
$$
这里的$a$在神经网络中有一个专门的名称，叫做**activation**激活值，代表一个神经元向下游的其他神经元发送高输出的程度，在这里$a$就是$f(x)$。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241110194925174.png" alt="image-20241110194925174" style="zoom:50%;" />

这里，输入价格$x$进入神经元中，使得神经元输出一个$a$，代表该成品为畅销品的概率。这里的神经元可以视为一个学习模型，或者一台微型计算机，它的工作内容就是对输入运行逻辑回归然后给出输出。真正的大脑神经元要完成的事情要复杂得多，这就是为什么神经网络是对人脑的极大简化模型。

然而人脑中并不只有一个神经元，往往是多个神经元在一起进行工作。对应到本例题中，我们假设拥有四个特征：价格、运费、该类衬衫的营销量与材料质量，并依赖这四个特征来输出最终我们认为该产品是畅销品的概率。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241110200224478.png" alt="image-20241110200224478" style="zoom: 50%;" />

为此，我们为四个输入组合成为三个新的特征：购买负担力、商品认识与感知质量，并用三个神经元（学习模型）来模拟计算这三个新的组合特征。最后，再根据这三个特征，计算出最终的输出概率。

用神经网络的术语进行描述，即我们将特征向量$X$作为输入，在input layer{% bubble 输入层,"输入数据的layer定义为输入层","#ec5830" %}中将数据输出到{% bubble 隐藏层,"在输入层和输出层之间的layer称为隐藏层","#ec5830" %}，得到激活值$a^{[2]}_1$、$a^{[2]}_2$与$a^{[2]}_3$。这三个激活度又作为output layer{% bubble 输出层,"输出结果的layer定义为输出层","#ec5830" %}的输入进行计算，最终输出结果$a^{[3]}_1$。

{% note info simple %}

约定：$a^{[i]}_j$代表神经网络第$i$层的第$j$个输出值。

{% endnote %}

但是在实际运用中，用人工选择组合特征实在是过于繁琐，事实上神经网络也根本不知道自己在隐藏层在计算的是购买负担力、商品认识与感知质量。现实情况下，{% span green,我们根本不需要手动为神经网络指定计算的组合特征，神经网络会自己学习自己的特征，从而输出一个更为可靠的结果 %}，这就是为什么神经网络是当今世界上最强的算法之一。为了让神经网络自己去学习数据集的特征，它需要访问到上一层的所有数据，这就是为什么我们要将图片修改如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241110203207729.png" alt="image-20241110203207729" style="zoom:50%;" />

这就是一个运用神经网络的例子。你也可以选择加入更多的隐藏层，或者在隐藏层中加入更多神经元来提升神经网络的效果。在后文会介绍如何选择神经网络架构来优化算法性能的方法。

### Neural Network Layers

让我们展开一层分析神经网络是怎么运行的。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241110205837460.png" alt="image-20241110205837460" style="zoom:50%;" />

将输入层记为layer0，把输入向量$X$输入到layer1中，并将其展开。layer1中一共有三个神经元，也就是三个学习模型，我们将其统一称为**激活单元**。

可以看到，每个激活单元的任务就是对输入向量$X$应用逻辑回归算法，由于**权重**和**偏置**不同，各个激活单元输出的激活值也各不相同。按照图中的展开图来说，可以总结式子如下，对于第$i$层第$j$个激活值$a^{[i]}_j$来说：
$$
a^{[i]}_j=g(w^{[i]}_j\cdot x+b^{[i]}_j)
$$
将第$i$层的所有激活值用向量的形式表达出来，可以得到激活值向量${\vec a}^{[i]}$，将作为第$i+1$层的输入向量进行运算：
$$
a^{[i+1]}_j=g(w^{[i+1]}_j\cdot {\vec a}^{[i]}+b^{[i+1]}_j)
$$
有了这个公式，就可以根据前一层的数据计算任意一层的激活值。

我们可以知道：每一个$𝑎$都是由上一层所有的$𝑥$和每一个$𝑥$所对应的权重与偏置决定的。我们把这样从左到右的算法称为**前向传播算法**( FORWARD PROPAGATION )

{% note info simple %}

权重和偏置是什么？其实就是$w$与$b$，前者为参数的系数，后者为常数项。

{% endnote %}

总结一下，神经网络的工作方式就是：

> 每一层输入一个数字向量并应用一堆逻辑回归单元，然后计算另一个数字向量，这个向量然后从一层传递到另一层，直到你得到最终输出层的计算，这就是一个神经网络的预测。

### TensorFlow Implication

从神经网络开始将逐渐增多代码的分量，我们来学习如何利用TensorFlow简单的部署神经网络模型。

> 假如我想用神经网络预测一杯咖啡是否好喝（0/1），并且拥有两个特征：咖啡温度与打磨咖啡的持续时间。

输入以下代码：

~~~python
x = np.array([[200.0,17.0]])  # 将输入向量x表示为一个一维矩阵
layer_1 = Dense(units=3, activation='sigmoid') # 指定生成一个包含3个激活单元的神经层
a1 = layer_1(x) # 计算x得到激活值a1,a1将包含三个元素
~~~

代码中的`Dense`代表“密集层”，是神经网络层的别名。`Dense`函数接收参数后，返回值也为一个函数，即`layer_1`。将特征向量`x`作为`layer_1`的参数，即可计算出该层的激活值`a1`。

假设我们要在`layer_2`中输出结果，即作为输出层，则可以仿制编写代码如下：

```python
layer_2 = Dense(units=1, activation='sigmoid') # layer_2只有一个激活单元，所以最后的结果向量只包含一个元素
a2 = layer_2(a1) # 得到结果，为咖啡好喝的概率
```

最后得到的`a2`是咖啡是否好喝的概率值，但我们要求输出二元的结果好喝 or not，所以需要给`a2`设置一个阈值，来决定最后输出0还是1。这个阈值可以随意取，不过一般都取0.5，当然你想取0.7什么的也行。

```python
if ax >=0.5:
    yhat=1
else:
	yhat=0
```

还有必要提一嘴，由于历史遗留原因，TensorFlow和Numpy各自用来表示数据的方式不同。在神经网络中，特征向量$X$是一个向量，但是在Numpy中必须要用`numpy([[200.0,17.0]])`来表示，而这其实是一个一维矩阵的表示方法。理论和实践中运用总会有偏差，要记住在Python代码中应该用正确的形式表达特征向量。

除此之外，经过`layer_1`函数计算后得到的激活值`a1`的形式也发生了改变，如果你在代码中打印出`a1`，你将会得到一个张量。

```python
print(a1)
>>>	tf.Tensor([[0.000000e+00 1.836337e-15 8.152347e-09]], shape=(1, 3), dtype=float32)
```

不难发现，张量的第一个参数代表其计算得到的一维矩阵，第二个参数描述了矩阵的特征（即一行三列），第三个参数表示矩阵中元素的数据是32位的浮点数。从技术上来说，张量要比矩阵更为通用，但是在本课程范围内，可以将张量视为表示矩阵的一种形式。

你也可以将张量转换为Numpy数组的表示形式：

```python
print(a1.numpy())
>>>	[[0.000000e+00 1.836337e-15 8.152347e-09]]
```

且对于`Dense()`函数来说，其传入参数是张量抑或是Numpy形式的矩阵都是可以的。

你可以自己尝试运行下面的测试代码查看结果：

~~~python
import tensorflow
import numpy as np

x=np.array([[200.0,17.0]])
layer_1=tensorflow.keras.layers.Dense(units=3,activation="sigmoid")
a1=layer_1(x)

layer_2=tensorflow.keras.layers.Dense(units=1,activation="sigmoid")
a2=layer_2(a1)
print(a1)
print(a2)
print(a1.numpy())
print(a2.numpy())
~~~

现在我们来使用TensorFlow搭建一个神经网络架构。假设我们有数据集如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241111205452242.png" alt="image-20241111205452242" style="zoom:50%;" />

按照机器学习训练的基本流程，首先我们导入训练数据集来训练模型，然后输入待预测的输入得到预测值$\hat{y}$。故编写代码如下：

~~~python
layer_1 = Dense(units=3, activation='sigmoid') 
layer_2 = Dense(units=1, activation='sigmoid')
model = Sequential([layer_1,layer_2]) # 将两个密集层连接在一起

x = np.array([[200.0,17.0],
              [120.0,5.0],
              [425.0,20.0],
              [212.0,18.0]])
y = np.array([[1,0,0,1]])

model.compile(...) # 编译模型，这部分先省略
model.fit(x,y) # 拟合数据

model.predict(x_new) # 将输出预测值yhat
~~~

对于代码的前三行，还可以进行进一步简化。`layer_1`与`layer_2`并不一定需要显式表达，可以直接嵌入`Sequential()`中

```python
model = Sequential([Dense(units=3, activation='sigmoid'),
                   Dense(units=1, activation='sigmoid')])
```

### Neural Network Implementation  in Python

这一小节主要来介绍TensorFlow中的Dense层的底层实现，来帮助你理解**向前传播算法**是怎么工作的。这一小节是本周内容中最后一节有关代码的部分，掌握这部分内容有助于训练模型时调试代码，不过如果暂时不想涉及底层实现的话，也可以直接跳过这一小节。

观察下面这幅图：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241112195619167.png" alt="image-20241112195619167" style="zoom:50%;" />

在得到最终的结果$\vec{a}^{[2]}$前，代码都做了些什么呢？

回顾我们之前提到过的公式：
$$
a^{[i]}_j=g(w^{[i]}_j\cdot x+b^{[i]}_j)
$$
其实只要按照这个公式实现代码就可以了，阅读下面的代码：

```python
w1_1 = np.array([1,2]) # 注意，这里w1_1的表现形式是一个一维数组
b1_1 = np.array([-1])
z1_1 = np.dot(w1_1,x)+b1_1 # 对w1_1和x运用点乘，并加上b1_1
a1_1 = sigmoid(z1_1) # 结果代入sigmoid函数计算激活值
```

可以说代码实现与公式分毫不差，上面只展示了计算$\vec {a_1}^{[1]}$的部分，$\vec {a_2}^{[1]}$与$\vec {a_3}^{[1]}$计算同理。要计算$\vec {a}^{[2]}$的话也很简单，只需要把输入参数$x$替换成前一层计算出的激活值$\vec {a}^{[1]}$就可以了。

```python
w2_1 = np.array([-7,8,9]) # 这里的w有三个参数，对应第一层有三个激活单元
b2_1 = np.array([3])
z2_1 = np.dot(w2_1,a1)+b2_1 
a2_1 = sigmoid(z2_1)
```

这就是我们由数学公式推断出的底层代码写法，可以看到代码中有很多重复的部分，所以在Python中，我们可以继续对其写法进行优化。这就是为什么我们引入了`Dense()`函数和`Sequential()`函数。来看看这两个函数的底层是个怎么个事。

在实际中，我们把三个权重向量$w_1^{[1]}$、$w_2^{[1]}$、$w_3^{[1]}$整合在一起得到一个权重矩阵$W^1$，同理偏置也可以进行整合为一个偏置向量$b^1$。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241112201234647.png" alt="image-20241112201234647" style="zoom:50%;" />

{% note danger simple %}

W权重矩阵中，是列向量而非行向量代表原先的权重向量。比如对于$w_1^{[1]}$来说，应该取$[1,2]$而不是$[1,-3,5]$。

{% endnote %}

有了$W^1$和$b^1$，我们就可以给出`Dense()`与`Sequantial()`函数的定义，阅读下面的代码。

```python
def dense(a_in,W,b):
    units = W.shape[1] # 取列的数量，代表激活单元的数量
    a_out = np.zero(units) # 将输出的激活值初始化为元素个数为units的向量
    for j in range(units):
        w = W[:,j] # 切片操作，代表取出W矩阵的第j列
        z = np.dot(w,a_in) + b[j]
        a_out[j] = g(z) # 激活函数g在dense函数外部被定义，可以是sigmoid或其他函数
    return a_out
```

对于`Sequantial()`函数，有：

```python
def sequential(x):
    a1 = dense(x,W1,b1)
    a2 = dense(a1,W2,b2)
    a2 = dense(a2,W3,b3)
    a2 = dense(a3,W4,b4)
    f_x = a4
    return f_x
```

这就是Python中的底层实现逻辑，其实对于资深的Pythoner来说，看到代码就应该能对底层实现架构猜的八九不离十。不过为了清晰起见，这里还是把底层的代码明确地给了出来，方便理解。

{% note info simple %}

事实上，对于`Dense()`函数，还有进一步的优化方法。之所以我们约定在W权重矩阵中，是列向量而非行向量代表原先的权重向量，就是为了这一刻——用向量化计算代替循环。如果你有线性代数基础，知道矩阵的乘法，那么你可以对下方的代码感到十分的心领神会：

~~~python
def dense(a_in,W,b):
    z = np.matmul(a_in,W) + b # a_in与W进行矩阵乘法
    a_out = g(z)
    return a_out
~~~

{% endnote %}

### Is There a Path to AGI?

在本周学习的最后一部分，我们来谈一谈AGI，即{% bubble 广义人工智能,"artificial general intelligence","#ec5830" %}。

在说AGI之前，我们先来说说AI。大部分人对于AI这个词来说都不陌生，但是现在，社会上对于AI的炒作已经到了一个不恰当的地步，麻烦的是，AI这个词其实包含有两个意思差别很大的概念，所以分清楚它们是有必要的。这两个词就是：

- ANI，artificial narrow intelligence，狭义人工智能。
- AGI，artificial general intelligence，广义人工智能。

ANI即用于专门处理某一个特定问题的AI，比如自动驾驶、智能语音、人脸识别、工厂加工等。不可否认的是ANI在近几年的确取得了长足的进步，他们中的很多算法已经在现实世界中开始发挥巨大的作用。但是，这往往给人们带来一种错觉，那就是相比于ANI，AGI也同样取得了巨大的进展，事实却并非如此。

AGI，是指广义的人工智能，它可以完成一切泛人类的活动，比如推理、情感理解、自我意识以及在不确定或新的情境下迅速学习的能力，被誉为人工智能研究中的“圣杯”。在很多文学作品中出现的人工智能往往都是指AGI，像是《底特律：变人》。这类AI别说现实中取得多大进步了，就连能否被实现现在都饱受争议。

毕竟，正如一开始所提到的，神经网络算法的初衷是模拟大脑中的神经元来达到模拟人类大脑的目的。在这篇文章中，我们为每个“神经元”选用了逻辑回归函数作为其“思考方式”，然而大脑的神经元所要处理的事情远远比简单的逻辑回归复杂的多。况且，迄今为止我们对于人类大脑到底是如何思考的原理还几乎一无所知，这对于AGI来说无疑是雪上加霜。换句话说，用现在的算法去模拟大脑思考几乎不可能。强如ChatGPT，也不过是一款功能强大的，语言模拟方面的ANI。

不过，AndrewNg仍然对此持有希望，它给出了以下事实：

> 1. 研究证明，将动物中用于处理听觉的大脑皮层和听觉神经切断，转而接入视觉神经，最后动物的听觉皮层将学会“看”；同样的，将用于处理触觉的大脑皮层区域对接视觉神经，那么触觉皮层也会学会“看”东西。
> 2. 研究人员将摄像头绑在人的额头上，摄像头将输出前方的低灰度图像到一块电板上，电板将根据图像像素的灰度大小输出高低电压。将电板置于盲人的舌头上，能让盲人通过舌头来恢复部分对环境的感知。
> 3. 盲人通过训练，可以像蝙蝠和海豚一样，学会用弹舌来一定程度上回声辨位。
> 4. 将一块只会由处于北方的电极发电的电圈系在腰上，人类可以像鸽子一样通过磁极来确认方向。
> 5. 在青蛙的头顶移植第三只眼，青蛙可以学会使用额外的眼睛。

这些证据似乎在暗示一个事实：大脑似乎可以实现任意的功能，而这只取决于输入大脑的数据为何。也就是说，大脑是否存在一个**单一学习算法**，只要给定特定的数据，大脑就能够自动学习这些数据从而输出想要的结果呢？如果我们找到了这个**单一学习算法**，再将其运用于神经网络中，是否就可以实现AGI了呢？

当然这些都是猜测，大脑中也有可能存在少数或者更多其他的算法。不过，这至少给了我们希望，也许有一天，人类真的可以实现AGI。到了那时，想必又是一个人与机器人共存的崭新新世界。

---

![123363067_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/123363067_p0.jpg)

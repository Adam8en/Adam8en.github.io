---
title: Coursera-ML-AndrewNg-Notes-Week2
date: 2024-11-02 16:02:14
updated: 2026-01-07 15:56:22
tags:
  - Machine Learning
  -  Linear Regression with Multiple Variable
categories: Machine-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/50140585_p0.jpg?x-oss-process=style/blog
description: My notes of Coursera-ML-AndrewNg-Week2, introducing Linear Regression with Multiple Variable and Nonlinear Regression.
---


{% span center logo large, Coursera-ML-AndrewNg-Notes-Week2 %}

{% span center small, My machine learning notes %}

这里是吴恩达机器学习视频的Week2部分，笔记如下。

本周的内容依然是继续介绍线性回归方程，只不过在Week1的背景下继续向外延伸。Week2中我们将学习处理多变量、多维特征的线性回归方程，梯度下降法的优化策略以及多项式回归方程，最后还将浅谈正规方程的使用。

视频链接在下方：

{% btn 'https://www.bilibili.com/video/BV1Bq421A74G?spm_id_from=333.788.videopod.episodes&vd_source=5e421b52b9103cce8e012430aa932553',Machine Learning Specialization,far fa-hand-point-right,block center larger %}

## Linear Regression with Multiple Variable

### Multiple Features

先前我们预测房价的模型只考虑了单变量的回归模型，假如我们对房价模型加入更多的特征，比如房屋层数等，将构成一个多变量的回归模型。此时特征为$(x_1,x_2,...x_n)$。

让我们回到Week1中计算损失函数的核心公式上：

> 一个以参数$\theta$为特征函数的**代价函数**：
> $$
> J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \left( h_\theta(x^{(i)}) - y^{(i)} \right)^2
> $$
> 其中：$h_\theta(x) = \hat{y} = \theta^T X = \theta_0 x_0 + \theta_1 x_1 + \theta_2 x_2 + \cdots + \theta_n x_n$

可以看到Week1中的公式完美支持对多特征模型的运算。此时$X$代表特征向量矩阵，${\theta }^{T}$即为参数矩阵的转置。当然参数$\theta$和$X$都可以用向量本身来表示，然后用向量点积的乘法方式也能得到相同的结果。

{% note info simple %}
你可能会发现，按照这个公式计算代价函数的话，在Week1中出现的常数$b$怎么不见了呢？这是因为为了简洁起见，我们约定$x_0=1$，也就是说此时参数$\theta_0$即代表回归方程中的标量$b$。
{% endnote %}

比如有模型如下：

![image-20241102140152298](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241102140152298.png?x-oss-process=style/blog)

那么此时$
x^{(2)} = \begin{pmatrix}
1416 \\
3 \\
2 \\
40
\end{pmatrix}
$

无论用向量还是矩阵表示都是正确的，只要后续采取对应的运算方法就好。

{% note info simple %}
在Week1中我们约定：$<s^{(i)},w^{(i)}>$中$s$和$w$的指数$(i)$并不是幂运算的意思，而是代表数据集中第$i$条对应的信息。

引入多变量后我们追加约定：$x_j^{(i)}$代表特征矩阵中第$i$行第$j$个特征，也就是第$i$个训练实例的第$j$个特征。如上图中的$x_3^{(2)}=2$。
{% endnote %}

### Gradient Descent For Multiple Variables

引入多变量后，梯度下降的规则仍然不变：对每个参数求偏导，并选择合适的学习率根据梯度迭代递减参数。
$$
\theta_{\text{new}} = \theta_{\text{old}} - \alpha \nabla_{\theta} J(\theta_{\text{old}})
$$
我们将这条公式拓展到多变量上：
$$
\theta_{0} := \theta_{0} - a \frac{1}{m} \sum_{i=1}^{m} \left( h_{\theta}(x^{(i)}) - y^{(i)} \right) x_{0}^{(i)}
$$

$$
\theta_{1} := \theta_{1} - a \frac{1}{m} \sum_{i=1}^{m} \left( h_{\theta}(x^{(i)}) - y^{(i)} \right) x_{1}^{(i)}
$$

$$
\theta_{2} := \theta_{2} - a \frac{1}{m} \sum_{i=1}^{m} \left( h_{\theta}(x^{(i)}) - y^{(i)} \right) x_{2}^{(i)}
$$

$$
...
$$

对应的Python代码如下：

~~~python
def computeCost(X, y, theta):
    inner = np.power (((X *theta.T) -y), 2)
    returnnp.sum(inner) /(2*len(X))
~~~

### Gradient Descent in Practice

#### Feature Scaling

引入多个特征时，往往会出现一个问题，就是特征之间的尺度不一致：比如房屋的面积可能在100（m^2^）左右浮动，而房屋的层数可能只有2、3（层）。如果此时绘制出特征之间的图像，大概会长这样：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241102142659666.png?x-oss-process=style/blog" alt="image-20241102142659666" style="zoom:67%;" />

再看看代价函数$J(\theta)$的图像，我们会发现图像会很“扁”。

![image-20241102142439837](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241102142439837.png?x-oss-process=style/blog)

这是理所当然的。当多特征方程中一个特征$x_0$的变化量显著大于其他变量$x$时，意味着沿着它下降的梯度会非常“陡峭”。然而我们的学习率$\alpha$是唯一的，这就导致学习率相对于这个变量对应的参数$\theta_0$来说可能过于大，而相对于其他参数来说又过于小。于是就会出现“反复横跳”的问题——梯度下降需要的迭代次数变多了。

要解决这个问题，我们需要对特征进行缩放。一个常见的方法是对特征进行归一化处理：即将所有的特征尺度缩放到$[-1,1]$的区间内。缩放方法有两种：

1. 均值归一化：$x_n = \frac{x_n - \mu_n}{x_{max}-x_{min}}$，即实例值减去均值，再除以数据集中最大项与最小项的差。
2. 标准差归一化：$x_n = \frac{x_n - \mu_n}{s_n}$，其中$u_n$是平均值，$s_n$是标准差，$s_n = \sqrt{\frac{1}{N} \sum_{i=1}^{N} (x_i - \mu)^2}$。

经过特征缩放处理后的代价函数图像将看起来更加圆润：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241102143846751.png?x-oss-process=style/blog" alt="image-20241102143846751" style="zoom:50%;" />

#### Learning Rate

在Week1中我们提到学习率$\alpha$的取值比较随意。实际上采取技巧对学习率取值，也能够加快模型训练的速度。

梯度下降算法收敛所需要的迭代次数根据模型的不同而不同，我们不能提前预知，我们可以绘制迭代次数和代价函数的图表来观测算法在何时趋于收敛。

![image-20241102144043735](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241102144043735.png?x-oss-process=style/blog)

也有一些自动测试代价函数是否收敛的方法：比如设置一个阈值，当梯度下降的幅度小于这个阈值，我们就认为代价函数已经收敛完毕。但是通常，直接观察图表的方法更好。

学习率的取值可以逐渐增加，让模型的训练速度加快的同时保证最后结果不过于粗糙。可以采取以下取值：
$$
\alpha=0.01,0.03,0.1,0.3,1,3,10...
$$
即每次将学习率扩大三倍，再观察代价函数查看收敛情况即可。

### Features and Polynomial Regression

对于房屋预测模型来说，我们先前引入的变量大多都是单次项的，所以用线性回归方程即可以满足我们的需求。但是我们发现，比起房屋的长度$x_1$和宽度$x2$，也许房屋的面积对于价格的预测来说影响更大。所以我们决定引入新的特征$x_3=x_1\times x_2$，用于代表面积。

这个引入新特征的过程即为**特征工程**。它的定义如下：

{% note info simple %}
Feature engineering: 

Using intuition to design new features, by transforming or combining original features.
{% endnote %}

我们可以通过知识或直觉来设计新特征，它通常是通过转换和组合问题的原始特征来得到的，以便让学习算法得出更为准确的预测。通过定义新的特征，可能会得到更好的模型。

这个时候再度绘制关于面积$x_3$的样本点数据图，我们假定它大概长这样：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241102145307638.png?x-oss-process=style/blog" alt="image-20241102145307638" style="zoom:50%;" />

很明显，此时线性回归将不再适用于我们的模型。为了更好的拟合图像，我们应该引入非线性回归方程，比如一个二次函数：
$$
h_{\theta}(x) = \theta_{0} + \theta_{1} x_{1} + \theta_{2} x_{2} + + \theta_{3} x_{3}^2
$$
由图可知，要引入二次函数拟合图像，很显然这个二次函数应该开口向下，那么就会出现房屋面积增加而价格下跌的图像，这显然是不符合现实的。所以，也许我们应该引入三次函数：
$$
h_{\theta}(x) = \theta_{0} + \theta_{1} x_{1} + \theta_{2} x_{2}^2 + + \theta_{3} x_{3}^3
$$
如果不希望三次函数后期上升的过于陡峭，采用平方根函数也是个不错的选择：
$$
h_{\theta}(x) = \theta_{0} + \theta_{1} x_{1} + \theta_{2} x_{2} + \theta_{3} \sqrt{x_{3}}
$$
此外，也可以令$x_2=x_2^2$，$x_3=x_3^3$等换元操作把模型转化为线性回归。

总之，我们应该先观察数据然后再决定准备尝试怎样的模型，而不是采用单一的线性回归。大多数更复杂的情况下，非线性回归模型会取得比线性回归模型更好的预测效果。

![image-20241102151636564](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241102151636564.png?x-oss-process=style/blog)

{% span yellow, 注：如果我们采用多项式回归模型，在运行梯度下降算法前，特征缩放非常有必要。 %}

{% note danger simple %}

“很明显，此时线性回归将不再适用于我们的模型，~~因为我们引入的特征是根据长度和宽度这两个特征组合得到的~~。”

请注意，并没有规定**面积是通过长度和宽度两个特征相乘得到与面积与价格的函数是曲线之间有因果关系**。我一开始这里也理解错误了，其实最终函数图像如何只取决于数据集的数据，当然也可以是直线关系，只不过我们这里便于引入曲线回归方程而设定了一个曲线图像图。

{% endnote %}

### Normal Equation

Normal Equation，即正规方程。可以利用正规方程来一次计算出使得代价函数最小的参数：$\frac{\partial}{\partial \theta_j} J(\theta_j) = 0$ ，而无需选择学习率来多次迭代。

> 假设我们的训练集特征矩阵为 X（包含了${x_0}=1$）并且我们的训练集结果为向量 y，则利用正规方程解出向量 $\theta = (X^T X)^{-1} X^T y$ 。
>
> 上标T代表矩阵转置，上标-1 代表矩阵的逆。设矩阵$A={X^T}X$，则：$(X^T X)^{-1} = A^{-1}$

然而这个方法仅适用于线性回归方程，几乎不能用在后续所有模型的优化。而且因为涉及到对矩阵的多次运算，所以时间复杂度为$O(n^3)$，在特征数量$n$特别大时（$n>10000$）时间开销将无法接受。所以在大部分情况下人们还是使用线性回归，这个方法仅供了解即可。

{% note warning simple %}
至于正规方程是如何得出来的，我不知道。我查了一下原理，涉及到矩阵微积分运算，并不在基础的线性代数知识范围之内，~~所以笔者也看不懂~~。

有兴趣的话可以自己去了解。

{% endnote %}

梯度下降与正规方程比较如下：

| 梯度下降                    | 正规方程                    |
| --------------------------- | --------------------------- |
| 需要学习率$\alpha$          | 不需要                      |
| 需要多次迭代                | 只需要一次计算              |
| 特征数量$n$很大时也较好适用 | 特征数量$n$过大时将无法接受 |
| 适用于各类模型              | 仅适用于线性模型            |

---

![50140585_p0](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/50140585_p0.jpg?x-oss-process=style/blog)

---
title: Coursera-ML-AndrewNg-Notes-Week1
date: 2024-10-30 12:50:11
updated: 2026-01-07 15:56:22
tags:
  - Machine Learning
  - Linear Regression
categories: Machine-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/b887646c5f1680f1750aaad7fbedc57.png?x-oss-process=style/blog
description: My notes of Coursera-ML-AndrewNg-Week1, which introduces what is ML and explain how linear regression to solve problem.
---


{% span center logo large, Coursera-ML-AndrewNg-Notes-Week1 %}

{% span center small, My machine learning notes %}

文章主要整理一下吴恩达机器学习教学视频的笔记，这里是Week1部分，链接放在下方：

{% btn 'https://www.bilibili.com/video/BV1Bq421A74G?spm_id_from=333.788.videopod.episodes&vd_source=5e421b52b9103cce8e012430aa932553',Machine Learning Specialization,far fa-hand-point-right,block center larger %}

{% note warning flat %}
不保证能该系列更新完毕，~~因为笔者太菜~~。
{% endnote %}

## What is Machine Learning?

> "Field of study that gives computers the ability to learn without being explicitly programmed."
>
> Arthur Samuel (1959)

机器学习是一种利用算法和统计模型来使计算机系统从数据中自动改进其表现的人工智能方法，而不依赖于显式的编程。其核心思想是通过从数据中学习经验或模式，使得计算机能够在没有人为干预的情况下对新数据进行预测或分类。

机器学习主要分为以下几类：

- **Supervised Learning**：即监督学习，基于标注数据训练模型，预测或分类新数据，如回归和分类任务。如今大部分机器学习采用的都是监督学习，也是这门课的重点介绍部分。

- **Unsupervised Learning**：即无监督学习在没有标注的数据上寻找数据的潜在结构，如聚类和降维。

- **Reinforcement learning**：即强化学习，通过与环境的交互、基于奖励和惩罚机制来优化策略，如游戏中的智能体训练。这门课程中介绍的部分较少，实际上可以作为一个单独的类别深入研究。

### Supervised Learning

监督学习是一种事先给定训练集（Training Set）和标注结果集（Target Set），让机器学习数据集中由$X$到$Y$的映射关系$f$，从而实现预测新的数据的目标。

比如房屋价格预测，给定一组数据对$<s^{(i)},w^{(i)}>$，其中$s^{(i)}$代表房屋面积，$w^{(i)}$代表房屋价格。机器通过学习面积$s$与价格$w$的映射关系，找到一个最优拟合的函数$f$。这样，当给定一个房屋面积$s$时，模型可以提供一个相对合理的预测价格$w$。

{% note info simple%}

$<s^{(i)},w^{(i)}>$中$s$和$w$的指数$(i)$并不是幂运算的意思，而是代表数据集中第$i$条对应的信息。

{% endnote %}

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241030105108665.png?x-oss-process=style/blog" alt="image-20241030105108665" style="zoom: 33%;" />

在实际中，训练数据集可以包含多个特征维度，这有助于提高模型的预测精度。例如，在利用机器学习诊断肿瘤良恶性的场景中，训练数据可以包括年龄、性别、肿瘤大小、厚度等多维度指标，模型最终输出良性或恶性预测。随着维度增加，模型学习的逻辑也会更加复杂。

至于机器学习是如何进行学习这个步骤的，下文将介绍一种用于监督学习的简单方法——线性回归（Linear Regression）。此外，非线性回归（Nonlinear Regression）也可以被采用，如利用抛物线或曲线来替代线性函数，以获得更好的拟合效果，但相应的计算复杂度也会增加。

### Unsupervised Learning

非监督学习，即只给定Training Set而不给订标注结果的Target Set。在这种情况下机器将无法给出预测，而只能根据数据本身的特征给出数据的结构信息。一般运用场景为聚类或者降维。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241030105244154.png?x-oss-process=style/blog" alt="image-20241030105244154" style="zoom: 33%;" />

例如，在一个推荐场景中，当你阅读一篇关于熊猫在日本动物园成功繁育的新闻时，系统可能推荐相关的熊猫或动物园新闻。然而我相信并没有程序员会专门编写程序去推荐熊猫相关的新闻，而是通过机器的无监督学习，根据你当前阅读的新闻自动聚类相关内容，以生成个性化推荐。

非监督学习主要用于数据分类或结构发现，而不用于具体的预测任务。

## Linear Regression

在第一周，课程主要介绍了相对简单的线性回归来简述机器学习（监督学习）是怎么做到“学习”找到映射关系$f$，进而进行预测的。这本质上是个回归的统计学问题。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241030105542110.png?x-oss-process=style/blog" alt="image-20241030105542110" style="zoom:33%;" />

对于给定的一组数据，我们的目标是找到一个直线，使得它的拟合效果最好。定义回归直线方程为：

$$
\hat{y}^{(i)}=wx^{(i)}+b
$$
对于给定数据的标注结果$y^{(i)}$和回归方程的预测结果$\hat{y}^{(i)}$，定义误差为：

$$
error=\hat{y}^{(i)}-y^{(i)}
$$
为了避免符号带来的计算困难，我们对$error$进行平方处理，并依次相加求和，即计算回归曲线中各个数据点到线性回归直线的距离之和的平方：

$$
\sum\limits_{i=1}^{m} \left( \hat{y}^{(i)} - y^{(i)} \right)^2
$$
然而这个误差只会越来越大，为了避免误差随着$m$的增大而增大，我们选择对平方误差取均值，即乘以系数$\frac{1}{2m}$。

$$
\frac{1}{2m}\sum\limits_{i=1}^{m} \left( \hat{y}^{(i)} - y^{(i)} \right)^2
$$
这个$2$仅仅是为了最后得出的结果更加美观，实际上要不要这个$2$最后得到的结果意义都是正确的，后文会介绍这个“美观”的意义何在。

最后我们得到一个以参数$\theta$为特征函数的**代价函数**：

$$
J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \left( h_\theta(x^{(i)}) - y^{(i)} \right)^2
$$


其中：$h_\theta(x) = \hat{y} = \theta^T X = \theta_0 x_0 + \theta_1 x_1 + \theta_2 x_2 + \cdots + \theta_n x_n$

参数$\theta$即为输入的变量，是一个矩阵。${\theta }^{T}$即为矩阵的转置。在单变量时linear regression时参数$\theta$为一个一维变量，也就是一个标量。

{% note info simple%}

在机器学习中，代价函数、损失函数、成本函数指的是同一个东西。

{% endnote %}

我们的目的是求得使代价函数$J(\theta)$最小时的参数$\theta_{min}$，意味着此时的拟合效果最好。如何求$\theta_{min}$呢？在机器学习中一个广泛运用的算法是**梯度下降法**，该方法能够高效地找到函数的局部最小值。

### Gradient Descent

梯度下降法（Gradient Descent）是一种用于寻找函数局部最小值的迭代优化算法。该方法的核心思想是从一个初始点开始，沿着目标函数的梯度（即最陡上升方向的反方向）迭代更新参数，直到找到函数的最小值。每次迭代更新参数的公式如下：

$$
\theta_{\text{new}} = \theta_{\text{old}} - \alpha \nabla_{\theta} J(\theta_{\text{old}})
$$
这里$\theta_{\text{new}}$是更新后的参数，$\theta_{\text{old}}$是更新前的参数，$\alpha$是学习率（一个正的常数，控制步长大小），$\nabla_{\theta} J(\theta_{\text{old}})$是代价函数$J$在当前参数$\theta_{\text{old}}$处的梯度。梯度的计算方法如下：

$$
\nabla f = \left( \frac{\partial f}{\partial x_1}, \frac{\partial f}{\partial x_2}, \ldots, \frac{\partial f}{\partial x_n} \right)
$$
即对各个变量求偏导，详见：[梯度（数学名词）](https://baike.baidu.com/item/梯度/13014729?fr=ge_ala)。由于代价函数$J$总是带有一个平方多项式，所以对其求偏导的过程永远会下来一个$2$，恰好与之前为了美观而强行加入的参数$\frac{1}{2}$相约分，这就是美观的意义所在。

{% note danger simple %}

梯度下降法只能只能找到**局部最小值**而不是**全局最小值**。对于一个凸函数而言，它的局部最小值总是全局最小值，然而如果函数为非凸函数（如深度学习中的神经网络）就不一定了。事实上，对于不同的变量值，运用梯度下降法所陷入的局部最小值并不一定相同，所以梯度下降法无法保证在非凸函数中一定会找到全局最小值。

如何找到全局最小值呢？我们可以用多起点梯度下降，或者采取模拟退火、遗传算法、粒子群算法等全局优化算法求解。然而这些全局优化算法需要大量的迭代和计算，尤其是当参数空间大或模型复杂时，计算成本会显著增加。对于非凸问题，尽管存在多个局部最小值，但研究发现这些局部最小值的性能相差不大，甚至有些局部解在泛化性能上更优。

所以我们还是常常使用梯度下降法来求解最小值。

{% endnote %}

回顾梯度下降法的计算公式：$\theta_{\text{new}} = \theta_{\text{old}} - \alpha \nabla_{\theta} J(\theta_{\text{old}})$。这里的学习率$\alpha$如何取值？答案是**适当**就好。

- 如果$\alpha$取值太小，那么梯度下降的过程将非常缓慢，相应的计算成本就越高，但是下降过程更平滑，最后得到的拟合效果更好。
- 如果$\alpha$取值太大，那么将会出现由于步长太大而“左右横跳”的情况（想象代价函数是一个二次函数，而你的步长太大将导致参数$\theta$的取值在对称轴两侧跳来跳去）。极端的情况甚至会导致梯度下降函数无法收敛，变成发散函数。

所以学习率$\alpha$的取值完全就是凭感觉（比如取个0.01），~~这也是机器学习为什么好水论文的一个缩影吧~~。

即便你正确的选择了学习率$\alpha$，梯度下降过程中也会不可避免的出现*学习率衰退*。因为梯度下降法的本质就是沿着函数在当前该点的切线（导数方向/梯度向量）移动一个很小的距离（学习率），而随着变量不断趋于局部最小，导数会逐渐平缓趋于0，所以下降的过程也会更为缓慢。

{% image https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241030115344324.png?x-oss-process=style/blog, width=400px, alt=代价降低速率逐渐减缓，但总是在降低。 %}

### Batch Gradient Decent

批量梯度下降（batch gradient decent）和梯度下降原理相同，只不过每次计算梯度时都会用到所有的数据进行计算，在更新参数时基于所有数据点的误差进行调整，所以称为batch。这种方法对收敛效果较为稳定，但在数据集非常大的情况下，计算代价较高，且内存占用大。有些算法中计算梯度并不会计算所有数据，而是取数据的子集进行计算。比如随机梯度下降和小批量梯度下降。

### Conclusion

要运用梯度下降法求解线性回归问题，我们主要运用到三条公式：
$$
\begin{cases}
    J(\theta) = \frac{1}{2m} \sum_{i=1}^{m} \left( \hat{y}^{(i)} - y^{(i)} \right)^2 \\
    \hat{y}^{(i)} = f_{w,b}(x^{(i)}) = wx^{(i)} + b \\
    \theta_{\text{new}} = \theta_{\text{old}} - \alpha \nabla_{\theta} J(\theta_{\text{old}})
\end{cases}
$$
因为线性回归只有$w$和$b$两个参数，我们可以很方便地对其求偏导从而计算出这两个参数的梯度迭代公式：
$$
\begin{aligned}
w_{\text{new}} &= w_{\text{old}} - \alpha \frac{1}{m} \sum_{i=1}^{m} \left( f_{w, b}(x^{(i)}) - y^{(i)} \right) x^{(i)} \\
b_{\text{new}} &= b_{\text{old}} - \alpha \frac{1}{m} \sum_{i=1}^{m} \left( f_{w, b}(x^{(i)}) - y^{(i)} \right)
\end{aligned}
$$
通过设置学习率$\alpha$和迭代次数$i$，每次迭代计算参数$\theta$，从而求解出最小代价时的参数$\theta_{min}$，也就是$w_{min},b_{min}$。最终可以得到拟合效果最优的线性回归直线方程：$f(x)=w_{min}x+b_{min}$。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20241030123140570.png?x-oss-process=style/blog" alt="image-20241030123140570" style="zoom:80%;" />

---

![b887646c5f1680f1750aaad7fbedc57](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/b887646c5f1680f1750aaad7fbedc57.png?x-oss-process=style/blog)

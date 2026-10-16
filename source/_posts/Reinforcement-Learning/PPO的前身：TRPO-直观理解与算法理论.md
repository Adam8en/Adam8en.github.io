---
title: PPO的前身：TRPO 直观理解与算法理论
date: 2026-10-15 21:27:15
updated: 2026-10-15 21:27:15
tags:
  - Reinforcement-Learning
  - TRPO
categories: Reinforcement-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261016142854053.png?x-oss-process=style/blog
description: 主要详细的介绍了TRPO的数学推导流程
---

{% span center logo large, RL笔记 · 五 %}

{% span center small, PPO的前身：TRPO 直观理解与算法理论 %}

## TRPO

TRPO算法的全称是：**T**rust **R**egion **P**olicy **O**ptimization，翻译一下就是置信域策略优化。

什么是置信域呢？就是旧策略的邻域。

> 邻域的概念学过数学分析的话应该都很熟悉，就是样本点附近的一小块区域。在二维数轴，可以表示为$(x-\delta,x+\delta)$，$\delta$是一个很小的实数；在三维空间中，则可以理解为以样本点为中心，半径很小的一个球；多维空间中依此类推。

那么置信域策略优化，顾名思义，就是在旧策略的邻域里优化策略。我们用KL散度来衡量新旧策略的远近，并将其限制在阈值内。关于KL散度的具体信息会在后续介绍。

TRPO最突出的一点在于，它从理论上证明了自己是单调改进的。之前我们学习的很多算法，不管是Q-learning还是QAC，在进行梯度下降/上升时如果更新步长/步子迈得太大的话，是有可能越过极值点导致性能下降的。而TRPO从数学上证明，这套算法的更新改进一定是上升的，这无疑是一块里程碑式的成就。

接下来我们来详细讲解TRPO的推导过程。

## 推导流程

首先，我们需要知道我们的优化目标是什么，在TRPO中，我们的优化目标是新旧策略的期望回报。

### 期望回报

我们定义策略 $\pi$ 的期望回报为：
$$
\eta(\pi) = \mathbb{E}_{s_0, a_0, \cdots} \left[ \sum_{t=0}^{\infty} \gamma^t r(s_t) \right]
$$
这个式子不难理解，内部其实就是discounted return折扣回报，外部对其求一次期望。新旧策略的期望是有一个差值的，Kakade & Langford, 2002的工作证明了
$$
\text{新策略的期望回报} = \text{旧策略的期望回报} + \text{新策略在旧策略优势函数上的累计期望}
$$
用数学公式表达如下：
$$
\eta(\tilde{\pi}) = \eta(\pi) + \mathbb{E}_{s_0, a_0, \cdots \sim \tilde{\pi}} \left[ \sum_{t=0}^{\infty} \gamma^t A_\pi(s_t, a_t) \right]
$$
对于第二项中的$A_\pi(s_t, a_t)$，这就是我们先前在Actor-Critic算法中引入的优势函数，其含义是在采取策略$\pi$时，执行动作$a_t$带来的动作价值与状态$s_t$下采取所有动作$a$的加权平均值之差，也可以表达为$Q(s_t,a_t) - V(s)$，用于衡量当前动作优于平均表现的程度。

我们知道，期望具有线性性质。若级数收敛，则求期望和求无穷级数可以交换顺序，因此我们可以得到：
$$
\mathbb{E}_{s_0, a_0, \cdots \sim \tilde{\pi}} \left[ \sum_{t=0}^\infty \gamma^t A_\pi(s_t, a_t) \right] = \sum_{t=0}^\infty \gamma^t \cdot \mathbb{E}_{s_0, a_0, \cdots \sim \tilde{\pi}} \left[ A_\pi(s_t, a_t) \right]
$$

> 在继续推导TRPO前，这里我们先引入一个概念：折扣访问频率（状态占据度量）
> $$
> \rho_\pi(s) = P(s_0 = s) + \gamma P(s_1 = s) + \gamma^2 P(s_2 = s) + \cdots
> $$
> 它其实就是把策略$\pi$下的每个状态出现频率前乘以一个对应的折扣率$\gamma$，表示状态 $s$ 在策略 $\pi$ 下的长期权重
>
> 我们把经过 $t$ 步后处于状态 $s$ 的折扣概率求和，就得到这么一个式子：
> $$
> \rho_{\tilde{\pi}}(s) = \sum_{t=0}^\infty \gamma^t \cdot \mathbb{P}_{s_0 \sim d, \tilde{\pi}} [s_t = s]
> $$

如果我们将 $A_\pi(s_t, a_t)$ 视为随机变量，则它的期望可以分解为：

$$
\mathbb{E}_{s_0, a_0, \cdots \sim \tilde{\pi}} [A_\pi(s_t, a_t)] = \sum_s \sum_a A_\pi(s, a) \cdot \mathbb{P}_{s_0, a_0, \cdots \sim \tilde{\pi}} (s_t = s, a_t = a)
$$

对求和部分的第二项，我们把联合概率拆成边缘概率与条件概率的乘积：

$$
\mathbb{P} [s_t = s, a_t = a] = \mathbb{P} [s_t = s] \cdot \mathbb{P} [a_t = a \mid s_t = s]
$$

由于强化学习是马尔可夫链，即动作选择仅依赖当前状态，我们尽量用初状态和策略去表示。先说$\mathbb{P} [a_t = a \mid s_t = s]$，它其实可以直接用策略函数来表示：

$$
\mathbb{P} [a_t = a \mid s_t = s] = \tilde{\pi}(a \mid s)
$$

我们把$\mathbb{P} [s_t = s, a_t = a]$用马尔科夫链的形式表达为$\mathbb{P}_{s_0, a_0, \cdots \sim \tilde{\pi}} (s_t = s, a_t = a)$，再代入上式，就得到了：
$$
\mathbb{P}_{s_0, a_0, \cdots \sim \tilde{\pi}} (s_t = s, a_t = a) = \mathbb{P}_{s_0, a_0, \cdots \sim \tilde{\pi}} (s_t = s) \cdot \tilde{\pi}(a \mid s)
$$

把这个式子代回$A_\pi(s_t, a_t)$优势函数的期望表达式中，就得到了：
$$
\mathbb{E}_{s_0, a_0, \cdots \sim \tilde{\pi}} [A_\pi(s_t, a_t)] = \sum_s \sum_a A_\pi(s, a) \cdot \mathbb{P}_{s_0, a_0, \cdots \sim \tilde{\pi}} (s_t = s) \cdot \tilde{\pi}(a \mid s)
$$
把折扣因子加上，就得到了完整的新策略在旧策略优势函数上的累计期望：
$$
\mathbb{E}_{s_0, a_0, \cdots \sim \tilde{\pi}} \left[ \gamma^t A_\pi(s_t, a_t) \right] = \gamma^t \cdot \left( \sum_s \sum_a A_\pi(s, a) \cdot \mathbb{P}(s_t = s) \cdot \tilde{\pi}(a \mid s) \right)
$$
我们把得到的期望关于$t$求和，就得到了：
$$
\sum_{t=0}^\infty \sum_s \sum_a \gamma^t \cdot A_\pi(s, a) \cdot \mathbb{P}(s_t = s) \cdot \tilde{\pi}(a \mid s)
$$
我们交换一下求和顺序，把关于$t$求和的无穷级数放在里面，得到：
$$
\sum_s \sum_a \left( \sum_{t=0}^\infty \gamma^t \cdot \mathbb{P}(s_t = s) \right) \cdot \tilde{\pi}(a \mid s) \cdot A_\pi(s, a)
$$
注意到$\left( \sum_{t=0}^\infty \gamma^t \cdot \mathbb{P}(s_t = s) \right)$就是我们之前定义的折扣访问频率$\rho_{\tilde{\pi}}(s)$，将其代入，得到：
$$
\sum_s \rho_{\tilde{\pi}}(s) \sum_a \tilde{\pi}(a \mid s) A_\pi(s, a)
$$
因此，新策略的期望回报可以表示为：
$$
\eta(\tilde{\pi}) = \eta(\pi) + \sum_s \rho_{\tilde{\pi}}(s) \sum_a \tilde{\pi}(a \mid s) A_\pi(s, a)
$$
但这个式子依旧是不可计算的，因为公式的第二项中包含新策略本身$\tilde{\pi}$，我们只能用旧策略$\pi$来计算。因此，我们引入一个代理函数
$$
L_\pi(\tilde{\pi}) = \eta(\pi) + \sum_s \rho_\pi(s) \sum_a \tilde{\pi}(a \mid s) A_\pi(s, a)
$$

### 代理函数

这个代理函数的实质就是把新策略的折扣访问频率$\rho_{\tilde{\pi}}(s)$替换为旧策略的折扣访问频率$\rho_{\pi}(s)$，只保留了新策略的动作分布 $\tilde{\pi}(a \mid s)$。也就是把折扣访问频率当作固定的（用旧策略算），只让动作选择随着新策略变。这么做是因为折扣访问频率/状态分布对策略的变化不敏感，而动作分布直接决定了优势函数怎么被加权。

注意到，当 $\tilde{\pi} = \pi$ 时：
$$
L_\pi(\pi) = \eta(\pi) + \sum_s \rho_\pi(s) \sum_a \pi(a|s) A_\pi(s, a)
$$
而

$$
\sum_a \pi(a|s) A_\pi(s, a) = \sum_a \pi(a|s) \left( Q_\pi(s, a) - V_\pi(s) \right) = V_\pi(s) - V_\pi(s) = 0
$$

所以：

$$
L_\pi(\pi) = \eta(\pi)
$$

说明在旧策略处，代理函数的值等于真实目标函数的值。

对 $\tilde{\pi}$ 求梯度，在 $\tilde{\pi} = \pi$ 处：

$$
\nabla_{\tilde{\pi}} L_\pi(\tilde{\pi}) \bigg|_{\tilde{\pi} = \pi} = \nabla_{\tilde{\pi}} \eta(\tilde{\pi}) \bigg|_{\tilde{\pi} = \pi}
$$
也就是说，在旧策略 $\pi$ 处，$L_\pi$ 和 $\eta$ 的值相同且一阶梯度相同。那么在旧策略附近优化 $L_\pi$，就近似于优化 $\eta$。

### KL散度与TV散度

我们在上文提到，要在旧策略**附近**优化 $L_\pi$，才能近似于优化 $\eta$。如何定义这个“附近”呢？这里我们需要引入一个概念：KL散度。

对于两个离散的概率分布$p$和$q$，KL散度的定义为：

$$
D_{KL}(P||Q) = E_p \left[ \log \frac{P(x)}{Q(x)} \right] = \sum_i p_i \log \frac{p_i}{q_i}
$$

它用于衡量两个概率分布的**远近**，表示用$q$来近似$p$时的信息损失。

> 注意这里我们用词是“远近”而不是“距离”，因为“距离”一般需要满足两边之和大于第三边等定义，而对于概率分布来说并没有这种定义，所以用户“远近”表述更加得体。

除此之外，还有TV散度：

$$
D_{TV}(P||Q) = \frac{1}{2} \sum_i |p_i - q_i|
$$
根据Pinsker不等式 
$$
\|Q - P\|_{\text{TV}} \leq \sqrt{\frac{1}{2} D_{\text{KL}}(Q\|P)}
$$
将该不等式两边分别平方化简，就得到了
$$
D_{TV}(p\|q)^2 \leq D_{KL}(p\|q)
$$


论文证明了代理函数 $L_\pi$ 和真实的性能 $\eta$ 存在一个误差下界：
$$
\eta(\pi_{new}) \geq L_{\pi_{old}}(\pi_{new}) - \frac{4\epsilon\gamma}{(1 - \gamma)^2} \alpha^2
$$

其中 $\epsilon$ 为优势函数 $A_\pi(s, a)$ 在各个 $s$ 与 $a$ 上的最大值。
$$
\epsilon = \max_{s,a} |A_\pi(s, a)|
$$
而 $\alpha$ 为新旧两个策略在所有状态下的最大总变差散度，就是KL散度。我们把 $\frac{4\epsilon\gamma}{(1 - \gamma)^2}$ 视为一个常数 $C$，就得到了：
$$
\eta(\tilde{\pi}) \geq L_\pi(\tilde{\pi}) - C \cdot D_{KL}^{\max}(\pi, \tilde{\pi})
$$

### MM算法

我们把刚刚得到的不等式右边作为新策略的**性能下界**，就有：

$$
M(\pi) = L_\pi(\tilde{\pi}) - C \cdot D_{KL}^{\max}(\pi, \tilde{\pi})
$$

那么，只要我们提升 $M(\pi)$，或者说最大化 $M(\pi)$，就能保证 $\eta$ 的性能单调上升。通过不断提高下界的方式去优化目标函数，这种思想在VAE中也有体现。

这种算法叫做Minorization-Maximization，简称MM算法。它的做法就是每次迭代找到目标函数的一个下界函数，并且不断求这个下界函数的最大值。此时目标函数的性能一定是上升的，因为它必须要大于下界函数。

### 置信域

在下界函数中，我们追求 $L_\pi(\tilde{\pi})$ 更大，$C \cdot D_{KL}^{\max}(\pi, \tilde{\pi})$ 可被视为一个惩罚项。

但是，这个下界函数还是有一个问题。我们知道，$C = \frac{4\epsilon\gamma}{(1 - \gamma)^2}$，分母中含有 $(1 - \gamma)^2$ 。这就导致 $C$ 通常很大，也就是惩罚项的权重过高。它会大幅度抑制 $D_{KL}^{\max}(\pi, \tilde{\pi})$ 的更新，让每一轮的参数更新幅度过小。

我们的做法是将惩罚项改为置信域。将原来的问题：

$$
\underset{\theta}{\text{maximize}} \left[ L_{\theta_{old}}(\theta) - C \cdot D_{KL}^{\max}(\theta_{old}, \theta) \right]
$$

变成：

$$
\begin{array}{ll}
\underset{\theta}{\text{maximize}} & L_{\theta_{old}}(\theta) \\
\text{subject to} & \overline{D}_{KL}^{\rho_{\theta_{old}}}(\theta_{old}, \theta) \leq \delta
\end{array}
$$
同样是让 $L_{\theta_{old}}(\theta)$ 最大，我们将其变为了一个带约束条件的最大化问题。这里我们让KL散度小于等于一个阈值 $\delta$，同时把最大KL散度 $D_{KL}^{\max}$，变为了平均KL散度 $\overline{D}_{KL}^{\rho_{\theta_{old}}}$。

之所以这么做，是因为给最大KL散度做约束的话，要求所有状态的KL散度都小于某个值，这是难以实现的。而平均KL散度实际上约束的是旧策略访问到的状态的平均KL散度，相对于最大KL散度的约束没有那么高。平均KL散度的表示如下：

$$
\overline{D}_{KL}^{\rho}(\theta_1, \theta_2) := \mathbb{E}_{s \sim \rho} \left[ D_{KL}(\pi_{\theta_1}(\cdot|s) \parallel \pi_{\theta_2}(\cdot|s)) \right]
$$
它代表 $\pi_{\theta_1}$ 与 $\pi_{\theta_2}$ 在 $\rho$ 这么一个状态占据度量（即折扣访问频率）上，对它们的KL散度求期望。

### 重要性采样

这里又引入一个新概念：重要性采样

如果我们想计算 $E_{X \sim q}[f(X)]$，但是从$q$上采样可能并不方便。那么，我们可以做一些手脚：
$$
\begin{array}{rl}
\mathbb{E}_{X \sim q}[f(X)] &= \int f(x)q(x)dx \\
&= \int f(x) \cdot \frac{q(x)}{p(x)} \cdot p(x)dx \\
&= \mathbb{E}_{X \sim p} \left[ f(X) \cdot \frac{q(x)}{p(x)} \right]
\end{array}
$$

这样$X$ 就变成了从$p$上采样，其中 $\frac{q(x)}{p(x)}$ 称为重要性权重。将求期望的函数乘以一个重要性权重，我们就能把从 $p(x)$ 采样的样本修正到 $q(x)$ 分布下的期望估计。

而对于我们研究的问题

$$
\begin{array}{ll}
\underset{\theta}{\text{maximize}} & L_{\theta_{old}}(\theta) \\
\text{subject to} & \overline{D}_{KL}^{\rho_{\theta_{old}}}(\theta_{old}, \theta) \leq \delta
\end{array}
\qquad
L_{\theta_{old}}(\theta) = \mathbb{E}_{s \sim \rho_{\theta_{old}}, a \sim \pi_\theta} \left[ A_{\pi_{\theta_{old}}}(s, a) \right]
$$

*注：$\eta(\pi)$ 与这里研究的 $\theta$ 无关，所以我们将其从 $L_{\theta_{old}}(\theta)$ 省略了。*

$L_{\theta_{old}}(\theta)$ 指的是新策略 $\theta$ 相比于旧策略 $\theta_{old}$ 的性能改进期望，这里的 $a$ 需要从新策略 $\theta$ 里采样动作，可我们只能从旧策略 $\theta_{old}$ 里采样动作，因此使用重要性采样：
$$
\mathbb{E}_{a \sim \pi_\theta}[f(a)] = \mathbb{E}_{a \sim \pi_{\theta_{old}}} \left[ f(a) \cdot \frac{\pi_\theta(a|s)}{\pi_{\theta_{old}}(a|s)} \right]
$$

因此我们得到：
$$
L_{\theta_{old}}(\theta) = \mathbb{E}_{s \sim \rho_{\theta_{old}}, a \sim \pi_{\theta_{old}}} \left[ \frac{\pi_\theta(a|s)}{\pi_{\theta_{old}}(a|s)} \cdot A_{\pi_{\theta_{old}}}(s, a) \right]
$$

### 基于泰勒展开的近似

TRPO将目标函数$L$ 和平均KL散度都在 $\theta = \theta_{old}$ 附近做了近似：

- 目标函数 $L_{\theta_{old}}(\theta)$ 在 $\theta = \theta_{old}$ 做一阶泰勒展开
  $$
  L_{\theta_{old}}(\theta) \approx L_{\theta_{old}}(\theta_{old}) + \nabla_\theta L_{\theta_{old}}(\theta_{old}) \cdot (\theta - \theta_{old})
  $$

- 约束条件（平均KL散度）在 $\theta = \theta_{old}$ 做二阶泰勒展开

  对于平均KL散度泰勒展开的第一项与第二项：
  $$
  \overline{D}_{KL}(\theta_{old}, \theta_{old}) \quad \nabla_\theta \overline{D}_{KL}(\theta_{old}, \theta) \big|_{\theta = \theta_{old}}
  $$

  很容易看出，这两项其实都是0。因此，平均KL散度的二阶泰勒展开只剩下最后一项：
  $$
  \overline{D}_{KL}^{\rho_{\theta_{old}}}(\theta_{old}, \theta) \approx \frac{1}{2} \Delta\theta^T A \Delta\theta
  $$

  这里的 $\Delta\theta$ 为参数的更新量，$A$为平均KL散度在 $\theta_{old}$ 处的Hessian矩阵

> Hessian矩阵，其实就是多元函数二阶偏导数构成的一个对称矩阵。
>
> 比如 $f(X)$ 在 $X(0)$ 处的海森矩阵为
>
> $$
> \begin{bmatrix}
> \frac{\partial^2 f}{\partial x_1^2} & \frac{\partial^2 f}{\partial x_1 \partial x_2} & \cdots & \frac{\partial^2 f}{\partial x_1 \partial x_n} \\
> \frac{\partial^2 f}{\partial x_2 \partial x_1} & \frac{\partial^2 f}{\partial x_2^2} & \cdots & \frac{\partial^2 f}{\partial x_2 \partial x_n} \\
> \vdots & \vdots & \ddots & \vdots \\
> \frac{\partial^2 f}{\partial x_n \partial x_1} & \frac{\partial^2 f}{\partial x_n \partial x_2} & \cdots & \frac{\partial^2 f}{\partial x_n^2}
> \end{bmatrix}_{X^{(0)}}
> $$
>
> 因此，$A$ 就是
>
> $$
> \frac{\partial}{\partial \theta_i} \frac{\partial}{\partial \theta_j} \mathbb{E}_{s \sim \rho_\pi} \left[ D_{KL}(\pi(\cdot|s, \theta_{old}) \parallel \pi(\cdot|s, \theta)) \right] \bigg|_{\theta = \theta_{old}}
> $$

由此，原始问题由
$$
\begin{array}{ll}
\max_{\theta} & L_{\theta_{\text{old}}}(\theta) \\
\text{s.t.} & \overline{D}_{\text{KL}}(\theta_{\text{old}}, \theta) \leq \delta
\end{array}
$$
转化为
$$
\begin{array}{ll}
\max & g^T(\theta - \theta_{old}) \\
s.t. & \frac{1}{2}(\theta - \theta_{old})^T H(\theta - \theta_{old}) \leq \delta
\end{array}
$$

$g$ 就是刚才的 $\nabla_\theta L_{\theta_{old}}(\theta_{old})$，$H$ 就是刚才的海森矩阵。它把复杂的非线性优化变成了一个二次规划问题，而这个二次规划可以用拉格朗日法求解。

设 $\Delta\theta = \theta - \theta_{\text{old}}$，问题变成：

$$
\max_{\Delta\theta} g^T \Delta\theta \quad \text{s.t.} \quad \frac{1}{2} \Delta\theta^T H \Delta\theta \leq \delta
$$

解是：

$$
\Delta\theta = \sqrt{\frac{2\delta}{g^T H^{-1} g}} \cdot H^{-1} g
$$

即：

$$
\theta = \theta_{\text{old}} + \sqrt{\frac{2\delta}{g^T H^{-1} g}} \cdot H^{-1} g
$$

这就是 TRPO 的更新公式。

---

![image-20261016142854053](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261016142854053.png?x-oss-process=style/blog)

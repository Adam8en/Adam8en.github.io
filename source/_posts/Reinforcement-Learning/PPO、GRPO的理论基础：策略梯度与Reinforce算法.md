---
title: PPO、GRPO的理论基础：策略梯度与Reinforce算法
date: 2026-10-13 20:38:28
updated: 2026-10-13 20:38:28
tags:
  - Reinforcement-Learning
  - Policy-Gradient
categories: Reinforcement-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261013225314321.png?x-oss-process=style/blog
description: 探讨了value-based算法的不足，以及介绍了策略梯度定理的完整数学推导
---

{% span center logo large, RL笔记 · 三 %}

{% span center small, PPO、GRPO的理论基础：策略梯度与Reinforce算法 %}

## Value-based方法遇到的问题

在先前的学习中，我们探讨了Q-learning算法，以及DQN用神经网络代替Q表的优化。但总的来说，我们采取的策略都是最小化一个损失函数来逼近Q函数。这里的策略是隐式的，是基于值函数的，也就是Value-based。

但这么做会带来一个问题，假设我们有这么一个场景：扫地机器人需要清洁地板上的污渍，地板上除了污渍还有两群可爱的仓鼠，黑色的部分代表墙壁，如下图所示。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261013204758281.png?x-oss-process=style/blog" alt="image-20261013204758281" style="zoom:50%;" />

问题发生在当图中机器人经过红色区域时。当机器人从中间位置经过左边的红色区域时，它会感知到上方有墙壁（往上走撞墙给Q值扣分），而左边的区域是一片空白，那么显然机器人会学习到往左走这个动作；当机器人从中间位置经过右边的红色区域时，问题就产生了。机器人感知到上方有墙，但此时他所应该采取的动作应该是向右走，这就与先前学习的策略冲突了！

我们来系统地重述一遍问题：在两个红色区域里，机器人的感知态是相同的。在动作价值函数$Q(s,a)$中，输入s是智能体的感知态，而非环境的真实状态。所有共享同一感知态的真实状态（如图中的两个红色区域S~1~与S~2~），其动作$a$的Q值会被混合计算，此时S~1~与S~2~经验会混合更新S~alias~的Q值，导致智能体无法为S~1~与S~2~分别学习左/右的动作价值。

事实上，遇到这种情况最好的办法是在红色区域随机选取左右行动。但value-based值函数方法的策略是从Q值推导的副产品，本质是确定性策略，无法在S~alias~下稳定输出随机动作。因为 $\arg\max_a Q(s, a)$ 只能选一个动作；即使用 ε‌-greedy，随机性也是外加的、与环境无关的，无法学到“在 S~alias~下 50% 左、50% 右”这种依赖状态的随机策略。

总结一下，value-based的方法问题出在Q值与感知态的强绑定：

- ε‌-greedy无法学习随机策略
- 无法区分感知相同但需求不同的状态
- 确定性（准确定性/ε‌-greedy）策略无法应对非对称场景

## 如何解决：policy-based

在这种场景下，我们就不再学习值函数，转而直接显式学习策略，也就是policy-based。这样就可以学习到随机的策略，而不会一直被卡住。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261013211926039.png?x-oss-process=style/blog" alt="image-20261013211926039" style="zoom:50%;" />

policy-based不同于value-based追求最小化损失函数逼近Q值，它直接去优化策略$\pi$。

具体来说，我们先将策略参数化为：
$$
\pi_\theta(s) = P[A|s; \theta]
$$
意思是给定参数 $\theta$ ，将处于状态 $s$ 时的策略表述为采取各个动作的概率。我们通过优化 $\theta$，来让策略 $\pi_\theta(s)$ 变好，这样我们可以得到一个随机的策略，输出一个动作的概率分布。

如何优化 $\theta$ 呢？我们定义一个目标函数 $J(\theta)$，$J(\theta)$ 代表的是预期的累计奖励。我们让 $J(\theta)$ 最大，就找到了最优策略。之前我们让损失函数最小时使用的是梯度下降方法，那么在追求目标函数最大时，我们就采用梯度上升。

其实就是把梯度下降的步骤反过来，对函数求梯度，沿着梯度方向更新参数即可。

话都说到这份上了，接下来我们就该对 $J(\theta)$ 求梯度了。首先我们定义目标函数 $J(\theta)$ 为：
$$
J(\theta) = \sum_\tau P(\tau; \theta) R(\tau)
$$

其中 $\tau$ 代表一个 trajectory 轨迹。接着，对 $J(\theta)$ 求梯度：

$$
\begin{array}{rl}
\nabla_\theta J(\theta) &= \nabla_\theta \sum_\tau P(\tau; \theta) R(\tau) \\
&= \sum_\tau \nabla_\theta P(\tau; \theta) R(\tau) \\
&= \sum_\tau \frac{\nabla_\theta P(\tau; \theta)}{P(\tau; \theta)} P(\tau; \theta) R(\tau)
\end{array}
$$
最后一步得到$\sum_\tau \frac{\nabla_\theta P(\tau; \theta)}{P(\tau; \theta)} P(\tau; \theta) R(\tau)$ 是有意为之的，因为我们知道对 $\log$ 函数求导的形式为：
$$
\nabla_x \log f(x) = \frac{\nabla_x f(x)}{f(x)}
$$
因此注意到（我知道你要说什么），我们有：
$$
\frac{\nabla_\theta P(\tau; \theta)}{P(\tau; \theta)} = \nabla_\theta \log P(\tau; \theta)
$$
也就是说，目标函数的导数 $\nabla_\theta J(\theta)$ 可以表示为：
$$
\nabla_\theta J(\theta) = \sum_\tau P(\tau; \theta) \nabla_\theta \log P(\tau; \theta) R(\tau)
$$
这一步其实符合对期望定义的展开式：
$$
E[X] = \sum_{\text{所有可能结果 } \tau} P(\tau) X(\tau)
$$
也就是说，轨迹 $\tau$ 发生的概率为$P(\tau; \theta)$，对应值为 $\nabla_\theta \log P(\tau; \theta) R(\tau)$，我们把 $\nabla_\theta J(\theta)$ 转写为期望表达式：
$$
\begin{array}{rl}
\nabla_\theta J(\theta) &= \sum_\tau P(\tau; \theta) \nabla_\theta \log P(\tau; \theta) R(\tau) \\
&= E_{\tau \sim P(\tau; \theta)} \nabla_\theta \log P(\tau; \theta) R(\tau)
\end{array}
$$
而根据大数定律，从独立同分布的样本里采样，最终样本均值会收敛到理论的期望，我们可以用采样均值来近似期望值。
$$
\nabla_\theta J(\theta) = \frac{1}{m} \sum_{i=1}^m \nabla_\theta \log P(\tau^{(i)}; \theta) R(\tau^{(i)})
$$

其中 $\tau^{(i)}$ 表示采样出来的一条轨迹。接下来我们要对 $\nabla_\theta \log P(\tau^{(i)}; \theta)$ 进一步化简，我们先把$P(\tau; \theta)$拆开。我们先前说过，轨迹 $\tau$ 本质上是state-action-reward chain。因此，$P(\tau; \theta)$可被视为一连串独立步骤的概率连乘，类似于数理统计中观测与事件的关系。
$$
P(\tau; \theta) = \prod_{t=0} P(s_{t+1} | s_t; a_t) \pi_\theta(a_t | s_t)
$$

我们再把公式改写为 $\tau^{(i)}$ 的形式，代表我们是从轨迹的第 $i$ 步开始采样。
$$
P(\tau^{(i)}; \theta) = \mu(s_0) \prod_{t=0}^H P\left(s_{t+1}^{(i)} \mid s_t^{(i)}, a_t^{(i)}\right) \pi_\theta\left(a_t^{(i)} \mid s_t^{(i)}\right)
$$

将结果代回 $\nabla_\theta \log P(\tau^{(i)}; \theta)$：
$$
\nabla_\theta \log P(\tau^{(i)}; \theta) = \nabla_\theta \log \left[ \mu(s_0) \prod_{t=0}^H P\left(s_{t+1}^{(i)} \mid s_t^{(i)}, a_t^{(i)}\right) \pi_\theta\left(a_t^{(i)} \mid s_t^{(i)}\right) \right]
$$

这里就变成了数理统计中非常简单的取对数化简法，将对数连乘表示为对数连加：
$$
\nabla_\theta \log P(\tau^{(i)}; \theta) = \nabla_\theta \left[ \log \mu(s_0) + \sum_{t=0}^H \log P\left(s_{t+1}^{(i)} \mid s_t^{(i)}, a_t^{(i)}\right) + \sum_{t=0}^H \log \pi_\theta\left(a_t^{(i)} \mid s_t^{(i)}\right) \right]
$$

我们把括号拆开，分别对三个部分应用求导：
$$
\nabla_\theta \log \mu(s_0) + \nabla_\theta \sum_{t=0}^H \log P\left(s_{t+1}^{(i)} \mid s_t^{(i)}, a_t^{(i)}\right) + \nabla_\theta \sum_{t=0}^H \log \pi_\theta\left(a_t^{(i)} \mid s_t^{(i)}\right)
$$

注意到，前两个部分求导部分与参数 $\theta$ 无关，故为0。因此我们的式子就被化简如下：
$$
\nabla_\theta \log P(\tau^{(i)}; \theta) = \nabla_\theta \sum_{t=0}^H \log \pi_\theta\left(a_t^{(i)} \mid s_t^{(i)}\right)
$$

再把 $\nabla_\theta \log P(\tau^{(i)}; \theta)$ 代回 $\nabla_\theta J(\theta) = \frac{1}{m} \sum_{i=1}^m \nabla_\theta \log P(\tau^{(i)}; \theta) R(\tau^{(i)})$，我们就得到了策略梯度$J(\theta)$ 在采样估计下的表达式：
$$
\nabla_\theta J(\theta) = \hat{g} = \frac{1}{m} \sum_{i=1}^m \sum_{t=0}^H \nabla_\theta \log \pi_\theta\left(a_t^{(i)} \mid s_t^{(i)}\right) R(\tau^{(i)})
$$

这个采样估计式所逼近的理论期望，就是策略梯度的精确表达式：
$$
\nabla_\theta J(\theta) = \mathbb{E}_{\tau \sim P(\cdot; \theta)} \left[ \sum_{t=0}^H \nabla_\theta \log \pi_\theta(a_t \mid s_t) R(\tau) \right]
$$
也就是说，前者是用 m 条采样轨迹对后者做的 Monte Carlo 估计。它的直觉是：

* 如果一条轨迹回报高（$R(\tau)$ 大），就增大这条轨迹里所有动作的概率 $\rightarrow$ 让模型更倾向于重复这些动作
* 如果一条轨迹回报低（$R(\tau)$ 小或负），就减小这条轨迹里所有动作的概率 $\rightarrow$ 让模型避免这些动作
* $\nabla_\theta \log \pi_\theta(a_t|s_t)$ 是“增大动作 $a_t$ 概率”的方向
* $R(\tau)$ 是权重，决定“这个方向要加多少”

一句话概括就是：好的轨迹，让它的动作更可能发生；坏的轨迹，让它的动作更不可能发生。

综上所述，我们可以总结出策略梯度定理 $\nabla_\theta J(\theta) = \mathbb{E}_{\tau \sim P(\cdot; \theta)} \left[ \sum_{t=0}^H \nabla_\theta \log \pi_\theta(a_t \mid s_t) R(\tau) \right]$。该定理给出了策略梯度的精确形式，但是期望难以计算，我们选择使用Reinforce算法（Monte Carlo策略梯度）去逼近结果

- 首先用当前策略走一条完整的轨迹
- 倒推计算这条轨迹中每个时间步的累计回报
- 相乘得到一条轨迹的梯度估计
- 沿着梯度上升的方向更新策略 $\theta \leftarrow \theta + \alpha \hat{g}$
- 重复上述步骤，直到策略收敛

---

![image-20261013225314321](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261013225314321.png?x-oss-process=style/blog)

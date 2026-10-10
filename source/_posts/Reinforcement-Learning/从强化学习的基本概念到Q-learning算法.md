---
title: 从强化学习的基本概念到Q-learning算法
date: 2026-10-10 16:22:56
updated: 2026-10-10 16:22:56
tags: 
  - Reinforcement-Learning
  - Q-learning
categories: Reinforcement-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261010163953905.png?x-oss-process=style/blog
description: 强化学习的基础概念学习，说说基本概念、贝尔曼公式和Q-learning
---

{% span center logo large, RL笔记 · 一 %}

{% span center small, 从强化学习的基本概念到Q-learning算法 %}

## 基本概念

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261009210613709.png?x-oss-process=style/blog" alt="image-20261009210613709" style="zoom:25%;" />

假设我们有一个Grid World，机器人在`s1`，尝试到达`s4`。其中`s3`是禁止区域，走到`s3`有惩罚，而走到`s4`有奖励。那么强化学习的目的，就是使得奖励最大化。强化学习的几个概念可以一一对应如下：

- state：状态。对应机器人目前处在哪个格子
- state space：状态空间。对应整个Grid World
- action：行动。向左走，还是向下走？
- action space of a state：状态的行动空间。对应机器人所有行动的集合
- transition dynamics：状态转移。描述机器人从一个grid到另一个grid
- reward function：奖励函数。对应当机器人采取了行动导致状态转移到的当时，我们给出的实数奖励。

在继续之前，我们回顾一下什么是笛卡尔积：

> 集合A和集合B的笛卡尔积，即取A的元素为第一个元素，B的元素为第二个元素的有序对组成的集合。

那么我们领状态空间为S，状态的行动空间为A，就有

- 状态转移函数P

  S × A → Δ(S)，Δ(S)表示S上的概率分布。得到下一个状态。

- 奖励函数R

  S × A → Δ( R )，Δ( R )表示实数域R上的概率分布。得到一个奖励实数。

- 策略policy

  策略是一种条件概率 S→ Δ(A)，表示状态到动作的映射

  比如 π(a~1~|s~1~) = 0, π(a~2~|s~1~) = 1。意味着在状态s~1~时采取动作a~2~的策略是确定的。

- 轨迹trajectory

  本质上是state-action-reward chain
  $$
  S_1 \xrightarrow[r=0]{a_3} \quad S_4 \xrightarrow[r=-1]{a_3} \quad S_7 \xrightarrow[r=0]{a_2} \quad S_8
  $$

- 回报return

  沿着trajectory的reward相加，我们就得到了return

- 折扣率discount rete

  我们有$\gamma \in[0,1)$，用以衡量当前奖励与未来奖励，目的是为了对不同时刻的reward做加权。

- 折扣返回discounted return

  对未来第$t$步的奖励，乘以一个折扣因子$\gamma^t$，这样距离当前越远的reward，权重越低。其中$t = 1,2,3,\dots$
  $$
  G_t = R_{t+1} + \gamma R_{t+2} + \gamma^2 R_{t+3} + \dots
  $$
  简便起见，下文提到的return均为discounted return。

- 状态价值state value，V

  S → R，将状态映射到实数域，表示当前状态的价值。具体来说，是从一个state触发，对各个trajectory的return求期望。
  $$
  v_\pi(s) = E[G_t|S_t=s]
  $$
  上面的公式表示：从状态s出发，遵循策略π时，未来所有回报的期望总和。

- 行动价值action value，Q

  S × A → R，将当前状态s的情况下采取a这个行动后，所得到的return求期望总和。
  $$
  Q_\pi(s,a)=E[G_t|S_t=s,A_t=a]
  $$

state value可以用来衡量策略的好坏。如果我们有
$$
v_{\pi2}(s)>v_{\pi1}(s)
$$
那么就认为策略π~2~优于π~1~。而如果我们有
$$
v_{\pi^*}(s)>v_{\pi}(s)
$$
对于任意的状态s和策略π都成立，则称π\*为最优策略。由此我们也可以衍生出：

- 最优state value V\*，即遵循最优策略π\*时，状态s的最大可能价值
- 最优action value Q\*，即遵循最优策略π\*时，(s,a)的最大可能价值

那么有了这些基础知识，我们就可以较为清晰的对强化学习下一个定义：**强化学习描述的是智能体以最大化累计奖励为目标，在与环境交互的过程中学习到最优策略的过程。**这个**交互**指的是智能体在不同状态依据当前的策略采取不同的行动，完成状态转移，同时环境向智能体反馈即时奖励。而智能体根据已知信息（状态、行动、及时反馈……）更新策略，最终学到最优策略π\*。

这也是即将介绍的Q-learning算法所遵循的核心思想

## 贝尔曼公式

我们知道，状态价值的公式是：
$$
v_\pi(s) = E[G_t|S_t=s]
$$
而$G_t$又可以表示为：
$$
\begin{array}{rl}
G_t &= R_{t+1} + \gamma R_{t+2} + \gamma^2 R_{t+3} + \cdots \\
    &= R_{t+1} + \gamma (R_{t+2} + \gamma R_{t+3} + \cdots) \\
    &= R_{t+1} + \gamma G_{t+1}
\end{array}
$$
我们将结果代回到状态价值的计算公式中，再结合期望的可加性，可以得到：
$$
\begin{array}{rl}
v_\pi(s) &= E[G_t \mid S_t = s] = E[R_{t+1} + \gamma G_{t+1} \mid S_t = s] \\
         &= E[R_{t+1} \mid S_t = s] + \gamma E[G_{t+1} \mid S_t = s]
\end{array}
$$
它们分别对应**即时奖励的期望**和**未来的折扣回报项**，接下来我们分别对这两个部分进行推导。

- $E[R_{t+1} | S_t = s]$ 代表状态s下，下一步奖励R~t+1~的期望。而R~t+1~不是直接确定的，而是取决于你先选了什么动作A。

  由全期望公式：
  $$
  E[X] = \sum_y E[X \mid Y = y] P(Y = y)
  $$
  这里把Y换成动作A~t~，X换成奖励R~t+1~，就得到：
  $$
  E[R_{t+1} \mid S_t = s] = \sum_a \underbrace{E[R_{t+1} \mid S_t = s, A_t = a]}_{\text{给定状态下选动作}a\text{后的期望奖励}} \cdot \underbrace{\pi(a \mid s)}_{P(A_t=a \mid S_t=s)}
  $$
  而对于内层的期望$E[R_{t+1} \mid S_t = s, A_t = a]$，在“状态s、动作a都给定”的情况下，奖励R~t+1~仍然是一个随机变量，它的分布就是环境给的奖励函数：
  $$
  p(r \mid s, a) = P(R_{t+1} = r \mid S_t = s, A_t = a)
  $$

  所以这个条件期望，按期望的定义（取值 × 概率，求和）就是：

  $$
  E[R_{t+1} \mid S_t = s, A_t = a] = \sum_r r \cdot p(r \mid s, a)
  $$
  由此我们可以推导出
  $$
  E[R_{t+1} | S_t = s] = \sum_a \pi(a \mid s) \sum_r p(r \mid s, a) r
  $$

- $E[G_{t+1} | S_t = s]$ 代表从当前状态s出发，对未来累计回报G~t+1~求期望。而G~t+1~的值不直接依赖于 S~t~，而是依赖于下一步转移到了哪个状态S~t+1~。所以，我们把 S~t+1~的所有可能取值 s′ 拿来遍历，乘以从 s 转移到 s‘ 的概率 $p(s' \mid s)$。应用全概率公式，得到
  $$
  E[G_{t+1} \mid S_t = s] = \sum_{s'} E[G_{t+1} \mid S_{t+1} = s'] p(s' \mid s)
  $$
  注意到价值函数的定义 $v_\pi(s') = E[G_{t+1} \mid S_{t+1} = s']$。之后，对$p(s' \mid s)$应用一次全概率公式，将其展开。得到：
  $$
  E[G_{t+1} | S_t = s] = \sum_{s'} v_\pi(s') \sum_a p(s' \mid s, a) \pi(a \mid s)
  $$

将推导结果代入回原式，我们就得到了完整的贝尔曼期望方程：
$$
v_\pi(s) = \sum_a \pi(a|s) \sum_r p(r|s,a)r + \gamma \sum_{s'} v_\pi(s') \sum_a \pi(a|s) p(s'|s,a)
$$
把两项合并，可以写成更紧凑的形式：
$$
\begin{array}{rl}
v_\pi(s) &= \textstyle \sum_a \pi(a|s) \left[ \sum_r p(r|s,a)r + \gamma \sum_{s'} p(s'|s,a) v_\pi(s') \right] \\
         &= \textstyle \sum_a \pi(a|s) \left[ R(s,a) + \gamma \sum_{s'} p(s'|s,a) v_\pi(s') \right]
\end{array}
$$
当前状态的价值 = 期望的即时奖励 + 折扣后的期望未来价值。这正是贝尔曼方程的核心思想。

## 贝尔曼最优公式

我们先前提到：
$$
v_\pi(s) = E[G_t|S_t=s] \\
Q_\pi(s,a)=E[G_t|S_t=s,A_t=a]
$$
可以得到：
$$
v(s) = \textstyle \sum_a \pi(a|s) Q(s, a)
$$
对于最优状态价值 $v_*$ ，可以表示为：
$$
v_*(s) = \textstyle \sum_a \pi_*(a|s) Q_*(s, a)
$$
也就是说，最优状态价值 $v_*$ 是所有动作价值 $Q_*(s, a)$ 按照策略$\pi^*$的加权平均。那么我们想要让 \(v_*\) 最大，只需把所有权重押在$Q$值最大的动作上即可。令 $\pi_*(a|s) =$

- 1，若$a = \text{argmax}_a Q_*(s, a) \qquad$
- 0， 其他

此时求和函数已经没有意义，可以进一步简化公式为：
$$
v_*(s') = \max_{a'} Q_*(s', a')
$$
这个式子表示，最优状态价值是最优动作价值的“最大值”。

再回到这个式子$v(s) = \textstyle \sum_a \pi(a|s) Q(s, a)$，对比我们之前推导的贝尔曼方程$v(s)=\sum_a \pi(a|s) \left[ R(s,a) + \gamma \sum_{s'} p(s'|s,a) v_\pi(s') \right]$，得到：
$$
Q(s, a)=R(s,a) + \gamma \sum_{s'} p(s'|s,a) v_\pi(s')
$$
将$Q$替换为最优动作价值$Q^*$，就有
$$
Q_*(s, a) = R(s, a) + \gamma \textstyle \sum_{s'} p(s'|s, a) v_*(s')
$$
再代入我们先前推导得出的$v_*(s') = \max_{a'} Q_*(s', a')$
$$
Q_*(s, a) = R(s, a) + \gamma \textstyle \sum_{s'} p(s'|s, a) \, max_{a'} Q_*(s', a')
$$
由于此时的$p(s' \mid s)$已经确定为1，所以该项可以直接化简消去，我们就得到了在确定性环境下的贝尔曼最优公式：
$$
Q_*(s, a) = R(s, a) + \gamma \, max_{a'} Q_*(s', a')
$$

## Q-learning算法

贝尔曼最优公式告诉了我们该如何求解最优动作函数最大值，即做什么action能收益最大化：取决于即时奖励R以及带折扣的下一个Q\*。我们要做的就是不断寻找最大的Q\*，从而学习到最优的action value函数Q*(s,a)，这就是Q-learning算法的初衷。

那么我们要如何做呢？Q-learning算法本质上就是要学习到一个行为状态s，列为动作a的表格。我们先初始化一个Q表，用它来存储对最优Q值的近似，不断更新。更新公式为：新估计值=旧估计值+步长×[目标-旧估计值]
$$
Q(s, a) \leftarrow Q(s, a) + \alpha \left( R(s, a) + \gamma \max_{a'} Q(S', a') - Q(s, a) \right)
$$
这里的步长$\alpha$，对应于机器学习中的学习率learning rate，概念是相似的。

直觉上：

* 如果 $Q(s, a)$ 比目标值小（低估了），括号里为正，$Q$ 就被调大。
* 如果$Q(s, a)$ 比目标值大（高估了），括号里为负，$Q$ 就被调小。
* 每次只走$\alpha$那么一小步，反复迭代，$Q$ 就会慢慢稳定到 $Q_*$。

在满足一定条件（每个 $(s, a)$ 被访问无限次、学习率满足 Robbins-Monro 条件）时，可以严格证明它以概率 1 收敛到最优$Q_*$，这里的最优$Q_*$就是我们刚才提到的贝尔曼最优公式。

顺带一提，这个更新式其实是一个通用的 TD（Temporal Difference，时序差分）更新模板：

$$
\text{新估计} \leftarrow \text{旧估计} + \alpha \times (\text{实际观察到的回报} - \text{旧估计})
$$
Q-learning的算法具体步骤如下：

1. 初始化Q表，元素全为0

2. 以$\epsilon$的概率**探索**，从动作空间中随机选择一个动作；以1-$\epsilon$的概率**利用**，选择当前状态下Q值最大的动作。这里的$\epsilon$是一个小概率。

3. 不断执行动作，获得环境反馈，包括：下一个状态s’，即时奖励r

4. 利用更新公式更新表格

5. 重复以上步骤，直到下一个状态达到终止条件，开启下一个episode。episode 结束后，下一个 episode 从初始状态重新开始（比如回到起点），但 Q 表要保留。

   终止条件包括：到达终点、撞墙次数达到上限、迭代步数达到上限·……

6. 直到Q表收敛，算法终止

> 看到这里，也许会有人和笔者一样仍然存在些许困惑。这个算法听起来一直都是动态的，如何保证Q表一定会收敛呢？
>
> 理论上，Q-Learning 的更新是一个压缩映射：
>
> $$
> Q_{k+1}(s, a) = R(s, a) + \gamma \max_{a'} Q_k(s', a')
> $$
>
> 只要 $\gamma < 1$，这个迭代无论从什么初始值出发，都会唯一收敛到 $Q_*$。全 0 初始化只是一个起点，完全合法。因此不需要一开始就知道$\max Q(S', a')$的真值，算法本身会在无数次迭代中把它磨出来。
>
> 和考研的压缩映射其实是同一个数学概念：
>
> 若存在常数$0 < k < 1$，使得对任意$x, y$都有
>
> $$
> |f(x) - f(y)| \leq k|x - y|
> $$
>
> 则称 $f$ 是一个压缩映射。此时迭代$x_{n+1} = f(x_n)$必收敛到唯一不动点$x^* = f(x^*)$。

## 参考

- [【零基础友好】【代码实战】从强化学习的基本概念到Q-learning算法 含代码讲解 含贝尔曼公式、贝尔曼最优公式的推导](https://www.bilibili.com/video/BV1Cmx9zgEDy/?spm_id_from=333.1387.collection.video_card.click&vd_source=5e421b52b9103cce8e012430aa932553)

---

![](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261010163953905.png?x-oss-process=style/blog)

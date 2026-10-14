---
title: 速通Actor-Critic算法与Advantage Actor-Critic算法
date: 2026-10-14 20:11:14
updated: 2026-10-14 20:11:14
tags:
  - Reinforcement-Learning
  - Actor-Critic
categories: Reinforcement-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261014225001175.png?x-oss-process=style/blog
description: 介绍了Reinforce算法的不足，以及基于Q函数与优势函数的两种Actor-Critic算法
---

{% span center logo large, RL笔记 · 四 %}

{% span center small, 速通Actor-Critic算法与Advantage Actor-Critic算法 %}

## Reinforce 算法的不足

在上一篇博客中，我们在末尾介绍了策略梯度，以及使用Reinforce 算法计算策略梯度的过程。但是，Reinforce 算法面临着两个问题：

- 方差大
- 必须要对整条轨迹采样才能计算

先说说第一个问题吧，为什么Reinforce 算法会导致数据方差很大？一句话来说，这是由它的无偏性所决定的。他没有估算回报，而是直接采样每条轨迹的真实回报。

我们可以用机器学习里的欠拟合与过拟合来理解。如果我们把训练集的数据点投影在二维的坐标系中，然后用一条直线去拟合数据的分布，那么这条直线的预测结果肯定是很差的。这种情况就是欠拟合，它的偏差很大，但是方差很低。因为对于一条直线来说，给出一个测试点$x_0$，直线的预测值都接近，但他们都系统性的偏离真实曲线。

那么如果我们让一条线弯弯拐拐穿过每一个数据点呢？那么就是过拟合。此时曲线的方差很大，但它可能是无偏的。这是因为过拟合太依赖某一批训练数据，它虽然拟合出了一定的规律，但是对噪声过于敏感，泛化到新数据集上表现很不稳定。

在强化学习里同样存在偏差和方差，他们是一组trade-off。比如Q-learning算法，它并不是无偏的。因为无论是Q-learning用Q表去拟合Q值，还是DQN用神经网络拟合Q值，都存在一定的偏差，那么他们的方差就比较小。而Reinforce 算法直接把真实轨迹的回报值拿来计算，它的偏差值为0，这就导致它的方差必然很大。

第二，Reinforce 算法既然要计算真实轨迹的回报值，那么他就必须等轨迹结束才能更新。也就是说，必须等一个episode结束才能求return。这无疑是低效的，而且还要求任务必须在有限步内结束。如果任务是无限步的，那么就无法采用Reinforce 算法。

由此，我们引入了本篇博客的主角：Actor-Critic算法

## 基于Q值的Actor-Critic算法

本文介绍两种基础的 Actor-Critic 更新形式：直接使用动作价值估计QAC，以及使用优势估计A2C。这里我们先介绍前者。但不管是QAC还是A2C，他们的核心思想都是一致的：用价值函数来替代MonteCarlo采样的总return，来指导策略更新。

首先，我们引入Actor（演员、行动者）：它的负责选取动作a，是一个由 $\theta$ 参数化的策略函数 $\pi_{\theta}(a|s)$，本质上就是给定状态$s$的情况下，输出一个包含$\theta$且关于$a$的分布函数。

然后，我们引入Critic（批评家）：它用于**评价动作的好坏**，而评估结果则用于指导Actor改进策略。

如果Critic用Q值（以防你忘记了，这是动作价值函数）来计算误差，则定义为基于Q值的Actor-Critic算法，也就是QAC。

在QAC中，Critic为价值网络，参数为$\omega$。它的目的是学习Q值，以逼近真实的逼近真实的 $Q_\pi(s, a)$。

> $Q_\pi(s, a)$就是基于策略$\pi$，在状态$s$下采取行动$a$的动作价值函数，可以衡量动作好坏。

这一点和DQN很像，但还有更像的，在Q-learning中，我们有：

- TD target: $r_t + \gamma \cdot \max Q(s_{t+1}, a'; w)$
- TD error: $r_t + \gamma \cdot \max Q(s_{t+1}, a'; w) - Q(s_t, a_t; w)$

> 这里的TD指的是Temporal Difference Learning，时序差分学习。TD 算法 = 用“当前估计”去更新“当前估计”，不需要等到 episode 结束，也不需要环境的完整模型。我们之前学习到Q-learning、DQN都属于TD算法。

而基于Q值的AC中，我们有：

- TD target: $r_t + \gamma \cdot q(s_{t+1}, a_{t+1}; w)$
- TD error: $r_t + \gamma \cdot q(s_{t+1}, a_{t+1}; w) - Q(s_t, a_t; w)$

注意，这里的 $q(s_{t+1}, a_{t+1}; w)$ 不同于 $\max Q(s_{t+1}, a'; w)$ ，后者表示最大的动作价值函数，也就意味着执行能够带来最大价值的动作；而前者只是到达新状态后进行一个动作采样，并不实际执行，然后拿采样结果减去 $t$ 时间步的Q值。

我们来详细地描述一下QAC的流程：

- Actor观测当前状态，按照当前策略随机执行一个动作

- Agent从环境获取即时反馈 $r_t$

- Actor按照当前的策略网络 $\theta$ 随机采样一个动作

- Critic用当前价值网络 $\omega$ 计算：

  当前状态动作对的估计价值 $\hat{q}_t$，对应 $Q(s_t, a_t; w)$

  下一个状态动作对的估计价值 $\hat{q}_{t+1}$，对应 $q(s_{t+1}, a_{t+1}; w)$

- 将上述结果代入，得到计算表达式：

  TD Target：$\hat{y}_t = r_t + \gamma \cdot \hat{q}_{t+1}$

  TD Error：$\delta_t = \hat{y}_t - \hat{q}_t$

- 梯度下降，更新参数

梯度下降方法也是老生常谈，这里把详细过程放在A2C中一起讲。

## Advantage Actor-Critic算法

QAC 用 $Q$ 值直接指导策略更新。但直接学 $Q(s, a)$ 会有一个问题：它需要为每个动作分别估计价值，网络负担重，而且方差仍然偏大。如果我们能把“动作好不好”这件事相对于“这个状态平均好不好”来评价，就能进一步降低方差——这就是 A2C 里优势函数的动机。

Advantage Actor-Critic算法又称A2C，它是通过优势函数 $A(s, a) = Q(s, a) - V(s)$ 作为预测误差来指导策略更新的。如果你还记得基础概念的话，$Q(s,a)$是在当前状态 $s$ 下执行动作 $a$ 的动作价值函数。而$V(s)$是状态价值函数，代表在当前状态下执行各个动作 $a$ 所得到的加权平均价值。

那么优势函数的含义其实就是：在状态 $s$ 下选动作 $a$，比状态 $s$ 的**平均动作价值**好多少。

我们用 $r_t + \gamma V_\omega(s_{t+1})$ 来近似 $Q$。

> $r_t + \gamma V_\omega(s_{t+1})$ 之所以能近似 $Q(s_t, a_t)$，是因为：
>
> 1. $Q(s_t, a_t) = r_t + \gamma \mathbb{E}[V^\pi(s_{t+1})]$ ，这个式子可以在先前推导贝尔曼方程时得出
> 2. 把期望换成单次采样的 $s_{t+1}$
> 3. 把真实 $V^\pi$ 换成估计网络 $V_\omega$

我们把近似值代回优势函数，此时预测误差可以写成
$$
\delta(t) = r_t + \gamma V_\omega(s_{t+1}) - V_\omega(s_t)
$$

- $\delta(t)$ 为正，本次采样结果好于当前价值网络的预期，Actor 据此提高该动作的概率。
- $\delta(t)$ 为负，本次采样结果差于预期，Actor 据此降低该动作的概率。

Critic的目标是让自己的预测更准确，更好地输出评估当前动作的价值。那么，Critic就应该不断修正自己的估计来让$\delta(t)$最小化（趋于0）。这意味着 $V_\omega(s_t)$ 可以更精确表示从状态 $s_t$ 出发的实际回报。批评家的评价越准确，演员的动作调整才越正确。

那么如何让 $\delta(t)$ 最小化呢？还是老三样：求损失函数、求损失函数梯度、梯度下降。

我们依旧定义平方损失误差：

$$
L(\omega) = \frac{1}{2} \left( r_t + \gamma V_\omega(s_{t+1}) - V_\omega(s_t) \right)^2
$$

对其求梯度，更新参数 $\omega$。
$$
\nabla_\omega L(\omega) = -\left( r_t + \gamma V_\omega(s_{t+1}) - V_\omega(s_t) \right) \nabla_\omega V_\omega(s_t)
$$

严格来说，这里其实是**半梯度**。因为$r_t + \gamma V_\omega(s_{t+1})$出现在TD 目标中，我们把这一项冻结，当做常数处理，只对$V_\omega(s_t)$部分求梯度。

接下来使用梯度上升来更新 Actor 策略网络参数$\theta$：
$$
\theta = \theta + \alpha_\theta \sum_t \delta_t \nabla_\theta \log \pi_\theta(a_t|s_t)
$$
有必要对这个式子进行解释。注意到这里我们对时间步 $t$ 进行了一次求和，去累计观测误差与$\nabla_\theta \log \pi_\theta(a_t|s_t)$ ，这里$\nabla_\theta \log \pi_\theta(a_t|s_t)$ 衡量的是参数 $\theta$ 调整时动作选择概率的变化率。而我们之所以要对 $t$ 求和，是因为这里也是对偏差与方差的一次trade-off。如果我们每一步都更新一次，又会陷入无偏性导致方差过大的窘境，让我们的策略非常不稳定，那么我们就把 $t$ 次的求和加在一起更新就好。

A2C 的核心贡献是：用 TD 误差 $\delta_t$ 作为优势函数的估计，代替 Reinforce 里的整条轨迹回报 $R(\tau)$。这样既保持了策略梯度的基本框架，又通过自举大幅降低了方差。它是 PPO、GRPO 等现代 On-policy 算法的直接前身。

## On-policy 与 Off-policy

最后，简单说说On-policy 与 Off-policy。

* on-policy: the target and the behavior policies are the same

  产出数据的策略和用这批数据做更新的策略是同一个

  智能体一边用某个策略与环境互动、产生行动，一边直接用这些自己刚做的行动和反馈来更新这个策略

* off-policy: the learning is from the data off the target policy

  产出数据的策略和用这批数据做更新的策略不是同一个

  学习时只关注最优可能的行动反馈，或者直接用其他策略的数据来更新目标策略

本文介绍的基础 Actor-Critic 更新方式以及标准 REINFORCE 属于 on-policy；Q-learning、DQN 属于 off-policy。

---

![image-20261014225001175](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20261014225001175.png?x-oss-process=style/blog)

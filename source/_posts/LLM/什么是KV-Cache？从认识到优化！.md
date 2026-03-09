---
title: 什么是KV Cache？从认识到优化！
date: 2026-03-09 21:09:19
updated: 2026-03-09 21:09:19
tags:
  - LLM
  - KV Cache
  - Attention
categories: LLM
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260309211638054.png?x-oss-process=style/blog
description: 从KV Cache到MHA再到GQA，一篇文章带你厘清。
---

{% span center logo large, 什么是KV Cache？ %}

{% span center small, 从KV Cache到MHA到GQA %}

## 背景

要理解KV Cache，必须要对自注意力的计算机制有一定的了解。我们从著名的 Attention 计算公式开始：
$$
\text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V
$$
具体来说，这里面其实包含了从微观（单个词）到宏观（整个句子矩阵）的过程：

**第一步：生成身份向量 (Q, K, V)**

我们首先把输入句子中的每个词转换为嵌入向量 $x_i$，然后让它分别与系统学到的 $W_Q, W_K, W_V$ 三个权重矩阵做乘法，得到每个词专属的 $q, k, v$ 三个向量。
$$
\begin{array}{ccc} x_1 \xrightarrow{W_Q} q_1, & x_1 \xrightarrow{W_K} k_1, & x_1 \xrightarrow{W_V} v_1 \\ x_2 \xrightarrow{W_Q} q_2, & x_2 \xrightarrow{W_K} k_2, & x_2 \xrightarrow{W_V} v_2 \\ ... & ... & ... \end{array}
$$

- **$q$ (Query)**：代表“我要找什么特征”，表示当前词的搜索意图。
- **$k$ (Key)**：代表“我有什么属性”，用于被其他词搜索和匹配。
- **$v$ (Value)**：代表“我有什么实质内容”，它是匹配成功后真正传递出去的信息。

**第二步：计算单个词的注意力（以 $x_1$ 为例）**

为了搞清楚 $x_1$ 应该吸收哪些上下文，我们用它的查询意图 $q_1$，分别去和句子里所有词的标签 $k_1, k_2, ..., k_n$ 做向量内积（点乘），算出匹配得分。

然后，把这些得分除以缩放因子 $\sqrt{d_k}$，再通过 Softmax 函数将它们转化为总和为 1 的**注意力权重**：
$$
\text{Attention Weights for } x_1 = \text{softmax}\left(\frac{[q_1 \cdot k_1, \ q_1 \cdot k_2, \ \dots, \ q_1 \cdot k_n]}{\sqrt{d_k}}\right)
$$

> *注：除以缩放因子 $\sqrt{d_k}$ 是为了防止向量内积的结果过大，导致处于 Softmax 极其平缓的区域，进而产生“梯度消失”现象。*

拿到百分比后，我们将这些权重分别乘以对应的实际内容 $v_1, v_2, ..., v_n$ 并求和。这就得到了 $x_1$ 结合了全局语境后的最终输出向量 $z_1$。

**第三步：拼成矩阵，一次性算完**

在深度学习框架中，为了利用 GPU 加速，我们不会写 for 循环一个个算 $x_i$。

我们将所有的 $x_i$ 堆叠成一个大的输入矩阵 $X$；同理，所有的 $q_i, k_i, v_i$ 也就堆叠成了大矩阵 $Q, K, V$。

此时，矩阵乘法 $Q K^T$ 就是并行完成所有词与所有词的内积打分。

算出来的结果是一个 $N \times N$ 的方阵（其中每一行，就是对应词的 Softmax 权重分布）。最后再将这个巨大的权重方阵乘以内容矩阵 $V$，就一次性得到了所有词的最终输出矩阵 $Z$。

这就是 $\text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$ 公式的完整物理意义。

**第四步：继续迭代，步入MHA**

单一的注意力容易钻牛角尖。拷贝多套相互独立的 QKV 矩阵，让模型能同时从多个角度去审视同一句话。每一组QKV矩阵视为一个“头”，也就是Head。顾名思义，引入多组头就是所谓的多头注意力机制Multi-Head Attention，用$head_i$表示每个头的输出结果。
$$
head_i = \text{Attention}(QW_i^Q, KW_i^K, VW_i^V)
$$
接下来我们把h个头拼接在一起特到最终的输出结果。
$$
\text{MultiHead}(Q, K, V) = \text{concat}(head_1, head_2, \dots, head_h) \cdot W_O
$$
$W_O$ 的作用是把各个视角的信息进行深度融合与降维，最终输出一个全面、立体的上下文特征表示。

**第五步：自回归预测，大模型发力**

LLM的本质是**next token prediction**，它是通过自回归（AR，Autoregressive）机制运行的。自回归的本质是根据前一段时间的数据预测下一时刻的数据，通俗来说，类似文字接龙游戏。
$$
x_{t+1} = f(x_t, x_{t-1}, \dots, x_{t-p+1})
$$
因为模型本身没有记忆，每次想让它吐出一个新词，都必须把完整的前文重新塞给它。

- **第 1 轮**：输入 `abc`。模型把 `a` `b` `c` 三个词放进 Transformer，并行算出它们的 Q、K、V，做完注意力计算，最后预测出下一个词是 `d`。 *(此时模型内部的计算全清空了，什么都没留下)*
- **第 2 轮**：让它继续写。因为模型失忆了，所以不能只喂给它 `d`，必须输入完整的 `abcd`。模型把 `a` `b` `c` `d` 四个词放进去，重新算出这四个词的 Q、K、V，预测出 `e`。 *(注意！这里的 `a` `b` `c` 的 Q、K、V 被完完整整地重新算了一遍！)*
- **第 3 轮**：输入完整的 `abcde`。模型重新算 `a` `b` `c` `d` `e` 的 Q、K、V，预测出 `f`。

以上就是 KV Cache 出现前，自回归大模型极其消耗算力的朴素工作机制。

## KV Cache的引入

了解完自回归大模型的背景后，我们会发现一个问题：

*假如我们要计算1000个token，从输入$x_1$开始，一直到输入$x_{999}$后模型输出$x_{1000}$结束。在这个过程中，$x_1$的$k_1$和$v_1$被重复计算了999次。*

显然，这造成了相当大的不必要计算开销。解决办法也很简单，就是把计算出的K和V矩阵存储起来。这样我们用当前的token值$x_i$计算出$q_i,k_i,v_i$后，把$k_i,v_i$和缓存的K和V矩阵拼接起来更新KV，再用$q_i$去与K、V矩阵运算得到它的注意力权重，计算最终的输出。如此，就避免了对之前输出的KV值重复运算。注意，在这个过程中Q并没有重复计算，所以不需要缓存矩阵Q。

引入KV Cache之后，我们再回头梳理一遍自回归大模型的运行机制，有必要厘清KV Cache机制是何时引入的。

**第一步：预填充（Prefill Phase）**

首先，用户输入提示词，假如输入的是 `abc`。

此时，模型会利用 GPU 强大的并行能力，一瞬间同时算出 `a` `b` `c` 初始的 Q、K、V，并将算出的 $K, V$ 矩阵直接存进显存里。这就是 KV Cache 的第一波写入。

最后，基于这段消化完毕的上下文，模型预测出第一个新词 `d`。

**第二步：解码阶段（Decode Phase）**

从这一步开始，KV Cache开始发力，算力消耗出现断崖式下跌。

因为显存里已经存了 `abc` 的回忆，我们不会再把 `abcd` 输进模型了。我们只把新生成的单词 `d` 塞进模型。

1. 模型只计算 `d` 这一个词的 $q_d, k_d, v_d$。
2. 更新 $K, V$ 矩阵，把新算出来的 $k_d, v_d$ 追加存进 KV Cache 里。
3. 当 `d` 需要联系上下文时，模型直接去Cache里把存好的 $K, V$ 矩阵读取出来，和当前的 $q_d$ 进行点乘打分。
4. 预测出新词 `e`。

同理，我们只把 `e` 塞进模型。算 $q_e, k_e, v_e$，更新K、V，去 Cache 里提款，算注意力，预测出 `f`。

这么做我们的确能够极大的加速大模型的推理，省略大量重复计算。但这本质上是一种以空间换时间的做法，当上下文特别长的时候，会出现KV的“显存爆炸”。而每张显卡的显存是有限的，为了解决这个矛盾，又有许多人提出了对KV Cache机制的优化。

## 对KV Cache的优化方案

**首先是 MQA (Multi-Query Attention)。**

MQA 的原理十分简单粗暴：Query 头保持多头不变，但强制所有注意力头共用同一套 KV Cache。理论上，它直接将 KV Cache 的显存占用减少到了原来的 $\frac{1}{h}$。这么做使得显存消耗大幅度降低，同时通过参数共享，效果损失也比较有限。

**再之后是 GQA (Grouped-Query Attention)。**

GQA 本质上是在 MQA 和 MHA 之间的折中方案：它依然保持 Query 的多头数量不变，但将所有的 Query 头分为 $g$ 个组（$g$ 是能整除 $h$ 的数字），同一组的 Query 头共用一套 KV Cache。

- 当 $g=h$ 时，相当于每个 Query 头都有自己独立的 KV，GQA 退化为 **MHA**。
- 当 $g=1$ 时，相当于所有 Query 头都被分在同一个大组里共用一套 KV，GQA 退化为 **MQA**。

GQA 的做法有点类似于计算机组成原理中 CPU Cache 的组相联映射 (Set-Associative Mapping)，在极端吃显存（MHA）和极端压缩（MQA）之间，找到一个最优雅的性能与精度的平衡点。这也是目前 LLaMA-3、Qwen-2 等主流开源大模型标配的底层架构。

## 参考资料

1. [【GQA】【MQA】【KV Cache初探】 7分钟从KV Cache的基础原理讲到后续优化_bilibili](https://www.bilibili.com/video/BV1EAp4z1EbJ/?spm_id_from=333.337.search-card.all.click&vd_source=5e421b52b9103cce8e012430aa932553)
2. [大模型推理加速：看图学KV Cache - 知乎](https://zhuanlan.zhihu.com/p/662498827)

---

![image-20260309211638054](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260309211638054.png?x-oss-process=style/blog)

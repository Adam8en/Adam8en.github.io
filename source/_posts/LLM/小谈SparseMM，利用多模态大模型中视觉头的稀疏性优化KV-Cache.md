---
title: 小谈SparseMM，利用多模态大模型中视觉头的稀疏性优化KV Cache
date: 2026-03-10 21:41:05
updated: 2026-03-10 21:41:05
tags:
  - LLM
  - SparseMM
  - Sparse Attention
categories: LLM
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310214707597.png?x-oss-process=style/blog
description: 《SparseMM：Head Sparsity Emerges from Visual Concept Responses in MLLMs》论文精读。
---

{% span center logo large, 小谈SparseMM %}

{% span center small, 利用多模态大模型中视觉头的稀疏性优化KV Cache %}

> 利用视觉头稀疏性进行 KV-Cache 优化的策略（Sparsity Emerges from Visual Concept Responses in MLLMs，简称 SparseMM）是由清华大学智能视觉实验室联合腾讯混元 X 组于 2025 年 6 月 5 日提出的一种键值缓存优化策略，它根据大语言模型中各注意力头的视觉得分，为其分配非对称的计算预算，相关论文成果为「[SparseMM: Head Sparsity Emerges from Visual Concept Responses in MLLMs](https://arxiv.org/abs/2506.05344)」。
>
> 与以往方法相比，SparseMM 在解码过程中优先强调并保留视觉语义。在主流多模态基准测试上的大量评估表明，SparseMM 实现了更优的精度—效率权衡。在效率测试中，SparseMM 实现了 1.38 倍的实时加速和 52% 的内存减少，同时保持了性能相当。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310210354279.png?x-oss-process=style/blog" alt="image-20260310210354279" style="zoom:67%;" />

## 正文

《SparseMM》提出了一个很巧妙的方法，用于识别出真正干活的“视觉头”——即在多模态任务处理时主要聚焦于图像而非文本的头，并且提出了一个惊人的发现：在多模态模型中视觉头具有稀疏性，仅占大约5%左右。而在多模态任务中，视觉token占比远高于文本token。基于这个发现，文章设计出了一种非对称分配KV Cache的方案，让真正参与视觉任务的“视觉头”得到大部分Cache，削减非视觉头的资源，从而实现降本增效。

首先我们来关注论文找到视觉头的算法。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310205509560.png?x-oss-process=style/blog" alt="image-20260310205509560" style="zoom:50%;" />

作者通过准备一组带文字的图片，并用OCR扫描处理，输出识别到的文字和文字所在的边界框，将其整理为`[文字，边界框]`格式的列表（这个边界框本质上是一组绝对坐标）。然后将图片输入MLLM，获得其输出output_token。最后，作者便按图索骥去寻找哪个头出力最多。

我们知道，MLLM主要由**视觉编码器**，**适配器**与一个基于纯文本训练的标准**LLM**组成。多模态数据首先经过视觉编码器被切割成固定长度的patch，将其flatten（拉平为一维向量）并被映射为视觉特征信息，适配器将视觉特征信息对齐到文本特征信息空间，再经过LLM获取最终输出结果。

知道MLLM的工作流程后，就可以看懂作者的实验思路。具体来说，作者在获取OCR扫描的`[文字，边界框]`列表与MLLM的输出output_token后：

- 首先遍历每一个output_token，找到和token相对应的`[文字，边界框]`组，提取其bbox（如果该token不对应OCR结果中的任何文字，就直接跳过该token）。
- 接着，匹配和该边界框对应的patch_id，再由patch_id定位文字所在图像被flatten到了一维序列中的哪个位置，我们把对应位置的序列集合记为image_tokens。

概括一下，就是**定位输出token对应的文字图像在进入LLM前的位置**，确定追踪对象。

确定完追踪对象后，作者遍历LLM的每一个层以及它的每一个头，寻找真正关注该对象的视觉头。具体来说，就是查看当前头的注意力矩阵Attention Matrix，找出Attention Matrix中权重最大的token序号，意味着当前头对这个token的关注度最高。如果关注度最高的token恰好在image_tokens中，意味着当前头高度关注图像上的文字部分，也就是找到了所谓视觉头。

我们给这个头加分 $\frac{1}{\#\text{image\_tokens}}$ ，这个$\#\text{image\_tokens}$代表image_tokens这个集合中的元素数量。这么做主要是给视觉头的作用加上一个权重，来评估其能力。这意味着更小（更精确）的区域会获得更高的分数，因为它们更难被捕捉。

最后，我们返回一个 $Score_{L \times H}$ 矩阵（即 $S$ 矩阵，L与H代表层数与头数），这个矩阵即LLM中所有头的视觉评估得分。

![image-20260310210323887](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310210323887.png?x-oss-process=style/blog)

有了 $S$ 矩阵，我们就可以确定给每个头分配的KV Cache大小。我们分配KV Cache的策略由三部分组成，假设KV Cache的总大小为 $B$ ：

1. Local Window Cache：局部窗口缓存。它规定每个token必须要缓存它的前 $w$ 个token的KV，默认取 $w = 32$ 。分配给LWC的总大小为 $w \times N$ ， $N$ 即头的数量。 

2. Uniform-Based Cache：统一基础的缓存，相当于低保，保证每一个头都留有那么一点Cache。这个值通过设置超参数 $\rho$ 来划分（ $\rho \in (0,1)$ ），比如 $\rho = 0.1$，那么就固定划分总量的10%作为UBC。每个头分到的大小 则可以表示为：
   $$
   r = \frac{\rho · (B - N · w)}{N}
   $$

3. Score-Preferred Cache：分数优先缓存，即根据 $S$ 矩阵得出的视觉得分来分配Cache。可供分配SPC的总大小可表示为：
   $$
   B_{\text{remain}}=B - N ·w - \rho(B-N·w)
   $$
   不难看出，SPC可分配的空间是巨大的，而它的分配方式也很简单，根据 $S$ 矩阵计算每个头的视觉关注权重即可。我们用 $s_{ij}$ 来表示 $S$ 矩阵 $i$ 行 $j$ 列的元素，可以确定每个头在SPC中应该分配的空间为：
   $$
   b_{ij}^{\text{score}} = B_{\text{remain2}} \cdot \frac{s_{ij}}{\sum_{i=1}^{L} \sum_{j=1}^{H} s_{ij}}
   $$

综上所述，对于任意一个头 head $(i,j)$ ，它的最终Cache分配为：
$$
b_{ij} = w + r +b_{ij}^{\text{score}}
$$
<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310210241292.png?x-oss-process=style/blog" alt="image-20260310210241292" style="zoom: 67%;" />

在确定了每个头的Cache最大容量后，我们需要选择把哪些token的KV放入Cache中。这里论文参考了SnapKV的方法引入了observation window，只取末尾的32个token的Q值与全部token的K值计算注意力，用得到的平均注意力权重分数选择前 $K$ 个token的KV缓存。而 $K= r +b_{ij}^{\text{score}}$ 。（注意，这里没有 $w$ ，因为这部分是LWC，规定存储的是距离最近的token，不由平均注意力决定）

这么做可以将原本的时间复杂度从 $O(N^2)$ 降低至 $O(N\times L)$ ，在这里 $L = 32$ 。显然，大大加快了计算速度。

## 感想

经典的Transformer架构需要对所有输入计算全局注意力，时间复杂度为 $O(N^2)$ ，尤其是处理长文本任务时，开销对于自回归大模型来说几乎是不可接受的。尽管引入了KV Cache作为加速推理的手段避免重复计算，但这仍然是一种以空间换时间的做法，没有降低复杂度，且仍然受到显存的制约。

因此，人们开始研究Sparse Attention（稀疏注意力机制）来加速模型推理，本质上是一种对 $O(N^2)$ 的剪枝，使之优化为 $O(N\times K)$ ，可以看成是“以精度换资源”。一开始对稀疏注意力的优化比较笨拙，比如Openai在19年提出的strided跨步稀疏注意力 和fixed固定稀疏注意力，都是用一种人为规定的范式强加给机器，取得的效果必然是差强人意的。

之后，Deepseek提出了Deepseek Sparse Attention（DSA），这种新的注意力机制引入了一个lighting indexer，能够轻量级筛选计算出关键token，让机器自己去选择token，让稀疏注意力步入了一个新的台阶。

回到本文，SparseMM同样是立足于多模态大模型的任务场景，巧妙的设计了一套方法让机器自己评估每个头的贡献程度，在此基础上分配KV Cache与选择token。这种设计抓住了MLLMs的模态分工特性——多数头仍专注文本，仅少数负责视觉，通过“保核心（视觉头）、压冗余（非视觉头）”实现资源高效利用，比传统均匀压缩方法（MQA，GQA）更贴合多模态推理的本质需求。

## 参考资料

1. [【DSA】【深度解读】10分钟看懂最新发布的DeepSeek稀疏注意力新技术 从Sparse Attention讲起_bilibili](https://www.bilibili.com/video/BV1iynyzXEKx/?spm_id_from=333.1387.collection.video_card.click&vd_source=5e421b52b9103cce8e012430aa932553)
2. [ ICCV 2025 开源｜清华&腾讯提出 SparseMM：仅5%视觉头激活，MLLMs推理加速1.87倍！ - 知乎](https://zhuanlan.zhihu.com/p/1952406823031251108)
3. [SparseMM: Head Sparsity Emerges from Visual Concept Responses in MLLMs](https://arxiv.org/abs/2506.05344)

---

![image-20260310214707597](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310214707597.png?x-oss-process=style/blog)

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

## 方法论

《SparseMM》用了一个很巧妙的方法，识别出真正干活的“视觉头”——即在多模态任务处理时主要聚焦于图像而非文本的头，并且提出了一个惊人的发现：在多模态模型中视觉头具有稀疏性，仅占大约5%左右。而在多模态任务中，视觉Token的占比远高于文本Token。基于这个发现，文章设计出了一种非对称分配KV Cache的方案，让真正参与视觉任务的“视觉头”得到大部分Cache，削减非视觉头的资源，从而实现降本增效。

首先我们来关注论文找到视觉头的算法。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310205509560.png?x-oss-process=style/blog" alt="image-20260310205509560" style="zoom:50%;" />

简单来说就是：作者通过准备一组带文字的图片，并用OCR扫描处理，输出识别到的文字和文字所在区域的边界框，将其整理为`[文字，边界框]`格式的列表（这个边界框本质上是一组绝对坐标）。然后将图片输入MLLM，获得其输出output_Token。最后，作者便如同按图索骥一般去寻找哪个头出力最多。

我们知道，MLLM主要由**视觉编码器**，**适配器**与一个基于纯文本训练的标准**LLM**组成。多模态数据首先经过视觉编码器被切割成固定长度的patch，将其flatten（拉平为一维向量）并被映射为视觉特征信息，适配器将视觉特征信息对齐到文本特征信息空间，再经过LLM获取最终输出结果。

知道MLLM的工作流程后，我们就可以看懂作者的实验思路。具体来说，作者在获取OCR扫描的`[文字，边界框]`列表与MLLM的输出output_Token后：

- 首先遍历每一个output_Token，找到和Token相对应的`[文字，边界框]`组，提取其bbox（如果该Token不对应OCR结果中的任何文字，就直接跳过该Token）。
- 接着，根据提取出的bbox匹配和该边界框对应的patch_id。
- 最后，由patch_id定位文字所在图像被flatten到了一维序列中的哪个位置，我们把对应位置的序列集合记为image_Tokens。

概括一下，就是{% span red,定位输出Token对应的文字图像在进入LLM前的位置  %}，以确定追踪对象。

确定完追踪对象后，作者遍历LLM的每一层的所有头，寻找真正关注该对象的视觉头。具体来说，就是查看当前头的注意力矩阵Attention Matrix，找出Attention Matrix中权重最大的Token序号，也就是说当前头对这个Token的关注度最高。如果关注度最高的Token恰好在image_Tokens中，说明当前头高度关注图像上的文字部分，这个头就是所谓视觉头。

我们给这个头加分 $\frac{1}{\#\text{image\_Tokens}}$ ，这个$\#\text{image\_Tokens}$代表image_Tokens这个集合中的元素数量。这么做主要是给视觉头的作用加上一个权重，来评估其能力。这会让更小（更精确）的区域会获得更高的分数，因为它们更难被捕捉。

最后，我们返回一个 $Score_{L \times H}$ 矩阵（即 $S$ 矩阵，L与H代表层数与头数），这个矩阵即LLM中所有头的视觉评估得分。

![image-20260310210323887](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310210323887.png?x-oss-process=style/blog)

有了 $S$ 矩阵，我们就可以确定给每个头分配的KV Cache大小。我们分配KV Cache的策略由三部分组成，令KV Cache的总大小为 $B$ ：

1. Local Window Cache：局部窗口缓存。它规定每个Token必须要缓存它的前 $w$ 个Token的KV，默认取 $w = 32$ 。分配给LWC的总大小为 $w \times N$ ， $N$ 为头的数量。 

2. Uniform-Based Cache：统一的基础缓存，相当于低保，保证每一个头都留有那么一点Cache。这个值通过设置超参数 $\rho$ 来划分（ $\rho \in (0,1)$ ），比如 $\rho = 0.1$，那么就固定划分总量的10%作为UBC。每个头分到的大小则可以表示为：
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

在确定了每个头的Cache最大容量后，我们需要选择把哪些Token的KV放入Cache中。这里论文参考了SnapKV的方法引入了Observation Window，只取末尾的32个Token的Q值与全部Token的K值计算注意力，用得到的平均注意力权重分数选择前 $K$ 个Token的KV缓存。而 $K= r +b_{ij}^{\text{score}}$ 。（注意，这里没有 $w$ ，因为这部分是LWC，规定存储的是距离最近的Token，不由平均注意力决定）

这么做可以将原本的时间复杂度从 $O(N^2)$ 降低至 $O(N\times L)$ ，在这里 $L = 32$ 。显然，大大加快了计算速度。

> 关于Observation Window
>
> 为什么仅选取最后32个Token对历史Token进行评估呢？我的理解是，这主要涉及三个原因：
>
> 1. 几乎所有的开源和闭源大模型，在底层都会对用户输入进行强制的Chat Template。用户提问序列的末端，永远是系统强行塞进去的生成触发词（比如 `<|im_start|>assistant`）以及它前后的几个指令 Token。也就是说，输入序列一般长这样`[图片：清明上河图...] 帮我找一下图里穿红衣服的人。`，包含用户最终意图的，永远是最后面那句话。
> 2. 退一万步讲，假设大模型连 Chat Template 都没有，Observation Window依然有效，这是由于大模型是Casual的。在因果注意力机制中，后面的词可以看前面的词，前面的词不能看后面的词。所以，靠后的Token能够包含上文信息。这不是由Token本身决定的，而是因为当前Token的 $q$ 会与历史Token的 $k$ 与 $v$ 计算注意力，从而吸纳了他们的信息。
> 3. 最后，是SnapKV提出Observation Window所依赖的一种朴素物理直觉：“谁最能预测未来？答案是最接近未来的人。”排在序列最末尾的 32 个 Token，无论它们原本是字还是图，它们在物理位置上**无限逼近即将生成的答案**。它们所提取的上下文（注意力分数），与未来生成的 Token 所需要的上下文，重合度是最高的。 所以，拿它们当历史Token的考官，其实是在提前模拟未来，筛选出对未来生成最有用的一批记忆（KV）。

## 实验

学习完论文的方法论之后，我们来看看这套方法表现如何。实验的配置如下：

- **参赛模型（Models）：** 选取了 3 款当下最火的开源多模态大模型，分别是 LLaVA-NeXT-Vicuna-7B（基于传统的 MHA 多头注意力）、LLaVA-NeXT-Mistral-7B（基于 GQA 分组查询注意力）以及 Qwen2-VL-7B（基于 GQA） 。
- **对标竞品（Baselines）：** 挑选了目前业界最强的几个 KV Cache 压缩算法作为假想敌，包括 SnapKV、PyramidKV 和 AdaKV 。此外，为了证明“视觉头”不是玄学，作者还刻意设置了一个“随机挑选头（Random Head）”的基准线来进行反向证明 。
- **测试考卷（Benchmarks）：** 选用了 5 个主流的视觉问答（VQA）和图像描述数据集（如 DocVQA、OCRBench、TextVQA 等），以及 2 个综合性的多项选择基准测试（MMBench 和 VQAv2） 。

首先，作者在极度克扣 KV Cache 容量的情况下，输出对比了各个模型的表现。

![image-20260311140347286](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260311140347286.png?x-oss-process=style/blog)

实验结果表明，在极端的缓存限制下（如 128 或 256），SparseMM 的表现持续碾压所有基线方法 。

比如在 TextVQA 任务中，SparseMM 在仅使用 256 个 Token 预算（约占总长 2376 的 10.77%）的情况下，达到了和“不压缩（Full Cache）”完全一致的性能；而在这个名额下，AdaKV 等其他方法已经掉点了约 3% 。而“随机挑选头”的基线表现最差，这说明如果瞎给注意力头分配显存，模型会直接变智障，这反向证明了作者寻找视觉头算法的含金量 。

在精度得到证明后，作者还评估了SparseMM的效率。作者测试了从 2K 到 32K 不同的上下文长度，固定256的KV Cache容量与100个Token的输出长度，计算平均解码延迟和显存占用峰值。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260311141203907.png?x-oss-process=style/blog" alt="image-20260311141203907" style="zoom:67%;" />

结果表明：KV Cache的减少显著降低了推理过程中的计算负载，从而提升了推理速度。当输入序列长度达到 32K 时，LLaVA-NeXT-Vicuna-7B 模型实现了 **1.87 倍**的加速 。且内存开销同步大幅下降。同样在 32K 长度下，原本需要高达 32.87 GB 的显存，使用 SparseMM 后暴降至 17.38 GB，**省了将近 50% 的显存** 。

最后，作者设置了消融实验与可视化证明，进一步证明SparseMM的作用机制正确。

![image-20260311141839598](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260311141839598.png?x-oss-process=style/blog)

作者在代码里把找到的这 5% 的“视觉头”强行Mask掉。结果模型看图的能力出现暴跌；作为对比，如果随机Mask同等数量的其他头，模型几乎不受影响。这证实了这 5% 的视觉头确实是干活的绝对主力 。

如果我们把头的注意力矩阵画成热力图和原图做对比，可以更直观的观察到视觉头起到的作用。

![image-20260311142443214](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260311142443214.png?x-oss-process=style/blog)

可以看到，被揪出来的“视觉头”确实死死盯住了图片里的关键文字和物体，而那些“非视觉头”的注意力要么没在图片上，要么在毫无意义的背景盲区上 。

此外，作者还解释了下为什么要用 OCR（文字识别）来找视觉头，而不用 OD（目标检测）找。这是因为 OCR 任务能建立像素和输出的绝对一对一映射，而目标检测的边界框通常太大，里含有太多背景噪音，容易让找错头 。随后设计的实验也证明了，基于COCO数据集（OD数据集）来找出视觉头的效果不如基于MLT、CTW（OCR数据集）的效果好。

## 感想

经典的Transformer架构需要对所有输入计算全局注意力，时间复杂度为 $O(N^2)$ ，尤其是处理长文本任务时，开销对于自回归大模型来说几乎是不可接受的。尽管引入了KV Cache作为加速推理的手段避免重复计算，但这仍然是一种以空间换时间的做法，没有降低复杂度，且仍然受到显存的制约。

因此，人们开始研究Sparse Attention（稀疏注意力机制）来加速模型推理，本质上是一种对 $O(N^2)$ 的剪枝，使之优化为 $O(N\times K)$ ，可以看成是“以精度换资源”。一开始对稀疏注意力的优化比较笨拙，比如Openai在19年提出的strided跨步稀疏注意力 和fixed固定稀疏注意力，都是用一种人为规定的范式强加给机器，取得的效果必然是差强人意的。

之后，Deepseek提出了Deepseek Sparse Attention（DSA），这种新的注意力机制引入了一个lighting indexer，能够轻量级筛选计算出关键Token，让机器自己去选择Token，让稀疏注意力步入了一个新的台阶。

回到本文，SparseMM同样是立足于多模态大模型的任务场景，巧妙的设计了一套方法让机器自己评估每个头的贡献程度，在此基础上分配KV Cache与选择Token。这种设计抓住了MLLMs的模态分工特性——多数头仍专注文本，仅少数负责视觉，通过“保核心（视觉头）、压冗余（非视觉头）”实现资源高效利用，比传统均匀压缩方法（MQA，GQA）更贴合多模态推理的本质需求。

## 参考资料

1. [【DSA】【深度解读】10分钟看懂最新发布的DeepSeek稀疏注意力新技术 从Sparse Attention讲起_bilibili](https://www.bilibili.com/video/BV1iynyzXEKx/?spm_id_from=333.1387.collection.video_card.click&vd_source=5e421b52b9103cce8e012430aa932553)
2. [ ICCV 2025 开源｜清华&腾讯提出 SparseMM：仅5%视觉头激活，MLLMs推理加速1.87倍！ - 知乎](https://zhuanlan.zhihu.com/p/1952406823031251108)
3. [SparseMM: Head Sparsity Emerges from Visual Concept Responses in MLLMs](https://arxiv.org/abs/2506.05344)

---

![image-20260310214707597](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260310214707597.png?x-oss-process=style/blog)

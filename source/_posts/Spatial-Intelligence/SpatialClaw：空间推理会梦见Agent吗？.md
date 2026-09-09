---
title: SpatialClaw：空间推理会梦见Agent吗？
tags:
  - Spatial Intelligence
  - Agent
  - Action interface
date: 2026-09-09 20:01:10
updated: 2026-09-09 20:01:10
categories: Spatial-Intelligence
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909193808303.png?x-oss-process=style/blog
description: 《SpatialClaw：Rethinking Action Interface for Agentic Spatial Reasoning》论文精读
---


{% span center logo large, SpatialClaw %}

{% span center small, 空间推理会梦见Agent吗？ %}

本文整理了个人对于[[2606.13673\] SpatialClaw: Rethinking Action Interface for Agentic Spatial Reasoning](https://arxiv.org/abs/2606.13673)的一些见解与思考。论文代码地址：

[![NVlabs/SpatialClaw - GitHub](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/SpatialClaw.svg)](https://github.com/NVlabs/SpatialClaw)

细心的读者可能发现了，论文的副标题不是叫“重新思考智能体空间推理的动作接口”么？

没错，“空间推理会梦见Agent吗？”是笔者即兴发挥的，嘿嘿。

那么废话少说，我们直接进入正题。

## 方法论

### 背景

何谓Spatial Reasoning？

> *Spatial reasoning, the ability to determine where objects are, how they relate, and how they move in 3D, remains a fundamental challenge for vision-language models (VLMs). Tool-augmented agents attempt to address this by augmenting VLMs with specialist perception modules, yet their effectiveness is bounded by the **action interface** through which those tools are invoked.*

以上节选自论文摘要。简单的说，Spatial Reasoning的定义是：物体在哪里，他们之间有什么关联，物体在3D空间内又是怎么移动的。

![image-20260909161343701](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909161343701.png?x-oss-process=style/blog)

一言以蔽之，论文提出了一套称之为SpatialClaw的方法{% psw 本质是agent harness %}{% psw 笔者高度怀疑这是在蹭OpenClaw的热点 %}，并声称它在共20个Spatial Reasoning benchmark上取得了平均59.9%的Acc，高出最近的其他Spatial Agent 11.2 point。表现如上图所示。

### 核心设计

论文列出了三种解决空间推理的模式：

- single-pass code execution：单次代码执行
- structured tool-call interface：多步 agent loop，每步通过固定的 JSON schema 调用一个预定义 tool。常见的ReAct-style agent
- SpatialClaw：提出一个新的action interface。维护一个持久的Python Kernel，每步生成任意 Python cell作为动作执行，复用已有变量

最终的novelty在于：维护一个持久的Python Kernel，每步生成任意 Python cell，并复用已有变量。比single-pass code execution多出了loop，比常见的ReAct架构中structured tool-call interface更直接，Python cell这个interface也许对agent更友好。

锐评一下，就是拿agent的铲子做Embodied intelligence/Spatial intelligence的活。

### 数据流

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/SpatialClawWorkflow.svg" alt="SpatialClawWorkflow" style="zoom: 67%;" />

如上图所示，这是论文代码中实际的数据流。benchmark sample首先由`run.py`并发采样，然后交由`Workflow.arun()`函数具体处理。黄色部分是由LangGraph定义的AgentState状态流，其中蓝色的节点是agent loop中会反复执行的节点。最后Agent结束循环返回一个final answer进行eval。

接下来我将详细拆解每一个节点的实际执行逻辑。

#### agent state: init_node

> - 启用或复用一个Kernel
> - 通过cloudpickel临时文件注入样本对象
> - 搭建初始message
> - 记录变量注册表
> - 初始化日志

首先是init节点，它的主要作用是启动或者复用一个Kernel，注入样本对象，再初始化message。

这个样本对象如何理解？就是将图片和一些已经写好的方法注入进Kernel，这样Agent就能在Kernel里以对象为目标调用这些方法处理数据。

message分为system message和human message，前者用来构造系统prompt，后者构造用户指令。除此之外，后续还会记录变量注册表和初始化日志。注册变量是为了不让模型因为上下文记错变量的名字，具体通过后续feedback节点的 variable diff实现。

#### agent state: plan_node*

> - 不看图片，text-only，防止猜答案
> - 搭建**独立**的planning session messages
> - 注入plan
> - *提取checklist items*

该节点是可选的。

plan节点主要作用是调用 LLM 生成执行计划，并把计划和过渡提示用一条human message的形式加入 Agent 的消息历史。

这里有几个细节：第一，LLM在进行plan时只能读取文本信息，看不到图片，这么做是为了防止LLM看到图片后开始猜测答案；第二，用于plan的LLM会话和执行主Agent的LLM 会话是相互独立的，这么做也许是为了减少耦合，并且只专注于进行plan；第三，最后提取的checklist item用于给reflection节点做检查，但只有启用了reflection功能才会提取。

#### agent state: llm_step_node

> - 搭建给LLM的message并发送
> - 验证返回的structured response
> - 如果成功：从structured response中提取code等信息
> - 搭建带有structured content的AI message

llm_step节点调用LLM来生成要执行的代码，并且更新agent state的状态。但是它不做实际执行，只做输出格式检查。

它先把message发送给LLM，然后接受并验证返回的structured response。如果验证成功就从中提取code等信息，整理成一个规格化形式的AI message。这个 AIMessage 可以理解为一份规范化的 trajectory record，主要目的是让后续 Agent 和 reflection 继续读取，同时也方便人类阅读。而原始的raw response 则单独保存在日志里。

#### agent state: execute_node

> - 安全性检查；黑名单静态检查，不是系统级Sandbox
> - 清空缓冲区
> - 在Jupyter Kernel中执行代码
> - 计数tool calls；正则搜索，不准确
> - 从VLM和feedback modules中收集VLM queries
> - 更新current_step_result

execute节点的作用是对代码进行安全性检查，再交由Jupyter Kernel实际执行，并收集 stdout、异常、图片和 VLM 调用等数据，将其更新进current_step_result。

这里有几个细节，一个是这里的安全性检查其实只是黑名单静态检查，对一些涉及到系统操作的敏感函数拒绝调用，并不是系统级别的sandbox。第二是这里对tool calls进行统计，代码里的具体实现是直接对生成的code进行正则匹配，统计函数名出现的次数，实际上这一块的计数是相当不严谨的。

#### agent state: feedback_node

> - 从Kernel中获取现有变量并且记录产生变化的变量
> - 对errored steps决策使用何种rollback策略
> - 检查大变量更新step_result
> - 检查ReturnAnswer sentinel
> - 搭建condense messages
> - 搭建messages

feedback节点的作用主要是整理结果、反馈给 LLM，并判断是否结束。

首先这里从Kernel中获取现有变量并且记录产生变化的变量（variable diff），就用上了先前在init节点中保存的变量快照。这里单独记录发生变化的变量，能让模型不至于一次性读入太多变量，然后因上下文过长而产生幻觉记错名字，同时也让 Agent 更容易掌握本轮产生了哪些新状态。

而后，如果执行代码中出现了error，feedback节点将决定使用什么rollback策略。一种是能定位错误行，并且有新变量产生，就采用部分回滚策略：只删除发生error的对应行所产生的新变量，上文中没有出错的变量作为Survivor全部保留；另一种是无法确认error产生的范围，就采用完全回滚策略：把所有在这一轮代码执行过程中新产生的变量全部删除，本质上是一种尽最大努力的清除还原策略。

检查大变量是为了预防内存耗尽，通过向agent发出警告来实现这一点，并不采取强制性预防措施。

检查ReturnAnswer sentinel来判断是否产生了final answer，如果有，就更新agent状态。

搭建condense messages的目的是对错误信息进行压缩，防止因错误产生的无用代码占据太多上下文。

最后，再搭建一轮新的message，准备传给下一轮循环的LLM。

#### agent state: reflection_node*

> - 检查逻辑、几何、工具使用和证据充分性，维护Checklist
> - 发现问题时给出警告
> - 答案提交后发现问题时可撤销答案并要求主 Agent继续验证
> - 受到剩余步数和提交次数限制，防止无限反思
> - 同样是一次独立的LLM调用

reflection节点也是可选的。

它额外调用一次 LLM，对 Agent 刚才的执行过程和答案进行自我审查。

不过，如果剩余步骤太少或者答案已被拒绝太多次/已经提交过太多次，它会接受当前答案，避免 Agent 因反复修改answer最终被强制终止。

#### should_continue/router

> - final_answer: END
>
>   
>
> - step_count >= max_steps: force_terminate
>
> - failure_count >= max_failures: force_terminate
>
> - total_tool_calls >= max_tool_calls: force_terminate

should_continue，它实际上充当一个路由的角色，也就是router，来决定工作流走向。

如果此时Agent state中存在final answer，就直接进入END，退出agent loop。而剩下的三种情况：超过最大执行步数、LLM连续执行出错超过最大错误限制、超过最大工具调用次数，都会被force_terminate，然后再进入END。

#### force_terminate

> - 记录强制终止的reason
> - 提交最近一次产生的answer
> - 如果先前没有产生过answer，执行一次CoT产生answer提交
> - 搭建summary

如果进入到了force_terminate节点，那么它会首先记录强制终止的reason，然后再尝试提交一个answer，优先级是：

1. 使用最近一次提交过的答案 
2. 调用 CoT 视觉模型产出answer兜底
3. 如果CoT也失败了，那就查看历史记录，尝试用正则找出一个答案 
4. 实在没有才返回一个空答案。

最后，搭建一个summary。

### 模式配置

介绍完AgentState状态流，项目的基本架构就差不多明显了。再回头说说论文里提到的三种模式，其实他们都共享同一套底层架构，只不过是通过参数和消融来实现，或者说模拟不同的执行效果。

- Single-pass模式：通过设置`max_step = 1`，然后关闭Plan和Reflection节点来实现。这样就相当于只执行了一次代码生成。
- ReAct模式：每一步只让LLM输出一个JSON tool call。应该是通过prompt注入实现的，然后再把Json格式翻译成Python执行。
- Code模式：也就是SpatialClaw，每步生成一个自由的python cell，组合多个操作。

| 模式        | 动作                                     | 循环 | Planning/Reflection |
| ----------- | ---------------------------------------- | ---- | ------------------- |
| Single-pass | 一个自由 Python cell，可调用多个工具     | 1 轮 | 关闭                |
| ReAct       | 每步一个 JSON tool call，再翻译成 Python | 多轮 | 复用相同 graph      |
| Code        | 每步一个自由 Python cell，可组合多个操作 | 多轮 | 可配置              |

## 实验部分

### 实验设置

实验一共采用了20个Benchmark，分为五类：

- 单图空间推理，4个
- 多视角空间推理，3个
- 视频空间与 4D 推理，6 个
- 通用空间推理，3 个
- 通用视频理解，4 个

且最终 Average 是 20 个 benchmark 分数的非加权平均。

使用6个开源的VLM：

- Qwen3.5-397B-A17B		GPTQ Int4
- Qwen3.5-122B-A10B		FP8
- Qwen3.6-35B-A3B		FP8
- Qwen3.6-27B			FP8
- Gemma4-31B			FP8
- Gemma4-26B-A4B		FP8

所有模型使用相同的system prompt，perception tools，输入预处理，且`max_step = 30`

### 实验结果

{% tabs result %}
<!-- tab 只改变action-interface -->
<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909190246615.png?x-oss-process=style/blog" alt="image-20260909190246615" style="zoom:80%;" />

> - No-tool reasoning	53.4
> - Single-pass code	55.2
> - Structured tool-call	56.7
> - **SpatialClaw		59.9**

固定一个模型Gemma4-31B，然后只改变action interface对比分数。这里解释一下No tool reasoning baseline，其实就是把问题拿去问LLM，然后LLM也不生成代码，直接给出答案。最后可以看到Spatialclaw的平均分是最高的。

<!-- endtab -->

<!-- tab 与其他Spatial Agent对比 -->
<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909190309199.png?x-oss-process=style/blog" alt="image-20260909190309199" style="zoom:80%;" />

> - VADAR只支持单图	  -
> - SpaceTools-Toolshed	48.7
> - pySpatial			47.8
> - SpatialClaw		59.9

这里是与其他Spatial Agent的比较，Spatialclaw也是拿下了最高平均分。可以看到作者拿来对比的Agent得分甚至不如baseline，~~我也不知道为什么会这样~~。

<!-- endtab -->

<!-- tab 消融实验 -->
<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909190641531.png?x-oss-process=style/blog" alt="image-20260909190641531" style="zoom:80%;" />

这里是作者做的消融实验，第一行是完整的Spatialclaw，第二行移除了提前写好的计算工具，第三行移除了视觉感知工具，第四行是baseline。

从结果我们可以看出，预定义的 tools.Mask这些CPU工具不是关键，去掉他们的分数只掉了0.5分左右。而依赖GPU的perception tools很重要，去掉他们分数直接掉了5.5分。

第三是没有 perception tools 时仍比 no-tool 高 2.7 分，论文认为这说明了action interface本身也有贡献。不过这里也不是很严谨，因为他没有排除掉plan，多步循环等因素，所以说因果性不是很严格。

<!-- endtab -->
{% endtabs %}

![image-20260909191534964](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909191534964.png?x-oss-process=style/blog)

最后作者对实验结果做了整理，统计了表现更好的任务和表现不如single-pass与structured tool-call的任务。

可以看出增益明显的任务主要有camera motion， multiview reasoning这种多视角组合任务，增益一般或者负增益的任务主要是visual recognition，spatial counting这种偏静态识别的任务。这就说明：{% span red, 当任务需要需要跨帧、跨视角组合多个中间结果时，persistent code interface 最有价值， %}不然的话表现可能还不如传统方法。

### 失败分析

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909192101621.png?x-oss-process=style/blog" alt="image-20260909192101621" style="zoom: 50%;" />

作者对失败案例单独进行了分析：用LLM as judge的方法让Gemini-3.1-Pro分类了1000个错误轨迹。可以看到占大头的错误是{% emp 几何计算错误 %}，{% emp 工具选择或覆盖不足 %}，{% emp 工具不支持视觉判断 %}和{% emp VLM幻觉 %}。

这说明目前的bottleneck主要集中于{% u 正确感知 %}，{% u 正确选工具 %}，{% u 正确几何计算 %}和{% u 错误恢复 %}这几个方面，主要聚焦于底层VLM和视觉工具，继续研究action interface的提升空间比较有限。

## 结论

最后我们可以得出几个结论。

第一是这套action interface对空间推理任务来说确有提升，准确的说是persistent Kernel、Agent loop，还有中间过程检查与修改这么几个机制共同提升了任务表现。

第二是在需要跨帧计算几何信息链的场景下，才能够让SpatialClaw的表现最大化。因为这样才能够更充分的利用到SpatialClaw架构多轮循环检查带来的优势，在单帧场景下的就显得有点冗余，表现可能还不如传统方法。

第三就是Spatialclaw目前的bottleneck主要在于底层的VLM和感知工具的质量，因为SpatialClaw的执行与检查都依赖这两个组件，而缺乏对他们的校验机制。

第四就是这个方法的推理成本高，它每一轮循环都会调用额外的LLM 会话做规划反思，还要对中间结果检查，会在这几个步骤上耗费很多token。

## 不足

笔者认为的不足主要有三点。一是计算的预算不公平：No-tool baseline一次执行只调用一次llm，但是SpatialClaw的一步执行可能会在代码中调用多次VLM，还有planner，SAM3等。所以，论文里给出的“59.9%”的数据和提升，并不好说到底是来自action interface，还是更多 test-time compute 和更多外部工具。论文没有给出 accuracy-token-cost-latency 曲线，所以无法判断 SpatialClaw 是更高效，还是“花更多资源得到更高准确率”。

第二是没有把 harness 组件的贡献拆开。SpatialClaw 同时包含 persistent kernel、visual feedback、variable summary、planner 和 verification prompt。论文主要比较的是整套 bundle，没有单独证明哪个组件最重要。也就是说，消融部分还有待改进。

第三是统计和指标口径不够严谨。论文没有报告多随机种子、置信区间或显著性检验；20 个 benchmark 还混合了 Accuracy、MRA 和 VCI，并进行等权平均。因此 59.9% 只是一个方便汇总的 macro-average，不等于所有问题的总体正确率，也不能直接判断较小的提升是否稳定。

## 参考文献

- [[2210.03629\] ReAct: Synergizing Reasoning and Acting in Language Models](https://arxiv.org/abs/2210.03629)
- [[2405.15793\] SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering](https://arxiv.org/abs/2405.15793)

---

![image-20260909193808303](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260909193808303.png?x-oss-process=style/blog)

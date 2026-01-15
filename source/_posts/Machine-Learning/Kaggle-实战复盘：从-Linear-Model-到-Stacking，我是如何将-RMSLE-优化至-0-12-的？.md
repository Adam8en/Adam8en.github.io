---
title: 从 Linear Model 到 Stacking，我是如何将 RMSLE 优化至 0.12 的？
tags:
  - Linear Model
  - MLP
  - XGBoost
date: 2026-01-15 20:06:12
updated: 2026-01-15 20:06:12
categories: Machine-Learning
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260115192208544.png?x-oss-process=style/blog
description: Kaggle 房价预测实战复盘。记录从 Linear Model (0.16) 到 Stacking (0.12) 的优化全流程。
---


{% span center logo large, Kaggle 实战复盘 %}

{% span center small, 从 Linear Model 到 Stacking，我是如何将 RMSLE 优化至 0.12 的？ %}

笔者近期正在学习[《动手学深度学习》](https://zh.d2l.ai/)（后简称《D2L》）这本书，在4.10节处，书中手把手带我们用最简单的线性模型复现了Kaggle上一个预测房价的模型。我在按照书上的代码复现后，又根据Gemini的建议采取了进一步的优化建议以取得更好的效果。这篇博客旨在记录笔者的复现流程，以及一点学习心得。

题目的链接如下：

{% btn 'https://www.kaggle.com/competitions/house-prices-advanced-regression-techniques/overview',House Prices - Advanced Regression Techniques,far fa-hand-point-right,block center larger %}

我们先从《D2L》这本书的做法写起吧。

## 《D2L》的做法

我们简单分为数据预处理与模型训练两部分来说。

### 数据预处理

首先，我们先把Kaggle房屋数据集下载到本地，并用pandas库加载训练数据集与测试数据集。

~~~python
import numpy as np
import pandas as pd
import torch
from torch import nn
from d2l import torch as d2l

#@save
DATA_HUB = dict()
DATA_URL = 'http://d2l-data.s3-accelerate.amazonaws.com/'

def download(name, cache_dir=os.path.join('..', 'data')):  #@save
    """下载一个DATA_HUB中的文件，返回本地文件名"""
    assert name in DATA_HUB, f"{name} 不存在于 {DATA_HUB}"
    url, sha1_hash = DATA_HUB[name]
    os.makedirs(cache_dir, exist_ok=True)
    fname = os.path.join(cache_dir, url.split('/')[-1])
    if os.path.exists(fname):
        sha1 = hashlib.sha1()
        with open(fname, 'rb') as f:
            while True:
                data = f.read(1048576)
                if not data:
                    break
                sha1.update(data)
        if sha1.hexdigest() == sha1_hash:
            return fname  # 命中缓存
    print(f'正在从{url}下载{fname}...')
    r = requests.get(url, stream=True, verify=True)
    with open(fname, 'wb') as f:
        f.write(r.content)
    return fname

def download_extract(name, folder=None):  #@save
    """下载并解压zip/tar文件"""
    fname = download(name)
    base_dir = os.path.dirname(fname)
    data_dir, ext = os.path.splitext(fname)
    if ext == '.zip':
        fp = zipfile.ZipFile(fname, 'r')
    elif ext in ('.tar', '.gz'):
        fp = tarfile.open(fname, 'r')
    else:
        assert False, '只有zip/tar文件可以被解压缩'
    fp.extractall(base_dir)
    return os.path.join(base_dir, folder) if folder else data_dir

def download_all():  #@save
    """下载DATA_HUB中的所有文件"""
    for name in DATA_HUB:
        download(name)

DATA_HUB['kaggle_house_train'] = (  #@save
    DATA_URL + 'kaggle_house_pred_train.csv',
    '585e9cc93e70b39160e7921475f9bcd7d31219ce')

DATA_HUB['kaggle_house_test'] = (  #@save
    DATA_URL + 'kaggle_house_pred_test.csv',
    'fa19780a7b011d9b009e8bff8e99922a8ee2eb90')

train_data = pd.read_csv(download('kaggle_house_train'))
test_data = pd.read_csv(download('kaggle_house_test'))
~~~

![image-20260113154943290](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260113154943290.png?x-oss-process=style/blog)

可以看到，训练数据集包括1460条样本，每个样本有80个特征和一个标签。而测试数据集有1459条样本，每个样本包含80个特征。

再看看训练数据集的前四个和后两个特征，结果如下。

![image-20260113155337806](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260113155337806.png?x-oss-process=style/blog)

可以看到，训练数据集中每个样本的第一个特征是ID值，用以唯一标识该样本。然而，在实际训练中，ID值不反映任何信息，因此我们需要将ID列从数据集中删除。

~~~python
all_features = pd.concat((train_data.iloc[:, 1:-1], test_data.iloc[:, 1:])) # 将第0列（ID）从数据集中删除
~~~

#### 数据标准化

我们对数据进行预处理大体上有两个任务：

1. 将所有的缺失值替换为相应特征值的平均值
2. 将所有特征值重新缩放到零均值和单位方差来标准化数据

这看似是两个任务，其实可以一步搞定。所谓数据标准化，其实可以参考概率论中正态分布标准化的方法，即用以下步骤得到$x$。
$$
x \leftarrow \frac{x - \mu}{\sigma}
$$
$\mu$和$\sigma$分别代表样本均值与标准差。不难得出，处理后的特征$x$具有零均值和单位方差，推导过程如下：
$$
E[\frac{x - \mu}{\sigma}] = \frac{\mu - \mu}{\sigma} = 0 \\
E[(\frac{x - \mu}{\sigma}) ^ 2] = \frac{E(x^2) - 2\mu^2 + \mu^2}{\sigma ^ 2} = \frac{(\sigma^2 + \mu^2) - \mu^2}{\sigma ^ 2} = 1 \\
D[\frac{x - \mu}{\sigma}] = 1 - 0^2 = 1
$$
这么做有两个好处：首先，它方便优化。因为将所有的数值进行标准化后，特征均值就{% bubble 全部变为0,"均值消失","#ec5830" %}。因此，我们可以将缺失值统一设置为0，视为均值填充；其次，我们不知道哪些特征是相关的，所以我们不想让惩罚分配给一个特征的系数比分配给其他特征的系数更大。

~~~python
# 数据预处理
# 将特征进行标准化，重新缩放到零均值和单位方差
numeric_features = all_features.dtypes[all_features.dtypes != 'object'].index
all_features[numeric_features] = all_features[numeric_features].apply(
    lambda x: (x - x.mean()) / (x.std())
)
# 标准化数据后，均值为0，故缺失值设置为0
all_features[numeric_features] = all_features[numeric_features].fillna(0)
~~~

#### 处理离散值

接下来，对于离散值，如“MSZoning”之类的特征，我们可以用{% bubble 独热编码,"One-Hot Encoding","#ec5830" %}来替换。使用pandas库下的`get_dummies()`方法可以让我们很轻松的做到这一点。

> 例如，“MSZoning”包含值“RL”和“Rm”。 我们将创建两个新的指示器特征“MSZoning_RL”和“MSZoning_RM”，其值为0或1。 根据独热编码，如果“MSZoning”的原始值为“RL”， 则：“MSZoning_RL”为1，“MSZoning_RM”为0。

~~~python
# 接下来，用独热编码替换离散值
all_features = pd.get_dummies(all_features, dummy_na=True)
~~~

顺带一提，独热编码的本质是把一个特征拆分成多个正交关系的特征。比如“街道”不能被直接拆分成“1、2、3……”，因为它们之间没有大小关系，只能用独热编码处理。

值得注意的是，这么做会导致数据集特征数量大幅增长，原因在于对离散值独热编码会让特征分裂。这很好理解，比如“MSZoning”会分裂为“MSZoning_RL”和“MSZoning_RM”两个新的特征。事实上，这里的数据集特征也的确从79个增加到了331个。

最后，通过values属性，将pandas格式的数据集提取为NumPy格式，并将其转换为张量开始训练。

~~~python
# 从pandas格式提取NumPy格式，并转换为张量用于训练
n_train = train_data.shape[0]
train_features = torch.tensor(all_features[:n_train].values, dtype=torch.float32)
test_features = torch.tensor(all_features[n_train:].values, dtype=torch.float32)
train_labels = torch.tensor(
    train_data.SalePrice.values.reshape(-1, 1),dtype=torch.float32
)
~~~

### 模型训练

《D2L》这本书训练了一个带有损失平方的线性模型，这个模型非常基础，能力也相当一般。但它可以作为一个{% bubble 基线,"baseline","#ec5830" %}模型，让我们知道后续模型的能力超出了它多少。

~~~python
# 训练一个线性模型，作为baseline
loss = nn.MSELoss()
in_features = train_features.shape[1]

def get_net():
    net = nn.Sequential(nn.Linear(in_features,1))
    return net
~~~

一个小细节是：为了更客观的评价模型的误差，我们还需要引入{% bubble RMSLE,"均方根对数误差","#ec5830" %}。
$$
\sqrt{\frac{1}{n} \sum_{i=1}^{n} (\log y_i - \log \hat{y}_i)^2}
$$
因为MSE关注的是绝对误差，RMSLE关注的是相对误差，显然后者才是我们需要的。打个比方，对于一栋12.5万美元的房子，我们的预测偏了10万美元，那么这个模型预测结果就很糟糕；如果是一栋400万美元的豪宅，我们的预测同样偏差了10万美元，那我们的结果就还不错。但是，对于使用MSE误差的模型来说，这两个误差程度是相同的，这显然不是我们想要的结果。所以，我们需要引入RMSLE。

~~~python
def log_rmse(net, features, labels):
    # 为了在取对数时进一步稳定该值，将小于1的值设置为1
    clipped_preds = torch.clamp(net(features), 1, float('inf'))
    rmse = torch.sqrt(loss(torch.log(clipped_preds),
                           torch.log(labels)))
    return rmse.item()
~~~

之后，我们引入Adam优化器和K折交叉验证来辅助训练模型。

~~~python
def train(net, train_features, train_labels, test_features, test_labels,
          num_epochs, learning_rate, weighr_decay, batch_size):
    train_ls, test_ls =[], []
    train_iter = d2l.load_array((train_features, train_labels), batch_size)

    optimizer = torch.optim.Adam(net.parameters(),
                                 lr=learning_rate,
                                 weight_decay=weighr_decay)
    for epoch in range(num_epochs):
        for X, y in train_iter:
            optimizer.zero_grad()
            l = loss(net(X),y)
            l.backward()
            optimizer.step()
        train_ls.append(log_rmse(net, train_features, train_labels))
        if test_labels is not None:
            test_ls.append(log_rmse(net, test_features, test_labels))
    return train_ls, test_ls

def get_k_fold_data(k, i, X, y):
    assert k > 1
    fold_size = X.shape[0] // k
    X_train, y_train = None, None
    for j in range(k):
        idx = slice(j * fold_size, (j+1) * fold_size)
        X_part, y_part = X[idx, :], y[idx]
        if j == i:
            X_valid, y_valid = X_part, y_part
        elif X_train is None:
            X_train, y_train = X_part, y_part
        else:
            X_train = torch.cat([X_train, X_part], 0)
            y_train = torch.cat([y_train, y_part], 0)
    return X_train, y_train, X_valid, y_valid

def k_fold(k, X_train, y_train, num_epochs, learning_rate, weight_decay,
           batch_size):
    train_l_sum, valid_l_sum = 0, 0
    for i in range(k):
        data = get_k_fold_data(k, i, X_train, y_train)
        net = get_net()
        train_ls, valid_ls = train(net, *data, num_epochs, learning_rate,
                                   weight_decay, batch_size)
        train_l_sum += train_ls[-1]
        valid_l_sum += valid_ls[-1]
        if i == 0:
            d2l.plot(list(range(1, num_epochs + 1)), [train_ls, valid_ls],
                     xlabel='epoch', ylabel='rmse', xlim=[1, num_epochs],
                     legend=['train', 'valid'], yscale='log')
            # 【新增代码】将图像保存到当前目录下的 result.png 文件中
            # plt.savefig('result1.png')
            # print("图像已保存为 result1.png") 
            
        print(f'折{i + 1}，训练log rmse{float(train_ls[-1]):f}, '
              f'验证log rmse{float(valid_ls[-1]):f}')
              
    
    return train_l_sum / k, valid_l_sum /k
~~~

关于Adam优化器，可以参照我之前的博客：[Coursera-ML-AndrewNg-Notes-Week5 | Adam8en の 8log](https://adamben.top/posts/282cf3400e09/?highlight=adam)。简单来说，Adam算法就是对每个参数动态的调整它们的学习率从而一定程度上优化模型。

K折交叉验证是一个在本地训练和验证模型的方法。简单来说，它将训练集划分为$K$折，然后以此选择第$i$个切片作为验证数据，其余部分作为训练数据。

不过，这么做并不是处理数据的最有效方法。因为它的原理是将划分出的数据集**复制了一份**。当数据集很大时（比如100GB），这么做不仅耗时而且会大量占用内存。目前的工业界主流做法是用索引＋采样器，核心逻辑是不移动数据，只维护一个索引列表。如果数据大到连内存都装不下（比如1TB的文本数据），这个时候就用“流式读取”。

因为这道题的数据量很小（几百KB的CSV文件），所以用笨方法完全可行。

这里还有一个很有趣的细节：训练用的 Loss 和评估用的 Metric 是不一样的。

![image-20260113170317785](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260113170317785.png?x-oss-process=style/blog)

- **教练（Optimizer）**：使用的是 **MSE Loss**。因为它数学性质好，求导平滑，适合用来指导神经网络调整参数（反向传播）。
- **裁判（Evaluation）**：使用的是 **RMSLE (Log RMSE)**。这是 Kaggle 官方的计分标准。我们虽然优化的是 MSE，但最终必须用 RMSLE 来衡量模型在赛场上的真实表现。

这就好比高考：平时的模拟题（MSE）是为了练手感，但最后录取只看高考卷面分（RMSLE）。虽然题目不一样，但能力提升了，两个分数自然都会高。

### 最终结果

《D2L》中提供了一组未经调优的超参数供我们训练模型。

```python
k, num_epochs, lr, weight_decay, batch_size = 5, 100, 5, 0, 64
train_l, valid_l = k_fold(k, train_features, train_labels, num_epochs, lr,
                          weight_decay, batch_size)
print(f'{k}-折验证: 平均训练log rmse: {float(train_l):f}, '
      f'平均验证log rmse: {float(valid_l):f}')
```

运行后可以得到如下结果：

![result1](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/result1.png?x-oss-process=style/blog)

看样子训练的结果还不错。最后，我们在题目给定的测试数据集上用模型预测标签，输出预测结果并将其保存在一个CSV文件中，提交到Kaggle就可以查看成绩了。

~~~python
def train_and_pred(train_features, test_features, train_labels, test_data,
                   num_epochs, lr, weight_decay, batch_size):
    net = get_net()
    train_ls, _ = train(net, train_features, train_labels, None, None,
                        num_epochs, lr, weight_decay, batch_size)
    d2l.plot(np.arange(1, num_epochs + 1), [train_ls], xlabel='epoch',
             ylabel='log rmse', xlim=[1, num_epochs], yscale='log')
    plt.savefig('train_final.png')
    print(f'训练log rmse：{float(train_ls[-1]):f}')
    # 将网络应用于测试集。
    preds = net(test_features).detach().numpy()
    # 将其重新格式化以导出到Kaggle
    test_data['SalePrice'] = pd.Series(preds.reshape(1, -1)[0])
    submission = pd.concat([test_data['Id'], test_data['SalePrice']], axis=1)
    submission.to_csv('submission.csv', index=False)

train_and_pred(train_features, test_features, train_labels, test_data,
               num_epochs, lr, weight_decay, batch_size)
~~~

最后得到的分数值是**0.16696**。

## 优化改进

### 引入XGBoost

在经过Gemini和资料查阅后，我了解到工业界处理表格数据的王者其实是 **Gradient Boosting（梯度提升）**。其中，最常被人使用的是XGBoost模型。

在这里我不打算对决策树和XGBoost的底层原理做详细的展开，如果将来有时间的话，也许我会把它整理成一篇博客。尽管如此，在这里我还是想阐述一些我对它们的浅层理解（参考了知乎文章和吴恩达的《machine-learning》课程）

首先让我们来看看决策树长啥样。如果我们拥有一堆猫和狗的样本，需要根据不同的特征对数据集进行划分，希望得到一个模型来识别输入样本是猫还是狗（一个典型的分类问题），那么我们可以得到下面这棵决策树。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260115154435207.png?x-oss-process=style/blog" alt="image-20260115154435207" style="zoom:67%;" />

简单地说，决策树模型就是通过不断地回答问题，输出Yes or No，一直向下走直到抵达叶子节点，叶子节点的值就是预测值。

在我们训练一棵决策树时，我们需要选择一个特征作为分裂点，使得**信息增益**最大化。通常可以用递归的方法生成一棵决策树，直到分裂出来的子集合为“**纯净的**”（即 全猫或者全狗）或者到达了树所允许分裂的最大深度就停止分裂。这个信息增益这里不多做探究，本质上就是一个度量节点纯净度的方法，涉及一些很基本的信息论定义。

一棵决策树往往不足以用来解决问题，因为它高度依赖数据集本身来决定用哪个特征分裂以实现信息增益最大化。所以，**袋装决策树**和**随机森林算法**出现了。袋装决策树的核心理念就是：在原始数据集上进行有放回随机抽样得到多个训练数据集，以此训练多棵决策树来进行预测，最后对所有决策树的输出进行投票，来决定最终的预测结果。它的算法伪代码描述如下：

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260115155728813.png?x-oss-process=style/blog" alt="image-20260115155728813" style="zoom:67%;" />

这么做有一个小问题：当$B$非常大时，可能会生成很多个根节点使用相同的分割、或者根节点附近使用相同分割的决策树。**随机森林算法**则是在袋装决策树上进一步优化：随机森林在分裂节点时，**并不是在所有特征中寻找最优解，而是随机抽取一部分特征（通常取 $\sqrt{M}$，其中 $M$ 为特征总数）进行选择**。这种特征层面的随机性进一步降低了树与树之间的相关性，让投票结果更健壮。

这么做的好处就在于，输入数据集的任意变化，都不太可能对随机森林模型的预测结果产生巨大的影响，因为它已经对训练数据集的微小变化进行了平均化处理。

最后就是我们的XGBoost模型，XGBoost 属于 **Boosting（提升）** 家族，这与随机森林的 Bagging 思想完全不同。随机森林是**并行**地训练多棵树然后投票，而 XGBoost 是**串行**地训练。它的核心思想是：**每一棵新树的建立，都是为了修正前一棵树的错误。**

简单来说，如果第一棵树预测的结果和真实值有差距（这个差距称为残差），那么第二棵树的目标就不再是预测原始数据，而是去拟合这个残差。

这种算法背后的思想直观上也很好理解：就像你做模拟卷，第一次考完后发现导数题丢分了（产生了残差），那么你接下来的复习计划（下一棵树）就**专门针对导数这部分偏差进行修正**，而不是从头再把整张卷子做一遍。这种策略让 XGBoost 能够不断逼近正确结果，也让它成为了 Kaggle 比赛中的夺冠常客。

至于 XGBoost 的底层数学原理这里就不展开赘述。我们只要知道它不同于传统的决策树模型用信息增益最大化作为分裂节点的策略，而是通过泰勒展开用到二阶导数信息，来极小化目标损失函数。这使得它比只运用一阶导数的传统 GBDT 更加精准和高效。详细可以参考文章：[超详细解析XGBoost（你想要的都有） - 知乎](https://zhuanlan.zhihu.com/p/562983875)

对于前置知识的介绍到此为止，接下来就是在模型中引入XGBoost。要修改代码也不难，XGBoost有一个非常方便的开源库可以调用，通过pip下载后，在代码中引入库文件。

~~~python
import xgboost as xgb
~~~

之后，把训练部分替换为以下代码。

~~~python
# 1. 定义模型 (参数是随手填的，不用细调也能赢 MLP)
xgb_model = xgb.XGBRegressor(
    objective='reg:squarederror',
    n_estimators=1000,     # 树的数量
    learning_rate=0.05,    # 学习率
    max_depth=5,           # 树的深度
    n_jobs=-1              #以此来动用你所有的CPU核心
)

# 2. 训练 (记得把 PyTorch 张量转回 numpy)
# train_features 和 train_labels 是你之前处理好的
# reshape(-1) 是为了把标签变成一维数组，XGBoost 喜欢一维的 y
print("开始训练 XGBoost...")
xgb_model.fit(train_features.numpy(), train_labels.numpy().reshape(-1))

# 3. 预测
print("正在预测...")
predictions = xgb_model.predict(test_features.numpy())

# 4. 保存结果
test_data['SalePrice'] = pd.Series(predictions)
submission = pd.concat([test_data['Id'], test_data['SalePrice']], axis=1)
submission.to_csv('submission_xgb.csv', index=False)
~~~

将得到的CSV文件上传到Kaggle，这次的分数值是**0.13312**。

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260115163623779.png?x-oss-process=style/blog" alt="image-20260115163623779" style="zoom:50%;" />

### 特征工程＋模型融合

后续的优化过程就比较单调了，因为我直接让Gemini直接给我优化建议，我很好奇这道题能优化到什么程度。

Gemini给了我两个建议：

1. 引入特征工程，对原训练数据集的特征进行处理，尝试根据直觉构造一些新的强力特征取辅助机器学习。

   > 比如总面积：地下室 + 一楼 + 二楼
   >
   > 房龄 = 卖出年份 - 建成年份 等

2. 引入模型融合，不要只信一个模型，可以引入多个模型对预测结果取加权平均，来利用各个模型的优点。

   > 这里Gemini给出的范例是：
   > $$
   > \text{Final Price} = 0.6 \times \text{XGBoost} + 0.2 \times \text{Lasso} + 0.2 \times \text{Ridge}
   > $$

- **XGBoost (树模型)**：绝对的主力（权重 60%）。它擅长捕捉非线性的复杂关系和特征交互，但它的预测本质上是阶梯状的，容易过拟合。
- **Lasso Regression (L1 正则)**：激进的线性模型。它能将不重要的特征系数压缩为 0（自动做特征选择），负责剔除噪音，防止 XGBoost 在无关特征上钻牛角尖。
- **Ridge Regression (L2 正则)**：稳健的线性模型。它处理共线性特征（比如多个代表面积的指标），让模型更平滑。

之后，修改模型代码（完整代码在文末一起放出），重新训练并生成一个CSV文件提交给Kaggle。这次的得分是**0.12686**。

### 引入LightGBM

LightGBM 是微软开发的，它和 XGBoost 的切分逻辑不同，两者融合通常能产生奇效。

简单来说，LightGBM就是肉的一批的同时伤害还贼高。

1. 模型精度：XGBoost和LightGBM相当。
2. 训练速度：LightGBM远快于XGBoost。(快百倍以上，跟数据集有关系)
3. 内存消耗：LightGBM远小于XGBoost。(大约是XGB的五分之一)
4. 缺失值特征：XGBoost和LightGBM都可以自动处理特征缺失值。
5. 分类特征：XGBoost不支持类别特征，需要OneHot编码预处理。LightGBM直接支持类别特征。

最后，我们引入LightGBM并且调整模型权重为：XGB (30%) + LGBM (30%) + Lasso (20%) + Ridge (20%)

训练分数定格在**0.12462**。这还是在未经过任何调参，纯用Gemini给的超参数提交的结果。

![image-20260115173501721](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260115173501721.png?x-oss-process=style/blog)

## 结语

事实证明，决策树模型比神经网络更加适合处理表格类型的数据。别的不说，哪怕不做特征工程和模型融合，光是引入XGBoost模型，得分就能从0.16优化为0.13，可见XGBoost之威力。

这里插播一段小插曲，在查阅相关资料时，我无意间了解到了机器学习两大流派之间的争论。

> 机器学习主要可以分为联结主义（Connectionism）和符号主义（Symbolism，或称统计学习学派）两大流派。前者以 MLP、深度学习为代表，后者则以决策树、XGBoost 等算法为代表。
>
> 所谓联结主义，可以理解为通过数据预处理，把研究对象看作一个高维矩阵。它本质上是在寻找一个复杂的函数 $f(x) = y$，通过反向传播算法不断微调权重矩阵，以最小化目标函数。
>
> 它的思维方式是连续的：就像捏泥人，通过基于微积分的梯度下降，一点点把模型捏成想要的形状。但这也带来了弊端——它必须从零开始学习所有规律。哪怕是万有引力这样显而易见的物理定律，在神经网络眼里也只是如果不通过海量样本训练就无法察觉的隐性特征。此外，它的黑盒特性导致人们很难控制其学习过程，容易出现过拟合。
>
> 而以树模型为代表的符号主义，它的逻辑截然不同。它不进行复杂的矩阵乘法，而是遵循 If-Else 的硬逻辑。它通过回答一个个离散的问题，把样本空间一步步切割得更纯净。
>
> “在哪里切这一刀”不是人定的，而是机器依靠算法自动找出来的。如果说联结主义是微调，那么树模型就是贪心——无论是随机森林利用信息增益并行生长，还是 XGBoost 利用残差和梯度串行修补，它们都主张把问题离散化，在每一步寻找当下最好的切分点。
>
> 从当下的技术热点来看，联结主义无疑占据了统治地位。以 GPT 为代表的大语言模型证明了大力是真的能出奇迹的。通过海量参数和反向传播，机器涌现出了惊人的智能。很多人认为，只要算力足够大，神经网络就能解决一切问题。但与此同时，也有人在反思当下是否走了弯路。毕竟神经网络能给机器带去直觉，却不一定能理解规律，他们认为，符号主义才是通往AGI的正确道路。

还有一点，在模型选择遇到性能瓶颈后，可以对数据集进行特征工程处理，手动构造出有用的特征值。此外，通过模型融合来综合考虑各个模型的输出结果也能提升表现。这些方法都在这次实战中得到了证实。

如果有时间，最好在本地构造验证集，并尝试不同的超参数，也许能够获得更好的效果。

另外，完整的提交代码如下。一共有三份，分别对应MLP模型，XGBoost模型与模型融合代码。

{% folding cyan, 查看完整代码 %}

{% tabs Kaggle_House_Prices_Prediction,3 %}
<!-- tab MLP.py -->

```python
import hashlib
import os
import tarfile
import zipfile
import requests

import numpy as np
import pandas as pd
import torch
from torch import nn
from d2l import torch as d2l
import matplotlib.pyplot as plt

#@save
DATA_HUB = dict()
DATA_URL = 'http://d2l-data.s3-accelerate.amazonaws.com/'

def download(name, cache_dir=os.path.join('..', 'data')):  #@save
    """下载一个DATA_HUB中的文件，返回本地文件名"""
    assert name in DATA_HUB, f"{name} 不存在于 {DATA_HUB}"
    url, sha1_hash = DATA_HUB[name]
    os.makedirs(cache_dir, exist_ok=True)
    fname = os.path.join(cache_dir, url.split('/')[-1])
    if os.path.exists(fname):
        sha1 = hashlib.sha1()
        with open(fname, 'rb') as f:
            while True:
                data = f.read(1048576)
                if not data:
                    break
                sha1.update(data)
        if sha1.hexdigest() == sha1_hash:
            return fname  # 命中缓存
    print(f'正在从{url}下载{fname}...')
    r = requests.get(url, stream=True, verify=True)
    with open(fname, 'wb') as f:
        f.write(r.content)
    return fname

def download_extract(name, folder=None):  #@save
    """下载并解压zip/tar文件"""
    fname = download(name)
    base_dir = os.path.dirname(fname)
    data_dir, ext = os.path.splitext(fname)
    if ext == '.zip':
        fp = zipfile.ZipFile(fname, 'r')
    elif ext in ('.tar', '.gz'):
        fp = tarfile.open(fname, 'r')
    else:
        assert False, '只有zip/tar文件可以被解压缩'
    fp.extractall(base_dir)
    return os.path.join(base_dir, folder) if folder else data_dir

def download_all():  #@save
    """下载DATA_HUB中的所有文件"""
    for name in DATA_HUB:
        download(name)

DATA_HUB['kaggle_house_train'] = (  #@save
    DATA_URL + 'kaggle_house_pred_train.csv',
    '585e9cc93e70b39160e7921475f9bcd7d31219ce')

DATA_HUB['kaggle_house_test'] = (  #@save
    DATA_URL + 'kaggle_house_pred_test.csv',
    'fa19780a7b011d9b009e8bff8e99922a8ee2eb90')

train_data = pd.read_csv(download('kaggle_house_train'))
test_data = pd.read_csv(download('kaggle_house_test'))

# 去除ID列表
all_features = pd.concat((train_data.iloc[:, 1:-1], test_data.iloc[:, 1:]))

# print(train_data.iloc[0:4, [0, 1, 2, 3, -3, -2, -1]])
# print(all_features.iloc[0:4, [0, 1, 2, 3, -3, -2, -1]])

# 数据预处理
# 首先将缺失的值替换为相应特征的平均值，然后将特征进行标准化，重新缩放到零均值和单位方差
numeric_features = all_features.dtypes[all_features.dtypes != 'object'].index
all_features[numeric_features] = all_features[numeric_features].apply(
    lambda x: (x - x.mean()) / (x.std())
)
# 标准化数据后，均值为0，故缺失值设置为0
all_features[numeric_features] = all_features[numeric_features].fillna(0)

# 接下来，用独热编码替换离散值
all_features = pd.get_dummies(all_features, dummy_na=True)
# all_features.shape

# 从pandas格式提取NumPy格式，并转换为张量用于训练
n_train = train_data.shape[0]
train_features = torch.tensor(all_features[:n_train].values, dtype=torch.float32)
test_features = torch.tensor(all_features[n_train:].values, dtype=torch.float32)
train_labels = torch.tensor(
    train_data.SalePrice.values.reshape(-1, 1),dtype=torch.float32
)

# 训练一个线性模型，作为baseline
loss = nn.MSELoss()
in_features = train_features.shape[1]

def get_net():
    net = nn.Sequential(nn.Linear(in_features,1))
    return net

def log_rmse(net, features, labels):
    # 为了在取对数时进一步稳定该值，将小于1的值设置为1
    clipped_preds = torch.clamp(net(features), 1, float('inf'))
    rmse = torch.sqrt(loss(torch.log(clipped_preds),
                           torch.log(labels)))
    return rmse.item()

def train(net, train_features, train_labels, test_features, test_labels,
          num_epochs, learning_rate, weight_decay, batch_size):
    train_ls, test_ls =[], []
    train_iter = d2l.load_array((train_features, train_labels), batch_size)

    optimizer = torch.optim.Adam(net.parameters(),
                                 lr=learning_rate,
                                 weight_decay=weight_decay)
    for epoch in range(num_epochs):
        for X, y in train_iter:
            optimizer.zero_grad()
            l = loss(net(X),y)
            l.backward()
            optimizer.step()
        train_ls.append(log_rmse(net, train_features, train_labels))
        if test_labels is not None:
            test_ls.append(log_rmse(net, test_features, test_labels))
    return train_ls, test_ls

def get_k_fold_data(k, i, X, y):
    assert k > 1
    fold_size = X.shape[0] // k
    X_train, y_train = None, None
    for j in range(k):
        idx = slice(j * fold_size, (j+1) * fold_size)
        X_part, y_part = X[idx, :], y[idx]
        if j == i:
            X_valid, y_valid = X_part, y_part
        elif X_train is None:
            X_train, y_train = X_part, y_part
        else:
            X_train = torch.cat([X_train, X_part], 0)
            y_train = torch.cat([y_train, y_part], 0)
    return X_train, y_train, X_valid, y_valid

def k_fold(k, X_train, y_train, num_epochs, learning_rate, weight_decay,
           batch_size):
    train_l_sum, valid_l_sum = 0, 0
    for i in range(k):
        data = get_k_fold_data(k, i, X_train, y_train)
        net = get_net()
        train_ls, valid_ls = train(net, *data, num_epochs, learning_rate,
                                   weight_decay, batch_size)
        train_l_sum += train_ls[-1]
        valid_l_sum += valid_ls[-1]
        if i == 0:
            d2l.plot(list(range(1, num_epochs + 1)), [train_ls, valid_ls],
                     xlabel='epoch', ylabel='rmse', xlim=[1, num_epochs],
                     legend=['train', 'valid'], yscale='log')
            # 【新增代码】将图像保存到当前目录下的 result.png 文件中
            # plt.savefig('result1.png')
            # print("图像已保存为 result1.png") 
            
        print(f'折{i + 1}，训练log rmse{float(train_ls[-1]):f}, '
              f'验证log rmse{float(valid_ls[-1]):f}')
              
    # 注意：下面这个 return 缩进有问题（见下文“额外提示”）
    return train_l_sum / k, valid_l_sum /k
    
k, num_epochs, lr, weight_decay, batch_size = 5, 100, 5, 0, 64
train_l, valid_l = k_fold(k, train_features, train_labels, num_epochs, lr,
                          weight_decay, batch_size)
print(f'{k}-折验证: 平均训练log rmse: {float(train_l):f}, '
      f'平均验证log rmse: {float(valid_l):f}')

def train_and_pred(train_features, test_features, train_labels, test_data,
                   num_epochs, lr, weight_decay, batch_size):
    net = get_net()
    train_ls, _ = train(net, train_features, train_labels, None, None,
                        num_epochs, lr, weight_decay, batch_size)
    d2l.plot(np.arange(1, num_epochs + 1), [train_ls], xlabel='epoch',
             ylabel='log rmse', xlim=[1, num_epochs], yscale='log')
    plt.savefig('train_final.png')
    print(f'训练log rmse：{float(train_ls[-1]):f}')
    # 将网络应用于测试集。
    preds = net(test_features).detach().numpy()
    # 将其重新格式化以导出到Kaggle
    test_data['SalePrice'] = pd.Series(preds.reshape(1, -1)[0])
    submission = pd.concat([test_data['Id'], test_data['SalePrice']], axis=1)
    submission.to_csv('submission.csv', index=False)

train_and_pred(train_features, test_features, train_labels, test_data,
               num_epochs, lr, weight_decay, batch_size)
```

<!-- endtab -->

<!-- tab XGBoost.py -->

```python
import hashlib
import os
import tarfile
import zipfile
import requests

import numpy as np
import pandas as pd
import torch
from torch import nn
from d2l import torch as d2l
import matplotlib.pyplot as plt
import xgboost as xgb

#@save
DATA_HUB = dict()
DATA_URL = 'http://d2l-data.s3-accelerate.amazonaws.com/'

def download(name, cache_dir=os.path.join('..', 'data')):  #@save
    """下载一个DATA_HUB中的文件，返回本地文件名"""
    assert name in DATA_HUB, f"{name} 不存在于 {DATA_HUB}"
    url, sha1_hash = DATA_HUB[name]
    os.makedirs(cache_dir, exist_ok=True)
    fname = os.path.join(cache_dir, url.split('/')[-1])
    if os.path.exists(fname):
        sha1 = hashlib.sha1()
        with open(fname, 'rb') as f:
            while True:
                data = f.read(1048576)
                if not data:
                    break
                sha1.update(data)
        if sha1.hexdigest() == sha1_hash:
            return fname  # 命中缓存
    print(f'正在从{url}下载{fname}...')
    r = requests.get(url, stream=True, verify=True)
    with open(fname, 'wb') as f:
        f.write(r.content)
    return fname

def download_extract(name, folder=None):  #@save
    """下载并解压zip/tar文件"""
    fname = download(name)
    base_dir = os.path.dirname(fname)
    data_dir, ext = os.path.splitext(fname)
    if ext == '.zip':
        fp = zipfile.ZipFile(fname, 'r')
    elif ext in ('.tar', '.gz'):
        fp = tarfile.open(fname, 'r')
    else:
        assert False, '只有zip/tar文件可以被解压缩'
    fp.extractall(base_dir)
    return os.path.join(base_dir, folder) if folder else data_dir

def download_all():  #@save
    """下载DATA_HUB中的所有文件"""
    for name in DATA_HUB:
        download(name)

DATA_HUB['kaggle_house_train'] = (  #@save
    DATA_URL + 'kaggle_house_pred_train.csv',
    '585e9cc93e70b39160e7921475f9bcd7d31219ce')

DATA_HUB['kaggle_house_test'] = (  #@save
    DATA_URL + 'kaggle_house_pred_test.csv',
    'fa19780a7b011d9b009e8bff8e99922a8ee2eb90')

train_data = pd.read_csv(download('kaggle_house_train'))
test_data = pd.read_csv(download('kaggle_house_test'))

# 去除ID列表
all_features = pd.concat((train_data.iloc[:, 1:-1], test_data.iloc[:, 1:]))


# 数据预处理
# 首先将缺失的值替换为相应特征的平均值，然后将特征进行标准化，重新缩放到零均值和单位方差
numeric_features = all_features.dtypes[all_features.dtypes != 'object'].index
all_features[numeric_features] = all_features[numeric_features].apply(
    lambda x: (x - x.mean()) / (x.std())
)
# 标准化数据后，均值为0，故缺失值设置为0
all_features[numeric_features] = all_features[numeric_features].fillna(0)

# 接下来，用独热编码替换离散值
all_features = pd.get_dummies(all_features, dummy_na=True)
# all_features.shape

# 从pandas格式提取NumPy格式，并转换为张量用于训练
n_train = train_data.shape[0]
train_features = torch.tensor(all_features[:n_train].values, dtype=torch.float32)
test_features = torch.tensor(all_features[n_train:].values, dtype=torch.float32)
train_labels = torch.tensor(
    train_data.SalePrice.values.reshape(-1, 1),dtype=torch.float32
)

# 1. 定义模型 (参数是随手填的，不用细调也能赢 MLP)
xgb_model = xgb.XGBRegressor(
    objective='reg:squarederror',
    n_estimators=1000,     # 树的数量
    learning_rate=0.05,    # 学习率
    max_depth=5,           # 树的深度
    n_jobs=-1              #以此来动用你所有的CPU核心
)

# 2. 训练 (记得把 PyTorch 张量转回 numpy)
# train_features 和 train_labels 是你之前处理好的
# reshape(-1) 是为了把标签变成一维数组，XGBoost 喜欢一维的 y
print("开始训练 XGBoost...")
xgb_model.fit(train_features.numpy(), train_labels.numpy().reshape(-1))

# 3. 预测
print("正在预测...")
predictions = xgb_model.predict(test_features.numpy())

# 4. 保存结果
test_data['SalePrice'] = pd.Series(predictions)
submission = pd.concat([test_data['Id'], test_data['SalePrice']], axis=1)
submission.to_csv('submission_xgb.csv', index=False)

print("搞定！去提交 submission_xgb.csv 吧！")
```

<!-- endtab -->

<!-- tab Final.py -->

```python
import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.linear_model import Ridge, Lasso
from sklearn.model_selection import KFold, cross_val_score
import warnings
import lightgbm as lgb  # 引入新巨头

# 忽略一些恼人的警告
warnings.filterwarnings('ignore')

# -----------------------------------------------------------
# 1. 读取数据 (假设数据在 ../data/ 目录下，根据实际情况修改)
# -----------------------------------------------------------
print("正在读取数据...")
train_path = '../data/kaggle_house_pred_train.csv'
test_path = '../data/kaggle_house_pred_test.csv'

# 如果找不到文件，尝试在当前目录找
try:
    train_data = pd.read_csv(train_path)
    test_data = pd.read_csv(test_path)
except FileNotFoundError:
    train_data = pd.read_csv('kaggle_house_pred_train.csv')
    test_data = pd.read_csv('kaggle_house_pred_test.csv')

# -----------------------------------------------------------
# 2. 特征工程 (Feature Engineering) - 这里的每一行都是分数的来源
# -----------------------------------------------------------
print("正在进行高级特征工程...")

# 去掉训练集中的极端离群点 (Outliers)，这是数据科学界的共识
# 比如有些房子面积特别大(>4000)但价格却很便宜，这种数据会误导模型
train_data = train_data[train_data.GrLivArea < 4500]
train_data.reset_index(drop=True, inplace=True)

# 记录训练集数量，准备拼接
n_train = train_data.shape[0]
train_y = np.log1p(train_data.SalePrice.values) # 标签 Log 变换
all_data = pd.concat((train_data.iloc[:, 1:-1], test_data.iloc[:, 1:]))

# --- 构造强力新特征 ---
# 1. 总面积：地下室 + 一楼 + 二楼。这是决定房价最核心的因素
all_data['TotalSF'] = all_data['TotalBsmtSF'] + all_data['1stFlrSF'] + all_data['2ndFlrSF']

# 2. 浴室总数：全浴 + 半浴*0.5
all_data['Total_Bathrooms'] = (all_data['FullBath'] + (0.5 * all_data['HalfBath']) +
                               all_data['BsmtFullBath'] + (0.5 * all_data['BsmtHalfBath']))

# 3. 房子综合素质：总体评价 * 总面积 (交互特征)
all_data['Total_SF_Qual'] = all_data['TotalSF'] * all_data['OverallQual']

# 4. 有无泳池/地下室/二楼 (布尔特征)
all_data['HasPool'] = all_data['PoolArea'].apply(lambda x: 1 if x > 0 else 0)
all_data['Has2ndFloor'] = all_data['2ndFlrSF'].apply(lambda x: 1 if x > 0 else 0)
all_data['HasGarage'] = all_data['GarageArea'].apply(lambda x: 1 if x > 0 else 0)

# 5. 房龄特征
all_data['YrBltAndRemod'] = all_data['YearBuilt'] + all_data['YearRemodAdd']

# --- 数据清洗与编码 ---
# 填补缺失值 (不同类型的列用不同策略)
# 文本列缺省通常意味着“没有”，比如 GarageType 缺省就是没有车库
cols_fillna_none = ['PoolQC', 'MiscFeature', 'Alley', 'Fence', 'FireplaceQu',
                   'GarageType', 'GarageFinish', 'GarageQual', 'GarageCond',
                   'BsmtQual', 'BsmtCond', 'BsmtExposure', 'BsmtFinType1', 'BsmtFinType2']
for col in cols_fillna_none:
    all_data[col] = all_data[col].fillna('None')

# 数值列缺省通常填 0
cols_fillna_0 = ['GarageYrBlt', 'GarageArea', 'GarageCars', 'BsmtFinSF1', 'BsmtFinSF2',
                 'BsmtUnfSF','TotalBsmtSF', 'BsmtFullBath', 'BsmtHalfBath']
for col in cols_fillna_0:
    all_data[col] = all_data[col].fillna(0)

# 其他零散的缺失值填众数 (最常见的值)
all_data['MSZoning'] = all_data['MSZoning'].fillna(all_data['MSZoning'].mode()[0])
all_data['Electrical'] = all_data['Electrical'].fillna(all_data['Electrical'].mode()[0])
all_data['KitchenQual'] = all_data['KitchenQual'].fillna(all_data['KitchenQual'].mode()[0])
all_data['Exterior1st'] = all_data['Exterior1st'].fillna(all_data['Exterior1st'].mode()[0])
all_data['Exterior2nd'] = all_data['Exterior2nd'].fillna(all_data['Exterior2nd'].mode()[0])
all_data['SaleType'] = all_data['SaleType'].fillna(all_data['SaleType'].mode()[0])

# 独热编码
all_data = pd.get_dummies(all_data).fillna(0) # 最后的保险，把剩下的 NaN 填 0

# 拆分回训练集和测试集
X_train = all_data[:n_train]
X_test = all_data[n_train:]

# -----------------------------------------------------------
# 3. 定义模型融合 (Model Stacking/Blending) - 进阶版
# -----------------------------------------------------------
import lightgbm as lgb  # 引入新巨头

print("准备四大模型...")

# 模型 1: Ridge (线性)
ridge = Ridge(alpha=13) # 稍微调了一下 alpha

# 模型 2: Lasso (线性)
lasso = Lasso(alpha=0.0005)

# 模型 3: XGBoost (树)
xgb_model = xgb.XGBRegressor(
    objective='reg:squarederror',
    n_estimators=3000,
    learning_rate=0.01,
    max_depth=4,
    min_child_weight=1,
    gamma=0,
    subsample=0.7,
    colsample_bytree=0.7,
    n_jobs=-1,
    random_state=42
)

# 模型 4: LightGBM (树 - 新加入)
# LightGBM 对叶子节点的生长策略不同，能捕捉 XGB 漏掉的信息
lgb_model = lgb.LGBMRegressor(
    objective='regression',
    num_leaves=31,
    learning_rate=0.01,
    n_estimators=3000,
    max_bin=200,
    bagging_fraction=0.75,
    bagging_freq=5,
    bagging_seed=7,
    feature_fraction=0.2,
    feature_fraction_seed=7,
    verbose=-1,
    n_jobs=-1
)

# -----------------------------------------------------------
# 4. 训练与预测
# -----------------------------------------------------------
print("训练 Ridge...")
ridge.fit(X_train, train_y)
ridge_pred = np.expm1(ridge.predict(X_test))

print("训练 Lasso...")
lasso.fit(X_train, train_y)
lasso_pred = np.expm1(lasso.predict(X_test))

print("训练 XGBoost...")
xgb_model.fit(X_train, train_y)
xgb_pred = np.expm1(xgb_model.predict(X_test))

print("训练 LightGBM...")
lgb_model.fit(X_train, train_y)
lgb_pred = np.expm1(lgb_model.predict(X_test))

# -----------------------------------------------------------
# 5. 终极四模型融合 (Blending)
# -----------------------------------------------------------
print("正在融合四大天王...")

# 权重分配策略：树模型负责强攻，线性模型负责修正
# 0.3 * XGB + 0.3 * LGB + 0.2 * Lasso + 0.2 * Ridge
final_pred = (0.3 * xgb_pred) + (0.3 * lgb_pred) + (0.2 * lasso_pred) + (0.2 * ridge_pred)

# -----------------------------------------------------------
# 6. 保存结果
# -----------------------------------------------------------
submission = pd.DataFrame()
submission['Id'] = test_data.Id
submission['SalePrice'] = final_pred

filename = 'submission_final_4models.csv'
submission.to_csv(filename, index=False)

print(f"\n成功生成: {filename}")
print(f"融合策略: XGB(30%) + LGB(30%) + Lasso(20%) + Ridge(20%)")
```

<!-- endtab -->
{% endtabs %}

{% endfolding %}

最后，放一下提交记录截图。

![image-20260115173548437](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260115173548437.png?x-oss-process=style/blog)

---

![image-20260115192208544](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/image-20260115192208544.png?x-oss-process=style/blog)

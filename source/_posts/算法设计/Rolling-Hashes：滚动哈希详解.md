---
title: Rolling Hashes：滚动哈希详解
date: 2024-12-11 20:22:13
updated: 2024-12-11 20:22:13
tags:
  - Rolling Hashes
  - Rabin-Karp
categories: 算法笔记
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/2404CBF21EC9ECF50FF185A745A075DE.jpg?x-oss-process=style/blog
description: 关于滚动哈希算法的原理介绍，以及实战运用。
---

# 滚动哈希算法

## 哈希函数

什么是哈希函数？

> 哈希函数是将输入映射到固定大小输出的函数。它可以将一个字符串映射成一个整数，这个整数称为哈希值。
>
> 通常我们使用的哈希函数具有以下两个特点：
>
> - 均匀性：对于任意两个不同的输入，哈希值相等的概率很小。
> - 稳定性：对于同一个输入，哈希值相同。

了解了哈希函数的定义，就可以学习滚动哈希算法了。

## 滚动哈希

滚动哈希，即 Rolling Hashes 是一种快速计算字符串哈希值的方法。它利用字符串前后子串的关系，只需要 O(1) 的时间就可以计算新的哈希值。

滚动哈希的计算公式如下所示：
$$
\text{hash}(s_{i+1\dots i+m})=(d(\text{hash}(s_{i\dots i+m-1})-s_i\times d^{m-1})+s_{i+m})\mod M
$$
其中：

- $\text{hash}(s_{i\dots i+m-1})$代表从第$i$个字符开始，长为$m$的子串的哈希值
- $d$代表一个常数，叫做**进制数**，通常取一个较大的质数，比如31、131、13331等
- $s_i$和$s_{i+m}$代表字符串中的第$i$个字符和第$i+m$个字符
- $M$代表一个大的模数，用来控制哈希数的范围并减少哈希冲突

这个式子的含义是：**新的子串的哈希值，等于旧的子串的哈希值减去最左边元素的贡献再加上新的字符**

### 应用场景

#### 字符串匹配问题

滚动哈希是经典的 **Rabin-Karp 字符串匹配算法** 的核心思想，用于在一个长字符串中查找特定模式的所有出现位置。

Rolling Hashes 可以通过计算文本串和模式串的哈希值来解决字符串匹配问题。具体来说，我们可以先计算出模式串的哈希值，然后依次对文本串中的每个长度为模式串长度的子串计算哈希值，并将其与模式串的哈希值进行比较。如果匹配成功，则返回位置。

#### 最长公共子串

给定两个字符串 $s1$ 和 $s2$ ，找到它们的最长公共子串。例如，对于字符串 “abcde” 和 “ababcde”，它们的最长公共子串为 “abcde”。

Rolling Hashes 可以通过计算两个字符串的哈希值来解决最长公共子串问题。可以先计算第一个字符串的所有长度小于$n$的子串的哈希值，其中$n$是字符串长度。然后再一一计算第二个字符串的所有子串哈希值，检测是否发生哈希碰撞。如果发生碰撞，就说明出现了相等的字符串。

还有一种可选的做法是先将两个字符串拼接起来，然后对于所有长度小于等于 $n$ 的子串计算哈希值，其中 $n$ 是字符串长度。最后，我们在两个字符串中分别查找哈希值相等的最长子串，即可找到它们的最长公共子串。

将字符串拼接后的好处是我们不必再在两个字符串中进行检索，只需要在一个拼接后的字符串中查找是否有相同的子串就好，更加直观了。

#### 最长回文子串

最长回文子串问题是指，给定一个字符串 $s$，找到它的最长回文子串。例如，对于字符串 “babad”，它的最长回文子串为 “bab” 或 “aba”。

它实际上是最长公共子串的变种，我们只需要把给定的字符串逆序然后拼接在原字符串上，就转化为了最长公共子串问题。

## 实战

让我们做一道题：[718. 最长重复子数组 - 力扣（LeetCode）](https://leetcode.cn/problems/maximum-length-of-repeated-subarray/)

> 给两个整数数组 `nums1` 和 `nums2` ，返回 *两个数组中 **公共的** 、长度最长的子数组的长度* 。
>
> **示例 1：**
>
> ```
> 输入：nums1 = [1,2,3,2,1], nums2 = [3,2,1,4,7]
> 输出：3
> 解释：长度最长的公共子数组是 [3,2,1] 。
> ```
>
> **示例 2：**
>
> ```
> 输入：nums1 = [0,0,0,0,0], nums2 = [0,0,0,0,0]
> 输出：5
> ```

我们可以代入最长公共子串问题的做法：

1. 用二分法快速定位最长子串的长度`length`
2. 用滑动窗口计算`length`下，所有`nums1`子串的哈希值，记录在哈希表中
3. 继续用滑动窗口计算`length`下，所有`nums2`子串的哈希值，检测是否发生碰撞

这里要求的是最长子数组，所以我们可以省去用哈希函数处理字符的过程，直接代入数字去计算它们的哈希值。此时，哈希值的计算公式为：
$$
\text{hash}=(a_1 \cdot b^{L-1}+a_2\cdot b^{L-2}+\cdots+a_L\cdot b^0)\mod M
$$
对应的代码如下：

~~~go
// 计算长度为length的数组字串哈希值
for i := 0; i < length; i++{
    hash = (hash*base + nums1[i]) % mod
    power = (power * base) % mod
}
~~~

至于这个`power`有什么用我们待会再说，现在你只要知道这是**权重**的意思。

当我们完成了长度为`length`的窗口哈希值计算，我们就可以开始移动窗口了。现在，我们要移除最左边的元素，添加窗口右边的一个元素，也就是把窗口向右边移动一位，并计算新的子串的哈希值。

显然，继续套用哈希值计算公式，我们要做大量的重复计算，代价十分高昂，所以是不可取的。我们之前提到过计算新的子串哈希值的做法：：**新的子串的哈希值，等于旧的子串的哈希值减去最左边元素的贡献再加上新的字符**。

也就是：
$$
\text{new\_hash\_intermediate}=(\text{hash}-a_1\cdot b^{L-1})\cdot b \\
\text{new\_hash}=(\text{new\_hash\_intermediate}+a_{L+1})\mod M
$$
代入整理一下即可得到
$$
\text{new\_hash}=((\text{hash}-a_1\cdot b^{L-1})\cdot b+a_{L+1})\mod M
$$
通俗解释一下，我们要减去最左边的元素对哈希值的贡献并加上新的元素的哈希值。加上新元素的哈希值不难理解，问题在于怎么去除最左边的元素对哈希值的贡献？

最左边的元素其实也就是第一个元素，在计算第一个窗口的过程中，它被不断的乘上$\text{base}$并重复$L$次，其中$L$是窗口长度，`base`是哈希的基数。每次滑动窗口，最左边的元素需要移除，这就意味着它的贡献（包括权重）也需要被移除。所以我们需要减去$a_1\cdot b^{L-1}$，这个$b^{L-1}$就是权重，也就是我们代码中的`power`。

那你可能会问了：可不可以临时计算`power`？比如直接用$\text{power}=\text{base}^{\text{length-1}}\mod M$得到，这样做比逐步计算`power`是否更好？

这种方式是可行的，每次计算$\text{power}=\text{base}^{\text{length-1}}\mod M$时，可以使用**快速幂算法**，时间复杂度仅为$O(\text{log}(\text{length}))$，而逐次迭代计算`power`的时间复杂度为$O(\text{length})$。实际运用中也推荐这么做，但我懒得搓快速幂算法，就图省事了……

故而我们滑动窗口的代码可以写作：

~~~go
// m是nums1的长度
for i := length; i < m; i++{
    hash = (hash*base - nums1[i-length]*power + nums1[i]) % mod
    if hash < 0{
        hash += mod
    }
}
~~~

这就是滚动哈希的全部内容了。但是要解开这道题还不够，我们需要做一些善后工作。

假定我们校验哈希值的函数为`check(length int) bool`，我们需要用二分法确定合适的`length`值。这部分相比滚动哈希就要简单很多了，代码如下：

~~~go
    // 运用二分法确定最大公共子串长度；m，n分别为nums1和nums2的长度
    left, right := 0, min(m,n)
    maxLength := 0
    for left <= right{
        mid := (left + right) / 2
        if check(mid){
            if mid > maxLength{
                maxLength = mid
            }
            left = mid + 1
        }else{
            right = mid - 1
        }
    }

    return maxLength
~~~

至此我们的代码主体就撰写完毕了。完整的代码如下：

{% folding cyan, 查看完整代码 %}

~~~go
func findLength(nums1 []int, nums2 []int) int {
    /*
    用二分法+滚动哈希来解决
    滚动哈希的逻辑
    */
    m := len(nums1)
    n := len(nums2)
    mod := int(1e9 - 7)
    base := 101

    check := func (length int) bool {
        hashSet := make(map[int]struct{})
        // 计算nums1的初始哈希值
        power := 1
        hash := 0

        for i := 0; i < length; i++{
            hash = (hash*base + nums1[i]) % mod
            power = power*base % mod
        }
        hashSet[hash] = struct{}{} // 记录原始哈希

        // 计算滑动窗口的每个哈希值
        for i := length; i < m; i++{
            hash = (hash*base - nums1[i-length]*power + nums1[i]) % mod
            if hash < 0{
                hash += mod
            }
            hashSet[hash] = struct{}{}
        }

        //计算nums2的初始哈希值
        hash = 0
        
        for i := 0; i < length; i++{
            hash = (hash*base + nums2[i]) % mod
        }
        // 如果发生碰撞，则返回真
        if _,exist := hashSet[hash]; exist{
            return true
        }

        // 计算滑动窗口的每个哈希值
        for i := length; i < n; i++{
            hash = (hash*base - nums2[i-length]*power + nums2[i]) % mod
            if hash < 0{
                hash += mod
            }
            if _,exist := hashSet[hash]; exist{
                return true
            }
        }
        //走到这里说明没发生碰撞
        return false
    }

    // 运用二分法确定最大公共子串长度
    left, right := 0, min(m,n)
    maxLength := 0
    for left <= right{
        mid := (left + right) / 2
        if check(mid){
            if mid > maxLength{
                maxLength = mid
            }
            left = mid + 1
        }else{
            right = mid - 1
        }
    }

    return maxLength
}

func min(m int, n int) int{
    if m > n{
        return n
    }else{
        return m
    }
}
~~~

{% endfolding %}

小贴一手用时情况:fire:

<img src="https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/fb526ed9340e525e85a88458840344a.png?x-oss-process=style/blog" alt="fb526ed9340e525e85a88458840344a" style="zoom:50%;" />

## 总结

滚动哈希是一种高效处理字符串和数组子段问题的算法，通过将子段转化为哈希值，可以快速比较或匹配子段。它的核心在于利用滑动窗口，通过递推公式在 $O(1)$ 时间内更新哈希值，避免重新计算整个子段的哈希。

滚动哈希常用于字符串匹配（如 Rabin-Karp 算法）、检测重复子串、最长公共子串等问题。它尤其适合固定长度的子段处理。通过合理选择基数 $b$ 和模数 $M$，可以有效减少哈希冲突，提高算法准确性和效率。

在需要寻找最长满足某条件的子段问题中，滚动哈希通常与**二分查找**结合使用。二分查找确定子段长度，滚动哈希验证是否存在符合条件的子段，这种组合将时间复杂度优化为 $O(n \cdot log(n))$。

---

![2404CBF21EC9ECF50FF185A745A075DE](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/2404CBF21EC9ECF50FF185A745A075DE.jpg?x-oss-process=style/blog)

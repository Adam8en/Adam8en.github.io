---
title: LeetCode经典面试150题题解
date: 2024-05-08 20:52:01
updated: 2024-05-08 20:52:01
tags: 
  - Go
  - 算法
categories: LeetCode
cover: https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%7B930EB68A-6F85-4666-BA42-9333A5074315%7D.png
description: LeetCode面试经典 150 题的个人题解笔记
---

# 88. 合并两个有序数组


> Problem: [88. 合并两个有序数组](https://leetcode.cn/problems/merge-sorted-array/description/)

## 思路

使用“双指针”技术，从两个数组的末尾开始比较元素，然后将较大的元素放入nums1的末尾。这样，我们可以确保nums1在每一步都保持有序。这种方法的关键在于我们从后往前填充nums1，这样就不会覆盖nums1中尚未处理的元素。

## 解题方法

1. 初始化两个指针 p1 和 p2 到 nums1 和 nums2 的初始元素的最后一个位置上，然后再用一个指针 p 指向 nums1 的最后一个位置。

2. 比较 nums1[p1] 和 nums2[p2] 的值，将较大的值放入 nums1[p] 的位置上，然后将 p 指针和较大值的指针都向前移动一位。

3. 重复步骤 2，直到 p1 或 p2 小于 0，这意味着 nums1 或 nums2 的元素已经全部放入 nums1 中。

4. 如果 p2 还没有小于 0，那么将 nums2 中剩余的元素复制到 nums1 的前面。

## 复杂度

时间复杂度:
时间复杂度是 O(m+n)，其中m和n分别是 nums1 和 nums2 的长度。在最坏的情况下，我们可能需要遍历 nums1 和 nums2 中的所有元素。因为我们只遍历每个元素一次，所以时间复杂度是线性的。

空间复杂度:
空间复杂度是O(1)。这是因为我们没有使用额外的空间来存储数据。所有的操作都是在原地进行的，我们只是使用了几个额外的变量来保存索引。因此，空间复杂度是常数的。



## Code

```go
func merge(nums1 []int, m int, nums2 []int, n int)  {
    p1:=m-1
    p2:=n-1
    p:=m+n-1

    for p1>=0 && p2>=0{
        if nums1[p1]>nums2[p2]{
            nums1[p]=nums1[p1]
            p1--
            p--
        }else{
            nums1[p]=nums2[p2]
            p2--
            p--
        }
    }

    for p2>=0{
        nums1[p]=nums2[p2]
        p--
        p2--
    }

}
```

# 27. 移除元素


> Problem: [27. 移除元素](https://leetcode.cn/problems/remove-element/description/)

## 思路

这题如果直接用Go的切片功能去删除元素会出现问题，因为一遍遍历数组一边修改数组会导致遍历时的索引出现问题，所以我们还是继续用双指针。双指针技术在数组或链表的问题中非常常用，它可以帮助我们以线性时间复杂度解决问题。

## 解题方法

创建两个指针，一个用于遍历数组（我们称之为右指针），另一个用于指向下一个将要插入的位置（我们称之为左指针）。
从左到右遍历数组，对于每一个元素，检查它是否等于给定的值。
如果元素不等于给定的值，就把它复制到左指针指向的位置，然后把左指针向右移动一位。
如果元素等于给定的值，就忽略它，不做任何操作。
遍历完数组后，左指针的位置就是新的数组长度。

## 复杂度

时间复杂度:
这两段代码都是通过一次遍历完成的，其中 n 是数组的长度。在遍历过程中，每个元素都被访问一次并进行一次比较操作，因此，时间复杂度是 O(n)。

空间复杂度:
这两段代码都是在原地修改数组，没有使用额外的数组或其他数据结构。除了输入数组外，只使用了常数个变量（例如，左指针、右指针和 val）。因此，空间复杂度是 O(1)。

## Code

```Go 
func removeElement(nums []int, val int) int {
    i:=0
    for j:=0;j<len(nums);j++{
        if nums[j]!=val{
            nums[i]=nums[j]
            i++
        }
    }
    return i
}
```

# 26.删除有序数组中的重复项


> Problem: [26. 删除有序数组中的重复项](https://leetcode.cn/problems/remove-duplicates-from-sorted-array/description/)

## 思路

代码的主要思想是使用两个指针，一个慢指针 i 和一个快指针 j，同时遍历数组。其中，慢指针指向当前处理的元素，快指针用于寻找下一个不同的元素。

## 解题方法

首先检查数组是否为空，如果为空，则直接返回0，因为没有元素需要处理。

初始化两个指针 i 和 j，并设置 i=0。这里，i 是一个慢指针，它表示已处理的不同元素的数量，j 是一个快指针，用于遍历数组寻找下一个不同的元素。

使用一个 for 循环，从 j=1 开始遍历数组。在每次迭代中，检查 nums[j] 是否与 nums[i] 不同。如果 nums[j] 与 nums[i] 不同，这意味着我们找到了一个新的不同的元素。此时，我们将 nums[j] 的值赋给 nums[i+1]，并将 i 的值加1，表示我们找到了一个新的不同的元素。当 for 循环结束时，i+1 的值就是数组中不同元素的数量。因此，我们返回 i+1。

## 复杂度

时间复杂度:
时间复杂度是O(n)，因为我们只遍历数组一次。

空间复杂度:
空间复杂度是 O(1)，因为我们只使用了常数个额外的变量。



## Code

```Go []
func removeDuplicates(nums []int) int {
    if len(nums) == 0 {
        return 0
    }
    if len(nums) == 1{
        return 1
    }
    
    i := 0
    for j := 1; j < len(nums); j++ {
        if nums[j] != nums[i] {
            i++
            nums[i] = nums[j]
        }
    }
    return i + 1
}
```

# 80.删除有序数组中的重复项 II


> Problem: [80. 删除有序数组中的重复项 II](https://leetcode.cn/problems/remove-duplicates-from-sorted-array-ii/description/)

## 思路

这道题目要求我们在一个有序数组中删除重复项，使每个元素最多出现两次，并返回新的数组长度。在不使用额外空间的条件下，我们可以考虑使用双指针的方法来解决这个问题。

注意题给数组为有序数组

## 解题方法

我们使用两个指针，一个用于遍历数组（fast），另一个指向当前修改的位置（slow）。

具体步骤如下：

如果数组的长度小于等于2，那么所有的元素都应该保留，因为他们的出现次数都不会超过2次，所以直接返回数组的长度即可。

初始化两个指针，slow = 2 和 fast = 2。slow指针表示处理过的数组的长度，fast指针表示已经检查过的数组的长度。

当 fast < n时，比较 nums[slow - 2] 和 nums[fast]，如果相等，则说明已经有两个数相等，fast指针继续前进。如果不相等，将 nums[fast]的值复制到 nums[slow]，然后增加 slow 和 fast。

返回 slow，表示处理后的数组长度。

## 复杂度

时间复杂度: O(n)
这是因为我们只需要遍历一次数组。

空间复杂度: O(1)
我们只使用了常数级别的额外空间。

## Code

```go
func removeDuplicates(nums []int) int {
    var slow,fast,n=2,2,len(nums)
    if n<=2{
        return n
    }
    for fast<n{
        if(nums[slow-2]!=nums[fast]){
            nums[slow]=nums[fast]
            slow++
        }
        fast++
    }
    return slow
}
```

# 169. 多数元素

> Problem: [169. 多数元素](https://leetcode.cn/problems/majority-element/description/)

## 思路

这道题目要求我们找到一个数组中的多数元素，即出现次数大于数组长度一半的元素。由于题目保证一定存在这样的多数元素，我们可以使用Boyer-Moore投票算法来解决这个问题。

## 解题方法

Boyer-Moore投票算法的核心思想是利用“多数元素”的定义，即它的出现次数至少是数组长度的一半。这意味着，如果我们在遍历数组的过程中，对所有非多数元素进行投票（计数），那么当我们遇到多数元素时，计数器应该会增加，直到超过数组长度的一半。在这个过程中，我们只需要维护一个或两个候选多数元素及其计数。

### Boyer-Moore投票算法

Boyer-Moore 投票算法的步骤如下：

> 维护一个候选主要元素 candidate 和候选主要元素的出现次数count。
>
> 初始时candidate 为任意值，count=0。
>
> 遍历数组nums 中的所有元素，遍历到元素 x 时，进行如下操作：
>
> ​       如果count=0，则将 x 的值赋给candidate，否则不更新candidate 的值；
>
> ​        如果 x=candidate，则将 count 加 1，否则将count 减 1。
>
> 遍历结束之后，candidate的值可能为主要元素。（可能的原因是，如果是这样的一个数组[1,2,3]，那么剩下的元素是3，但是3并不是数量超过一半的元素）

可以类比为打擂台，candidate就是守擂的多数元素。接着遍历给定数组，如果遇到的同一个类型的数，那么守擂的人数就增加，对应count++；如果遇到的事不同类型的数字，那么守擂方就和打擂台的人同归于尽，对应count--。当count为0时，说明原守擂人已经全部GG了，于是把candidate设置为当前的这个数，作为新的守擂人。

由于一开始不知道谁是势力最大的帮派，所以各个不同帮派之间两两火并。最后剩下来的一定是势力最大的帮派。

就算所有小帮派知道谁是势力最大的帮派，他们“群起攻之”。每一个小帮派的人都消耗掉势力最大的帮派的一个人。但是由于势力最大的帮派的人数大于一半，所以即使这样，最后剩下来的还是大帮派的人。

以上就是Boyer-Moore 投票算法最通俗易懂的解释。

## 复杂度

时间复杂度:

O(n)

这个算法只需要遍历数组一次，因此时间复杂度是线性的。

空间复杂度:

O(1)

由于我们只需要一个或两个候选元素和它们的计数器，所以空间复杂度是常数级别的。

## Code

```go
func majorityElement(nums []int) int {
    candidate:=0
    count:=0
    for _,value := range nums{
        if count==0{
            candidate=value
        }
        if candidate==value{
            count++
        }else{
            count--
        }
    }
    return candidate
}
```

# 189.轮转数组

> Problem: [189. 轮转数组](https://leetcode.cn/problems/rotate-array/description/)

## **思路**

当拿到这个问题时，我们的目标是将一个整数数组 nums 向右轮转 k 个位置。这个问题可以通过几种不同的方法解决，但考虑到题目中提到的“原地”算法和空间复杂度为 O(1) 的要求，我们选择一种不需要额外空间的解决方案。

## 解题方法

我们选择的解题方法是三次反转法，这种方法简单且满足原地操作的要求。具体步骤如下：

反转整个数组：首先，我们反转整个数组 nums，这样原本在数组末尾的元素就会被移动到数组的开头。

反转前 k 个元素：接下来，我们只反转数组的前 k 个元素。这一步将数组的前 k 个元素放置到正确的位置。

反转剩余的元素：最后，我们反转数组中剩余的部分（从第 k+1 个元素到数组末尾），这样所有的元素都会被放置到正确的位置。

## 复杂度

时间复杂度:

O(n)

这个算法需要三次遍历整个数组来完成反转，因此时间复杂度是线性的，与数组的长度成正比。

空间复杂度:

O(1)

由于我们是在原地进行操作，没有使用额外的存储空间，所以空间复杂度是常数级别的。

```go
func rotate(nums []int, k int)  {
    n := len(nums)
    k = k % n // 防止k大于数组长度
    reverse(nums)          // 先逆序整个数组
    reverse(nums[:k])      // 逆序数组的前k个元素
    reverse(nums[k:])      // 逆序数组的剩余部分
}

func reverse(nums []int) {
    n := len(nums)
    for i := 0; i < n/2; i++ {
        nums[i], nums[n-1-i] = nums[n-1-i], nums[i]
    }
}
```

# 121.买卖股票的最佳时机

> Problem: [121. 买卖股票的最佳时机](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock/description/)

## 思路

这个问题的关键在于理解股票价格的变化趋势，并找到买入和卖出的最佳时机。由于我们只能进行一次交易，我们需要寻找一个价格的波谷（买入点）和一个紧随其后的价格波峰（卖出点）。

## 解题方法

代码采用了一种自底向上的方法来解决这个问题。这种方法的核心思想是从数组的最后一个元素开始向前遍历，动态地更新最大利润。

1. 初始化：首先，我们初始化 maxPrice 为数组的最后一个元素，这是我们假设的初始卖出价格。同时，result 初始化为0，这是我们的最大利润。
2. 逆序遍历：然后，我们从倒数第二个元素开始逆序遍历整个数组。
3. 更新最大利润：在每次迭代中，我们计算以当前价格为卖出点的最大利润（maxPrice - prices[i]），并将其与已有的 result 比较，取较大者作为新的最大利润。
4. 更新卖出价格：同时，我们也更新 maxPrice，使其为当前价格和之前 maxPrice 中的较大者。
5. 返回结果：遍历结束后，result 就是我们要找的最大利润。

## 复杂度

时间复杂度：

O(n)，其中 n 是数组 prices 的长度。这是因为我们只遍历了一次数组。

空间复杂度：

O(1)，我们只使用了两个额外的变量，与输入数组的大小无关。

## Code

```go
func maxProfit(prices []int) int {
    if len(prices) == 0 {
        return 0
    }
    maxPrice:=prices[len(prices)-1]
    var result int
    for i:=len(prices)-2;i>=0;i--{
        result=max(result,maxPrice-prices[i])
        maxPrice=max(maxPrice,prices[i])
    }
    return result
}
```

# 122.买卖股票的最佳时机 II

> Problem: [122. 买卖股票的最佳时机 II](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/description/)

## 思路

这个问题是关于股票交易的，目标是找到所有可能的交易对，使得利润最大化。题目要求我们在一个给定的数组中，找到所有可能的交易对，并且每次交易都是买入后卖出，从而获得最大利润。

## 解题方法

对于这个问题，我们可以采用一种贪心算法的思想。具体来说，我们可以遍历整个数组，对于每对相邻的天数，如果第二天的价格高于第一天，我们就认为这是一个买入和卖出的机会，从而获得利润。我们将所有这样的利润累加起来，就可以得到最大利润。

## 复杂度

时间复杂度: 

O(n)

我们只需要遍历一次数组，时间复杂度为线性。

空间复杂度: 

O(1)

我们只需要一个变量来存储结果，空间复杂度为常数。

## Code

```go
func maxProfit(prices []int) int {
    if len(prices)==0{
        return 0
    }
    var result int

    for i:=1;i<len(prices);i++{
        if(prices[i]>prices[i-1]){
            result+=prices[i]-prices[i-1]
        }
    }

    return result
}
```

# 55.跳跃游戏

> Problem: [55. 跳跃游戏](https://leetcode.cn/problems/jump-game/description/)

## 思路

思路很简单，利用贪心的思想，只要维护一个能到达的最远距离，就能保证当前索引到最远可达距离之间的所有元素都能到达。

## 解题方法

1. 如果数组长度为1，则直接返回true，因为只有一个位置，无需跳跃。
2. 如果数组的第一个元素为0，返回false，因为无法从起始位置跳到任何地方。
使用一个变量max_step来跟踪当前可以到达的最远索引。
3. 遍历数组，更新max_step为当前可跳跃距离和max_step两者中的最大值
4. 如果当前元素为0且max_step为0且当前索引不是数组的最后一个索引，则返回false，因为这意味着在某个点上无法前进。
5. 每次循环结束时，max_step减1，对应向前进了一格。

## 复杂度

时间复杂度:

我们只遍历了一遍数组，因此时间复杂度为O(1)

空间复杂度:

我们是就地操作的，除了维护最大可达距离的几个变量外，没有产生额外的空间。故空间复杂度为O(1)

## Code

```go
func canJump(nums []int) bool {
    if len(nums)==1{
        return true
    }
    if nums[0]==0{
        return false
    }
    max_step:=0
    for i,v := range nums{
        max_step=max(max_step,v)
        if v==0 && max_step==0 && i!=len(nums)-1{
            return false
        }
        max_step--
    }

    return true
}
```

# 45.跳跃游戏 II

> Problem: [45. 跳跃游戏 II](https://leetcode.cn/problems/jump-game-ii/description/)

## 思路

贪心的思想，确保每次跳的最远，一直往前跳即可。

## 解题方法

首先判断如果从改点直接尽力跳能否到达终点？如果能就直接跳并退出循环；如果不能直接到达终点，就寻找如何让自己接下来能够跳的更远：维护一个可以跳跃到达的最远距离，最远距离=该节点的跳跃距离+距离起跳点的距离。每次起跳前都检测自己的跳跃范围内，如何跳才能让自己下一步到达的距离更远。

## 复杂度

时间复杂度:

在jump函数中，主循环会持续进行直到step等于len(nums)-1，这意味着主循环会遍历整个数组nums。在循环体内，find_max_step函数被调用，该函数本身也是一个循环，它将遍历从step开始的nums[step]个元素。

因此，jump函数的时间复杂度主要由以下两部分组成：

主循环的时间复杂度：由于step每次增加的值取决于find_max_step函数的返回值，且每次至少增加1，最坏情况下，如果nums中的每个元素都为1，那么step需要增加到len(nums)-1，此时主循环的时间复杂度为O(n)。

find_max_step函数的时间复杂度：在最坏的情况下，这个函数将遍历nums[step]个元素，由于step的值在每次主循环迭代中增加，所以这个函数在整个算法执行过程中的总时间复杂度为O(n^2)。

综合以上两点，整个算法的时间复杂度为O(n^2)。但step的值为n时主函数只需要执行一次，所以实际情况复杂度会比理论上的复杂度更低。

空间复杂度:

在代码中，除了输入数组nums外，没有使用额外的存储空间来存储数据结构。find_max_step函数中的变量max_step和max_id仅用于临时存储，它们的大小不随输入规模n的变化而变化。

因此，空间复杂度为O(1)。

## Code

```go
func jump(nums []int) int {
    if len(nums)==1{
        return 0
    }
    step:=0
    res:=0
    for step<len(nums)-1{
        if step+nums[step]>=len(nums)-1{
            res++
            break
        }
        step=find_max_step(nums,step)
        res++
    }
    if step>=len(nums)-1{
        res++
    }

    return res
}

func find_max_step(nums []int,step int) int {
    // 寻找最大距离 = 当前节点跳跃距离 + 距离起跳点的距离
    max_step:=nums[step]
    max_id:=step
    for i:=0;i<=nums[step];i++{
        if max_step<nums[step+i]+i{
            max_id=step+i
            max_step=nums[step+i]+i
        }
    }
    return max_id
}
```

# 274.H 指数

> Problem: [274. H 指数](https://leetcode.cn/problems/h-index/description/)

## 思路

这个问题要求我们计算一个研究者的h指数，即至少有h篇论文被引用了h次或以上。解决这个问题的关键在于理解h指数的定义，并找到一种有效的方法来确定满足条件的最小h值。

## 解题方法

1. 构建额外数组：首先，我们创建一个额外的数组 m，大小为 len(citations) + 1，用来统计引用次数小于或等于每个可能的h值的论文数量。
2. 统计论文数量：遍历 citations 数组，对于每个引用次数 i，我们增加 m[min(len(citations), i)] 的计数，这样 m[j] 就代表了引用次数小于或等于 j 的论文数量。
3. 倒序遍历：然后，我们从 m 数组的末尾开始倒序遍历，累加每个 m[j] 的值到变量 s 中，这个累加值 s 表示引用次数大于或等于 j 的论文数量。
4. 找到h指数：当我们找到第一个满足 s >= j 的 j 时，这个 j 就是研究者的h指数。

## 复杂度

时间复杂度：

O(n)

我们只需要遍历一次 citations 数组来构建 m 数组，然后再遍历一次 m 数组来找到h指数，因此总的时间复杂度是线性的。

空间复杂度：

O(n)

我们创建了一个大小为 len(citations) + 1 的额外数组 m，因此空间复杂度是线性的。

## Code

```go
func hIndex(citations []int) int {
    // 用一个额外数组m来记录满足引用次数为min(n,citation(i))的论文数
    // 最后倒序遍历m，令s为m[j]的累加和，代表满足引用次数大于j的论文数
    // 当s>=j时，说明至少有满足引用条件的论文数量大于等于引用数
    m:=make([]int,len(citations)+1)
    for _, i:=range citations{
        m[min(len(citations),i)]++
    }
    s:=0
    for j:=len(citations);j>0;j--{
        s+=m[j]
        if s>=j{
            return j
        }
    }
    return 0
}
```

# 380.O(1) 时间插入、删除和获取随机元素

> Problem: [380. O(1) 时间插入、删除和获取随机元素](https://leetcode.cn/problems/insert-delete-getrandom-o1/description/)

## 思路

Go本身自带哈希表，用map数据结构去模拟RandomSet类。

## 解题方法

一开始的思路是完全用一个map去实现，但是遇到了两个问题：

1. 在处理最后一个GetRandom函数时，本来想用map的特性去处理。即为了保证代码安全性，map在用for进行迭代时返回的顺序是随机的。但是由于底层的某些原因，在共有n个且不足8个元素时，第一个元素的概率将是（8-n+1）/8而不是1/n。导致第一个元素出现的概率过大无法通过判题器。具体原因可以参考这篇文章：[golang Map迭代的随机性](https://blog.csdn.net/chillsoul/article/details/123572206)。
2. 所以我选择在GetRandom函数中手动创建一个切片，把map的键导出后再用随机数输出。但是每次调用一次GetRandom函数必然需要遍历一次map，因此时间复杂度为O(n)，导致最后提交代码时TE超时了。

所以我决定折中一下，在创建类时自带一个切片，用map储存数据->切片下标的映射，切片储存实际的数据。这样在GetRandom函数中就不需要再遍历map了。

## 复杂度

时间复杂度:

map的底层是哈希表，插入和删除操作均为O(1)，故时间复杂度为O(1)

空间复杂度:

RandomSet类创建了和数据等大的map和一个切片，因此占空间复杂度为O(n)。

## Code

```go
type RandomizedSet struct {
    Set map[int]int
    KeySet []int
}


func Constructor() RandomizedSet {
        return RandomizedSet{
        Set: make(map[int]int),
        KeySet: make([]int,0),
    }
}


func (this *RandomizedSet) Insert(val int) bool {
    _,ok:=this.Set[val]
    if !ok{
        this.Set[val]=len(this.KeySet)
        this.KeySet=append(this.KeySet,val)
        return true
    }
    return false
}


func (this *RandomizedSet) Remove(val int) bool {
    _,ok:=this.Set[val]
    if ok{
        id:=this.Set[val] //待删除元素的下标
        last:=len(this.KeySet)-1 //最后一个位置
        this.KeySet[id]=this.KeySet[last]
        this.Set[this.KeySet[id]]=id
        this.KeySet=this.KeySet[:last]
        delete(this.Set,val)
        return true
    }
    return false
}


func (this *RandomizedSet) GetRandom() int {
    randomKey := this.KeySet[rand.Intn(len(this.KeySet))]
    return randomKey
}


/**
 * Your RandomizedSet object will be instantiated and called as such:
 * obj := Constructor();
 * param_1 := obj.Insert(val);
 * param_2 := obj.Remove(val);
 * param_3 := obj.GetRandom();
 */
```

# 238.除自身以外数组的乘积

> Problem: [238. 除自身以外数组的乘积](https://leetcode.cn/problems/product-of-array-except-self/description/)

## 思路

这道题目要求我们计算一个数组中，除了每个元素自身之外，其他所有元素的乘积。题目中明确指出，数组中任意元素的全部前缀元素和后缀元素的乘积都在32位整数范围内，这意味着我们可以使用一个整数来存储这些乘积。

## 解题方法

解题的关键在于，我们可以将问题分解为两个部分：计算每个元素左边所有元素的乘积，以及计算每个元素右边所有元素的乘积。然后，将这两个乘积相乘，就可以得到除了当前元素之外的乘积。

1. 初始化：创建一个答案数组ans，其长度与输入数组nums相同，并将ans[0]初始化为1，因为第一个元素左边没有元素。

2. 计算左侧乘积：从第二个元素开始，将每个元素与其左侧所有元素的乘积累加到答案数组中。这可以通过一个临时变量tmp来实现，它存储当前元素左侧的乘积。

3. 计算右侧乘积：从倒数第二个元素开始，更新答案数组，将每个元素与其右侧所有元素的乘积累加到对应的答案元素上。

4. 注意：由于我们不能使用除法，所以我们不能简单地将左侧乘积除以当前元素来得到最终答案。相反，我们需要在计算右侧乘积时，将当前元素的右侧乘积与左侧乘积相乘。
![image.png](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/1717129925-qEDSKo-image.png?x-oss-process=style/blog)

## 复杂度

时间复杂度:

O(n)，其中n是数组nums的长度。这是因为我们只需要遍历数组两次。

空间复杂度:

O(1)，我们只使用了有限的额外空间（答案数组ans和临时变量tmp），它们的大小不随输入数组的大小而变化。

## Code

```go
func productExceptSelf(nums []int) []int {
    n := len(nums)
    ans := make([]int, n)
    ans[0] = 1
    tmp:=1
    // 计算下三角
    for i:=1;i<n;i++{
        ans[i]=ans[i-1]*nums[i-1]
    }
    // 计算上三角
    for i:=n-2;i>=0;i--{
        tmp*=nums[i+1]
        ans[i]*=tmp
    }
    return ans
}
```

# 134.加油站

> Problem: [134. 加油站](https://leetcode.cn/problems/gas-station/description/)

## 思路

最简单粗暴的思路就是一个一个遍历加油站，看能否到达。但是需要优化，不然会TE超时。

## 解题方法

最开始我的想法是将gas数组和cost数组相减，由于必须要保证启动时汽油充足，所以只需要考虑相减后结果为正数的加油站，再开始遍历。可惜时间复杂度还是太高，最后虽然通过了判题器但是耗时也是最大的那一批擦边过。

另一种简化方法是：经过研究发现，如果从第X个加油站出发，抵达Y加油站后没油了，那么可以证明在X~Y之间的所有加油站，最后都不可能抵达第Y+1个加油站。也就是说，我们在Y加油站瘫痪后，下一次可以直接从Y+1加油站出发，跳过了Y-X中间的所有加油站。经过简化后，耗时大大减短。

## 复杂度

时间复杂度:

我们只需要遍历一遍数组，所以时间复杂度为O(N)。

空间复杂度:

没有使用额外空间，故空间复杂度为O(1)。

## Code

```go
func canCompleteCircuit(gas []int, cost []int) int {
    length:=len(gas)
    for start_index:=0;start_index<length;{
        left_gas:=0
        for i:= 0;i<length;i++{
            cur_index:=(start_index+i)%length
            left_gas+=gas[cur_index]-cost[cur_index]
            if left_gas<0{
                if cur_index+1<=start_index{
                    return -1
                }
                start_index=cur_index+1
                break
            }
        }
        if left_gas>=0{
            return start_index
        }
    }
    return -1
}
```

# 135.分发糖果

> Problem: [135. 分发糖果](https://leetcode.cn/problems/candy/description/)

## 思路

这道题目要求给每个孩子分配糖果，满足以下两个条件：

每个孩子至少分配到 1 个糖果。

相邻两个孩子中，评分更高的孩子获得更多的糖果。

为了满足这些条件，我们可以采用双遍历的方法来解决这个问题：

第一次从左到右遍历，保证每个孩子比左边评分低的孩子多。

第二次从右到左遍历，保证每个孩子比右边评分低的孩子多。

通过这样的双向遍历，可以确保每个孩子得到的糖果数量既满足基本条件，又保证了相邻孩子评分高的糖果多。

## 解题方法

初始化一个数组 candies，大小与 ratings 相同，初始值都为 1，因为每个孩子至少分配到 1 个糖果。

从左到右遍历 ratings，如果 ratings[i] > ratings[i-1]，那么 candies[i] = candies[i-1] + 1。

从右到左遍历 ratings，如果 ratings[i] > ratings[i+1]，那么 candies[i] = max(candies[i], candies[i+1] + 1)，因为要同时考虑之前从左到右遍历的结果。

最后将 candies 数组中的值加起来就是所需的最少糖果数。

## 复杂度

时间复杂度: $O(n)$

因为我们需要两次遍历 ratings 数组，第一次从左到右，第二次从右到左。

空间复杂度: $O(n)$

需要一个与 ratings 等长的数组 candies 来存储每个孩子的糖果数。

## Code

```go
func candy(ratings []int) int {
    n := len(ratings)
    if n == 0 {
        return 0
    }
    
    // Step 1: Initialize candies array
    candies := make([]int, n)
    for i := range candies {
        candies[i] = 1
    }
    
    // Step 2: Traverse from left to right
    for i := 1; i < n; i++ {
        if ratings[i] > ratings[i-1] {
            candies[i] = candies[i-1] + 1
        }
    }
    
    // Step 3: Traverse from right to left
    for i := n - 2; i >= 0; i-- {
        if ratings[i] > ratings[i+1] {
            candies[i] = int(math.Max(float64(candies[i]), float64(candies[i+1] + 1)))
        }
    }
    
    // Step 4: Calculate the total number of candies
    totalCandies := 0
    for _, c := range candies {
        totalCandies += c
    }
    
    return totalCandies
}
```

# 42.接雨水

> Problem: [42. 接雨水](https://leetcode.cn/problems/trapping-rain-water/description/)

## 思路

思路有二，一种是我自己最开始的设想，一种是GPT给出的思想。

初始代码通过逐层处理每个高度来计算接雨水的格子数。

优化版本使用双指针法。

## 解题方法

### 解法一

1. 找到最高的柱子：首先遍历整个数组，找到最高的柱子位置 max_i 和高度 max_h。

2. 逐层处理：从最高的柱子高度开始，一层一层处理每一层的雨水量，直到所有柱子的高度都变为0。

3. 遍历当前数组：每层开始时，重置 left_flag 和 space。

   如果 left_flag 还没有设置，并且当前柱子高度不为0，则设置 left_flag 表示遇到了第一个柱子。

   如果 left_flag 已经设置，当前柱子高度不为0，并且之前记录了空格数量，则累加雨水量到 ans，重置 space。

   如果 left_flag 已经设置，并且当前柱子高度为0，则累加空格数到 space。

   如果当前柱子高度不为0，则将当前柱子的高度减1。

   重复以上步骤直到最高柱子的高度为0。

### 解法二

1. 初始化左右指针：初始化两个指针 left 和 right 分别指向数组的起始位置和结束位置。

2. 初始化左右最大高度：初始化 leftMax 和 rightMax 分别为数组起始和结束位置的高度。

3. 遍历数组：

   比较 height[left] 和 height[right]：

   如果 height[left] 较小，则：

   如果 height[left] 大于等于 leftMax，则更新 leftMax；

   否则，累加 leftMax 与 height[left] 之差到总雨水量 ans；

   移动左指针 left 向右一格。

   如果 height[right] 较小或相等，则：

   如果 height[right] 大于等于 rightMax，则更新 rightMax；

   否则，累加 rightMax 与 height[right] 之差到总雨水量 ans；

   移动右指针 right 向左一格。

   终止条件：当左右指针相遇时，遍历结束。

## 复杂度

时间复杂度:

其中原始代码由于每一层都需要遍历整个数组，时间复杂度接近 $O(n*h)$，其中 $n$ 是数组长度，$h$ 是最高柱子的高度。如果数组中存在很高的柱子，遍历次数会非常多。所以我自己的代码遇到了TLE超时错误，通过例320/322，不通过的例子中柱子的高度达到了近十万……

优化版本由于每个元素最多只会被处理一次，时间复杂度为 $O(n)$，其中 $n$ 是数组长度。

空间复杂度:

原始代码和优化代码都只是用了常数级的额外空间，故空间复杂度是$O(1)$

## Code

### 解法一

```go
func trap(height []int) int {
    // 思路：从第一个非零数字开始，每遇到一个0就可以计一格雨水，一直循环到数组末尾
    // 遍历完底层之后，所有柱子高度减一，高度为0的柱子不变
    // 追踪最高的柱子，当最高的柱子高度为0时意味着统计结束
    /*
    如何计算接到的雨水格子数也有窍门，不能简单的用一个flag去标记，因为电脑分不清墙和数组边界的区别
    所以需要用两个标志变量判断空隙是否两面夹墙
    具体来说，首先用left_flag来标记遇见起始墙
    然后用一个变量统计空格的个数
    如果又遇到了墙，设置right_flag来标记遇见了结束墙
    此时说明空格能够接水，把空格数加入到ans中，然后清零，并复位两个标志变量
    如果只遇到了开始墙却没有遇到结束墙，说明区域开放，丢弃统计的空格数
    */
    max_h:=0
    max_i:=0
    ans:=0
    for i,v := range height{
        if max_h<v{
            max_h=v
            max_i=i
        }
    }

    for height[max_i]!=0{
        left_flag:=0 
        //right_flag:=0
        space:=0
        for i,v := range height{ //遍历搜寻0格子
        //判断墙的情况
            if left_flag==0&&v!=0{
                left_flag=1 //遇到了第一个非0格子
            }else if left_flag==1&&v!=0&&space!=0{ //如果墙已经开始且遇到了新的墙且先前已经开始计数
                ans+=space
                //left_flag=0
                space=0
            }
        //判断空格的情况
            if left_flag==1&&v==0{
                space++
            }
            if v!=0{
                height[i]-- //离开柱子时将其高度减一
            }
        }
    }

    return ans
}
```

### 解法二

```go
func trap(height []int) int {
    if len(height) == 0 {
        return 0
    }

    left, right := 0, len(height)-1
    leftMax, rightMax := height[left], height[right]
    ans := 0

    for left < right {
        if height[left] < height[right] {
            if height[left] >= leftMax {
                leftMax = height[left]
            } else {
                ans += leftMax - height[left]
            }
            left++
        } else {
            if height[right] >= rightMax {
                rightMax = height[right]
            } else {
                ans += rightMax - height[right]
            }
            right--
        }
    }

    return ans
}
```

# 13.罗马数字转整数

> Problem: [13. 罗马数字转整数](https://leetcode.cn/problems/roman-to-integer/description/)

## 思路

看到这一题，我们需要将罗马数字字符串转换为整数。罗马数字有一些特定的规则：

1. 相同字符的重复表示加法，例如 "III" 表示 3。
2. 小的数字放在大的数字前面表示减法，例如 "IV" 表示 4。
3. 小的数字放在大的数字后面表示加法，例如 "VI" 表示 6。
4. 基于这些规则，我们可以通过遍历字符串来进行转换。

## 解题方法

1. 建立一个哈希表 dic，将罗马数字字符映射到对应的整数值。

2. 初始化一个变量 ans 用于存储最终的结果。

3. 遍历字符串 s：

   对于每一个字符 s[i]，如果当前字符的值小于下一个字符的值（即 dic[s[i]] < dic[s[i+1]]），则减去当前字符的值，因为这意味着这是一个减法操作。

   否则，加上当前字符的值。

   最终得到的 ans 就是转换后的整数值。

## 复杂度

时间复杂度: $O(n)$

我们只需要遍历字符串一次，因此时间复杂度为 $O(n)$，其中 $n$ 是字符串的长度。

空间复杂度: $O(1)$

除了存储映射关系的哈希表外，我们只使用了常数级别的额外空间。

## Code

```go
func romanToInt(s string) int {
    // 首先建立map哈希表映射字符串
    dic := map[byte]int{
        'I': 1,
        'V': 5,
        'X': 10,
        'L': 50,
        'C': 100,
        'D': 500,
        'M': 1000,
    }

    ans := 0
    n := len(s)

    // 对字符串从左到右处理
    for i := 0; i < n; i++ {
        // 如果第i个字符小于第i+1个字符，则减去第i个字符
        if i < n-1 && dic[s[i]] < dic[s[i+1]] {
            ans -= dic[s[i]]
        } else { // 否则，加上第i个字符
            ans += dic[s[i]]
        }
    }

    return ans
}
```

# 12.整数转罗马数字

> Problem: [12. 整数转罗马数字](https://leetcode.cn/problems/integer-to-roman/description/)

## 思路

暴力打表，同时运用贪心的算法尽可能的多匹配字符串。

## 解题方法

建立起数字映射表，然后从最大的数字开始匹配，并输出转换后的字符串

## 复杂度

时间复杂度：

$O(1)$，因为虽然有循环，但是循环次数是固定的，与输入大小无关。

空间复杂度：

$O(1)$，只使用了固定大小的额外空间

## Code

```go

func intToRoman(num int) string {
    // 建立罗马数字映射表
    val := []int{1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1}
    syms := []string{"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"}

    roman := ""

    // 从大到小遍历映射表
    for i := 0; i < len(val); i++ {
        // 对于每个罗马数字，尽可能多地匹配
        for num >= val[i] {
            num -= val[i]
            roman += syms[i]
        }
    }

    return roman
}
```

# 58.最后一个单词的长度

> Problem: [58. 最后一个单词的长度](https://leetcode.cn/problems/length-of-last-word/description/)

## 思路

直接调包，用strings.Split函数切割字符串，再打印最后一个单词的长度。

## 解题方法

用Split分隔后，从最后一项开始寻找非空字符串，然后返回长度。

## 复杂度

时间复杂度:

Split函数复杂度为$O(n)$，故时间复杂度为$O(n)$。

空间复杂度:

创建了一个原字符串大小的切片，故空间复杂度为$O(n)$

## Code

```go
import "strings"

func lengthOfLastWord(s string) int {
    slice:=strings.Split(s," ")
    for i:= len(slice)-1;i>=0;i--{
        if len(slice[i])==0{
            continue
        }
        return len(slice[i])
    }
    return 0
//    return len(slice[len(slice)-1])
}
```

# 14.最长公共前缀

> Problem: [14. 最长公共前缀](https://leetcode.cn/problems/longest-common-prefix/description/)

## 思路

思路有很多，可以横向搜索，也可以纵向搜索。这里我用的是纵向搜索。

## 解题方法

搜索每一个字符串中的第i个字符是否相等，如果不相等或者i等于某个子串的长度，查找结束，返回字符串即最长公共前缀。

## 复杂度

时间复杂度:

时间复杂度为$O(mn)$，m是最长公共前缀的长度，n是字符串的个数。

空间复杂度:

空间复杂度为$O(1)$，没有使用额外空间。

## Code

```go
func longestCommonPrefix(strs []string) string {
    if len(strs) == 0 {
        return ""
    }

    for i:=0;i<len(strs[0]);i++{
        for j:=0;j<len(strs);j++{
            if i==len(strs[j])||strs[j][i]!=strs[0][i]{
                return strs[0][:i]
            }
        }
    }
    return strs[0]
}
```

# 151.反转字符串中的单词

> Problem: [151. 反转字符串中的单词](https://leetcode.cn/problems/reverse-words-in-a-string/description/)

## 思路

灵活调包，用strings包下的Split和Join函数处理。

## 解题方法

首先用Split函数把字符串以空格为间隙切割成字符切片，然后从后往前遍历所有长度不为0的元素，倒序添加进新的切片并加上一个空格。

记住循环结束后要弹出结尾的空格。最后用Join函数合并字符切片转为字符串即可。

## 复杂度

时间复杂度:

Split函数的操作时间复杂度为$O(n)$，故时间复杂度应为$O(n)$。

空间复杂度:

创建了一个切片储存倒序字符串，故空间复杂度应为$O(n)$。

## Code

```go
import "strings"
func reverseWords(s string) string {
    split:=strings.Split(s," ")
    ans:=make([]string,0)

    for i:=len(split)-1;i>=0;i--{
        if len(split[i])!=0{
            ans=append(ans,split[i])
            ans=append(ans," ")
        }
    }
    ans=ans[:len(ans)-1] //弹出最后一个空格
    return strings.Join(ans,"")
}
```

# 6.Z字形变换

> Problem: [6. Z 字形变换](https://leetcode.cn/problems/zigzag-conversion/description/)

## 思路

这题与其说是Z字形变换，倒不如说是N字形……

可以通过模拟字符串的方式解决，即通过变换规律推导出结果矩阵，依次填充后再输出矩阵为字符串。同时，还可以通过压缩矩阵的方式降低空间复杂度。

但我们还可以通过推导规律直接写出矩阵对应id对应的字符串。

## 解题方法

观察矩阵：
```
0             0+t                    0+2t                     0+3t
1      t-1    1+t            0+2t-1  1+2t            0+3t-1   1+3t
2  t-2        2+t  0+2t-2            2+2t  0+3t-2             2+3t  
3             3+t                    3+2t                     3+3t
```
设矩阵的字符位置为idx，对应字符串s的位置为i。则不难发现规律：

1. 矩阵变换周期为$t=2·r-2$ 
2. 对矩阵第一行，只对应一个元素：$idx \equiv 0 \bmod t$
3. 对矩阵最后一行，也只对应一个元素：$idx \equiv r-1 \bmod t$
4. 对其余$i$行，对应两个元素：$idx \equiv i \bmod t$与$idx \equiv t-i \bmod t$

故可直接构造代码。

### 复杂度

时间复杂度:

$O(n)$，其中n为字符串s的长度。s中的每个字符仅会被访问一次，因此时间复杂度为 $O(n)$。

空间复杂度:

$O(1)$，返回值不计入空间复杂度。

## Code

```go
func convert(s string, numRows int) string {
    n,r:=len(s),numRows
    if r==1||r>=n{
        return s
    }
    t:=2*r-2
    ans:=make([]byte,0,n)
    for i:=0;i<r;i++{
        for j:=0;j+i<n;j+=t{
            ans=append(ans,s[i+j])
            if i>0 && i<r-1 && t-i+j<n {
                ans=append(ans,s[t-i+j])
            }
        }
    }

    return string(ans)
}
```

# 28.找出字符串中第一个匹配项的下标

> Problem: [28. 找出字符串中第一个匹配项的下标](https://leetcode.cn/problems/find-the-index-of-the-first-occurrence-in-a-string/description/)

## 思路

本来以为是KMP字符串匹配算法，结果是简单题？？？那就直接用内置的语言库秒了。

不过有点恶心的是，我们数据结构和算法设计都没有讲过KMP，我还得自学一遍……也许某天我会专门出一篇讲解KMP算法的博客吧。目前可以参考力扣官方的题解当代餐：[实现 strStr()](https://leetcode.cn/problems/find-the-index-of-the-first-occurrence-in-a-string/solutions/732236/shi-xian-strstr-by-leetcode-solution-ds6y/?envType=study-plan-v2&envId=top-interview-150)

## 解题方法

直接调库strings.Index()函数。

## 复杂度

时间复杂度:

Golang中 substr长度大于64/32(视CPU的情况而定)的情况，

查找采用的rabin-karp算法，它是由Richard M. Karp和 Michael O. Rabin在1987年提出的。它的时间复杂度为$O(n + m)$，最坏情况下的时间复杂度为$O(n * m)$。

Go的strings.Index()函数底层实现参考文章：[GOLANG STRINGS中的INDEX函数(字符串查找)](https://vearne.cc/archives/611)

空间复杂度:

没有使用额外空间，复杂度为$O(1)$

## Code

```go
import "strings"
func strStr(haystack string, needle string) int {
    return strings.Index(haystack,needle)
}
```

# 68.文本左右对齐

> \> Problem: [68. 文本左右对齐](https://leetcode.cn/problems/text-justification/description/)

## 思路

这道题目是关于文本左右对齐的问题，需要在给定的最大宽度下，将一系列单词进行排版，使得每一行的文本符合左右对齐的要求。关键点在于如何计算和分配每一行的空格，使得文本能够对齐。

## 解题方法

这里参照了力扣的官方题解[文本左右对齐](https://leetcode.cn/problems/text-justification/solutions/986756/wen-ben-zuo-you-dui-qi-by-leetcode-solut-dyeg/?envType=study-plan-v2&envId=top-interview-150)，总结出了以下规律：

> 1. 当前行是最后一行：单词左对齐，且单词之间应只有一个空格，在行末填充剩余空格；
> 2. 当前行不是最后一行，且只有一个单词：该单词左对齐，在行末填充空格；
> 3. 当前行不是最后一行，且不只一个单词：设当前行单词数为$numWords$，空格数为$numSpaces$，我们需要将空格均匀分配在单词之间，则单词之间至少有$\text { avgSpaces }=\left\lfloor\frac{\text { numSpaces }}{\text { numWords }-1}\right\rfloor$个空格，应该填在前$extraSpaces$个单词之间。因此，前$extraSpaces$个单词之间填充$avgSpaces+1$个空格，其余单词之间应该填充$avgSpaces$个空格。

## 复杂度

时间复杂度:

$O(m)$，m是数组words中所有字符串的长度之和。

空间复杂度:

$O(m)$

## Code

```go
func fullJustify(words []string, maxWidth int) (ans []string) {
    right,n:=0,len(words)
    for {
        left := right //当前行的第一个单词在word的位置
        sumLen:=0//统计这一行的单词长度之和
        //循环确定能放多少单词，单词之间至少有一个空格
        for right <n && sumLen+len(words[right])+right-left<=maxWidth{
            sumLen+=len(words[right])
            right++
        }
        // 当前行是最后一行：单词左对齐，且单词之间应只有一个空格，在行末填充剩余空格
        if right == n {
            s := strings.Join(words[left:], " ")//填充单词
            ans = append(ans, s+blank(maxWidth-len(s)))//填充空格
            return
        }

        numWords:=right-left // 本行总单词数
        numSpace:= maxWidth-sumLen //本行总空格数

        // 本行只有一个单词：单词向左对齐，末尾填充空格
        if numWords==1{
            ans=append(ans,words[left]+blank(numSpace))
            continue
        }

        // 当前行不止一个单词，先依次填充好单词和中间空格，再把额外的空格填入前extra个单词中间
        avgSpaces:= numSpace/(numWords-1)//填充进每个单词间的正常空格数
        extraSpaces:=numSpace%(numWords-1)//余下的空格数就是多出的空格

        s1:=strings.Join(words[left:left+extraSpaces+1],blank(avgSpaces+1)) // 额外拼接一个空格
        s2:=strings.Join(words[left+extraSpaces+1:right],blank(avgSpaces)) // 拼接其余单词
        ans=append(ans,s1+blank(avgSpaces)+s2)
    }
}

func blank(n int) string{
    return strings.Repeat(" ",n)
}
```

# 125.验证回文串

> \> Problem: [125. 验证回文串](https://leetcode.cn/problems/valid-palindrome/description/)

## 思路

要验证回文串的思路其实很简单，核心就是用双指针进行遍历判断。本题还在原先的基础上添加了空格、符号等字符进行干扰，要求清洗字符串并忽略大小写后再进行判断。要实现这两点的方法很多。

## 解题方法

一种方法是简单粗暴的调包，用string包的ToLower()转换字符串为全小写，然后再调用regexp包的Compile()与ReplaceAllString()来进行正则清洗后再进行回文串的判断。但这种方法会产生额外的字符串储存开销，而且正则编译比较耗时。

第二种方法就是直接在原字符串上进行操作，这样做更加省时快捷。

## 复杂度

时间复杂度:

方法一：时间复杂度: $O(n)$

将字符串全部转换为小写：$O(n)$。

使用正则表达式删除非字母数字字符：$O(n)$。

再次遍历清理后的字符串进行回文检查：$O(n)$。

方法二：时间复杂度: O(n)

遍历字符串一次，同时从两端向中间扫描，跳过非字母数字字符。

比较字符时，将小写字母转换为大写字母（如果需要）。

空间复杂度:

方法一：$O(n)$，使用了额外的字符串存储转换后的结果和清理后的结果。

方法二：$O(1)$，除了几个变量外，没有使用额外的空间。

## Code

方法一：

```go
import (
    "strings"
    "regexp"
)
func isPalindrome(s string) bool {
    lowered:=strings.ToLower(s)
    reg,_:=regexp.Compile("[^a-zA-Z0-9]+")
    cleaned:=reg.ReplaceAllString(lowered,"")

    left,right:=0,len(cleaned)-1
    for left<right{
        if cleaned[left]!=cleaned[right]{
            return false
        }
        left++
        right--
    }
    return true
}
```

方法二

```go
import "unicode"

func isPalindrome(s string) bool {
    left, right := 0, len(s)-1

    for left < right {
        for left < right && !unicode.IsLetter(rune(s[left])) && !unicode.IsDigit(rune(s[left])) {
            left++
        }
        for left < right && !unicode.IsLetter(rune(s[right])) && !unicode.IsDigit(rune(s[right])) {
            right--
        }
        if left < right {
            if unicode.ToLower(rune(s[left])) != unicode.ToLower(rune(s[right])) {
                return false
            }
            left++
            right--
        }
    }
    return true
}
```

# 392.判断子序列

> \> Problem: [392. 判断子序列](https://leetcode.cn/problems/is-subsequence/description/)

## 思路

一道比较简单的字符串处理题，用双指针和贪心思想依次遍历即可。

## 解题方法

设置两个指针p1、p2，分别指向字符串s、t。假如p2指向的字符和p1指向的相同，那么就同时右移指针；如果不同，就只右移p2指针用于寻找下一个匹配字符。当t被遍历完时说明寻找失败；如果是s先被遍历完则说明寻找成功。

注意，空字符串是任何字符串的子串；当t为空串时，除s也为空串外应直接返回false。

## 复杂度

时间复杂度:

$O(n+m)$，m和n分别是s和t字符串的长度。

空间复杂度:

$O(1)$，没有产生额外的空间。

## Code

~~~go
func isSubsequence(s string, t string) bool {
    //双指针做法
    //一个指s，一个指t
    if len(s)==0{
        return true
    }
    if len(t)==0{
        return false
    }
    p1,p2:=0,0 // s,t
    for p2!=len(t)-1{
        if s[p1]==t[p2]{
            p1++
            p2++
        }else{
            p2++
        }
        if p1==len(s)-1&&s[p1]==t[p2]{
            return true
        }
    }
    return false
}
~~~

# 167.两数之和 II - 输入有序数组

> Problem: [167. 两数之和 II - 输入有序数组](https://leetcode.cn/problems/two-sum-ii-input-array-is-sorted/description/)

## 思路

很简单的一道题，已知题目条件数组为非递减有序数组，则用二分查找的思想来寻找两数之和就好。

## 解题方法

设置两个指针left和right，分别指向数组两端，并计算两数之和sum。如果sum＜target，则left++；如果sum＞target，则right--；如果sum=target，则返回left+1和right+1的数组即可。

## 复杂度

时间复杂度:

$O(n)$，n为题给数组长度。

空间复杂度:

$O(1)$，只使用了常数级的额外空间。

## Code

~~~go
func twoSum(numbers []int, target int) []int {
    //题目已知序列为非递减有序
    //参考快排的方法从两边开始累加
    left,right:=0,len(numbers)-1
    for left<right{
        sum:=numbers[left]+numbers[right]
        if sum==target{
            return []int{left+1,right+1}
        }else if sum>target{
            right--
        }else{
            left++
        }
    }
    return []int{left+1,right+1}
}
~~~

# 11.盛最多水的容器

> Problem: [11. 盛最多水的容器](https://leetcode.cn/problems/container-with-most-water/description/)

## 思路

要求接最多的雨水，如果我们选择遍历所有情况，那么时间复杂度将为$O(N^2)$，所以我们选择用双指针的做法，将时间复杂度优化到$O(N)$。

和接雨水思路类似，往往这种需要根据数组元素求最值的题目用双指针会大大简便计算。

## 解题方法

设置两个指针分别指向高度数组的两端，计算体积并更新最大值。每次计算完后，移动指向高度较矮边的指针，直到两个指针相遇为止结束。

## 复杂度

时间复杂度:

$O(N)$，因为只遍历了一遍数组。

空间复杂度:

$O(1)$，只使用了常量级别的额外空间。

## Code

```go
func maxArea(height []int) int {
    left,right:=0,len(height)-1
    maxWater:=0
    for left<right{
        water:=calculateWater(height[left],height[right],right-left)
        if water>maxWater{
            maxWater=water
        }
        if height[left]>height[right]{
            right--
        }else{
            left++
        }
    }
    return maxWater
}
func calculateWater(a int,b int,h int) int {
    c:=min(a,b)
    return c*h
}
```

# 15.三数之和

> \> Problem: [15. 三数之和](https://leetcode.cn/problems/3sum/description/)

## 思路

一道非常经典的面试题，相比于基本的两数之和，题目考察的是无序数组的三数之和。我们可以先固定一个元素，这样我们就只需要移动两个元素了，自然而然就会想到用双指针。由于数组无序，所以我们需要先对数组预处理进行排序，然后再调用双指针进行后续处理。

## 解题方法

在对数组进行排序后，创建三个指针i，left，right。其中i初始指向数组最左端元素用于遍历每个固定的数组元素。left和right应该位于i+1和n-1的位置，接着移动指针求和直到满足条件为止。

注意的是，题目要求结果不能有重复，所以需要加入一些判断条件来去重。

## 复杂度

时间复杂度:

外层循环时间复杂度为$O(N)$，内层循环时间复杂度为$O(N)$，故总时间复杂度为$O(N^2)$。

空间复杂度:

额外的排序的空间复杂度为$O(log N)$，故空间复杂度为$O(log N)$。

## Code

~~~go
import "sort"
func threeSum(nums []int) [][]int {
    ans:=make([][]int,0)
    sort.Ints(nums)
    n:=len(nums)
    for i:=0;i<n;i++{
        if i>0 && nums[i]==nums[i-1]{
            continue
        }
        left,right:=i+1,n-1
        for left<right{
            sum:=nums[i]+nums[left]+nums[right]
            if sum>0{
                right--
            }else if sum <0{
                left++
            }else{
                ans=append(ans,[]int{nums[i],nums[left],nums[right]})
                for left<right&&nums[left]==nums[left+1]{
                    left++
                }
                for right>left&&nums[right]==nums[right-1]{
                    right--
                }
                left++
                right--
            }
        }
    }
    return ans
}
~~~

# 209.长度最小的子数组

> Problem: [209. 长度最小的子数组](https://leetcode.cn/problems/minimum-size-subarray-sum/description/)

## 思路

这道题目要求找到长度最小的连续子数组，使得其元素之和大于等于给定的整数 s。由于子数组的元素必须是连续的，暴力解法（检查所有可能的子数组）虽然可以解决问题，但时间复杂度过高。考虑到这一点，使用滑动窗口的方法是更为合适的选择。

## 解题过程

滑动窗口的思路是将子数组的边界设为两个指针 start 和 end，初始时都指向数组的起始位置。我们不断地向右移动 end 指针来扩大窗口的大小，直到窗口内的子数组的和 sum 大于等于 s，此时记录当前子数组的长度并尝试通过移动 start 指针来缩小窗口，找到更小的满足条件的子数组。

## 复杂度

时间复杂度: O(n)，其中 n 为数组的长度。start 和 end 指针各自最多移动 n 次，因此整体时间复杂度为线性。

空间复杂度: O(1)。我们只使用了固定大小的额外空间，空间复杂度为常数。

## Code

```go
func minSubArrayLen(s int, nums []int) int {
    n:=len(nums)
    if n == 0{
        return 0
    }
    ans:=math.MaxInt32
    start,end:=0,0
    sum:=0
    for end<n{
        sum+=nums[end]
        for sum>=s{
            ans = min(ans,end-start+1)
            sum-=nums[start]
            start++
        }
        end++
    }
    if ans == math.MaxInt32{
        return 0
    }
    return ans
}
```

# 3.无重复字符的最长子串

> Problem: [3. 无重复字符的最长子串](https://leetcode.cn/problems/longest-substring-without-repeating-characters/description/)

## 思路

用滑动窗口来跟踪当前正在检查的子串，并使用哈希表来存储当前窗口中每个字符的位置。如果遇到重复字符，就缩小窗口的左边界，从而移除重复的字符。

## 解题过程

创建一个哈希表，键名为字符，键值为整数代表该字符是否存在。从字符串最左边开始往右遍历并维护不重复字符子串长度，如果发现重复字符就把窗口向右移动，直接从右边界开始重新搜寻。

## 复杂度

时间复杂度: $O(n)$，其中 n 是字符串的长度。end 指针在最坏情况下会遍历字符串中的每个字符一次，start 也最多会遍历每个字符一次，所以整体时间复杂度为线性。

空间复杂度: $O(min(m, n))$，其中 m 是字符集的大小，n 是字符串的长度。哈希表存储的字符数量最多是 m，但在极端情况下可能会存储整个字符串的字符，因此空间复杂度为 O(min(m, n))。

## Code

~~~go
func lengthOfLongestSubstring(s string) int {
    charIndexMap := make(map[byte]int)
    maxLen := 0
    start := 0

    for end := 0; end < len(s); end++ {
        if index, found := charIndexMap[s[end]]; found && index >= start {
            start = index + 1
        }
        charIndexMap[s[end]] = end
        maxLen = max(maxLen, end - start + 1)
    }

    return maxLen
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}
~~~

# 30.串联所有单词的子串

> Problem: [30. 串联所有单词的子串](https://leetcode.cn/problems/substring-with-concatenation-of-all-words/description/)

## 思路

这道题要求我们在字符串 s 中找到所有的串联子串的起始位置。每个串联子串必须包含 words 数组中的所有字符串，并且这些字符串可以以任意顺序排列连接。要解决这个问题，我们可以采用滑动窗口和哈希表的组合策略，逐步扫描字符串 s，并检查是否存在符合条件的子串。

## 解题过程

假设 words 数组中的每个字符串长度为 wordLen，words 的总长度为 totalLen = len(words) * wordLen。

我们需要在字符串 s 中找到所有长度为 totalLen 的子串，并检查这些子串是否由 words 数组中的所有字符串拼接而成。

由于子串的长度是固定的 totalLen，我们可以在 s 中以 wordLen 为步长移动窗口，逐步检查窗口内的子串是否符合要求。

将字符串 s 分成多个长度为 wordLen 的段落，每次检查段落是否在 words 数组中。如果找到符合条件的子串，就记录其起始位置。

使用两个哈希表：一个记录 words 中每个字符串出现的频率，另一个记录当前窗口中每个字符串出现的频率。

当两个哈希表相等时，说明当前窗口内的子串是 words 的一个排列。

## 复杂度

\- 时间复杂度: $O((n - totalLen + 1) \times \text{wordLen})$，其中 n 是字符串 s 的长度。我们以 wordLen 为步长，遍历字符串，并在每一步比较哈希表的内容，因此时间复杂度近似为线性的。

\- 空间复杂度: $O(\text{numWords} \times \text{wordLen})$，我们使用的哈希表最多需要存储 words 中所有字符串的计数。

## Code

~~~go
func findSubstring(s string, words []string) []int {
    if len(s) == 0 || len(words) == 0 {
        return []int{}
    }

    wordLen := len(words[0])//单个单词的长度
    totalLen := wordLen * len(words)//给定words词组的总长度
    wordCount := make(map[string]int)//记录words词组中的word及其频数
    result := []int{}

    for _, word := range words {
        wordCount[word]++
    }

    for i := 0; i < wordLen; i++ {
        left := i
        right := i
        currentCount := make(map[string]int)//记录滑动窗口中的word及其频数

        for right+wordLen <= len(s) {
            word := s[right:right+wordLen]
            right += wordLen

            if _, ok := wordCount[word]; ok {
                currentCount[word]++
                for currentCount[word] > wordCount[word] {
                    leftWord := s[left:left+wordLen]
                    currentCount[leftWord]--
                    left += wordLen
                }//如果单词频数过高，则缩小滑动窗口直到符合频数为止

                if right-left == totalLen {
                    result = append(result, left)
                }//如果滑动窗口符合条件且长度相等，则是一个有效子串
            } else {
                currentCount = make(map[string]int)
                left = right
            }//如果窗口内的单词不匹配，该子串无效，清空currentCount哈希表，将left直接置于right，跳过这个窗口直接搜寻下一个
        }
    }

    return result
}
~~~

# 76.最小覆盖子串

> Problem: [76. 最小覆盖子串](https://leetcode.cn/problems/minimum-window-substring/description/)

## 思路

典型的滑动窗口问题，要求我们在字符串 s 中找到最小的子串，使得这个子串包含字符串 t 中的所有字符。

我们用两个指针 left 和 right 表示一个滑动窗口，初始时都指向字符串 s 的起始位置。随着 right 指针的移动，我们扩展窗口的右边界，将字符逐个加入窗口。当窗口内包含了字符串 t 的所有字符（包括重复字符），我们可以尝试缩小窗口（即移动 left 指针），以找到更小的子串。在每次找到符合条件的子串后，记录其长度，并与之前找到的最小子串长度进行比较，保留更小的子串。

一个哈希表 targetCount 用来存储字符串 t 中每个字符的频率。另一个哈希表 windowCount 用来存储当前滑动窗口中每个字符的频率。我们通过比较 windowCount 和 targetCount 来判断窗口是否包含了 t 中的所有字符。

扩展窗口：将 right 指针指向的字符加入 windowCount，然后向右移动 right 指针。

收缩窗口：当窗口包含了 t 中的所有字符时，尝试移动 left 指针缩小窗口，直到窗口不再包含 t 的所有字符为止。

## 解题过程

初始化：

使用 targetCount 记录字符串 t 中的每个字符及其出现次数。

初始化两个指针 left 和 right，right 从头开始遍历字符串 s。

变量 minLen 用来记录当前找到的最小子串的长度，minStart 用来记录这个子串的起始位置。

滑动窗口遍历：

随着 right 指针的移动，将字符加入 windowCount，并检查窗口是否包含了 t 中的所有字符。

如果当前窗口包含了 t 的所有字符，记录当前窗口的长度，并尝试缩小窗口，即移动 left 指针。

更新最小子串：

每次找到符合条件的窗口时，比较其长度与 minLen，如果更小，则更新 minLen 和 minStart。

最终结果：

如果 minLen 没有被更新过，说明不存在满足条件的子串，返回空字符串 ""。

否则，返回 s 中从 minStart 开始、长度为 minLen 的子串。

## 复杂度

\- 时间复杂度: $O(m + n)$，其中 m 是字符串 s 的长度，n 是字符串 t 的长度。每个字符在滑动窗口内最多进出一次，因此整个算法的时间复杂度是线性的。

\- 空间复杂度: $O(1)$（因为英文字母的数量是固定的，为 26 个），哈希表的大小不会超过 26 个字符。

## Code

~~~go
func minWindow(s string, t string) string {
    if len(s)==0||len(t)==0{
        return ""
    }

    targetCount:=make(map[byte]int)
    for i:=0;i<len(t);i++{
        targetCount[t[i]]++
    }//统计t中各个字符的出现频数

    windowCount:=make(map[byte]int)
    left,right:=0,0
    minLen:=len(s)+1//随便一个不可能的数字
    minStart:=0
    required:=len(targetCount)//t中需要被匹配的字符数量
    formed:=0

    for right<len(s){
        char:=s[right]
        windowCount[char]++

        if targetCount[char]>0 && targetCount[char]==windowCount[char]{
            formed++
        }

        for left<=right && formed==required{
            char=s[left]

            if right-left+1<minLen{
                minLen=right-left+1
                minStart=left
            }

            windowCount[char]--
            if targetCount[char]>0 && targetCount[char]>windowCount[char]{
                formed--
            }
            left++
        }
        right++
    }
    
    if minLen==len(s)+1{
        return ""
    }else{
        return s[minStart:minStart+minLen]
    }
}
~~~

# 36.有效的数独

> Problem: [36. 有效的数独](https://leetcode.cn/problems/valid-sudoku/description/)

## 思路

根据题给要求检查数独即可，分别按照行、列、小九宫格来依次检查。

## 解题过程

创建两个二维数组rows和columns，一个三维数组subboxes，用来储存九宫格在对应位置上的数字出现次数。遍历一遍数组，注意到九宫格中的位置i、j，分别对应rows[i]，columns[j]，subboxes[i/3][j/3]。于是只要扫描到一个数字，就将三个表格的index分别+1，index=board[i][j]-1

## 复杂度

\- 时间复杂度: $O(1)$

\- 空间复杂度: $O(1)$

## Code

~~~go
func isValidSudoku(board [][]byte) bool {
    var rows,columns [9][9]int
    var subboxes [3][3][9]int
    for i,row:=range board{
        for j,column:=range row{
            if column=='.'{
                continue
            }else{
                index:=column-'0'-1
                rows[i][index]++
                columns[j][index]++
                subboxes[i/3][j/3][index]++
                if rows[i][index]>1||columns[j][index]>1||subboxes[i/3][j/3][index]>1{
                return false
            }
            }
        }
    }
    return true
}
~~~

# 54.螺旋矩阵

> Problem: [54. 螺旋矩阵](https://leetcode.cn/problems/spiral-matrix/description/)

## 思路

题目要求按照顺时针螺旋顺序返回矩阵中的所有元素。我们可以通过设置四个边界（上、下、左、右）来控制遍历方向，并不断缩小边界范围，直到遍历完所有元素。

这种方法属于模拟法，即通过人为模拟出遍历矩阵的顺序，依次遍历边界并将其缩小，直至不再有元素可遍历。

## 解题过程

每次遍历按以下顺序进行：

从左到右遍历当前上边界，并将上边界向下移动。

从上到下遍历当前右边界，并将右边界向左移动。

从右到左遍历当前下边界，并将下边界向上移动。

从下到上遍历当前左边界，并将左边界向右移动。

当四个边界交叉时，说明已经没有未遍历的元素，结束循环。

## 复杂度

\- $O(m \times n)$，其中 $m$ 是矩阵的行数，$n$ 是矩阵的列数。我们需要遍历矩阵中的每个元素，所以时间复杂度与矩阵中的元素数量成正比。

\- $O(1)$（不考虑返回结果的空间），只使用了固定数量的额外变量。

## Code

~~~go
func spiralOrder(matrix [][]int) []int {
    if len(matrix) == 0 {
        return []int{}
    }
    
    r, d := len(matrix[0])-1, len(matrix)-1  // 右边界和下边界
    l, u := 0, 0                             // 左边界和上边界
    result := make([]int, 0)
    
    for l <= r && u <= d {
        // 从左到右
        for i := l; i <= r; i++ {
            result = append(result, matrix[u][i])
        }
        u++
        if u > d {  // 检查上边界是否越界
            break
        }
        
        // 从上到下
        for i := u; i <= d; i++ {
            result = append(result, matrix[i][r])
        }
        r--
        if r < l {  // 检查右边界是否越界
            break
        }
        
        // 从右到左
        for i := r; i >= l; i-- {
            result = append(result, matrix[d][i])
        }
        d--
        if d < u {  // 检查下边界是否越界
            break
        }
        
        // 从下到上
        for i := d; i >= u; i-- {
            result = append(result, matrix[i][l])
        }
        l++
        if l > r {  // 检查左边界是否越界
            break
        }
    }
    
    return result
}
~~~

# 48.旋转图像

> Problem: [48. 旋转图像](https://leetcode.cn/problems/rotate-image/description/)

## 思路

本题要求将一个 `n x n` 的二维矩阵表示的图像顺时针旋转 90 度，且要求 **原地旋转**，即不能使用额外的矩阵空间。通过分析，我们可以得出一种有效的思路：首先 **转置矩阵**，然后对每一行进行 **水平翻转**。

关键点：

1. 转置矩阵：将矩阵的行和列进行交换，即将矩阵 `matrix[i][j]` 和 `matrix[j][i]` 进行交换。这样，矩阵的对角线上的元素保持不变，而其他元素会发生位置变化。
2. 水平翻转每一行：将矩阵中的每一行从左右两端开始交换元素，直到中间为止。

通过这两个操作，我们可以在原地完成 90 度顺时针旋转。

## 解题过程

第一步：转置矩阵

转置矩阵的基本操作是将矩阵的行和列交换。对于一个 `n x n` 的矩阵，我们只需要交换矩阵的上三角部分与下三角部分的元素。具体来说，对于每一对 (i, j)，交换 `matrix[i][j]` 和 `matrix[j][i]`。

第二步：水平翻转每一行

转置完成后，矩阵的列已经变成了行，接下来我们需要水平翻转每一行。即将每一行的第 `left` 个元素和第 `right` 个元素交换，`left` 从 0 开始，`right` 从 `matrixSize - 1` 开始，直到它们相遇。

为什么这些步骤能实现 90 度顺时针旋转？

因为 **转置** 操作会将原来的列变成行，为旋转打下基础。
**水平翻转** 则完成了顺时针旋转的效果，因为顺时针旋转就是先转置，然后从右至左反转每一行。

## 复杂度

- 时间复杂度: $O(n^2)$
转置操作和水平翻转操作都需要遍历整个矩阵，每次遍历的时间复杂度是 $O(n^2)$，因此总的时间复杂度是 $O(n^2)$。

- 空间复杂度: $O(1)$
我们只使用了常数空间来交换元素，因此空间复杂度是 $O(1)$，满足了题目要求的原地旋转。

## Code

```C []
void rotate(int** matrix, int matrixSize, int* matrixColSize) {
    // 先转置矩阵，再水平翻转每一行即可
    //转置矩阵，交换上三角元素
    for (int i = 0; i < matrixSize; i++){
        for (int j = i + 1; j < matrixSize; j++){
            int tmp = matrix[i][j];
            matrix[i][j] = matrix [j][i];
            matrix[j][i] = tmp;
        }
    }
    //水平翻转每一行的元素
    for (int i = 0; i < matrixSize; i++){
        int left = 0;
        int right = matrixSize - 1;
        while(left < right){
            int tmp = matrix[i][left];
            matrix[i][left] = matrix[i][right];
            matrix[i][right] = tmp;
            left++;
            right--;
        }
    }
}
```

# 73.矩阵置零

> Problem: [73. 矩阵置零](https://leetcode.cn/problems/set-matrix-zeroes/description/)

## 思路

本题要求我们在一个 m x n 的矩阵中，如果某个元素为零，则将其所在的行和列全部置零。并且需要使用原地算法，即不能使用额外的矩阵来辅助计算。

### 方法选择

为了实现原地算法，可以使用矩阵的第一行和第一列作为辅助数组，用来标记哪些行和列需要置零。这样，我们可以避免使用额外的空间，同时完成矩阵的修改。具体步骤如下：

1. **标记第一行和第一列**：遍历矩阵中的每个元素，如果某个元素为零，便将其所在行的第一个元素和列的第一个元素置为零。
2. **处理内层矩阵**：根据第一行和第一列的标记，遍历矩阵并设置相应位置的元素为零。
3. **处理第一行和第一列**：最后单独处理第一行和第一列，因为它们在标记过程中被修改，且需要特别处理。

## 解题过程

### 1. 检查第一行和第一列是否需要清零

首先，遍历矩阵的第一行和第一列，记录它们是否包含零。为了避免修改原矩阵，我们使用两个变量 `firstRowZero` 和 `firstColZero` 来标记第一行和第一列是否需要置零。

### 2. 使用第一行和第一列作为辅助数组

接着，我们遍历矩阵的其他部分，如果遇到值为零的元素，我们将该元素所在行的第一个元素和列的第一个元素设置为零。这样，这些位置会作为标记，指示相应的行和列需要置零。

### 3. 根据标记清零

再遍历矩阵，通过检查第一行和第一列的标记，如果对应位置的值为零，则将该元素所在行列的值置为零。

### 4. 处理第一行和第一列

最后，单独处理第一行和第一列，依据之前的标记决定是否将它们置为零。

## 复杂度

- **时间复杂度**: $O(m \times n)$，需要遍历矩阵多次，每次遍历的复杂度是 $O(m \times n)$。
- **空间复杂度**: $O(1)$，使用常数空间，只依赖输入矩阵本身进行修改。

## Code

```C
void setZeroes(int** matrix, int matrixSize, int* matrixColSize) {
    int m = matrixSize; // 行数
    int n = matrixColSize[0]; // 列数
    int firstRowZero = 0;  // 用int来标记第一行是否需要清零
    int firstColZero = 0;  // 用int来标记第一列是否需要清零

    // 检查第一行是否需要清零
    for (int i = 0; i < n; i++) {
        if (matrix[0][i] == 0) {
            firstRowZero = 1;  // 设置为1表示第一行需要清零
            break;
        }
    }

    // 检查第一列是否需要清零
    for (int i = 0; i < m; i++) {
        if (matrix[i][0] == 0) {
            firstColZero = 1;  // 设置为1表示第一列需要清零
            break;
        }
    }

    // 遍历矩阵记录需要清零的地方
    for (int i = 1; i < m; i++) {  // 从1开始，避免修改第一行和第一列
        for (int j = 1; j < n; j++) {  // 从1开始，避免修改第一行和第一列
            if (matrix[i][j] == 0) {
                matrix[i][0] = 0;  // 标记该行需要清零
                matrix[0][j] = 0;  // 标记该列需要清零
            }
        }
    }

    // 清零矩阵，避免修改第一行和第一列
    for (int i = 1; i < m; i++) {  // 从1开始，避免修改第一行和第一列
        for (int j = 1; j < n; j++) {  // 从1开始，避免修改第一行和第一列
            if (matrix[i][0] == 0 || matrix[0][j] == 0) {
                matrix[i][j] = 0;
            }
        }
    }

    // 最后处理第一行和第一列
    if (firstRowZero == 1) {  // 检查firstRowZero是否为1
        for (int i = 0; i < n; i++) {  // 遍历第一行
            matrix[0][i] = 0;
        }
    }

    if (firstColZero == 1) {  // 检查firstColZero是否为1
        for (int i = 0; i < m; i++) {  // 遍历第一列
            matrix[i][0] = 0;
        }
    }
}

```

# 289.生命游戏

> Problem: [289. 生命游戏](https://leetcode.cn/problems/game-of-life/description/)

## 思路

为了在原地更新矩阵的状态，可以使用 **位运算** 来编码每个细胞的当前状态和下一状态。我们使用 **2 位** 来表示每个细胞的状态：
- **00**：当前死，下一死
- **01**：当前活，下一死
- **10**：当前死，下一活
- **11**：当前活，下一活

通过这种方式，当前状态和下一状态可以同时存储在同一个变量中，并通过位操作轻松提取。

## 解题过程

1. **遍历每个细胞**：
   - 对于每个细胞，检查其周围 8 个相邻细胞，计算出其活邻居的数量。
   - 根据以下规则更新当前细胞的状态：
     - 如果当前是活细胞（`board[i][j] == 1`），且活邻居数为 2 或 3，则细胞保持活。
     - 如果当前是死细胞（`board[i][j] == 0`），且活邻居数为 3，则细胞复活。
     - 其他情况，细胞死亡。

2. **使用位运算更新状态**：
   - 我们使用 **按位或（|）** 运算将当前状态和下一状态结合起来：如果需要改变细胞的状态，就把相应的位设置为 1。
   
3. **提取下一状态**：
   - 完成遍历后，使用 **右移运算（`>> 1`）** 将低位提取出，更新细胞的最终状态。

## 复杂度

- 时间复杂度: $O(m * n)$，每个细胞都需要检查其 8 个相邻细胞。
- 空间复杂度: $O(1)$，我们仅使用常量空间来存储临时的状态。

## Code

```C
void gameOfLife(int** board, int boardSize, int* boardColSize) {
    int m = boardSize;
    int n = boardColSize[0];

    /*
    00 当前死，下一死
    01 当前活，下一死
    10 当前死，下一活
    11 当前活，下一活
    */
    for(int i = 0; i < m; i++){
        for (int j = 0; j < n; j++){
            int liveCell = 0;
            // 遍历 8 个邻居
            for (int x = -1; x < 2; x++){
                for (int y = -1; y < 2; y++){
                    if (x == 0 && y == 0 ) continue;
                    int nx = i + x;
                    int ny = j + y;
                    // 检查边界
                    if (nx >= 0 && nx < m && ny >= 0 && ny < n){
                        liveCell += (board[nx][ny] & 1);
                    }
                }
            }
            // 更新状态
            if (board[i][j] == 1 && (liveCell == 2 || liveCell == 3))
                board[i][j] = board[i][j] | 2;  // 细胞保持活或死亡
            else if (board[i][j] == 0 && liveCell == 3)
                board[i][j] = board[i][j] | 2;  // 死细胞复活
        }
    }

    // 提取最终状态
    for (int i = 0; i < m; i++){
        for (int j = 0; j < n; j++){
            board[i][j] = board[i][j] >> 1;  // 提取低位，更新状态
        }
    }
}

```

# 383.赎金信

> Problem: [383. 赎金信](https://leetcode.cn/problems/ransom-note/description/)

## 思路

本题可以通过统计字符出现次数来解决。我们要判断是否能从 `magazine` 中取出足够的字符来构成 `ransomNote`。为此，可以使用一个大小为 26 的数组来记录 `magazine` 中每个字符的出现次数，再根据 `ransomNote` 中的每个字符检查是否能从 `magazine` 中找到足够的字符。

## 解题过程

1. **统计字符频次**：
   - 使用一个数组 `hash[26]` 来存储 `magazine` 中每个字符的频次，其中索引是字符与 `'a'` 的差值（即字符 `'a'` 的映射位置为 0，`'b'` 为 1，依此类推）。

2. **检查 `ransomNote` 中字符的需求**：
   - 遍历 `ransomNote` 中的每个字符，检查该字符在 `magazine` 中的剩余数量。如果剩余数量为 0，说明无法构成该字符，返回 `false`；否则减少相应字符的频次。

3. **结束条件**：
   - 如果遍历完 `ransomNote` 后没有发现任何不足的字符，则返回 `true`，表示可以成功构造 `ransomNote`。

## 复杂度

- **时间复杂度**: $O(m + n)$，其中 $m$ 是 `magazine` 的长度，$n$ 是 `ransomNote` 的长度。我们需要遍历 `magazine` 和 `ransomNote` 两次，分别统计字符频次和验证字符是否足够。
- **空间复杂度**: $O(1)$，我们使用的字符频次数组 `hash[26]` 大小固定，为常数空间。

## Code

```C
bool canConstruct(char* ransomNote, char* magazine) {
    int hash[26] = {0};
    // 统计 magazine 中每个字符的频次
    for (int i = 0; magazine[i]; i++){
        hash[magazine[i] - 'a']++;
    }
    // 检查 ransomNote 中每个字符的需求
    for (int i = 0; ransomNote[i]; i++){
        hash[ransomNote[i] - 'a']--;
        // 如果需求的字符不足
        if (hash[ransomNote[i] - 'a'] < 0) return false;
    }
    return true;
}

```

# 205.同构字符串

> Problem: [205. 同构字符串](https://leetcode.cn/problems/isomorphic-strings/description/)

## 思路

判断两个字符串是否是同构的。两个字符串 `s` 和 `t` 是同构的，当且仅当 `s` 中的每个字符可以按某种方式映射到 `t` 中的字符，同时保持字符的顺序一致。映射关系是双向的，即每个字符只能映射到一个唯一的字符，并且每个字符只能映射一次。

## 解题过程

使用两个哈希表来实现字符映射的判断：
- `map_s_to_t` 用于记录从 `s` 到 `t` 的映射关系。
- `map_t_to_s` 用于记录从 `t` 到 `s` 的映射关系。

遍历字符串 `s` 和 `t`，对于每个字符：
- 如果 `s[i]` 已经在 `map_s_to_t` 中映射到其他字符，且不等于 `t[i]`，说明映射冲突，返回 `false`。
- 如果 `t[i]` 已经在 `map_t_to_s` 中映射到其他字符，且不等于 `s[i]`，也说明映射冲突，返回 `false`。
- 如果没有冲突，就继续进行映射，保持双向一致。

通过这两个哈希表的双向映射判断，我们可以确保字符串 `s` 和 `t` 是否同构。

## 复杂度

- 时间复杂度: $O(n)$，其中 $n$ 是字符串 `s` 和 `t` 的长度。我们只需要遍历一次字符串并进行常数时间的哈希操作。
- 空间复杂度: $O(n)$，使用了两个哈希表来存储字符映射关系，最坏情况下需要 $O(n)$ 的空间。

## Code

```Go
func isIsomorphic(s string, t string) bool {
    map_s_to_t := make(map[byte]byte)
    map_t_to_s := make(map[byte]byte)

    // 如果字符在s到t的映射哈希表中且出现冲突，说明不是同构
    for i := range len(s){
        c, ok := map_s_to_t[s[i]]
        if !ok {
            map_s_to_t[s[i]] = t[i]
        } else {
            if c != t[i] {
                return false
            }
        }

        c, ok = map_t_to_s[t[i]]
        if !ok {
            map_t_to_s[t[i]] = s[i]
        } else {
            if c != s[i] {
                return false
            }
        }
    }    
    return true
}
```

# 290.单词规律

> Problem: [290. 单词规律](https://leetcode.cn/problems/word-pattern/description/)

## 思路

和上一道题类似，区别在于这里需要对应的是字符串。

题目要求判断字符串 `s` 是否遵循规律 `pattern`，即字符串 `s` 中的每个单词和 `pattern` 中的每个字符之间有一一对应的映射关系。我们需要检查：
- `pattern` 中的字符是否一一对应到 `s` 中的每个单词。
- 每个字符映射到的单词要唯一，且每个单词映射到的字符也要唯一，保持双向映射关系。

## 解题过程

- 首先使用 `strings.Fields(s)` 来将字符串 `s` 按照空格分割成单词，并存储在 `words` 数组中。
- 然后利用两个哈希表来建立双向映射：
  - `pattern_map` 用来记录 `pattern` 中字符到单词的映射。
  - `words_map` 用来记录 `words` 中单词到字符的映射。
- 遍历 `pattern` 和 `words`，检查每个字符和单词的对应关系：
  - 如果某个字符已经映射到一个单词，并且与当前单词不匹配，则返回 `false`。
  - 如果某个单词已经映射到一个字符，并且与当前字符不匹配，也返回 `false`。
- 如果遍历完后没有冲突，说明 `s` 遵循规律 `pattern`，返回 `true`。

## 复杂度

- 时间复杂度: $O(n)$，其中 $n$ 是 `pattern` 和 `s` 的长度。我们需要遍历一次 `pattern` 和 `words`。
- 空间复杂度: $O(n)$，我们使用了两个哈希表来存储映射关系，最坏情况下需要 $O(n)$ 的空间。

## Code

```Go
func wordPattern(pattern string, s string) bool {
    words := strings.Fields(s)
    pattern_map := make(map[byte]string)
    words_map := make(map[string]byte)

    if len(pattern) != len(words) {
        return false
    }

    for i := range pattern {
        str, ok := pattern_map[pattern[i]]
        if !ok {
            pattern_map[pattern[i]] = words[i]
        } else {
            if str != words[i] {
                return false
            }
        }

        bt, ook := words_map[words[i]]
        if !ook {
            words_map[words[i]] = pattern[i]
        } else {
            if bt != pattern[i] {
                return false
            }
        }
    }

    return true
}

```

---

截止至2024.12.11，更新了42题，打算坑了。

因为有些题太简单，不值得单独去发题解。

往后会单独开一个精选贴，记录我认为有价值的题目

---

![{930EB68A-6F85-4666-BA42-9333A5074315}](https://adam8en-blog-image.oss-cn-guangzhou.aliyuncs.com/%7B930EB68A-6F85-4666-BA42-9333A5074315%7D.png?x-oss-process=style/blog)


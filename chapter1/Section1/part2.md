#  链表 

在数据存储结构分类中，其中链式存储的实现就是链表结构 

链式存储:对逻辑上相邻的元素不要求其物理位置相邻，元素间的逻辑关系通过指针字段来表示，链式存储借助程序设计语言中的指针类型来实现  


__链表：是由数据节点组成的线性集合，每个节点可以利用指针指向其他节点，是一种包含多个节点，可用于表示顺序的数据结构(与数组同类)__  

![链表结构](http://ozjlhf9e0.bkt.clouddn.com/20180303152006101489650.gif) 
> 图片来自 https://visualgo.net/en
通过以上动图，形象的表示了链表结构  

链表由于其不需要连续的内存块资源，其结构可以充分的利用内存空间，实现灵活的内存管理。但是链表结构也有其弊端：其在插入与删除上，不需要过多的操作内存而一定程度降低了时间复杂度，但其在查找上就不那么灵活。以下链表中不同操作的时间复杂度：

* 索引`O(n)`
* 搜索`O(n)`
* 插入`O(1) `
* 移除`O(1)`  

__本部分会采用部分伪代码来介绍操作，其具体的实现会有相对应的实现__  

## 链表的基本操作 
以上内容，介绍了链表是如何的数据结构，以及通过动图的形式形象的展示了链表的简单结构，但并没有对链表有个更直接以及详细的了解。链表作为一种基本的数据结构，其如何操作如何运行呢？通常，在链表操作中，有一下几种基本操作：  

1. 初始化  
    初始化链表结构，构建一个空的线性表 
2. 长度     
    返回表的所含元素的个数  
3. 获取节点     
    获取指定位置的元素节点  
4. 查找节点     
    通过给定的值，超找包含此数据的节点位置  
5. 插入节点     
    在链表中插入新的节点 
6. 删除节点    
    在链表中删除已有节点  
7. 遍历链表    
    循环遍历链表中的所有节点


## 链表分类  
虽然在大体实现上都是连式结构，不过链表在具体实现由于其采用的方式不同，链表也可以细分为以下几类：
1. 单向链表    
2. 双向链表   
3. 循环链表    
4. 块状链表    
接下来将针对以上四种不同实现方式进行具体的介绍以及其链表的基本操作中的需要主要的地方    

### 单向链表  
链表中的节点都是单向操作的，从上个节点指向下个节点，最后一个节点指向空。通常单向链表节点需要包含两部分内容：    
1. 指针域     
    指针域包含的是下一个节点的内存地址。
2. 数据域     
    数据域存放的是具体的数据内容  

![链表](http://ozjlhf9e0.bkt.clouddn.com/20180303152006386989220.png)
> 图像来自维基百科  

针对于单链表相对来说简单，其只能访问下一个节点，并不能反向访问上一个节点。并且其在遍历时，只能按照顺序遍历

#### 单链表实现
1. 定义链表节点  
```java 
class ListNode {
    int val ;
    ListNode next;
    public ListNode(int val){
        this.val = val;
        this.next = null;
    }
}
```
2. 获取链表的长度  
```java  
public int getListLen(ListNode head){
    int len = 0;
    while(head != null){
        len ++;
        head = head.next;
    }
    return len;
}
```
3. 查找节点
```java 
 public ListNode findElem(ListNode head,int k){
        if(k<1||k>this.length())
            return null;
        ListNode p1=head;
        ListNode p2=head;
        for (int i = 0; i < k-1; i++) 
            p2=p2.next;
        while (p2.next!=null) {
            p2=p2.next;
            p1=p1.next;
        }
        return p1;
    }
```

4. 插入节点
```java
public void addNode(int d, ListNode head){
    ListNode node = new ListNode(d);
    if(head == null){
        head = node;
        return;
    }
    // 循环遍历获取链表的末尾节点
    ListNode node2 = head;
    while(node2.next != null){
        node2 = head.next;
    }
    //在末尾添加节点
    node2.next = node;
}
```

5. 删除节点  
    在单链表结构中，要根据一个index 删除一个节点，其我们先 回顾下链表的结构特点，链表是没有索引的， 但是此处需要通过一个索引来删除节点， 我们首先要通过这个索引，找到对应的节点，同时也要找到其前后节点，将前节点的下一个节点指向其后一个节点就可以了， 主要在查找的这个过程，需要的几个要素要明白    
    1. 索引计数  
    2. 当前节点上一个节点  
    3. 当前节点  
    4. 当索引计数等于索引时， 找到节点，将其pre 节点指向 当前节点next 节点    

    ```java
    public Boolean deleteNode(int index, ListNode head){
        if(index<0 || index>length()){
            return false;
        }
        if(index == 0){
            head = head.next;
            return true;
        }
        int i = 0;
        ListNode preNode = head;
        ListNode nextNode = head.next;
        while(nextNode != null){
            if(i == index){
                preNode.next = nextNode.next;
                return true;
            }
            preNode = nextNode;
            nextNode = nextNode.next;
            i++;
        }
        return true;
    }
    ```

6. 遍历链表 

    ```java 
    public void printList(){
            ListNode tmp=head;
            while(tmp!=null){
                System.out.print(tmp.data+" ");
                tmp=tmp.next;
            }
            System.out.println();
        }
    ```

7. 反转链表 

    反转链表将尾节点变为头结点， 将整个链表反转过来的过程  

    ```java 
    // 通过的是遍历的方式实现的反转的
    public ListNode reverseList(ListNode head){
        ListNode pre = null;
        while(head != null){
            ListNode next = head.next;
            head.next = pre;
            pre = head;
            head = next;
        }
        return pre;
    }
    ```
    通过遍历整个链表可以实现链表的反转，同时也可以通过递归的方式实现链表的反转过程  

    ```java 
    public ListNode reverseList(ListNode head){
        if(head == null || head.next== null) return head;
        ListNode resetHead = reverseList(head.next);
        head.next.next = head;
        head.next = null;
        return resetHead;
    }
    ```

8. 获取链表的中间节点 

    获取链表的中间节点，是一个比较常见的问题，在链表结构中获取中间节点，我们不能通过索引来获取。通过遍历也不是很方便获得链表中间节点。 其有一种取巧的方式就是通过步进的方式实现 

    ```java 
    public ListNode searchMid(ListNode head){
            ListNode q=head;
            ListNode p=head;
            while (p!=null&&p.next!=null&&p.next.next!=null) {
                q=q.next;
                p=p.next.next;
            }
            return q;
        }
    ```



### 双向链表 



### 循环链表  


### 块状链表 



## 总结  

1. 链表存在单向链表、双向链表、循环链表、块状链表 
2. 链表插入与删除操作快，查找操作慢  



## 参考 
[interviews](https://github.com/kdn251/interviews/blob/master/README-zh-cn.md)
[链表-维基百科](https://zh.wikipedia.org/wiki/%E9%93%BE%E8%A1%A8#%E5%85%B6%E5%AE%83%E6%89%A9%E5%B1%95)

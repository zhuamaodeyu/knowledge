#  栈与队列  

在学习数据结构以及真正的开发中，通常会将栈与队列放在一起去学习。栈和队列在基本的内部实现上可以说是一致的，不过在其具体的是上层实现上却有着不同的表现形式。本节将围绕栈和队列进行说明。了解栈和队列的异同    

## 栈  
栈在日常开发中，可能并不经常用到，但是并不能说明其用处不广。栈其实在日常开发中，隐藏于底层之中，为我们的上层业务代码实现提供了基础支持，比如函数的调用以及递归算法实现等。  
1. 函数调用栈  
    在程序运行过程中，程序在申请开启一个新的线程之时，系统会为此线程分配一定的内存空间(一般默认为2M)。此空间可以作为函数中变量的存储以及函数栈来实现，在线程中，调用一个函数就是一个压栈的过程，而一个函数代码的执行完成或者return 都是一个出栈的过程。所以函数的调用过程本身是一个栈操作过程    
2. 递归算法  
    递归算法是一个典型的栈结构的应用算法(本身没有实现栈结构，利用的还是函数栈概念)    

栈其本质是一个线性表结构的应用。最典型的特点是__先进后出__, 所有的操作都是从栈顶来进行，栈结构只有一个出口(栈顶)。针对栈操作，通常有两种: 压栈和出栈。 不管是压栈还是出栈都是从顶部实现   

![栈](../../assets/gitbook/20180312152086333361965.png)
> 图片来自维基百科   


### 栈操作 
通过以上内容，可以了解栈本身是一个线性表结构，而线性表表结构又分为数组(连续)与链表结构。针对栈的实现，我们可以通过链表或者动态数组的形式来实现。接下来将通过链表以及动态数组的形式来分别实现栈的操作  

#### 链表实现方式  
0. 初始化链表结构      

    ```java     
    class ListNode {
        int val ;
        ListNode next;
        public ListNode(int val){
            this.val = val;
            this.next = null;
        }
    }

    class Stack{
        ListNode header;
        int elementCount;       //元素个数
        int size;               // 栈大小
    }
    ```

1. push    
    入栈就是在链表末尾添加新的元素    

    ```java 
    public void push(Object value){
        // 判断栈是否满了 
        if(this.elementCount == this.size) throw new RuntimeException("满啦满啦");  
        ListNode node = new ListNode(d);
        this.header.next = node;
        this.header = node;
        // 循环遍历获取链表的末尾节点
        this.elementCount++;
    }
    ```

2. pop    
    删除链表的最后一个元素    

    ```java 
    public Boolean pop(){
        if(this.elementCount <=0){
             throw new RuntimeException("空哒空哒");  
        }
        // 通过链表的删除节点操作 
        Object object = this.header.getLastElement();

        this.elementCount--;
        return object;
        }
    ```


#### 数组实现方式  
通过数组的形式实现栈的操作将非常容易，无论是出栈还是入栈都是操作的数组尾部    

0. 初始化栈结构    

    ```java 
    class Stack {
        private ArrayList stack;
        public Stack(){
            this.stack = new ArrayList<>();
        }
    }

    ```
1. push(入栈)    

    ```java  
        public void push(int value){
            this.stack.add(value);
        }
    ```
2. pop     

    ```java 
        public int pop(){
            this.stack.remove(this.stack.length - 1);
        }
    ```


## 队列 
队列是另外一种典型的线性表的应用。其主要特点是先进先出(FIFO), 在日常开发中最常用的一个就是线程队列了。或者听到的其他的xxx 队列。其大部分都是针对队列的特殊封装(也有那种名字是队列，但是不是数据结构的)。队列的操作是可以同时进行的，可以将队列类比为一个管道，流过管道的水就可以看做为数据。   
* 普通队列  
    普通队列就是典型的队列结构，其一端作为入口，另外一端作为出口存在
* 双端队列  
    是一种同时具备队列和栈特性的抽象数据结构。双端队列中，队列的两端都可作为弹出和插入口。
![]()  
> 图片来自
一般针对队列的操作，主要包含以下几部分：  
1. 队列长度  
2. 是否为空 
3. 入队列  
4. 出队列 
5. 清空队列 


### 队列实现  
#### 普通队列
#####  数组实现  

1. 初始化队列结构    
    ```java 
     class Queue<T> {
         private T elementData[];
         private int front,rear;
         private int size;

         public Queue(){
               elementData= (T[]) new Object[10];
               front=rear=0;
         }
     } 
    ```
2. 队列长度    
    ```java 
    public int size(){
        return size;
    }
    ```
3. 判断是否为空    
    ```java 
    public boolean isEmpty(){
        return  size == 0;
    }
    ```
4. 入队列    
    ```java 
    public boolean add(T data){
     // 操作   
    }
    ```

#####  链表实现  

#### 双端队列 


## 总结  
针对队列与栈的数据结构，其应用上没什么太多复杂度，主要还是要了解其两者之间的特点，栈的先进后出以及队列的先进先出等。然后根据其不同的特点结合不同的业务需求来选择正确的数据结构。栈和队列的应用其主要针对的是其数据结构特点的应用。

## 参考 
[算法导论]()


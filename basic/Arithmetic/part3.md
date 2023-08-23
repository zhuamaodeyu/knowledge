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
         private int first,last; // 队列头和队列尾

         public Queue(){
               elementData = (T[]) new Object[10];
               first=last=0;
         }
     } 
    ```
2. 队列长度    
    ```java 
    public int size(){
        return (last+s.length-first)%s.length;
    }
    ```
3. 判断是否为空    
    ```java 
    public boolean isEmpty(){
        return  first==last;;
    }
    ```
4. 入队列    
    ```java 
    public void add(T data){
     // 操作    
     s[last] = data ; 
     last = (last + 1) % elementData.length; 

    }
    ```
5. 出队列  
    ```java  
    public T remove() {
        T element =  elementData[first]; 
        elementData[first] = null; 
         first=(first+1)%elementData.length;
        return element;
    }
    ```
6. 清空队列  
    ```java
    public void clear() {
        elementData.removeAllObject(); 
        frist = last = 0;
    }

    ```   
在通过数组实现的队列中，可以通过一定的方式针对整个队列进行优化。 例如： 
* 在入队列时，当队列已满或即将满时，将数组长度进行翻倍等操作以扩大队列的容量  
* 在出队列时， 当数组元素小于数组长度的一半或者其他大小时， 可以将数组长度减半以降低内存消耗。  


#####  链表实现  
1. 初始化队列数据结构   
    ```java 
    public class LinkQueue{
        private class Node {
            String item;
            Node next;
        } 
        private Node first, last;  
        private int size;
    }
    ```

2. 队列长度  
    ```java 
    public int size() {
        return size;
    }
    ```
3. 队列是否为空   
    ```java
    public bool isEmpty() {
        return first==null;
    }
    ```
4. 入队列  
    ```java 
    public void enter(String item) {
        Node copy = last;
        last = new Node(); 
        last.item = item;
        last.next = null;
        if (ifEmpty()) {
            first = last;
        }else{
            copy.next = last;
        }
        size++;
    }

    ```

5. 出队列
    ```java 
    public String leave() {
        String item = first.item;
        first = first.next;
        if (isEmpty()) {
            last = null;
        }
        size--;
        return item;
    }

    ```


#### 双端队列 
双端队列是一种特殊的队列，默认情况下，普通队列支持的是先进先出原则，并且是一端出一端进设计形式。但双端队列的两端都可进行出队和入队操作。通过对双端队列进行不同的限制以可以同时满足栈和普通队列的需求。例如： 
* 只使用双端队列的一端进行出队和入队操作， 那么次双端队列等价于 __栈__  
* 当只使用双端队列的一端出队，使用另一端进行入队时， 次双端队列等价于 __普通队列__   

同样的，双端队列也可以通过 数组 以及链表的形式进行实现。  

###### 实现思路： 
1. 双端队列内部维护头部下标和尾部下标。头部下标指向的事队列中第一个元素。 尾部下标指向的事下一个尾部元素插入位置。  
   1. 从头部下标到尾部下标，连续存放的事队列中的所有元素。在元素出队和入队时，通过移动下标来实现  
        * 当头部元素入队， 头部下标向左移动一位；头部元素出队时， 头部下标向右移动一位。 
        * 当尾部元素入队时，尾部下标向右移动一位；尾部元素出队时，尾部下标向左移动一位。    

一下是针对双端队列定义的接口：  

```java 
public interface Queue<T> {
    // 添加，从头部添加
    void addHead(E e); 
    // 从尾部添加
    void addTail(E e);
    // 删除 头部删除
    E removeHead();
    // 尾部删除
    E removeTail();

    int size();

    boolean isEmpty();
    // 清空所有
    void clear();
 
}
```
以上定义了整个双端队列的接口形式。
##### 数组实现   
在通过数组实现双端队列时，由于数组本身的数据结构特性所限，针对数组本身导致的问题点需要考虑进去。  
* 数组在查询上性能较好，但在数组操作上效率较差(时间复杂度为O(n))，尤其是针对队列这种频繁操作的容器来说，是不合适的。   
* 针对队列的扩容操作是如何进行的。   
* 当元素下标移动到边界时， 需要将数组看成一个环。
    * 下标从数组第0位时，向左移动一位，会跳转到数组的最后一位。  
    * 下标从数组最后一位时，向右移动一位，会跳转到数组的第0位。

1. 双向队列结构定义 
    ```java 
    public class ArrayQueue<E> implements Queue<E> {
        private Object[] elements;  

        private int head; 

        private int tail; 

        public  ArrayQueue() {
            this.element = new Object[10]; 
            this.head = 0;
            this.tail = 0;
        }

    } 
    ```
2. 添加头部、尾部  
    ```java 
    public void addHead(E e) {
        this.head = mod(this.head -1); 

        this.elements[this.head] = e; 

        if (head == tail) {
            // 扩容
        }

    }
    public void addTail(E e) {
        this.elemnts[this.tail] = e; 
        this.tail = mod(this.tail +1); 
        if (head == tail) {
            // 扩容
        }
    }

    ```
3. 删除  
    ```java 
    public void removeHead() {
        E needRemove = this.elements[this.head]; 

        this.elements[this.head] = null; 

        this.head = mod(this.head +1); 

        return  needRemove;
    }

    public void removeTail() {
        int lastIndex = mod(this.tail - 1);

        E dataNeedRemove = (E)this.elements[lastIndex];

        this.tail = lastIndex;

        return dataNeedRemove;
    }

    ```
4. 获取下标  
    ```java 
    private int mod(int index) {
        if (index < 0) {
            return index += this.elements.length;
        }else {
            return index -=  this.elements.length;
        }
    }
    ```
5. 扩容操作  
    当头部下标和尾部下标相同时， 说明当前队列已经满了，那么久你会涉及到扩容问题。在扩容问题上，其本质是针对内部数组的扩容，但扩容后，针对数组的下标索引是如何处理呢？如果只是简单的将数组中的内容复制到新的更大的数组中，并且针对下标做简单归零处理，那么会破坏队列的先进后出特性。  
    * 将头部下标到数组尾部的元素复制到信得数组中0 ~   
    * 将数组头到尾部下标的元素紧跟以上操作复制到新的数组中  

    ```java 
    private void expansion() {
        Object[] newElements = new Object[this.elements.length * 2]; 

        // 复制头部下标到数组尾部的元素 
        for(int i = this.head, j = 0; i < this.elements.length; i++,j++>) {
          newElements[j] = this.elements[i];
        }

        for(int i = 0, j = this.elements.lenght - this.head; i < this.head; i++,j++>) {
            newElements[j] = this.elements[i];
        }
        this.head = 0;
        this.tail = this.elements.length; 
        this.elements = newElements;
    }
    ```
6. size 和 empty  
    ```java 
    public int size() {
        return mod(tail - head);
    }

    public boolean isEmpty() {
        return head == tail;
    }
    ```
7. 清除所有  
    ```java 
    public void clear() {
        while(head != tail) {
            this.elements[head] = null; 
            head = mod(head + 1);
        }
        this.head = 0;
        this.tail = 0;
    }
    ```

##### 链表实现  
在基于链表实现的双端队列时，通常采用的是双向链表，其插入和删除操作效率都非常高。基于双向链表实现的双端队列非常简单。并且其也不需要考虑扩容等问题。

1. 定义数据结构  
    具体的双向链表请参考其他文章  
    ```java 
    public class DoubleLinkQueue<E> implements Queue<E> {
        private DoubleLinkedList<E> list;
    }
    ```
2. 插入操作 
    ```java  
    public void addHead(E e) { 
        list.insertFirst(e);
    }
    public void addTail(E e) { 
        list.insertLast(e);
    }
    ```

3. 删除操作  
    ```java 
    public E removeHead() { 
       return list.deleteFirst();
    }
    public E removeTail() {  
        return list.deleteLast();
    }
    ```


## 总结  
针对队列与栈的数据结构，其应用上没什么太多复杂度，主要还是要了解其两者之间的特点，栈的先进后出以及队列的先进先出等。然后根据其不同的特点结合不同的业务需求来选择正确的数据结构。栈和队列的应用其主要针对的是其数据结构特点的应用。

## 参考 
[算法导论]()


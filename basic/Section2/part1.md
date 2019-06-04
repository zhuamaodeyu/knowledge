# 荷兰国旗问题解决方案  

## 问题描述  
现有 红、白、蓝 三个不同颜色的小球，乱序排列在一起，请重新排列这些小球，使得红白蓝的同颜色的球在一起。

## 问题分析  
问题转换为给定一个数组，其中元素有 0， 1， 2 设计算法，使其排列等于 `1....12....23....3`   

通过给定三个指针：  
    begin  = 0 , current = 0, end = N -1  
    * A[current] == 2, 则 A[current] 与 A[end] 交换， end --, current 不变  
    * A[current] == 1, 则current ++ , begin 不变， end 不变 
    * A[current] == 0, 则有两种情况：  
        * 若 begin == current, 则 begin ++ , current ++ 
        * 若 begin != current, 则 A[current] 与 A[begin] 交换， begin ++ ,current 不变  


```cpp
// Version 1  

void Test(int * a , int length){
    int begin = 0;
    int current = 0;
    int end = length -1;
    while(current <= end){
        if(a[current] == 2){
            swap(a[end], a[current]);
            end--;
        }else if(a[current] == 1){
            current++;
        }else{
            if(begin == current){
                begin++;
                current++;
            }else{
                swap(a[current], a[begin]);
                begin++;
            }
        }
    }
}

```
### 优化版本 1  
* current 扫描过的位置，即： [begin, current) 区间内， 一定没有2   
    * 在前面的 A[current] == 2, 已经被替换到数组后面了       
    因此 A[begin]要么是0， 要么是1， 不可能是2     
* 考察begin 指向的元素的值：     
    * 若 begin != current, 则必有 A[begin] =1      
    因此，当A[current] == 0 时：    
    若begin != current, 因为 A[begin] == 1, 则交换后，A [current]== 1, 此时，可以current++  


```cpp
// Version 2

void Test(int * a , int length){
    int begin = 0;
    int current = 0;
    int end = length -1;
    while(current <= end){
        if(a[current] == 2){
            // 交换
            swap(a[end], a[current]);
            end--;
        }else if(a[current] == 1){
            current++;
        }else{
            // 可以将以下内容进行合并
            if(begin == current){
                begin++;
                current++;
            }else{
                swap(a[current], a[begin]);
                begin++;
                current ++;
            }
        }
    }
}


```

```cpp

void Test(int * a , int length){
    int begin = 0;
    int current = 0;
    int end = length -1;
    while(current <= end){
        if(a[current] == 2){
            // 交换
            swap(a[end], a[current]);
            end--;
        }else if(a[current] == 1){
            current++;
        }else{
            // 
            if(begin != current)
                    swap(a[current], a[begin]);
            begin++;
            current ++;
        }
    }
}

```

### 循环不变式  
__循环不变式：__ 如果在循环之前的结论是对的，保证在循环之中每步的结论是对的，那么在循环结束的结论也是对的   

* 三个变量 begin, current, end 将数组分为四个区域： 
    * [0, begin) : 所有的数据都是0 
    * [begin, current) : 所有数据都是1 
    * (end, size -1] : 所有的数据都是2 
    * [current, end) : 未知  
* 循环不变式 ：
    * 初值 begin = current = 0, end = size -1, 前三个区间都为空集合， 满足以上4个条件  
    * 遍历current, 根据 a[current] 的值做相应处理，直到区间[current, end) 为空， 即 current == end 时退出  
    * 得到Version 3 版本  


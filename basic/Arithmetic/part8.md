#排序

## 简介
排序是最常用的算法，本节将针对最常用的几种排序算法进行说明，通过前文中的介绍，了解算法的性能的依据是其空间复杂度、时间复杂度、稳定性等依据来衡量一个算法的优劣的，本文也将在介绍每种排序算法时带上其这些指标。并且每种排序算法也将针对性的进行实现  

## 说明
__本文中的图片资源等内容全部来源于网络,如有不当之处，可以联系与我，商讨斟酌__   

本文的排序算法的示例数据为[0,2,4,5,8,6,9,10,28,35,46,17,96,74,81,33,25]

##冒泡排序

  冒泡排序(Bubble Sort)是一种比较简单的排序算法，每次比较两个元素，如果它们的顺序错误，那么久将它们的顺序交换。所以针对数列中的数据，每走访一次都会有一个数据是排序正确的。走访的次数是
`n -1 + n-2 + n-3 ….1` 所以其时间复杂度可以近似的为 `O(n*n)` 不过由于其只是在数列内部进行数据位置的交换，没有使用到太多额外的内存空间(只有一个临时变量)，所以其的 空间复杂度为 `O(1)` ; 并且由于其只有再两个元素大小不符合条件是才会调换位置，并不会改变相同元素之间的位置，因此它是稳定的排序算法 

- 时间复杂度为 `O(n*n)`  
- 空间复杂度 `O(1)`
- 稳定性  (稳定的)

###步骤

1. 比较两个相邻的元素，如果两个的顺序 不一致，那么久交换顺序  
2. 对每一对元素同样的操作。这样最后一个元素就变为正确顺序的了 (最大的)  
3. 针对所有元素重复以上操作，直到最后一个  
4. 持续以上操作，直到最终结果正确  


![](../../assets/gitbook/20180217151884929290497.gif)
![](../../assets/gitbook/20180217151884931389339.gif)



通过以上的GIF 图可以很直观的了解算法的实现原理  

``` java 
Codeing

    /**
    
    */
    public static void bubbleSort(int[] arr){
        // 总体的循环此处
        for(int i = arr.length; i > 0; i--){
            // 每次循环的比较次数, 注意 这里的 j  不止需要小于 i  j + 1 也要小于 i  不然下边会数组越界
            for(int j = 0; (j+1)< i ; j++){
                if(arr[j] > arr[j+1]){
                    // 交换两个的值
                    int temp = arr[j];
                    arr[j] = arr[j+1];
                    arr[j+1] = temp;
                }
            }
            System.out.println("Sorting:" +  Arrays.toString(arr));
        }
    }

```
##选择排序

选择排序(Selection Sort) 工作原理就是在未排序的数列中，选择出最小的值，然后放在起始位置，然后在剩余中的数列中，一直选择最小的数据，依次放在排序序列末尾  

- 时间复杂度   `O(n*n)`  
- 空间复杂度  
- 稳定性   

###步骤

- 在未排序的序列中找到最小的元素， 存放在序列起始位置  
- 再从剩余元素中找到最小元素，放在排序的末尾  
- 一直重复第二步   
  
  
  
```java 
Coding

    public static void selectionSort(int [] arr){
        //  arr.length-1 次，这里并不是 arr.length 因为最有一个不用对比
        for (int i = 0; i < arr.length; i ++){
            // i 是当前已经排序的元素
            int min  = i;
            // 找出最小的元素
            for (int j = i + 1 ; j < arr.length; j++){
                if (arr[min] > arr[j]){
                    min = j;
                }
            }
            // 插入到最后边
            if (min != i){
                int temp = arr[min];
                arr[min] = arr[i];
                arr[i] = temp;
            }
            System.out.println("Sorting:" + Arrays.toString(arr));
        }
    }

```

##插入排序

插入排序通过对未排序的对象，在其它已排序的数列中找到其对应的位置并插入  

- 时间复杂度  `O(n*n)`  
- 空间复杂度 
- 稳定性  

###步骤

1. 将第一个待排序的元素作为一个有序的序列， 然后将第二个到最后一个作为未排序序列  
2. 扫描未排序序列，将扫描到的每个元素插入到有序序列适当的位置  




```java 
Coding

    public static  void  insertionSort(int[] arr){
        //第一个默认的是一个有序序列  所以从第二个开始 到  n-1 个
        for (int i = 0 ; i < arr.length - 1; i++) {
            //进行比较第二个元素与前面的有序序列进行比较
            for (int j = i + 1; j >0; j--) {
                if (arr[j-1] <= arr[j]) {
                    break;
                }
                // 交换值 一直更替交换上去直到正确的位置
                int temp = arr[j];
                arr[j] = arr[j-1];
                arr[j-1] = temp;
            }
            System.out.println("Sorting: " + Arrays.toString(arr));
        }
    }
```
##归并排序

- 时间复杂度  `O(N*logN) ` 
- 空间复杂度 
- 稳定性  

##快速排序

##堆排序

##希尔排序



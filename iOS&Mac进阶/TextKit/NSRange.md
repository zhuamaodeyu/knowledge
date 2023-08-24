
# NSRange 



1. 创建 
```swift 

NSArray *array = @[@1, @2, @3];
NSRange range = NSMakeRange(0, [array count]);
// {.location=0, .length=3}


```


2. 查询信息 

* NSEqualRanges: 返回一个指示给出的两个范围是否相等的布尔值。
    ```swift 

        NSRange range1 = NSMakeRange(0, 6);
        NSRange range2 = NSMakeRange(2, 7);
        BOOL equal = NSEqualRanges(range1, range2); // NO

    ```
* NSLocationInRange: 返回一个指示给定的位置是否存在于给定的范围的布尔值。 
    ```swift 

    NSRange range = NSMakeRange(3, 4);
    BOOL contained = NSLocationInRange(5, range); // YES

    ```

* NSMaxRange: 返回范围的位置和长度的和。  
    ```swift 


    NSRange range = NSMakeRange(3, 4);
    NSUInteger max = NSMaxRange(range); // 7

    ```

## 集合操作 
* NSIntersectionRange: 返回给定范围的交集。如果返回的范围长度字段为 0，则两个给定的范围值没有交集。位置字段的值是未定义的。 
    ```swift 

    NSRange range1 = NSMakeRange(0, 6);
    NSRange range2 = NSMakeRange(2, 7);
    NSRange intersectionRange = NSIntersectionRange(range1, range2);
    // {.location=2, .length=4}


    ```

* NSUnionRange: 返回给定范围的并集，即一个包含 range1 和 range2 当中和它们之间的值的 range。如果一个范围被完全包含在另一个之内，返回值是较大的那一个。  
    ```swift 

    NSRange range1 = NSMakeRange(0, 6);
    NSRange range2 = NSMakeRange(2, 7);
    NSRange unionRange = NSUnionRange(range1, range2);
    // {.location=0, .length=9}


    ```


> [NSRange](https://nshipster.cn/nsrange/)
# UICollectionView 部分方法失效问题  

iOS 开发中，UICollectionView 控件与 UITableView 同样是使用比重相对很重的基础控件，虽然两者在部分功能上是相同的，不过 UICollectionView 的表现力更加丰富，自定义程度更加自由。在很多场景需求下都会去考虑使用 UICollectionView来实现部分需求。虽然两者看上去类似，都是基于UIScrollView 的列表式实现，不过其内部采用了不同的实现机制。UICollectionView 的内部实现更加复杂，导致在UITableView 上的有些使用是可以实现的，但在UICollectionView 下却是失效的  

我们都知道在 UITableView 中，当拿到数据时通过 `[self.tableView reloadData]` 方法后，可以通过  


```  
- (__kindof UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;  
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
```

等方法，可以获取 indexPath 所对应的cell(注意此方法可以能获取的是nil，其官方文档给出的解释是，可能是indexPath 超出范围或者cell 未显示) 或者滚动到指定 indexPath 所对应的cell上(此方法在 tableView 下在 `reloadData`方法后调用是可以正常执行的)，这些方法在 UITableView 上使用时没有问题的，其盖因 在UITableView 下 `reloadData` 方法调用后，系统就会去计算并刷新UITableView，这个过程是同步的，在之后调用以上这些方法都是可以正常执行的。但是这些方法在 UICollectionView 下那就不一定有用了    

UICollectionView 和 UITableView 的一个很大的不同点就是在数据处理上， UICollectionView的`reloadData` 方法并不会实时的去刷新 cell, 所以 如果你是在 `reloadData` 方法刚调用后，就调用   

```
- (UICollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

```  
等方法，你会发现不管你怎么调用这些方法都是无效的。根本不起作用，根据以上原因，我们必须要等待其 cell 绘制后才可以调用以上等方法， 在 UICollectionView 在UIViewController 下的时候，如果其数据完备，并不是通过网络请求异步获取的，那么可以在  `-(void)viewDidLayoutSubviews` 方法中进行以以上方法的调用，此时view都已经创建完毕，不过如果你的数据是网络异步获取的，当获取到数据后才会调用 `reloadData` 方法刷新的时候，此时在 `-(void)viewDidLayoutSubviews` 方法中处理就不是很合适了，因为此方法调用时还可能没有数据，所以cell都还是不存在的    

#### 解决

针对以上问题，解决起来并不是很复杂，但是不了解的时候，可能会因为方法调用的问题 而走弯路。 需要在 `reloadData` 方法调用后，告诉 `collectionView` 你必须现在就给我计算cell, 可以通过 调用 `layoutIfNeeded` 方法来实现  

```
[self.collectionView reloadData];
[self.collectionView layoutIfNeeded];
```

在以上代码之后，可以通通过以上的系统方法获取cell 不过，通过以上方式后，只能获取到当前屏幕可以显示下的cell，比如当前屏幕可以显示4个cell，那么通过以上方式后，利用 `cellForRowAtIndexPath:`方法只能获取到 4个左右的cell,因为其他cell 还无法显示，所以无法获取，不过如果想在滚动后获取对应的cell， 可以通过一下方式   

```
// 获取第 10 个cell  
[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone scrollPosition animated:false]; 
[self.collectionView layoutIfNeeded]; 

// 此时就可以获取到了  
UICollectionViewCell *cell  = [self.collectionView cellForItemAtIndexPath:indexPath];
```
通过以上方式就彻底解决了无法获取cell以及滚动的问题了  



#### 扩展 
如果只是为了实现滚动到指定cell 的效果 ，可以直接通过 `- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;` 来实现，不过位置的计算就需要自己手动计算了  



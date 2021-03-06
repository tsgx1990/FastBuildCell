# FastBuildCell
tableView和collectionView的cell快速构建框架

在ios8以上系统中，存在tableView在滑动过程中会重新计算cell高度的问题。虽然可以通过设置tableView.estimatedRowHeight，以及cell的约束，让系统自动计算cell的高度，但是这种方式却并不适合ios7。",

## I  该轮子可以解决以下问题：
1，为了兼容ios7，同时考虑到在ios8以上系统中cell高度会重新计算的问题。  
2，计算并缓存cell高度，提升在ios8以上系统上tableView滑动的流畅性。  
3，为了快速创建含有多类型cell的复杂tableView。  
4，解耦。  
5，瘦身viewController，将cell的赋值操作抽离出来，在自定义的cell中进行。    
6，转屏的情况下仍能正确获取cell高度。    
                       
## II  该轮子使用起来也并不复杂：
                       
## III  特别说明：
1，headerFooter的高度没有重复计算的问题（转屏时会重新计算），所以不用考虑高度缓存问题。  
2，默认情况下会使用cell的高度缓存，而不是重新计算。也可以通过实现     UITableViewCacheDelegate协议的相关方法来控制是否使用缓存，或者调用model的 clearHeightCacheInScrollView:方法强行清除该model的高度缓存。   
3，在[tableView reloadData] 的时候会清除所有cell的高度缓存。        
4，缓存的高度存储在model中，以model所属cell的reuseIdentifier和tableView组成的key值进行存取。   

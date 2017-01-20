## KDRearrangeableCollectionViewFlowLayout ##

This is a simple implementation of a drag and rearrange collection view through its layout. It works for UICollectionViews with multiple sections.

Video Demo: [Here](https://v.usetapes.com/U5UrT2ePsO)

Tip: For drag and drop **between** multiple collection views look at the project [here](https://github.com/mmick66/KDDragAndDropCollectionView).

### Quick Guide ###

1. Add the *KDRearrangeableCollectionViewFlowLayout.swift* file to your project (it is the only file you need).
2. Set the layout of your UICollectionView to be the one in the file above. This can be done either programmatically or through the Storyboard.

![Storyboard Illustration](http://s17.postimg.org/4pimesmen/Screen_Shot_2016_01_04_at_17_45_54.png)

3. Make the data source of your UICollectionView to be *KDRearrangeableCollectionViewDelegate* subclass and implement the one mandatory method there.

```Swift
func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
```

An example implementation for a multisectioned UICollectionView is here:

```Swift
func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void {
    let name = self.data[fromIndexPath.section][fromIndexPath.item]
    self.data[fromIndexPath.section].removeAtIndex(fromIndexPath.item)
    self.data[toIndexPath.section].insert(name, atIndex: toIndexPath.item)
}
```

#### You can stop the dragging behaviour by setting the property

```Swift
self.collectionViewRearrangeableLayout.draggable = true
```

#### You can constraint the axist of the drag through an enum

```Swift
self.collectionViewRearrangeableLayout.axis = .Free
self.collectionViewRearrangeableLayout.axis = .X
self.collectionViewRearrangeableLayout.axis = .Y
```

#### You can prevent the of any cell by implementing:

```Swift
func canMoveItem(at indexPath : IndexPath) -> Bool
```

### KDRearrangeableCollectionViewCell

Another class that comes with this package is KDRearrangeableCollectionViewCell. It is a subclass of UICollectionViewCell and it implements a boolean property called 'dragging'. If you choose to make the cells of your collection view a subclass of KDRearrangeableCollectionViewCell this property will be set upon the start and end of the dragging and by overriding it you can set the style of the snapshot image that will be dragged around.

This method will be called before the visual swap happens.

### Make One Yourself ###

Please have a look at the [article](http://karmadust.com/?p=5) for a full explanation.

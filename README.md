## KDRearrangeableCollectionViewFlowLayout ##

This is a simple implementation of a drag and rearrange collection view through its layout. It works for UICollectionViews with multiple sections.

Video Demo: [Here](https://v.usetapes.com/U5UrT2ePsO)

Tip: For drag and drop **between** multiple collection views look at the project [here](https://github.com/mmick66/KDDragAndDropCollectionView).

### Quick Guide ###

1. Add the *KDRearrangeableCollectionViewFlowLayout.swift* file to your project (it is the only file you need).
2. Set the layout of your UICollectionView to be the one in the file above. This can be done either programmatically or through the Storyboard.
![Drag and Drop Illustration](http://postimg.org/image/3n8fw93l7/)
3. Make the data source of your UICollectionView to be *KDRearrangeableCollectionViewDelegate* subclass and implement the only method there.

```Swift
func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void
```

An exmple implementation for a multisectioned UICollectionView is here:

```Swift
func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void {
    let name = self.data[fromIndexPath.section][fromIndexPath.item]
    self.data[fromIndexPath.section].removeAtIndex(fromIndexPath.item)
    self.data[toIndexPath.section].insert(name, atIndex: toIndexPath.item)
}
```

This method will be called before the visual swap happens.

### Make One Yourself ###

Please have a look at the [article](http://karmadust.com/?p=5) for a full explanation.

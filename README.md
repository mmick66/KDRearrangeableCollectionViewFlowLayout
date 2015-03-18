### KDRearrangeableCollectionViewFlowLayout ###

This is a simple implementation of a drag and rearrange collection view through its layout

## Installation ##

At a minimum, just set the layout of your collection view to be a KDRearrangeableCollectionViewFlowLayout. Do this on a storyboard by selecting the layout component and changing the class name, not by changing the layout to custom by selecting the collection view. In this way you will maintain the ability to edit the size values on the storyboard.

## Data Driven ##

To fully implement the class you need to make your delegate a KDRearrangeableCollectionViewDelegate and implement its method like so:

```
#!swift

func moveDataItem(fromIndexPath : NSIndexPath, toIndexPath: NSIndexPath) -> Void {
    let customObject = collectionViewDataArray[fromIndexPath.item]
    collectionViewDataArray[fromIndexPath.item] = collectionViewDataArray[toIndexPath.item]
    collectionViewDataArray[toIndexPath.item] = customObject
}
```

This method will be called before the visual swap happens.

## Full Tutorial ##

Please have a look at the [http://karmadust.com/?p=5](http://karmadust.com/?p=5) for a full explanation.
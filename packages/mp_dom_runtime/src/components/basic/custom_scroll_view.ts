import { cssPadding, cssSizeFromMPElement } from "../utils";
import { CollectionView, CollectionViewLayout } from "./collection_view";
import { GridListLayout } from "./grid_list_layout";

export class CustomScrollView extends CollectionView {
  listChildren: any[] = [];

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.layout = new CustomScrollViewLayout(this);
  }

  setChildren(children: any) {
    if (!children) return;
    let listChildren: any[] = [];
    let sliverGridAttributes: { [key: number]: any } = {};
    let sliverGridEndIndex: { [key: number]: boolean } = {};
    children.forEach((obj: any, index: number) => {
      if (obj.name === "sliver_list" && obj.children) {
        sliverGridAttributes[listChildren.length] = obj.attributes;
        this.factory.fetchCachedChildren(obj.children).forEach((obj: any) => {
          listChildren.push(obj);
        });
        sliverGridEndIndex[listChildren.length - 1] = true;
      } else if (
        obj.children?.[0]?.name === "sliver_list" &&
        obj.children?.[0]?.children
      ) {
        sliverGridAttributes[listChildren.length] = obj.children[0].attributes;
        this.factory
          .fetchCachedChildren(obj.children[0].children)
          .forEach((obj: any, index: number) => {
            listChildren.push(obj);
          });
        sliverGridEndIndex[listChildren.length - 1] = true;
      } else if (obj.name === "sliver_grid" && obj.children) {
        sliverGridAttributes[listChildren.length] = obj.attributes;
        this.factory.fetchCachedChildren(obj.children).forEach((obj: any) => {
          listChildren.push(obj);
        });
        sliverGridEndIndex[listChildren.length - 1] = true;
      } else if (
        obj.children?.[0]?.name === "sliver_grid" &&
        obj.children?.[0]?.children
      ) {
        sliverGridAttributes[listChildren.length] = obj.children[0].attributes;
        this.factory
          .fetchCachedChildren(obj.children[0].children)
          .forEach((obj: any) => {
            listChildren.push(obj);
          });
        sliverGridEndIndex[listChildren.length - 1] = true;
      } else {
        listChildren.push(obj);
      }
    });
    this.listChildren = listChildren;
    (this.layout as CustomScrollViewLayout).items = listChildren;
    (this.layout as CustomScrollViewLayout).sliverGridAttributes =
      sliverGridAttributes;
    (this.layout as CustomScrollViewLayout).sliverGridEndIndex =
      sliverGridEndIndex;
    super.setChildren(listChildren);
    this.reloadLayouts();
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    (this.layout as GridListLayout).isHorizontalScroll =
      attributes.scrollDirection === "Axis.horizontal";

    if (attributes.appBarPinned) {
      this.setPinnedAppBar(attributes);
    } else if (this.appBarPinnedViews.length) {
      this.appBarPinnedViews.forEach((it) => it.removeFromSuperview());
      this.appBarPinnedViews = [];
      this.appBarPersistentHeight = 0.0;
    }
  }
}

class CustomScrollViewLayout extends CollectionViewLayout {
  isHorizontalScroll: boolean = false;
  items: any[] = [];
  maxVLength: number = 0;
  itemLayouts: { x: number; y: number; width: number; height: number }[] = [];
  sliverGridAttributes: { [key: number]: any } = {};
  sliverGridEndIndex: { [key: number]: boolean } = {};

  prepareLayout() {
    let viewWidth = this.collectionView.viewWidth;
    let viewHeight = this.collectionView.viewHeight;
    if (this.isHorizontalScroll && viewHeight <= 0.01) {
      return;
    }
    if (!this.isHorizontalScroll && viewWidth <= 0.01) {
      return;
    }
    let layouts: any[] = [];
    let currentVLength = 0.0;
    let currentWaterfallLayout: GridListLayout | undefined;
    let currentWaterfallItemPos = 0;
    this.items.forEach((data: any, index: number) => {
      {
        if (this.sliverGridAttributes[index]) {
          currentWaterfallItemPos = 0;
          currentWaterfallLayout = new GridListLayout(this.collectionView);
          currentWaterfallLayout.isHorizontalScroll = this.isHorizontalScroll;
          let waterfallItems: any[] = [];
          for (let nIndex = index; nIndex < this.items.length; nIndex++) {
            waterfallItems.push(this.items[nIndex]);
            if (this.sliverGridEndIndex[nIndex]) break;
          }
          currentWaterfallLayout.clientWidth = this.collectionView.viewWidth;
          currentWaterfallLayout.clientHeight = this.collectionView.viewHeight;
          const gridDelegate = this.sliverGridAttributes[index].gridDelegate;
          if (gridDelegate) {
            currentWaterfallLayout.isPlain =
              gridDelegate.classname !== "SliverWaterfallDelegate";
            currentWaterfallLayout.crossAxisCount = gridDelegate.crossAxisCount;
            currentWaterfallLayout.mainAxisSpacing =
              gridDelegate.mainAxisSpacing;
            currentWaterfallLayout.crossAxisSpacing =
              gridDelegate.crossAxisSpacing;
          }
          if (this.sliverGridAttributes[index].padding) {
            const padding = cssPadding(
              this.sliverGridAttributes[index].padding
            );
            currentWaterfallLayout.padding.top = parseFloat(
              padding.paddingTop ?? "0.0"
            );
            currentWaterfallLayout.padding.left = parseFloat(
              padding.paddingLeft ?? "0.0"
            );
            currentWaterfallLayout.padding.bottom = parseFloat(
              padding.paddingBottom ?? "0.0"
            );
            currentWaterfallLayout.padding.right = parseFloat(
              padding.paddingRight ?? "0.0"
            );
          }
          currentWaterfallLayout.items = waterfallItems;
          currentWaterfallLayout.prepareLayout();
        }
        if (currentWaterfallLayout) {
          if (
            currentWaterfallItemPos < currentWaterfallLayout.itemLayouts.length
          ) {
            let absFrame = {
              ...currentWaterfallLayout.itemLayouts[currentWaterfallItemPos],
            };
            if (this.isHorizontalScroll) {
              absFrame.x += currentVLength;
            } else {
              absFrame.y += currentVLength;
            }
            layouts.push(absFrame);
          } else {
            layouts.push({ x: 0, y: 0, width: 0, height: 0 });
          }
          currentWaterfallItemPos++;
        }
        if (this.sliverGridEndIndex[index] && currentWaterfallLayout) {
          if (this.isHorizontalScroll) {
            currentVLength +=
              currentWaterfallLayout.collectionViewContentSize().width;
          } else {
            currentVLength +=
              currentWaterfallLayout.collectionViewContentSize().height;
          }
          this.maxVLength = currentVLength;
          currentWaterfallLayout = undefined;
          return;
        }
        if (currentWaterfallLayout) {
          return;
        }
      }
      const elementSize = cssSizeFromMPElement(data);
      let itemFrame: { x: number; y: number; width: number; height: number };
      if (this.isHorizontalScroll) {
        itemFrame = {
          x: currentVLength,
          y: 0,
          width: elementSize.width,
          height: viewHeight,
        };
        currentVLength += elementSize.width;
      } else {
        itemFrame = {
          x: 0,
          y: currentVLength,
          width: viewWidth,
          height: elementSize.height,
        };
        if (
          data.name === "sliver_persistent_header" &&
          data.attributes.lazying
        ) {
        } else {
          currentVLength += elementSize.height;
        }
      }
      this.maxVLength = currentVLength;
      layouts.push(itemFrame);
    });
    this.itemLayouts = layouts;
  }

  collectionViewContentSize() {
    if (this.isHorizontalScroll) {
      return { width: this.maxVLength, height: this.collectionView.viewHeight };
    } else {
      return { width: this.collectionView.viewWidth, height: this.maxVLength };
    }
  }

  layoutAttributesForItemAtIndex(index: number) {
    return this.itemLayouts[index];
  }
}

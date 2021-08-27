import { cssSizeFromMPElement } from "../utils";
import { CollectionViewLayout } from "./collection_view";

export class GridListLayout extends CollectionViewLayout {
  isPlain: boolean = true;
  isHorizontalScroll: boolean = false;
  padding: { top: number; left: number; bottom: number; right: number } = {
    top: 0,
    left: 0,
    bottom: 0,
    right: 0,
  };
  clientWidth: number = 0;
  clientHeight: number = 0;
  crossAxisCount: number = 0;
  crossAxisSpacing: number = 0;
  mainAxisSpacing: number = 0;
  items: any[] = [];
  maxVLength: number = 0;
  itemLayouts: { x: number; y: number; width: number; height: number }[] = [];

  prepareLayout() {
    if (this.isPlain) {
      this.preparePlainLayout();
    } else {
      this.prepareWaterfallLayout();
    }
  }

  preparePlainLayout() {
    let clientWidth =
      (this.clientWidth > 0
        ? this.clientWidth
        : this.collectionView.viewWidth) - this.padding.right;
    let clientHeight =
      (this.clientHeight > 0
        ? this.clientHeight
        : this.collectionView.viewHeight) - this.padding.bottom;
    let layouts: any[] = [];
    let currentX = this.padding.left;
    let currentY = this.padding.top;
    let maxVLength = 0.0;
    this.items.forEach((obj, index) => {
      const itemSize = cssSizeFromMPElement(obj);
      const itemWidth = itemSize.width;
      const itemHeight = itemSize.height;
      if (this.isHorizontalScroll) {
        const rect = {
          x: currentX,
          y: currentY,
          width: itemWidth,
          height: itemHeight,
        };
        currentY += itemHeight + this.crossAxisSpacing;
        maxVLength = Math.max(currentX + itemWidth, maxVLength);
        if (currentY + itemHeight - clientHeight > 0.1) {
          currentY = this.padding.top;
          if (index + 1 < this.items.length) {
            currentX += itemWidth + this.mainAxisSpacing;
          }
        }
        layouts.push(rect);
      } else {
        const rect = {
          x: currentX,
          y: currentY,
          width: itemWidth,
          height: itemHeight,
        };
        currentX += itemWidth + this.crossAxisSpacing;
        maxVLength = Math.max(currentY + itemHeight, maxVLength);
        if (currentX + itemWidth - clientWidth > 0.1) {
          currentX = this.padding.left;
          if (index + 1 < this.items.length) {
            currentY += itemHeight + this.mainAxisSpacing;
          }
        }
        layouts.push(rect);
      }
    });
    if (this.isHorizontalScroll) {
      maxVLength += this.padding.right;
    } else {
      maxVLength += this.padding.bottom;
    }
    this.itemLayouts = layouts;
    this.maxVLength = maxVLength;
  }

  prepareWaterfallLayout() {
    if (this.crossAxisCount <= 0) {
      this.itemLayouts = [];
      return;
    }
    let currentRowIndex = 0;
    let layoutCache: {
      [key: number]: { x: number; y: number; width: number; height: number };
    } = {};
    let layouts: any[] = [];
    let maxVLength = 0.0;
    this.items.forEach((obj, idx) => {
      let itemSize = cssSizeFromMPElement(obj);
      let itemWidth = itemSize.width;
      let itemHeight = itemSize.height;
      let currentVLength = this.isHorizontalScroll
        ? this.padding.left
        : this.padding.top;
      {
        let index = currentRowIndex;
        let nextIndex = index + 1 >= this.crossAxisCount ? 0 : index + 1;
        if (layoutCache[index] && layoutCache[nextIndex]) {
          let curRect = layoutCache[index];
          let nextRect = layoutCache[nextIndex];
          if (this.isHorizontalScroll) {
            if (nextRect.x + nextRect.width < curRect.x + curRect.width) {
              currentRowIndex = nextIndex;
            } else {
              currentRowIndex = index;
            }
          } else {
            if (nextRect.y + nextRect.height < curRect.y + curRect.height) {
              currentRowIndex = nextIndex;
            } else {
              currentRowIndex = index;
            }
          }
        } else {
          currentRowIndex = index;
        }
      }

      if (layoutCache[currentRowIndex]) {
        let curRect = layoutCache[currentRowIndex];
        if (this.isHorizontalScroll) {
          currentVLength = curRect.x + curRect.width;
          if (idx >= this.crossAxisCount) {
            currentVLength += this.mainAxisSpacing;
          }
        } else {
          currentVLength = curRect.y + curRect.height;
          if (idx >= this.crossAxisCount) {
            currentVLength += this.mainAxisSpacing;
          }
        }
      } else {
        currentVLength = this.isHorizontalScroll
          ? this.padding.left
          : this.padding.top;
      }

      if (this.isHorizontalScroll) {
        let rect = {
          x: currentVLength,
          y:
            this.padding.top +
            itemHeight * currentRowIndex +
            currentRowIndex * this.crossAxisSpacing,
          width: itemWidth,
          height: itemHeight,
        };
        layoutCache[currentRowIndex] = rect;
        currentRowIndex = (currentRowIndex + 1) % this.crossAxisCount;
        maxVLength = Math.max(currentVLength + itemWidth, maxVLength);
        layouts.push(rect);
      } else {
        let rect = {
          x:
            this.padding.left +
            itemWidth * currentRowIndex +
            currentRowIndex * this.crossAxisSpacing,
          y: currentVLength,
          width: itemWidth,
          height: itemHeight,
        };
        layoutCache[currentRowIndex] = rect;
        currentRowIndex = (currentRowIndex + 1) % this.crossAxisCount;
        maxVLength = Math.max(currentVLength + itemHeight, maxVLength);
        layouts.push(rect);
      }
    });
    if (this.isHorizontalScroll) {
      maxVLength += this.padding.right;
    } else {
      maxVLength += this.padding.bottom;
    }
    this.itemLayouts = layouts;
    this.maxVLength = maxVLength;
  }

  collectionViewContentSize() {
    if (this.isHorizontalScroll) {
      return {
        width: this.maxVLength,
        height:
          this.collectionView.viewHeight -
          this.padding.top -
          this.padding.bottom,
      };
    } else {
      return {
        width:
          this.collectionView.viewWidth -
          this.padding.left -
          this.padding.right,
        height: this.maxVLength,
      };
    }
  }

  layoutAttributesForItemAtIndex(index: number) {
    return this.itemLayouts[index];
  }
}

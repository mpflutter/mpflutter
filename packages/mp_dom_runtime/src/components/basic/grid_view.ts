import { ComponentView } from "../component_view";
import { setDOMStyle } from "../dom_utils";
import { cssPadding, cssSizeFromMPElement } from "../utils";
import { CollectionView } from "./collection_view";
import { GridListLayout } from "./grid_list_layout";

export class GridView extends CollectionView {
  listChildren: any[] = [];

  constructor(document: Document, readonly initialAttributes?: any) {
    super(document, initialAttributes);
    this.layout = new GridListLayout(this);
  }

  setChildren(children: any) {
    super.setChildren(children);
    if (!children) return;
    let listChildren: any[] = [];
    this.factory.fetchCachedChildren(children).forEach((obj: any) => {
      listChildren.push(obj);
      this.factory.create(obj, this.document);
    });
    (this.layout as GridListLayout).items = listChildren;
    this.listChildren = listChildren;
    this.reloadLayouts();
  }

  setAttributes(attributes: any) {
    super.setAttributes(attributes);
    (this.layout as GridListLayout).isHorizontalScroll =
      attributes.scrollDirection === "Axis.horizontal";
    const gridDelegate = attributes.gridDelegate;
    if (gridDelegate) {
      (this.layout as GridListLayout).isPlain =
        gridDelegate.classname !== "SliverWaterfallDelegate";
      (this.layout as GridListLayout).crossAxisCount =
        gridDelegate.crossAxisCount;
      (this.layout as GridListLayout).mainAxisSpacing =
        gridDelegate.mainAxisSpacing;
      (this.layout as GridListLayout).crossAxisSpacing =
        gridDelegate.crossAxisSpacing;
    }
    if (attributes.padding) {
      const padding = cssPadding(this.attributes.padding);

      (this.layout as GridListLayout).padding.top = parseFloat(
        padding.paddingTop ?? "0.0"
      );
      (this.layout as GridListLayout).padding.left = parseFloat(
        padding.paddingLeft ?? "0.0"
      );
      (this.layout as GridListLayout).padding.bottom = parseFloat(
        padding.paddingBottom ?? "0.0"
      );
      (this.layout as GridListLayout).padding.right = parseFloat(
        padding.paddingRight ?? "0.0"
      );
    }
    if (attributes.appBarPinned) {
      this.setPinnedAppBar(attributes);
    } else if (this.appBarPinnedViews.length) {
      this.appBarPinnedViews.forEach((it) => it.removeFromSuperview());
      this.appBarPinnedViews = [];
      this.appBarPersistentHeight = 0.0;
    }
    this.reloadLayouts();
  }
}

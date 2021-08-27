Page({
  onLoad: function () {
    var demoDom = this.selectComponent("#demoDom");
    let document = demoDom.miniDom.document;
    document.body.setStyle({
      backgroundColor: "yellow",
    });
  },
});

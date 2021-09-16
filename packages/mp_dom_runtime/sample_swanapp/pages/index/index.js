/**
 * @file index.js
 * @author swan
 */
const app = getApp()

Page({
    onLoad: function () {
        let document = this.selectComponent('#vdom').miniDom.document;
        document.body.setStyle({
            backgroundColor: "yellow"
        });
        let divElement = document.createElement('div');
        divElement.setStyle({
            position: 'absolute',
            left: "100px",
            top: "100px",
            width: "200px",
            height: "200px",
            backgroundColor: "red",
        }); {
            let divElement2 = document.createElement('div');
            divElement2.setStyle({
                position: 'absolute',
                left: "50px",
                top: "50px",
                width: "100px",
                height: "100px",
                backgroundColor: "yellow",
            });
            divElement.appendChild(divElement2);
        }
        document.body.appendChild(divElement);
        console.log(document);

    },
})
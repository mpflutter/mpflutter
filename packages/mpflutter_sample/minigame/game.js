const canvas = wx.createCanvas()
const ctx = canvas.getContext('2d')

class Main {

  constructor() {
    this.restart();
  }

  restart() {
    ctx.clearRect(0,0,1000,1000);
    ctx.fillStyle = "red";
    ctx.fillRect(0,0,100,100);
  }

}

new Main()

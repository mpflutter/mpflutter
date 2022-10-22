const base = require('./base')

Component({
    mixins: base.mixins,
    behaviors: [base],
    options: {
        addGlobalClass: true, // 开启全局样式
    },
})

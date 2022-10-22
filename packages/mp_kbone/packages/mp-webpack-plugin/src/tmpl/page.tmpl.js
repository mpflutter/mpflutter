const mp = require('../../miniprogram_npm/miniprogram-render/index')
const getBaseConfig = require('../base.js')
const config = require('/* CONFIG_PATH */')

/* INIT_FUNCTION */

const baseConfig = getBaseConfig(mp, config, init)

if (typeof my !== 'undefined') {
  Page({
    ...baseConfig.base,
    ...baseConfig.methods,
  })
}

Component({
    ...baseConfig.base,
    ...baseConfig.methods,
    methods: {
        ...baseConfig.methods,
        /* PAGE_SCROLL_FUNCTION */
        /* REACH_BOTTOM_FUNCTION */
        /* PULL_DOWN_REFRESH_FUNCTION */
    },
})

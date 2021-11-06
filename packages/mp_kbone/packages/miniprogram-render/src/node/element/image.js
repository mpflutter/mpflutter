const Element = require('../element')
const Pool = require('../../util/pool')
const cache = require('../../util/cache')

const pool = new Pool()

class Image extends Element {
    /**
     * 创建实例
     */
    static $$create(options, tree) {
        const config = cache.getConfig()

        if (config.optimization.elementMultiplexing) {
            // 复用 element 节点
            const instance = pool.get()

            if (instance) {
                instance.$$init(options, tree)
                return instance
            }
        }

        return new Image(options, tree)
    }

    /**
     * 覆写父类的 $$init 方法
     */
    $$init(options, tree) {
        const width = options.width
        const height = options.height

        if (typeof width === 'number' && width >= 0) options.attrs.width = width
        if (typeof height === 'number' && height >= 0) options.attrs.height = height

        super.$$init(options, tree)

        this.$_naturalWidth = 0
        this.$_naturalHeight = 0

        this.$_initRect()
    }

    /**
     * 覆写父类的 $$destroy 方法
     */
    $$destroy() {
        super.$$destroy()

        this.$_naturalWidth = null
        this.$_naturalHeight = null
    }

    /**
     * 覆写父类的回收实例方法
     */
    $$recycle() {
        this.$$destroy()

        const config = cache.getConfig()

        if (config.optimization.elementMultiplexing) {
            // 复用 element 节点
            pool.add(this)
        }
    }

    /**
     * 更新父组件树
     */
    $_triggerParentUpdate() {
        this.$_initRect()
        super.$_triggerParentUpdate()
    }

    /**
     * 初始化长宽
     */
    $_initRect() {
        const width = this.$_attrs.get('width')
        const height = this.$_attrs.get('height')

        const widthNum = +width
        if (!isNaN(+widthNum) && +widthNum >= 0) this.$_style.width = `${width}px`
        else if (width && typeof width === 'string') this.$_style.width = width // 可能设置 width="100%"

        const heightNum = +height
        if (!isNaN(+heightNum) && +heightNum >= 0) this.$_style.height = `${height}px`
        else if (height && typeof height === 'string') this.$_style.height = height // 可能设置 width="100%"
    }

    /**
     * 重置长宽
     */
    $_resetRect(rect = {}) {
        this.$_naturalWidth = rect.width || 0
        this.$_naturalHeight = rect.height || 0

        this.$_initRect()
    }

    /**
     * 对外属性和方法
     */
    get src() {
        return this.$_attrs.get('src') || ''
    }

    get width() {
        return parseFloat(this.$_attrs.get('width'), 10) || 0
    }

    set width(value) {
        if (typeof value !== 'number' || !isFinite(value) || value < 0) return

        this.$_attrs.set('width', value)
        this.$_initRect()
    }

    get height() {
        return parseFloat(this.$_attrs.get('height'), 10) || 0
    }

    set height(value) {
        if (typeof value !== 'number' || !isFinite(value) || value < 0) return

        this.$_attrs.set('height', value)
        this.$_initRect()
    }

    get naturalWidth() {
        return this.$_naturalWidth
    }

    get naturalHeight() {
        return this.$_naturalHeight
    }
}

module.exports = Image

const fs = require('fs')
const {execSync} = require('child_process')

let baseCode = fs.readFileSync('./dist/miniprogram-element/base.js', {encoding: 'utf-8'})
baseCode = baseCode.replace(/require\("miniprogram-render"\)/g, 'require("../miniprogram-render/index")')
fs.writeFileSync('./dist/miniprogram-element/base.js', baseCode)

// Utils

class Utils {
    static replaceKeywords(path, ori, to) {
        const files = fs.readdirSync(path)
        files.forEach(it => {
            const filePath = `${path}/${it}`
            const statResult = fs.statSync(filePath)
            if (statResult.isDirectory()) {
                this.replaceKeywords(filePath, ori, to)
            } else if (statResult.isFile()) {
                let fileContents = fs.readFileSync(filePath, {encoding: 'utf-8'})
                fileContents = fileContents.replace(new RegExp(ori, 'g'), to)
                fs.writeFileSync(filePath, fileContents)
            }
        })
    }

    static renameSubfix(path, ori, to) {
        const files = fs.readdirSync(path)
        files.forEach(it => {
            const filePath = `${path}/${it}`
            const statResult = fs.statSync(filePath)
            if (statResult.isDirectory()) {
                this.renameSubfix(filePath, ori, to)
            } else if (statResult.isFile() && filePath.endsWith(ori)) {
                fs.renameSync(filePath, filePath.replace(ori, to))
            }
        })
    }
}

// Copy to dist_weapp and sample_weapp
execSync('rm -rf ../mp_dom_runtime/dist_weapp/kbone')
execSync('cp -rf ./dist ../mp_dom_runtime/dist_weapp/kbone')
execSync('rm -rf ../mp_dom_runtime/sample_weapp/kbone')
execSync('cp -rf ./dist ../mp_dom_runtime/sample_weapp/kbone')

// Copy to dist_swan and dist_swanapp
execSync('rm -rf ../mp_dom_runtime/dist_swan/kbone')
execSync('cp -rf ./dist ../mp_dom_runtime/dist_swan/kbone')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 'wx:if', 's-if')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 'wx:else', 's-else')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 'wx:elif', 's-elif')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 'wx:for="\\{\\{(.*?)\\}\\}"', 's-for="$1"')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 's-for="(.*?)" wx:key="(.*?)"', 's-for="$1 trackBy $2"')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 'wx:for-item', 's-for-item')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 'data="\\{\\{(.*?)\\}\\}"', 'data="{{{$1}}}"')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', 'wx\\.', 'swan.')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', '.wxml', '.swan')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', '.miniprogram-root >>> ', '')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', '<template s-elif="(.*?)" (.*?)/>', '<block s-elif="$1"><template $2/></block>')
Utils.replaceKeywords('../mp_dom_runtime/dist_swan/kbone', '<template s-if="(.*?)" (.*?)/>', '<block s-if="$1"><template $2/></block>')
Utils.renameSubfix('../mp_dom_runtime/dist_swan/kbone', '.wxml', '.swan')
Utils.renameSubfix('../mp_dom_runtime/dist_swan/kbone', '.wxss', '.css')
execSync('rm -rf ../mp_dom_runtime/sample_swanapp/kbone')
execSync('cp -rf ../mp_dom_runtime/dist_swan/kbone ../mp_dom_runtime/sample_swanapp/kbone')

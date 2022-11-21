rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MPDOM > ./mpdom.js
browserify --external "mp-custom-components" index.miniprogram.js --standalone MPDOM > ./mpdom.miniprogram.js
cd ..
node scripts/inject_global.js

# Build web
node scripts/change_env.js __MP_TARGET_BROWSER__
terser --compress --mangle -- ./dist/mpdom.js.__MP_TARGET_BROWSER__ > ./dist/mpdom.min.js
cp ./dist/mpdom.min.js ../mpflutter_sample/web/mpdom.min.js
cp ./dist/mpdom.min.js dist_web/mpdom.min.js

# Build weapp
node scripts/change_env.js __MP_TARGET_WEAPP__
terser --compress --mangle -- ./dist/mpdom.js.__MP_TARGET_WEAPP__ > ./dist/mpdom.min.js
cp ./dist/mpdom.min.js ../mpflutter_sample/weapp/mpdom.min.js
cp ./dist/mpdom.min.js dist_weapp/mpdom.min.js

## Clean
rm -rf dist
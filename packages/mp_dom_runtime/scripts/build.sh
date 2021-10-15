rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MPDOM > ./mpdom.js
browserify index.miniprogram.js --standalone MPDOM > ./mpdom.miniprogram.js
cd ..

# Build web
node scripts/change_env.js __MP_TARGET_BROWSER__
terser --compress --mangle -- ./dist/mpdom.js.__MP_TARGET_BROWSER__ > ./dist/mpdom.min.js
cp ./dist/mpdom.min.js sample_web/mpdom.min.js
cp ./dist/mpdom.min.js dist_web/mpdom.min.js

# Build weapp
node scripts/change_env.js __MP_TARGET_WEAPP__
terser --compress --mangle -- ./dist/mpdom.js.__MP_TARGET_WEAPP__ > ./dist/mpdom.min.js
cp ./dist/mpdom.min.js sample_weapp/mpdom.min.js
cp ./dist/mpdom.min.js dist_weapp/mpdom.min.js

# Build swanapp
node scripts/change_env.js __MP_TARGET_SWANAPP__
terser --compress --mangle -- ./dist/mpdom.js.__MP_TARGET_SWANAPP__ > ./dist/mpdom.min.js
cp ./dist/mpdom.min.js sample_swanapp/mpdom.min.js
cp ./dist/mpdom.min.js dist_swan/mpdom.min.js

## Clean
rm -rf dist
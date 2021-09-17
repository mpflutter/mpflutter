# Build web
rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MPDOM > ../mpdom.js
uglifyjs ../mpdom.js -c -m > ../mpdom.min.js
cd ..
cp mpdom.min.js sample_web/mpdom.min.js
cp mpdom.min.js dist_web/mpdom.min.js
rm -rf dist

# Build weapp
rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MPDOM > ../mpdom.js
uglifyjs ../mpdom.js -c -m > ../mpdom.min.js
cd ..
cp mpdom.min.js sample_weapp/mpdom.min.js
cp mpdom.min.js dist_weapp/mpdom.min.js
rm -rf dist

# Build swanapp
rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MPDOM > ../mpdom.js
uglifyjs ../mpdom.js -c -m > ../mpdom.min.js
cd ..
cp mpdom.min.js sample_swanapp/mpdom.min.js
cp mpdom.min.js dist_swan/mpdom.min.js
rm -rf dist

## Clean
rm -rf dist
rm mpdom.js
rm mpdom.min.js
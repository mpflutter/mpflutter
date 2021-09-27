rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MPDOM > ../mpdom.js
uglifyjs ../mpdom.js -c -m > ../mpdom.min.js
cd ..

# Build web
cp mpdom.min.js sample_web/mpdom.min.js
cp mpdom.min.js dist_web/mpdom.min.js

# Build weapp
cp mpdom.min.js sample_weapp/mpdom.min.js
cp mpdom.min.js dist_weapp/mpdom.min.js

# Build swanapp
cp mpdom.min.js sample_swanapp/mpdom.min.js
cp mpdom.min.js dist_swan/mpdom.min.js

## Clean
rm -rf dist
rm mpdom.js
rm mpdom.min.js
# Build web
rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MP_WEB_FEATURES > ../mp_web_features.js
uglifyjs ../mp_web_features.js -c -m > ../mp_web_features.min.js
cd ..
cp mp_web_features.min.js ../../dist_web/mp_web_features.min.js
cp mp_web_features.min.js ../../sample_web/mp_web_features.min.js
rm -rf dist

## Clean
rm -rf dist
rm mp_web_features.js
rm mp_web_features.min.js
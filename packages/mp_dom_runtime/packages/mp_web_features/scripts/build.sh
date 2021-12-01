# Build web
rm -rf dist
mkdir dist
tsc
cd dist
browserify index.js --standalone MP_WEB_FEATURES > ../mp_web_features.js
uglifyjs ../mp_web_features.js -c -m > ../mp_web_features.min.js
cd ..
cp mp_web_features.min.js ../../dist_web/mp_web_features.min.js
cp mp_web_features.css ../../dist_web/mp_web_features.css
cp mp_web_features.min.js ../../../mpflutter_sample/web/mp_web_features.min.js
cp mp_web_features.css ../../../mpflutter_sample/web/mp_web_features.css
rm -rf dist

## Clean
rm -rf dist
rm mp_web_features.js
rm mp_web_features.min.js
set -e
if [ -n "`which node|grep 'not found'`" ]; then
echo "please use install node or nvm"
exit 1;
fi
if [ -z "`node --version|grep v16.`" ]; then
echo "please use node 16"
exit 2;
fi
if [ -n "`which browserify|grep 'not found'`" ] || [ -n "`which tsc|grep 'not found'`" ] || [ -n "`which terser|grep 'not found'`" ]; then
echo "Install dependencies"
npm install -g browserify uglify-js typescript terser
fi
cd packages/mp_dom_runtime/
npm install
npm run build
cd packages/mp_web_features
npm install
npm run build
cd ../../
cd ../mp_kbone
npm install
npm run build
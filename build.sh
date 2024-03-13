#!/bin/bash
# This script is modified from https://github.com/ivan-hc/Chrome-appimage/raw/fe079615eb4a4960af6440fc5961a66c953b0e2d/chrome-builder.sh

APP=microsoft-edge
VARIANT=${VARIANT:-stable}  # "stable", "beta" or "dev"

mkdir ./${VARIANT}
cd ./${VARIANT}
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$(uname -m).AppImage -O appimagetool
chmod a+x ./appimagetool

wget "${URL}"
ar x ./*.deb
tar xf ./data.tar.xz
mkdir $APP.AppDir
mv ./opt/microsoft/msedge*/* ./$APP.AppDir/
mv ./usr/share/applications/*.desktop ./$APP.AppDir/
sed -i "s#/usr/bin/microsoft-edge#microsoft-edge#g" ./$APP.AppDir/*.desktop

if [ "$VARIANT" = "stable" ]; then
    cp ./$APP.AppDir/*logo_128*.png ./$APP.AppDir/$APP.png
    cd ./$APP.AppDir
    ln -sf microsoft-edge microsoft-edge-$VARIANT
    cd ..
else
    cp ./$APP.AppDir/*logo_128*.png ./$APP.AppDir/$APP-$VARIANT.png
    cd ./$APP.AppDir
    ln -sf microsoft-edge-$VARIANT microsoft-edge
    cd ..
fi

echo "Create a tarball"
cd ./$APP.AppDir
tar cJvf ../$APP-${VARIANT}-$VERSION-x86_64.tar.xz .
cd ..
mv ./$APP-${VARIANT}-$VERSION-x86_64.tar.xz ..

echo "Create an AppImage"
cat >> ./$APP.AppDir/AppRun << 'EOF'
#!/bin/sh
APP=microsoft-edge
HERE="$(dirname "$(readlink -f "${0}")")"
export UNION_PRELOAD="${HERE}"
exec "${HERE}"/$APP "$@"
EOF
chmod a+x ./$APP.AppDir/AppRun

ARCH=x86_64 ./appimagetool -n --verbose ./$APP.AppDir ../$APP-${VARIANT}-$VERSION-x86_64.AppImage
cd ..
rm -rf ./${VARIANT}

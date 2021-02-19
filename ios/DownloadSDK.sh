# Download ZegoExpressEngine

echo "\n[*] Start downloading the latest version of ZegoExpressEngine SDK...\n"

SRCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SDKURL="https://storage.zego.im/express/video/apple/zego-express-video-apple.zip"

cd $SRCROOT
echo "[*] cd into: "`pwd`

if [ ! -d "Libs/__sdk_download_tmp__" ]; then
    mkdir Libs/__sdk_download_tmp__
fi

echo "[*] Downloading SDK from: $SDKURL"
curl "$SDKURL" --output Libs/__sdk_download_tmp__/zego-express-video-apple.zip

cd Libs/__sdk_download_tmp__
echo "[*] cd into: "`pwd`

echo "[*] Unzip zego-express-video-apple.zip"
unzip -o zego-express-video-apple.zip

for element in `ls`; do
    dir=$element
    if [ -d $dir ]; then
        cd $dir
        echo "[*] cd into: "`pwd`
        break
    fi
done

echo "[*] Remove folder: $SRCROOT/Libs/ZegoExpressEngine.xcframework"
rm -rf $SRCROOT/Libs/ZegoExpressEngine.xcframework

echo "[*] Move ZegoExpressEngine.xcframework from: "`pwd`" to: $SRCROOT/Libs"
mv ZegoExpressEngine.xcframework $SRCROOT/Libs

echo "[*] Remove folder: $SRCROOT/Libs/__sdk_download_tmp__"
rm -rf $SRCROOT/Libs/__sdk_download_tmp__

echo "\n[*] Success!\n"
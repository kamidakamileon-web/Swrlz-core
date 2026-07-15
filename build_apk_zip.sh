#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
ANDROID_PROJECT_DIR="$REPO_ROOT/SWRLZ_NODE_HOST"
OUTPUT_DIR="$REPO_ROOT/apk-package"
APK_PATH="$ANDROID_PROJECT_DIR/app/build/outputs/apk/debug/app-debug.apk"
ZIP_NAME="swrlz-node-host-apk-latest-source.zip"

mkdir -p "$OUTPUT_DIR"

cd "$ANDROID_PROJECT_DIR"

if [[ ! -x "./gradlew" ]]; then
  echo "Error: gradlew not found or not executable in $ANDROID_PROJECT_DIR"
  exit 1
fi

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_SDK_ROOT="$REPO_ROOT/android-sdk-local"

./gradlew --no-daemon assembleDebug -Dorg.gradle.jvmargs='-Xmx1024m -XX:MaxMetaspaceSize=512m'

if [[ ! -f "$APK_PATH" ]]; then
  echo "Error: APK not found at $APK_PATH" >&2
  exit 1
fi

cp "$APK_PATH" "$OUTPUT_DIR/"
cd "$OUTPUT_DIR"

source_zip_info=$(git -C "$REPO_ROOT" log --pretty=format:'%h %s' -n 1 -- .)
cat > build-source.txt <<EOF
Latest source update:
$source_zip_info
EOF
zip -j "$ZIP_NAME" "$(basename "$APK_PATH")" build-source.txt

echo "Created $OUTPUT_DIR/$ZIP_NAME"

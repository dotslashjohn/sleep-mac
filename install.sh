#!/bin/zsh
# Builds SleepToggle.app from main.swift into ~/Applications and launches it.
# Only needed to (re)install after editing main.swift.
set -e
cd "$(dirname "$0")"
APP="$HOME/Applications/SleepToggle.app"
pkill -x SleepToggle 2>/dev/null || true
mkdir -p "$APP/Contents/MacOS"
cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>SleepToggle</string>
  <key>CFBundleIdentifier</key><string>local.sleeptoggle</string>
  <key>CFBundleExecutable</key><string>SleepToggle</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSUIElement</key><true/>
</dict></plist>
PLIST
swiftc -O main.swift -o "$APP/Contents/MacOS/SleepToggle"
codesign -s - --force "$APP"
open "$APP"
echo "Installed and launched $APP"

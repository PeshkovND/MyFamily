#!/bin/sh

set -e

SWIFTLINT_VERSION="swiftlint-0.52.2-macos"
SWIFTLINT="../Tools/Swiftlint/$SWIFTLINT_VERSION/bin/swiftlint"

echo "Swiftlint path=$SWIFTLINT"

if which $SWIFTLINT >/dev/null; then

    # Run swiftlint only for debug configuration
    if [ "${CONFIGURATION}" = "Debug" ]; then
        $SWIFTLINT
    fi

else
    echo "Error: SwiftLint is not installed. More Info: https://github.com/realm/SwiftLint"
    exit 1
fi

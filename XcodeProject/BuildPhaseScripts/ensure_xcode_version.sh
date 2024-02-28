#!/bin/sh

XCODE_VERSION_CONSTRAINT="1520"

echo "Max Allowed Xcode Version = ${XCODE_VERSION_CONSTRAINT}"
echo "Current Xcode Version = ${XCODE_VERSION_ACTUAL}"

 if [ $XCODE_VERSION_ACTUAL -gt $XCODE_VERSION_CONSTRAINT ]; then
     echo "🛑 Error: Curent Xcode Version ${XCODE_VERSION_ACTUAL} must be equal to ${XCODE_VERSION_CONSTRAINT}"
     return -1
 fi

# Table of Content

- [App description](#App-description)
- [Project Setup](#Project-Setup)
- [Technical Roadmap](#Technical-Roadmap)
- [iOS Team](#iOS-Team)
- [Links](#Links)

## App description

TBD

### App key features

TBD


### About project

Check out project websites - TBD


## Project Setup

### Used Environment

- macOS {Version}
- Xcode: {Version}
- Swift: {Version}


### Supported platforms

Project uses iOS `15.0` as deployment target (minimal iOS version) which defines the list of [compatible devices](https://support.apple.com/en-en/guide/iphone/iphe3fa5df43/15.0/ios/15.0). So the app can be run on devices since `iPhone 6s`.

The app is targeted to be run primarily on iPhones. iPad/iPod are supported in Compatibility mode which means that is the app is not univarsal and adaptive layuot is not supported for iPad/iPod. MacOs is not supported as well.

Device orientatation is resticted to `Portrait` mode without handling of rotation.


### Initial setup 

Clone project to some folder. For example, open `Terminal.app` and run the command:
````bash
git clone git@github.com:{project url}
````
Project uses [Swift Package Manager (SPM)](https://swift.org/package-manager/) as a primary dependency manager. SPM installs its dependencies automatically when you open project.

After that, open project using project file `XcodeProject/App.xcodeproj`.

Used 3rd party libraries and frameworks:
- [SPM dependency list](XcodeProject/App.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved)

### [Outdated] Xcode templates
*⚠️ Only works for App target, not SPM modules*

To install xcode templates for screen run command from terminal:
```bash
sudo cp -r Tools/ScreenXcodeTemplate.xctemplate "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Templates/Project Templates/iOS/Application"
```

## Technical Roadmap

- [ ] TBD


## iOS Team

- {First last name, email}

## Links
- [App Architecture](Docs/Architecture.md)
- [API Docs](TBD)
- [AppStore Connect](https://appstoreconnect.apple.com/)
- [Apple Developer Console](https://developer.apple.com/account/#/membership)
- [Slack](TBD)
- [JIRA Board](TBD)
- [CI/CD](TBD)
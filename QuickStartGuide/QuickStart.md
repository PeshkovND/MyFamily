# Quick Start Guide

## Table of Content

- [Preconditions](#Preconditions)
- [Overview](#Overview)
- [Set up Git](#Set-up-Git)
- [Copy Template Project](#Copy-Template-Project)
- [Replace copyrights](#Replace-Copyrights)
- [Configure Project](#Configure-Project)
- [Project Examples](#Project-Examples)
  - [Asynchronous Approach](#Asynchronous-Approach)
  - [Networking](#Networking)
  - [Data Layer](#Data-Layer)
  - [Logging](#Logging)
  - [Debug Menu](#Debug-Menu)
  - [DevTools](#DevTools)
  - [Dependency Management](#Dependency-Management)
  - [Support Tools](#Support-Tools)
  - [Screen Navigation](#Screen-Navigation)
  - [Building Screen](#Building-Screen)
  - [Project README](#Project-README)


## Preconditions
- You should have a cloned empty project repo or you need to create new one
- You should have installed Xcode
- You should have access to Project Developer Team to be able working with certificates, identifiers & profiles.

## Overview
1. [Set up Git](#Set-up-Git)
1. [Copy Template Project](#Copy-Template-Project)
1. [Replace copyrights](#Replace-Copyrights)
1. [Configure Project](#Configure-Project)
1. [Get Familiar with Project Examples](#Project-Examples)

## Set up Git
- Set up [git user](https://github.com/effectiveband/Collaboration-Guidelines/blob/master/VersionControl.md#prepare-account)
- Configure [git workflow](https://www.notion.so/effectiveband/iOS-Effective-Branching-Model-2fb7b4ed83c54cf49b5b36a3f5fa108e)
    - You should have main and develop branches
    - You should use feature branch and PRs for changing codebase 

## Copy Template Project

- Download `TemplateProject` from [here](./TemplateProject.zip)
- Unzip archive
- Put content of `TemplateProject` folder to git repo

## Replace Copyrights
You can use any text editor.

Open root project folder in text editor and replace string:
```
//  Copyright © 2021 Krasavchik OOO. All rights reserved.
```
to:
```
//  Copyright © 2021 YouCompanyName. All rights reserved.
```

## Configure Project

Open project file `App.xcodeproj`.

### Build Configurations

There are 4 [xcconfig files](https://nshipster.com/xcconfig/) in folder `App/xcconfigs` that allow to adjust build parameters.

- Debug.xcconfig
  
  It'used within `AppDevelopment` scheme for Run, Test and Analyze actions. Think of it as local development config.

- QaRelease.xcconfig
  
  It'used within `AppDevelopment` scheme for Profile and Archive actions. Think of it as config for QA builds.

- DebugProduction.xcconfig

  It'used within `AppProduction` scheme for Run, Test and Analyze actions. Think of it as config for debugging production builds.

- ProductionRelease.xcconfig

  It'used within `AppProduction` scheme for Profile and Archive actions. Think of it as config for release build for production.

### Set Build Configs

*You can extend any build config values via `xcconfig`. Use [documentation]((https://nshipster.com/xcconfig/)) for deep diving into it.*

Example of debug config:
  ```
//--------------------
// App settings
//--------------------
APP_DISPLAY_NAME = App (Debug)
APP_BUILD_TYPE = debug // production, qa

APP_API_STAGING = https:/$()/api.apptemplate.effective.band
APP_API_PRODUCTION = https:/$()/api.apptemplate.effective.band

//--------------------
// Override settings
//--------------------
PRODUCT_BUNDLE_IDENTIFIER = band.effective.apptemplate
DEVELOPMENT_TEAM = JVX7U43WRX

SWIFT_ACTIVE_COMPILATION_CONDITIONS = $(inherited) FLEX_ENABLED
```

There are two sections in config:
- custom build settings
- overidden existing build settings

So, you need to provide
- `APP_DISPLAY_NAME` - Name of application displayed on home screen
- `APP_BUILD_TYPE` - Build type in terms of debug/qa/production
- `APP_API_STAGING` - Base url for staging API
- `APP_API_PRODUCTION` - Base url for production API
- `PRODUCT_BUNDLE_IDENTIFIER` - Application bundle id
- `DEVELOPMENT_TEAM` - Development team id which is used for automatic code signing. You can find it on Membership page of Apple Developer Console (for instance).
- `SWIFT_ACTIVE_COMPILATION_CONDITIONS` - Custom compilation conditions.

Save files changes.

Allow xcode to finish updating project and that's it. 

Your project is ready for development! 🎉

Feel free to remove any components you don't need for your project.

## Project Examples

Get familiar with project examples to reuse code base and ideas, follow guidelines.

Project consist of some modules. You can read more details in [Architecture](../Docs/Architecture.md) page.

### Providing Components

There is `AppContainer.swift` in App module to store dependency graph and provide specific depdendecies

### Asynchronous Approach

The most API of components uses Function Reactive Programming (FRP) concept based on iOS Combine framework but some of components still uses old good callback-based api as well.

### Networking

Use `AlamofireHttpClient` for making http requests. It's based on Alamofire library.

API implementation is stored in `AppServices` module.
Use `HttpRequestFactory` for building requests. Also you can find here examples for core network resonse models, network mapping, alamofire authenticator, network error model.

### Data Layer

Repository pattern is used for making abstraction for access data. You can take a look at `AccountRepository` for details.

### Logging

Use app loggers provided by LoggerFactory. [os logging](https://developer.apple.com/documentation/os/logging) is used as implementation.

### Debug Menu

There is added debug menu in the app. You can open it by swiping from right side on any screen.

You can define any content you'd like. Extend `DebugView.swift` or implement new and provide for `InAppDebugger`.

Currenlty you can
- Switch API environments.
- Manage local debug toggles
- Show App Color Pallete
- Do force logout. You still need to implement API calls

Also you'll find here examples for ui components.

### DevTools

There is folder in app module with developer tools. Debug menu is one of them. There are also
- `FakeAuthService` used to fake auth process
- `DebugTogglesHolder` for managing local debug feature on device. 

  *Use case 1: you can use feature toggle to run only flow you wokring on and you don't need to go through whole app to get screen you need to make.*
  
  *Use case 2: you didn't finish feature yet but you'd like to merge changes to dev branch. So you can use feature toggle to disable feature and not break other features.*

  More info for inspiration: https://martinfowler.com/articles/feature-toggles.html

- `StubFlowCoordinator` for rapid prototying and adding stubs
- Demo screens like color pallete, ui compoments.

### Dependency Management

Recomentations:
- Use Swift Package Manager as primary DM

Specific 3rd party dependencies is described in [README Initial setup section](../README.md#Initial-setup)

### Support Tools

- [Swiftlint](https://github.com/realm/SwiftLint) is used to enforce Swift style and conventions.

  `.swiftlint.yml` config can be found in XcodeProject folder. Binary executable file is add to repo (`Tools` folder)

- [.gitignore](../.gitignore) file to manage git tracking.

- [GitHub Pull Request Template](../.github/PULL_REQUEST_TEMPLATE.md) to keep the unified style for PRs
  [More info on GitHub](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates)
  
### Screen Navigation

Coordinator idea is used for managing user flow. 

Examples of flows (Welcome, Signup, HomeFlow) is placed in Flow module in `AppModulesPackage`.

`AppCoordinator.swift` is root coordinator that manage top level flows.

Current implementation is based on [this example](https://medium.com/blacklane-engineering/coordinators-essential-tutorial-part-i-376c836e9ba7)

### Building Screen

MVVM pattern is used for presentation layer. 
- `Context` file containing view events, view states, screen output events and screen errors.
- `Content view` file where screen layout is defined
- `View Controller` file where view binding and rendering states are defined
- `ViewModel` file where presentation logic lives. View Model use interactors, app services or repositories to access data and running actions. Also ViewModel sends screen output event.


### Project README

Read Project [README](../README.md) and use it as template for main project documentation by filling TBD section for specific you project.
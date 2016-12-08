[![Version](https://img.shields.io/cocoapods/v/XCGLoggerNSLoggerConnector.svg?style=flat)](https://cocoapods.org/pods/XCGLoggerNSLoggerConnector)
[![License](https://img.shields.io/cocoapods/l/XCGLoggerNSLoggerConnector.svg?style=flat)](https://cocoapods.org/pods/XCGLoggerNSLoggerConnector)
[![Platform](https://img.shields.io/cocoapods/p/XCGLoggerNSLoggerConnector.svg?style=flat)](https://cocoapods.org/pods/XCGLoggerNSLoggerConnector)

#XCGLoggerNSLoggerConnector
#####By: Markus Winkler
- Twitter: [@CreativeGun](https://twitter.com/creativegun)

###tl;dr
Adds NSLogger support (with images) to XCGLogger.

###Compatibility

XCGLoggerNSLoggerConnector works for iOS projects. It is a Swift library intended for use in Swift projects.

###How to Use

In your AppDelegate, declare a global constant to the default XCGLogger instance.

```Swift
import XCGLogger
import NSLogger
import XCGLoggerNSLoggerConnector

let log: XCGLogger = {
    let log = XCGLogger.defaultInstance()
    log.setup(.Debug, showThreadName: false, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: .Debug)

    // NSLogger support
    // only log to the external window
    LoggerSetOptions(LoggerGetDefaultLogger(), UInt32( kLoggerOption_BufferLogsUntilConnection | kLoggerOption_BrowseBonjour | kLoggerOption_BrowseOnlyLocalDomain ))
    LoggerStart(LoggerGetDefaultLogger())
    log.add(destination: XCGNSLoggerLogDestination(owner: log, identifier: "nslogger.identifier"))

    return log
}()
```

You can also specify to display inline the file & function name (personal preference, makes it slightly easier to read where the call is coming from).
```
    log.add(destination: XCGNSLoggerLogDestination(owner: log, identifier: "nslogger.identifier", addInlineDebugInfo: true))
```

Now all levels accept an UIImage as a parameter and will output the content to the NSLogger window as an image.

``` Swift
log.verbose(image)
log.debug(image)
log.info(image)
log.warning(image)
log.error(image)
log.severe(image)
```

There is a new filter command, "customLabel". You can use that one to add your own label to filter later on in the NSLogger client.
The default value is "image" for image and "string" for string.
Use it to distinguish between different kinds of images or outputs (e.g. database results)
``` Swift
log.customLabel(image, label: "facebook icon")
log.customLabel(String(databaseOutput), label: "Database")
```
**Note**: the logLevel for customLabels is Info (3)


###References

You can find more info on XCGLogger/NSLogger (documentation and setup) here:
XCGLogger: https://github.com/DaveWoodCom/XCGLogger
NSLogger: https://github.com/fpillet/NSLogger  

###Change Log
* **Version 0.3.0**: *(2016/12/08)* - Xcode 8.1 support. Upgrade to iOS 9.
* **Version 0.2.0**: *(2016/11/23)* - Update for Swift 3
* **Version 0.1.4**: *(2016/08/23)* - added XCGLogger limit <= 3.3 since any version above will break this connector
* **Version 0.1.3**: *(2016/06/08)* - fixes
* **Version 0.1.2**: *(2016/02/15)* - added a switch to display additional debug info inline
* **Version 0.1.1**: *(2015/11/20)* - Initial Release


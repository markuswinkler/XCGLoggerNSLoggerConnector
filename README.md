#XCGLoggerNSLoggerConnector
#####By: Markus Winkler
- Twitter: [@CreativeGun](https://twitter.com/creativegun)

###tl;dr
Adds NSLogger support (with images) to XCGLogger.

###Compatibility

XCGLoggerNSLoggerConnector works in both iOS and OS X projects. It is a Swift library intended for use in Swift projects.

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
    log.addLogDestination(XCGNSLoggerLogDestination(owner: log, identifier: "nslogger.identifier"))

    return log
}()
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

* **Version 0.1.1**: *(2015/11/20)* - Initial Release


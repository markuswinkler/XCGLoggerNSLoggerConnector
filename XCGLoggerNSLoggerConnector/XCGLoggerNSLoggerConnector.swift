//
//  XCGLoggerSupport.swift
//  adds support for NSLogger in XCGLogger
//
//  add the line below to the init code in appDelegate
//  log.addLogDestination(XCGNSLoggerLogDestination(owner: log, identifier: "nslogger.identifier", addInlineDebugInfo: false))
//
//  New custom image level, accepts UIImage
//  Label is default set to "image", can be used to indicate e.g. source ("facebook", "imgur")
//  -- log.image(image)
//  -- log.image(image, label: "facebook")
//
//  All report levels support now UIImage
//  -- log.info(image)
//
//  New custom text report level to group functional reports
//  log.customLabel("Userdata: \(db.user)", label: "Database")
//
//  Created by Markus on 11/17/15.
//  Copyright © 2015 Markus Winkler. All rights reserved.
//

import XCGLogger
import NSLogger

public class XCGNSLoggerLogDestination: XCGBaseLogDestination {
    
    // use this variable to show file/functioname in the same line with the message
    // (just a personal preference, let me see the flow of the application better)
    public var addInlineDebugInfo: Bool = false
    
    // Report levels are different in NSLogger (0 = most important, 4 = least important)
    // XCGLogger level needs to be converted to use the bonjour app filtering in a meaningful way
    private func convertLogLevel(level:XCGLogger.LogLevel) -> Int32 {
        switch(level) {
        case .Severe:
            return 0
        case .Error:
            return 1
        case .Warning:
            return 2
        case .Info:
            return 3
        case .Debug:
            return 4
        case .Verbose:
            return 5
        case .None:
            return 3
        }
    }
    
    public init(owner: XCGLogger, identifier: String, addInlineDebugInfo: Bool = false) {
        super.init(owner: owner, identifier: identifier)
        self.addInlineDebugInfo = addInlineDebugInfo
    }
    
    public override func output(logDetails: XCGLogDetails, text: String) {
        
        switch(logDetails.logLevel) {
        case .None:
            return
        default:
            break
        }
        
        if addInlineDebugInfo {
            LogMessageF_va(logDetails.fileName, Int32(logDetails.lineNumber), logDetails.functionName, logDetails.logLevel.description, Int32(convertLogLevel(logDetails.logLevel)), "[\(NSString(string: logDetails.fileName).lastPathComponent):\(logDetails.lineNumber)] -> \(logDetails.functionName) : \(logDetails.logMessage)", getVaList([]))
        } else {
            LogMessageF_va(logDetails.fileName, Int32(logDetails.lineNumber), logDetails.functionName, logDetails.logLevel.description, Int32(convertLogLevel(logDetails.logLevel)), logDetails.logMessage, getVaList([]))
        }
        
    }
}

public extension XCGLogger {

    // declared here again for performance reasons
    private func convertLogLevel(level:LogLevel) -> Int32 {
        switch(level) {
        case .Severe:
            return 0
        case .Error:
            return 1
        case .Warning:
            return 2
        case .Info:
            return 3
        case .Debug:
            return 4
        case .Verbose:
            return 5
        case .None:
            return 3
        }
    }

    private func sendImageToNSLogger(image: UIImage?, level: LogLevel, label: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        // check if image is valid, otherwise display error
        if let image: UIImage = image {
            LogImageDataF(fileName, Int32(lineNumber), functionName, label, convertLogLevel(level), Int32(image.size.width), Int32(image.size.height), UIImagePNGRepresentation(image))
            self.logln(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: {return "Image: \(image)"})
        }
        else {
            self.logln(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: {return "Invalid Image: \(image)"})
        }
    }

    public func customLabel(@autoclosure closure: () -> UIImage?, label: String = "image", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        // check if image is valid, otherwise display error
        var arr = fileName.componentsSeparatedByString("/")
        var fileName2 = fileName
        if let last = arr.popLast() {
            fileName2 = last
        }
        let level = LogLevel.None
        if let image: UIImage = closure() {
            LogImageDataF(fileName, Int32(lineNumber), functionName, label, convertLogLevel(level), Int32(image.size.width), Int32(image.size.height), UIImagePNGRepresentation(image))
            LogMessageF_va(fileName, Int32(lineNumber), functionName, label, Int32(convertLogLevel(level)), "\(image)", getVaList([]))
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "Image: \(image)"})
        }
        else {
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "Invalid Image: \(closure())"})
        }
    }

    public func customLabel(@autoclosure closure: () -> String?, label: String = "string", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = LogLevel.None
        var arr = fileName.componentsSeparatedByString("/")
        var fileName2 = fileName
        if let last = arr.popLast() {
            fileName2 = last
        }

        if let message = closure() {
            LogMessageF_va(fileName, Int32(lineNumber), functionName, label, Int32(convertLogLevel(level)), "\(message)", getVaList([]))
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "[\(label)] \(message)"})
        }
        else
        {
            LogMessageF_va(fileName, Int32(lineNumber), functionName, label, Int32(convertLogLevel(level)), "nil", getVaList([]))
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "[\(label)] nil"})
        }
    }

    public func verbose(@autoclosure closure: () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = LogLevel.Verbose
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func debug(@autoclosure closure: () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = LogLevel.Debug
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func info(@autoclosure closure: () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = LogLevel.Info
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func warning(@autoclosure closure: () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = LogLevel.Warning
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func error(@autoclosure closure: () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = LogLevel.Error
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func severe(@autoclosure closure: () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = LogLevel.Severe
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

}
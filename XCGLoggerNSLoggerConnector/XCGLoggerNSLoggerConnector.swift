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

public class XCGNSLoggerLogDestination: BaseDestination {
    
    // use this variable to show file/functioname in the same line with the message
    // (just a personal preference, let me see the flow of the application better)
    public var addInlineDebugInfo: Bool = false
    
    // Report levels are different in NSLogger (0 = most important, 4 = least important)
    // XCGLogger level needs to be converted to use the bonjour app filtering in a meaningful way
    private func convertLogLevel(_ level:XCGLogger.Level) -> Int32 {
        switch(level) {
        case .severe:
            return 0
        case .error:
            return 1
        case .warning:
            return 2
        case .info:
            return 3
        case .debug:
            return 4
        case .verbose:
            return 5
        case .none:
            return 3
        }
        let x:FileDestination!
    }
    
	public init(owner: XCGLogger, identifier: String, addInlineDebugInfo: Bool = false, outputLevel: XCGLogger.Level = .debug) {
        super.init(owner: owner, identifier: identifier)
        self.addInlineDebugInfo = addInlineDebugInfo
		self.outputLevel = outputLevel
    }
    
    open override func output(logDetails: LogDetails, message: String) {
        
        switch(logDetails.level) {
        case .none:
            return
        default:
            break
        }

        let domain = logDetails.userInfo[Constants.userInfoKeyDomain] as? String ?? logDetails.level.description
        if let image = logDetails.userInfo[Constants.userInfoKeyImage] as? UIImage {
            LogImageDataF(logDetails.fileName, Int32(logDetails.lineNumber), logDetails.functionName, domain, convertLogLevel(logDetails.level), Int32(image.size.width), Int32(image.size.height), UIImagePNGRepresentation(image))
        }

        if addInlineDebugInfo {
            LogMessageF_va(logDetails.fileName, Int32(logDetails.lineNumber), logDetails.functionName, domain, Int32(convertLogLevel(logDetails.level)), "[\(NSString(string: logDetails.fileName).lastPathComponent):\(logDetails.lineNumber)] -> \(logDetails.functionName) : \(logDetails.message)", getVaList([]))
        } else {
            LogMessageF_va(logDetails.fileName, Int32(logDetails.lineNumber), logDetails.functionName, domain, Int32(convertLogLevel(logDetails.level)), logDetails.message, getVaList([]))
        }
        
    }
    
    public struct Constants {
        /// Prefix identifier to use for all other identifiers
        public static let baseIdentifier = "xcglogger.nslogger"
        
        /// UserInfo Key - domain
        public static let userInfoKeyDomain = "\(baseIdentifier).domain"
        
        /// UserInfo Key - image
        public static let userInfoKeyImage = "\(baseIdentifier).image"
    }

}

public extension XCGLogger {

    // declared here again for performance reasons
    private func convertLogLevel(_ level:XCGLogger.Level) -> Int32 {
        switch(level) {
        case .severe:
            return 0
        case .error:
            return 1
        case .warning:
            return 2
        case .info:
            return 3
        case .debug:
            return 4
        case .verbose:
            return 5
        case .none:
            return 3
        }
    }

    public func sendImageToNSLogger(_ image: UIImage?, level: Level, label: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        // check if image is valid, otherwise display error
        if let image: UIImage = image {
            #if swift(>=4.2)
                let png = image.pngData()
            #else
                let png = UIImagePNGRepresentation(image)
            #endif
            
            LogImageDataF(fileName, Int32(lineNumber), functionName, label, convertLogLevel(level), Int32(image.size.width), Int32(image.size.height), png)
            self.logln(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: {return "Image: \(image)"})
        }
        else {
            self.logln(level, functionName: functionName, fileName: fileName, lineNumber: lineNumber, closure: {return "Invalid Image: \(String(describing: image))"})
        }
    }

    public func customLabel(_ closure: @autoclosure () -> UIImage?, label: String = "image", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        // check if image is valid, otherwise display error
        var arr = fileName.components(separatedBy: "/")
        var fileName2 = fileName
        if let last = arr.popLast() {
            fileName2 = last
        }
        let level = XCGLogger.Level.none
        if let image: UIImage = closure() {
            #if swift(>=4.2)
                let png = image.pngData()
            #else
                let png = UIImagePNGRepresentation(image)
            #endif

            LogImageDataF(fileName, Int32(lineNumber), functionName, label, convertLogLevel(level), Int32(image.size.width), Int32(image.size.height), png)
            LogMessageF_va(fileName, Int32(lineNumber), functionName, label, Int32(convertLogLevel(level)), "\(image)", getVaList([]))
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "Image: \(image)"})
        }
        else {
            self.logln(level, functionName: functionName, fileName: fileName2, lineNumber: lineNumber, closure: {return "Invalid Image: \(String(describing: closure()))"})
        }
    }

    public func customLabel(_ closure: @autoclosure () -> String?, label: String = "string", functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = XCGLogger.Level.none
        var arr = fileName.components(separatedBy: "/")
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

    public func verbose(_ closure: @autoclosure () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = XCGLogger.Level.verbose
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func debug(_ closure: @autoclosure () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = XCGLogger.Level.debug
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func info(_ closure: @autoclosure () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = XCGLogger.Level.info
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func warning(_ closure: @autoclosure () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = XCGLogger.Level.warning
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func error(_ closure: @autoclosure () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = XCGLogger.Level.error
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

    public func severe(_ closure: @autoclosure () -> UIImage?, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
        let level = XCGLogger.Level.severe
        sendImageToNSLogger(closure(), level: level, label: level.description, functionName: functionName, fileName: fileName, lineNumber: lineNumber)
    }

}

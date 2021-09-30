//
//  Shout.swift
//  LaibanApp-iOS
//
//  Created by Tomas Green on 2020-03-03.
//  Copyright © 2020 Evry AB. All rights reserved.
//

import Foundation
import Combine
import os.log

private func unwrap<T>(_ any: T) -> Any {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional, let first = mirror.children.first else {
        return any
    }
    return first.value
}

public protocol Shoutable {
    static var log:Shout.Publisher { get }
}

public class Shout: ObservableObject {
    public typealias Subject = PassthroughSubject<Event,Never>
    public typealias Publisher = AnyPublisher<Event,Never>
    public struct Event: Equatable {
        public enum Level : String, Equatable {
            case info
            case warning
            case error
            public var emoji:String {
                switch self  {
                case .info: return "ℹ️"
                case .warning: return "⚠️"
                case .error: return "🚫"
                }
            }
        }
        public let level:Level
        public let filename:String
        public let lineNumber:Int
        public let function:String
        public let message:String
        public let description:String
        public init (_ items: [Any], level:Level = .info, filename: String = #file, lineNumber: Int = #line, function: String = #function) {
            self.message = items.compactMap({ (item) -> String in
                return String(describing: unwrap(item))
            }).joined(separator: " ")
            self.level = level
            self.filename = filename
            self.lineNumber = lineNumber
            self.function = function
            self.description = "\(level.emoji) [" + String(filename.split(separator: "/").last ?? "NOFILE") + ":\(function):\(lineNumber)] " + message
        }
        public static func info(_ items: Any..., filename: String = #file, lineNumber: Int = #line, function: String = #function) -> Event {
            return Event(items, level:.info, filename: filename, lineNumber: lineNumber, function: function)
        }
        public static func warning(_ items: Any..., filename: String = #file, lineNumber: Int = #line, function: String = #function) -> Event {
            return Event(items, level:.warning, filename: filename, lineNumber: lineNumber, function: function)
        }
        public static func error(_ items: Any..., filename: String = #file, lineNumber: Int = #line, function: String = #function) -> Event {
            return Event(items, level:.error, filename: filename, lineNumber: lineNumber, function: function)
        }
    }

    
    public let category: String
    public var disabled = false
    private let logger: OSLog
    private var publishers = Set<AnyCancellable>()
    public init(_ category: String) {
        self.category = category
        self.logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "unknown app", category: category)
    }
    public func info(_ items: Any..., filename: String = #file, lineNumber: Int = #line, function: String = #function) {
        log(Event.info(items,filename: filename,lineNumber: lineNumber,function: function))
    }
    public func warning(_ items: Any..., filename: String = #file, lineNumber: Int = #line, function: String = #function) {
        log(Event.warning(items,filename: filename,lineNumber: lineNumber,function: function))
    }
    public func error(_ items: Any..., filename: String = #file, lineNumber: Int = #line, function: String = #function) {
        log(Event.error(items,filename: filename,lineNumber: lineNumber,function: function))
    }
    private func log(_ event:Event) {
        if disabled {
            return
        }
        os_log("%@", event.description)
    }
    public func attach(_ publisher:Publisher) {
        publisher.sink { [weak self] event in
            self?.log(event)
        }.store(in: &publishers)
    }
}

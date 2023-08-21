//
//  Utils.swift
//  testLocation
//
//  Created by Tomas Kafka on 05.08.2023.
//

import Foundation
import UserNotifications

public extension Array {
	/*
	 // If you need this, you need the lock version
	 mutating func removeAndReturnAll() -> [Element] {
	 let copy = self
	 removeAll()
	 return copy
	 }
	 */

	mutating func removeAndReturnAll(withLock lock: NSLock) -> [Element] {
		lock.lock()
		defer { lock.unlock() }
						
		let copy = self
		removeAll()
		return copy
	}
}

public struct CustomError: LocalizedError {
	public let message: String
	public let logMessage: String

	public init(_ message: String, log: String) {
		self.message = message
		self.logMessage = log
	}

	public init(_ message: String) {
		self.init(message, log: message)
	}
	
	public init(_ error: Error) {
		self.init(error.messageAndCode)
	}
}

public extension Error {
	var messageAndCode: String {
		let message: String
		if let customError = self as? CustomError {
			message = customError.message
		} else {
			message = localizedDescription
		}

		let codeExtra: String
		if let nsError = self as NSError? {
			codeExtra = " (#\(nsError.code))"
		} else {
			codeExtra = ""
		}

		return "\(message)\(codeExtra)"
	}
}

extension UNAuthorizationStatus: DebugPrintable {
	public func debug() -> String {
		switch self {
		case .notDetermined:
			return "notDetermined"
		case .denied:
			return "denied"
		case .authorized:
			return "authorized"
		case .provisional:
			return "provisional"
		case .ephemeral:
			return "ephemeral"
		@unknown default:
			return "unknown(\(self.rawValue))"
		}
	}
}

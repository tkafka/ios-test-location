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
		return switch self {
		case .notDetermined:
			"notDetermined"
		case .denied:
			"denied"
		case .authorized:
			"authorized"
		case .provisional:
			"provisional"
		case .ephemeral:
			"ephemeral"
		@unknown default:
			"unknown(\(self.rawValue))"
		}
	}
}

public extension UNAuthorizationStatus {
	func canPush() -> Bool {
		return switch self {
		case .authorized, .provisional, .ephemeral:
			true
		case .notDetermined, .denied:
			false
		@unknown default:
			false
		}
	}
}

extension Dictionary where Key == AnyHashable, Value == Any {
	func asJson() -> String {
		var jsonString = "{\n"
		for (key, value) in self {
			let valueString: String
			if let stringVal = value as? String {
				valueString = "\"\(stringVal)\""
			} else {
				valueString = "\(value)"
			}
			jsonString += "  \"\(key)\": \(valueString),\n"
		}
		jsonString = String(jsonString.dropLast(2)) // Remove trailing comma and newline
		jsonString += "\n}"
		return jsonString
	}
}

extension Dictionary where Key == String, Value == AnyObject {
	func asJson() -> String {
		var jsonString = "{\n"
		for (key, value) in self {
			let valueString: String = "\(value)"
			jsonString += "  \"\(key)\": \(valueString),\n"
		}
		jsonString = String(jsonString.dropLast(2)) // Remove trailing comma and newline
		jsonString += "\n}"
		return jsonString
	}
}

extension String {
	func asIsoDate() -> Date? {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.timeZone = TimeZone(secondsFromGMT: 0)
		// formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
		let date = formatter.date(from: self)
		return date
	}
}

extension Data {
	func asTokenString() -> String {
		let tokenParts = self.map { data in String(format: "%02.2hhx", data) }
		let token = tokenParts.joined()
		return token
	}
}

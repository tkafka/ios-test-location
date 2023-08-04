//
//  Logger.swift
//  testLocation
//
//  Created by Tomas Kafka on 04.08.2023.
//

import Foundation
import OSLog

extension Logger {
	/// Using your bundle identifier is a great way to ensure a unique identifier.
	private static var subsystem = Bundle.main.bundleIdentifier!

	static let location = Logger(subsystem: subsystem, category: "location")
	static let app = Logger(subsystem: subsystem, category: "app")
}

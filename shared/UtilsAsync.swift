//
//  UtilsAsync.swift
//  WeathergraphKit
//
//  Created by Tomas Kafka on 14.06.2023.
//

import Foundation

public extension Task where Success == Never, Failure == Never {
	static func sleep(interval: TimeInterval) async throws {
		try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
	}
	
	static func sleep(interval: DispatchTimeInterval) async throws {
		switch interval {
		case let .seconds(s):
			try await Task.sleep(nanoseconds: UInt64(s) * 1_000_000_000)
		case let .milliseconds(ms):
			try await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
		case let .microseconds(us):
			try await Task.sleep(nanoseconds: UInt64(us) * 1_000)
		case let .nanoseconds(ns):
			try await Task.sleep(nanoseconds: UInt64(ns))
		case .never:
			// Do nothing for .never
			break
		@unknown default:
			// Handle possible future cases
			break
		}
	}

	static func safeSleep(interval: DispatchTimeInterval) async {
		do {
			switch interval {
			case let .seconds(s):
				try await Task.sleep(nanoseconds: UInt64(s) * 1_000_000_000)
			case let .milliseconds(ms):
				try await Task.sleep(nanoseconds: UInt64(ms) * 1_000_000)
			case let .microseconds(us):
				try await Task.sleep(nanoseconds: UInt64(us) * 1_000)
			case let .nanoseconds(ns):
				try await Task.sleep(nanoseconds: UInt64(ns))
			case .never:
				// Do nothing for .never
				break
			@unknown default:
				// Handle possible future cases
				break
			}
		} catch {
			/// ignore = continue the next action
		}
	}
}

//
//  DebugPrintable.swift
//  Weathergraph Independent
//
//  Created by Tomas Kafka on 12.07.2021.
//  Copyright © 2021 Tomáš Kafka. All rights reserved.
//

import Foundation

public protocol DebugPrintable {
	func debug() -> String
}

public func debugPrint<T: DebugPrintable>(_ value: T?) -> String {
	if let value = value {
		return value.debug()
	} else {
		return "nil"
	}
}

extension Int: DebugPrintable {
	public func debug() -> String {
		return "\(self)"
	}
}

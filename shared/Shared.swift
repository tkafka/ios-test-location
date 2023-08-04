//
//  Shared.swift
//  testLocation
//
//  Created by Tomas Kafka on 04.08.2023.
//

import Foundation

// MARK: Action

public typealias Action = () -> Void
public typealias AsyncAction = () async -> Void
public typealias ArgAction<T> = (T) -> Void
public typealias ArgAction2<T1, T2> = (T1, T2) -> Void
public typealias InOutArgAction<T> = (inout T) -> Void

public typealias MaybeAction = Action?
public typealias MaybeArgAction<T> = ArgAction<T>?

// MARK: ForegroundOrBackground

public enum ForegroundOrBackground: DebugPrintable {
	case foreground, background
	
	public var isBackground: Bool {
		switch self {
		case .foreground:
			return false
		case .background:
			return true
		}
	}
	
	public func debug() -> String {
		switch self {
		case .foreground:
			return "foreground"
		case .background:
			return "background"
		}
	}
}

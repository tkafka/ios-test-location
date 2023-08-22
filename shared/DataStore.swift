//
//  DataStore.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation

public enum DataKey: String {
	case date
}

public class DataStore: ObservableObject {
	// MARK: Singleton

	static let shared = DataStore()

	private init() {
		self.defaults = .standard
		self.load()
	}
	
	// MARK: DataStore
	
	let defaults: UserDefaults

	@Published var date: Date? = nil
	
	public func setDate(_ value: Date) {
		self.defaults.set(value, forKey: DataKey.date.rawValue)
		self.date = value
	}
	
	public func load() {
		self.date = self.defaults.object(forKey: DataKey.date.rawValue) as? Date
	}
}

public extension DataStore {
	func saveDataFromUserInfo(userInfo: [AnyHashable: Any]) {
		if
			let dateStr = userInfo["date"] as? String,
			let date = dateStr.asIsoDate()
		{
			print("Remote date is \(date)")
			self.setDate(date)
			
			triggerFeedback()
		}
	}
}

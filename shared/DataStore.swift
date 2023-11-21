//
//  DataStore.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation

public enum DataKey: String {
	case date
	case note
	case devicePushToken
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
	@Published var note: String? = nil
	@Published var devicePushToken: Data? = nil
	
	public func setDate(_ value: Date) {
		self.defaults.set(value, forKey: DataKey.date.rawValue)
		self.date = value
	}
	
	public func setNote(_ value: String) {
		self.defaults.set(value, forKey: DataKey.note.rawValue)
		self.note = value
	}
	
	public func setDevicePushToken(_ value: Data) {
		self.defaults.set(value, forKey: DataKey.devicePushToken.rawValue)
		self.devicePushToken = value
	}
	
	public func load() {
		self.date = self.defaults.object(forKey: DataKey.date.rawValue) as? Date
		self.note = self.defaults.string(forKey: DataKey.note.rawValue)
		self.devicePushToken = self.defaults.data(forKey: DataKey.devicePushToken.rawValue)
	}
}

public extension DataStore {
	func saveDataFromUserInfo(userInfo: [AnyHashable: Any]) -> Bool {
		var saved = false
		
		if
			let dateStr = userInfo["date"] as? String,
			let date = dateStr.asIsoDate()
		{
			print("Remote date is \(date)")
			self.setDate(date)
			saved = true
		}
		
		if let noteStr = userInfo["note"] as? String {
			print("Remote note is \(noteStr)")
			self.setNote(noteStr)
			saved = true
		}
		
		if saved {
			triggerFeedback()
		}
		
		return saved
	}
}

//
//  WatchApplicationDelegate.swift
//  testLocationWatch Watch App
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import WatchKit

class WatchExtensionDelegate: NSObject, WKApplicationDelegate {
	/// handleUserActivity can arrive at any random moment (and usually after the main controller activated!)
	func handleUserActivity(_ userInfo: [AnyHashable: Any]?) {
		if let userInfo {
			print("handleUserActivity: \(userInfo.asJson())")
			DataStore.shared.saveDataFromUserInfo(userInfo: userInfo)
		} else {
			print("handleUserActivity: no data")
		}
	}
	
	func didReceiveRemoteNotification(_ userInfo: [AnyHashable: Any]) async -> WKBackgroundFetchResult {
		print("Received remote notification: \(userInfo.asJson())")
		DataStore.shared.saveDataFromUserInfo(userInfo: userInfo)
		return .newData
	}
}

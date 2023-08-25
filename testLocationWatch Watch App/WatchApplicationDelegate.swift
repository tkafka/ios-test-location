//
//  WatchApplicationDelegate.swift
//  testLocationWatch Watch App
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import UserNotifications
import WatchKit

class WatchApplicationDelegate: NSObject, WKApplicationDelegate {
	let notificationDelegate = NotificationDelegate()

	func applicationDidFinishLaunching() {
		// Perform any final initialization of your application.
		// NotificationDelegate.requestNotificationAuthorization()
		
		let application: WKApplication = .shared()
		application.registerForRemoteNotifications()
		
		let center = UNUserNotificationCenter.current()
		center.delegate = self.notificationDelegate
	}
	
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
	
	func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
		NotificationDelegate.printToken(deviceToken: deviceToken)
	}
	
	func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
		print("Push notifications: Error registering for push notifications: \(error.localizedDescription)")
	}
}



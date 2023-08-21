//
//  AppDelegate.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [
			UIApplication.LaunchOptionsKey: Any
		]?
	) -> Bool {
		Task {
			let center = UNUserNotificationCenter.current()
			let authorizationStatus = await center
				.notificationSettings().authorizationStatus
								
			// if authorizationStatus == .authorized {
			await MainActor.run {
				application.registerForRemoteNotifications()
			}
			// }
		}
		return true
	}
	
	func application(
		_ application: UIApplication,
		didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
	) {
		let deviceTokenStr = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
		print("Push notifications: Got a device token: \(deviceTokenStr)")
		/// send the token to your server
	}

	func application(
		_ application: UIApplication,
		didFailToRegisterForRemoteNotificationsWithError error: Error
	) {
		print("Push notifications: Error registering for push notifications: \(error.localizedDescription)")
	}
}

//
//  NotificationDelegate.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import UserNotifications
#if os(watchOS)
import WatchKit
#else
import UIKit
#endif

class NotificationDelegate: NSObject {
	static func printToken(deviceToken: Data) {
		let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
		let token = tokenParts.joined()
		print("Push notifications: Got a device token: \(token)")
		/// send the token to your server
	}
	
	static func requestNotificationAuthorization() async -> Bool {
		let center = UNUserNotificationCenter.current()
		do {
			let success = try await center.requestAuthorization(options: [.alert])
			print("Requested authorization, result=\(success)")
			if success {
				return true
				// await self.refreshAuthorizationState()
			}
		} catch {
			print("Error requesting authorization: \(error.localizedDescription)")
		}
		return false
	}
	
	static func isRegisteredForNotifications() -> Bool {
		#if os(watchOS)
		return WKApplication.shared().isRegisteredForRemoteNotifications
		#else
		return UIApplication.shared.isRegisteredForRemoteNotifications
		#endif
	}
	
	/*
	 static func registerForRemoteNotifications() {
	 	let center = UNUserNotificationCenter.current()
	 	let authorizationStatus = await center.notificationSettings().authorizationStatus

	 	guard authorizationStatus == .authorized else { return }
	 	await MainActor.run {
	 		UIApplication.shared.registerForRemoteNotifications()
	 	}
	 }
	  */
}

extension NotificationDelegate: UNUserNotificationCenterDelegate {
	/// Make sure you're setting up your notifications to be silent. A silent notification requires the content-available key with a value of 1 in the APNs payload.
	/// Called when a notification is tapped
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		// Handle the notification data here
			
		print("Got a notification.didReceive")
			
		completionHandler()
	}
	
	/// Called in foreground only
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		/// Handle the userInfo as needed

		print("Got a notification.willPresent")
		
		completionHandler([]) /// No alert, sound, or badge
	}
}

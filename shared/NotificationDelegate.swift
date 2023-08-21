//
//  NotificationDelegate.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject {
	static func requestNotificationAuthorization() async -> Bool {
		let center = UNUserNotificationCenter.current()
		do {
			let success = try await center.requestAuthorization(options: [.alert])
			if success {
				return true
				// await self.refreshAuthorizationState()
			}
		} catch {
			print("Error requesting authorization: \(error.localizedDescription)")
		}
		return false
	}
}

extension NotificationDelegate: UNUserNotificationCenterDelegate {
	/// Make sure you're setting up your notifications to be silent. A silent notification requires the content-available key with a value of 1 in the APNs payload.
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		// Handle the notification data here
			
		print("Got a notification.didReceive")
			
		completionHandler()
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		let userInfo = notification.request.content.userInfo
		/// Handle the userInfo as needed

		print("Got a notification.willPresent")
		
		completionHandler([]) /// No alert, sound, or badge
	}
}

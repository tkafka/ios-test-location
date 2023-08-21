//
//  testLocationWatchApp.swift
//  testLocationWatch Watch App
//
//  Created by Tomas Kafka on 04.08.2023.
//

import SwiftUI
import UserNotifications

@main
struct testLocationWatch_Watch_AppApp: App {
	@WKApplicationDelegateAdaptor private var appDelegate: WatchExtensionDelegate
	
	let notificationDelegate = NotificationDelegate()
	
	init() {
		let center = UNUserNotificationCenter.current()
		center.delegate = self.notificationDelegate
		// requestNotificationAuthorization()
		print("Notification delegate registered")
	}

	var body: some Scene {
		WindowGroup {
			WatchContentView()
		}
	}
}

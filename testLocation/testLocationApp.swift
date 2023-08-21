//
//  testLocationApp.swift
//  testLocation
//
//  Created by Tomas Kafka on 04.08.2023.
//

import SwiftUI

@main
struct testLocationApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self)
	private var appDelegate
	
	let notificationDelegate = NotificationDelegate()
	
	init() {
		let center = UNUserNotificationCenter.current()
		center.delegate = self.notificationDelegate
		// requestNotificationAuthorization()
		print("Notification delegate registered")
	}
	
	var body: some Scene {
		WindowGroup {
			AppContentView()
		}
	}
}

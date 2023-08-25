//
//  testLocationWatchApp.swift
//  testLocationWatch Watch App
//
//  Created by Tomas Kafka on 04.08.2023.
//

import SwiftUI

@main
struct testLocationWatch_Watch_AppApp: App {
	@WKApplicationDelegateAdaptor
	private var appDelegate: WatchApplicationDelegate
	
	var body: some Scene {
		WindowGroup {
			WatchContentView(dataStore: .shared)
		}
	}
}

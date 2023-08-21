//
//  WatchExtensionDelegate.swift
//  testLocationWatch Watch App
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import WatchKit

class WatchExtensionDelegate: NSObject, WKApplicationDelegate {
	/// handleUserActivity can arrive at any random moment (and usually after the main controller activated!)
	func handleUserActivity(_ userInfo: [AnyHashable: Any]?) {
		print("handleUserActivity()")
		
		if let userInfo {
			/// log it
		}
	}
}

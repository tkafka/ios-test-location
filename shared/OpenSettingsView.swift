//
//  OpenSettingsView.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import SwiftUI

struct OpenSettingsView: View {
	func openSettings() {
		if let url = URL(string: UIApplication.openSettingsURLString) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		} else {
			print("Cannot open settings")
		}
	}
		
	public var body: some View {
		Button(action: {
			self.openSettings()
		}, label: {
			Text("App settings")
		})
	}
}

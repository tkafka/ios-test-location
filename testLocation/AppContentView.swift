//
//  AppContentView.swift
//  testLocation
//
//  Created by Tomas Kafka on 04.08.2023.
//

import CoreLocation
import SwiftUI

struct AppContentView: View {
	let locationManager: LocationManager2 = .init(withAccuracy: .threeKilometers, platformAllowsBackgroundUpdates: true)

	@ObservedObject var dataStore: DataStore
	
	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			
			Form {
				PushNotificationView(dataStore: self.dataStore)
				
				DataView(dataStore: self.dataStore)
				
				LocationView(locationManager: self.locationManager)
				
				OpenSettingsView()
			}
		}
	}
}

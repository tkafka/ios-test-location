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
	
	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			
			PushNotificationView()
			
			LocationView(locationManager: self.locationManager)
		}
	}
}

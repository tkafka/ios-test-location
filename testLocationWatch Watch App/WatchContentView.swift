//
//  WatchContentView.swift
//  testLocationWatch Watch App
//
//  Created by Tomas Kafka on 04.08.2023.
//

import SwiftUI

struct WatchContentView: View {
	let locationManager: LocationManager2 = .init(withAccuracy: .threeKilometers, platformAllowsBackgroundUpdates: true)

	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			LocationView(locationManager: self.locationManager)
		}
		.padding()
	}
}

//
//  LocationView.swift
//  testLocation
//
//  Created by Tomas Kafka on 05.08.2023.
//

import CoreLocation
import OSLog
import SwiftUI

struct LocationView: View {
	let locationManager: LocationManager2
	@State private var result: Result<CLLocationCoordinate2D, Error>?

	var body: some View {
		VStack {
			if let result {
				switch result {
				case let .success(location):
					Text("\(location.debug())")
				case let .failure(error):
					Text("\(error.localizedDescription)")
				}
			}
			
			Button {
				Task {
					let location = await locationManager.getCurrentLocation(
						context: .foreground,
						timeout: 15,
						allowRetries: false,
						authorizationChangedCompletion: { _ in
						}
					)
					switch location.response {
					case let .success(source, location):
						Logger.app.info("Location success: \(source.debug()), location = \(location.debug())")
						self.result = .success(location.coordinate)
					case let .failure(error):
						Logger.app.error("Location failure: \(error.localizedDescription)")
						self.result = .failure(error)
					}
				}
			} label: {
				Text("Get location")
			}
		}
	}
}

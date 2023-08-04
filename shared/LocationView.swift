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
	@State private var result: Result<CLLocationCoordinate2D, Error>? = nil
	@State private var authorizationStatus: CLAuthorizationStatus? = nil

	var body: some View {
		VStack {
			if let result {
				switch result {
				case let .success(location):
					Text("Loc: \(location.debug())")
				case let .failure(error):
					Text("Error: \(error.localizedDescription)")
				}
			}
			
			if let authorizationStatus {
				Text("Status: \(authorizationStatus.debug())")
			}
			
			Button {
				Task {
					let context: ForegroundOrBackground = .foreground
					let location = await locationManager.getCurrentLocation(
						context: context,
						timeout: 15,
						allowRetries: false,
						authorizationChangedCompletion: { _ in
						}
					)
					
					authorizationStatus = self.locationManager.getCurrentAuthorization(context: context)
					
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

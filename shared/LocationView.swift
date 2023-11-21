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
	let context: ForegroundOrBackground = .foreground
	
	@State private var isLoading: Bool = false
	@State private var result: Result<CLLocationCoordinate2D, Error>? = nil
	@State private var authorizationStatus: CLAuthorizationStatus? = nil

	var body: some View {
		Section(header: Text("Location")) {
			if let result {
				switch result {
				case let .success(location):
					KeyValueView(key: "Loc", value: location.debug())
				case let .failure(error):
					KeyValueView(key: "Error", value: error.localizedDescription)
				}
			}
			
			if let authorizationStatus {
				KeyValueView(key: "Loc auth", value: authorizationStatus.debug())
			}
			
			Button {
				self.isLoading = true
				Task {
					let location = await locationManager.getCurrentLocation(
						context: self.context,
						timeout: 15,
						allowRetries: false,
						authorizationChangedCompletion: { _ in
						}
					)
					
					Task { @MainActor in
						authorizationStatus = self.locationManager.getCurrentAuthorization(context: self.context)
						
						switch location.response {
						case let .success(source, location):
							Logger.app.info("Location success: \(source.debug()), location = \(location.debug())")
							self.result = .success(location.coordinate)
						case let .failure(error):
							Logger.app.error("Location failure: \(error.localizedDescription)")
							self.result = .failure(error)
						}
						
						self.isLoading = false
					}
				}
			} label: {
				HStack(spacing: 8) {
					Text("Get location")
					ProgressView()
						.progressViewStyle(.circular)
						.opacity(self.isLoading ? 1 : 0)
				}
			}
		}
		.onAppear {
			self.authorizationStatus = self.locationManager.getCurrentAuthorization(context: self.context)
		}
	}
}

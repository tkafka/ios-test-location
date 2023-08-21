//
//  LocationItem.swift
//  testLocation
//
//  Created by Tomas Kafka on 04.08.2023.
//

import CoreLocation
import Foundation

final class Item: Identifiable {
	var timestamp: Date
	var location: CLLocationCoordinate2D
    
	init(timestamp: Date, location: CLLocationCoordinate2D) {
		self.timestamp = timestamp
		self.location = location
	}
}

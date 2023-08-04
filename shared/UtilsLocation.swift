//
//  UtilsLocation.swift
//  Weathergraph Independent
//
//  Created by Tomas Kafka on 24.10.2021.
//  Copyright © 2021 Tomáš Kafka. All rights reserved.
//

import CoreLocation
import Foundation

// MARK: Location

extension CLLocationCoordinate2D: DebugPrintable {
	public func debug() -> String {
		return "lat=\(latitude), lon=\(longitude)"
	}
}

extension CLLocation: DebugPrintable {
	public func debug() -> String {
		return coordinate.debug()
		// return debugDescription
	}
}

public extension CLLocation {
	/// directly paste from right clicking on https://www.windy.com
	convenience init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
		self.init(latitude: latitude, longitude: longitude)
	}
}

/// Do we already have location permission?
public extension CLAuthorizationStatus {
	func locationPermissionObtained( /* platform: DataStorePlatform */ ) -> Bool {
		/*
		 if platform.isWidget && locationManager.isAuthorizedForWidgetUpdates == false {
		 return false
		 }
		 */
		
		#if os(macOS)
		return self == CLAuthorizationStatus.authorizedAlways
		#else
		return self == CLAuthorizationStatus.authorizedAlways || self == CLAuthorizationStatus.authorizedWhenInUse
		#endif
	}
}

extension CLAuthorizationStatus: DebugPrintable {
	public func debug() -> String {
		switch self {
		case .authorizedAlways:
			return "authorizedAlways"
		case .authorizedWhenInUse:
			return "authorizedWhenInUse"
		case .denied:
			return "denied"
		case .notDetermined:
			return "notDetermined"
		case .restricted:
			return "restricted"
		// case .authorized:
		//	return "authorized"
		@unknown default:
			return "unknown"
		}
	}
}

public extension CLLocationCoordinate2D {
	/// due to wtf error when probably some iOS versions have this as equatable and others don't???
	static func equals_alternate(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
		return lhs.latitude == rhs.latitude
			&& lhs.longitude == rhs.longitude
	}
}

/*
 /// redundant conformance of 'CLLocationCoordinate2D' to protocol 'Equatable'
 extension CLLocationCoordinate2D: Equatable {
 public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
 return lhs.latitude == rhs.latitude
 && lhs.longitude == rhs.longitude
 }
 }

 /// it's an enum, just add equatable
 /// redundant conformance of 'CLAuthorizationStatus' to protocol 'Equatable'
 extension CLAuthorizationStatus: Equatable {}
 */

// MARK: CLLocation

func locationsAreSimilar(_ loc1: CLLocation?, _ loc2: CLLocation?) -> Bool {
	guard let loc1 = loc1, let loc2 = loc2
	else {
		return false
	}
	
	return loc2.distance(from: loc1) < 1 * 1000 /// meters
}

// MARK: Coords

func coordsAreSimilar(_ coords1: Coords?, _ coords2: Coords?) -> Bool {
	guard let coords1 = coords1, let coords2 = coords2
	else {
		return false
	}
	
	let loc1 = coords1.location
	let loc2 = coords2.location
	
	return loc2.distance(from: loc1) < 1 * 1000 /// meters
}

// MARK: Random

#if DEBUG // && RANDOM_LOCATION
struct LocationRange {
	let latitudes: ClosedRange<CLLocationDegrees>
	let longitudes: ClosedRange<CLLocationDegrees>

	init(_ one: CLLocation, _ two: CLLocation) {
		let latMin = min(one.coordinate.latitude, two.coordinate.latitude)
		let latMax = max(one.coordinate.latitude, two.coordinate.latitude)
		let lonMin = min(one.coordinate.longitude, two.coordinate.longitude)
		let lonMax = max(one.coordinate.longitude, two.coordinate.longitude)
		
		self.latitudes = latMin ... latMax
		self.longitudes = lonMin ... lonMax
	}
	
	init(latitudes: ClosedRange<Double>, longitudes: ClosedRange<Double>) {
		self.latitudes = latitudes
		self.longitudes = longitudes
	}
	
	init(latitudes: ClosedRange<Int>, longitudes: ClosedRange<Int>) {
		self.latitudes = CLLocationDegrees(latitudes.lowerBound) ... CLLocationDegrees(latitudes.upperBound)
		self.longitudes = CLLocationDegrees(longitudes.lowerBound) ... CLLocationDegrees(longitudes.upperBound)
	}
	
	func randomLocation() -> CLLocation {
		return .init(
			latitude: Double.random(in: self.latitudes),
			longitude: Double.random(in: self.longitudes)
		)
	}
}

enum Locations: CaseIterable {
	static let prague = CLLocation(latitude: 50.0833, longitude: 14.4167)
	static let jihlava = CLLocation(latitude: 49.40018, longitude: 15.59758)
	static let calgary = CLLocation(latitude: 51.05, longitude: -114.06)
	static let reykjavik = CLLocation(latitude: 64.133333, longitude: -21.933333)
	static let oslo = CLLocation(latitude: 59.912949, longitude: 10.7466)
	static let jakarta = CLLocation(latitude: -6.134346, longitude: 106.83175)
	static let mtEverest = CLLocation(latitude: 27.988056, longitude: 86.925278)
	static let rio = CLLocation(latitude: -22.971779, longitude: -43.182952)
	static let sfo = CLLocation(latitude: 37.77493, longitude: -122.41942)
	static let tokyo = CLLocation(latitude: 35.708965, longitude: 139.732017)
	static let sahara = CLLocation(latitude: 32.213757, longitude: 5.467703)
	static let manila = CLLocation(latitude: 14.583333, longitude: 121)
	static let lombok = CLLocation(latitude: -8.5833, longitude: 116.1167)
	static let helsinki = CLLocation(latitude: 60.16952, longitude: 24.93545)
	static let karlsbad = CLLocation(latitude: 48.90971979788265, longitude: 8.510495037347402)
	static let hamburg = CLLocation(latitude: 53.59210269406979, longitude: 9.991312270616895)
	static let salen = CLLocation(latitude: 61.15, longitude: 13.266667)
	static let mora = CLLocation(latitude: 61.016667, longitude: 14.533333)
	static let longyearbyen = CLLocation(latitude: 78.2166658, longitude: 15.5499978)
	static let shackletonShelf = CLLocation(latitude: -66.0273997, longitude: 97.9486622)
	static let sabaneta = CLLocation(latitude: 8.708549381235628, longitude: -67.85137976546982)
	static let hamada = CLLocation(latitude: 34.900, longitude: 132.080)
	static let clearMoon = CLLocation(latitude: 59.8351918695614, longitude: -111.12667008683582)
	
	static let forecaError01 = CLLocation(latitude: 53.77151307457872, longitude: 46.01186137159911)
}

enum LocationRanges: CaseIterable {
	static let world = LocationRange(latitudes: -60 ... 75, longitudes: -180 ... 180)
	static let euTimezone = LocationRange(latitudes: -60 ... 75, longitudes: -15 ... 20)
	static let europe = LocationRange(latitudes: 25 ... 61, longitudes: -10 ... 28)
	static let scandinavia = LocationRange(latitudes: 54 ... 69, longitudes: 4 ... 28)
	static let canada = LocationRange(latitudes: 47 ... 72, longitudes: -168 ... -62)
	static let usa = LocationRange(latitudes: 32 ... 43, longitudes: -117 ... -73)
	static let sahara = LocationRange(latitudes: 18 ... 30, longitudes: -15 ... 39)
	static let saharaHot = LocationRange(latitudes: 15 ... 17, longitudes: 3 ... 5)
	static let saharaHotHumid = LocationRange(latitudes: 9 ... 10, longitudes: 7 ... 8)
	
	static let usaRainy = LocationRange(
		CLLocation(26.998, -100.420),
		CLLocation(39.756, -81.303)
	)
}

func randomLocation() -> CLLocation {
	return [
		Locations.prague,
		Locations.jihlava,
		Locations.calgary,
		Locations.reykjavik,
		Locations.oslo,
		Locations.jakarta,
		Locations.mtEverest,
		Locations.rio,
		Locations.sfo,
		Locations.tokyo,
		Locations.sahara,
		Locations.manila,
		Locations.lombok,
		Locations.helsinki,
		Locations.karlsbad,
		Locations.hamburg,
		Locations.salen,
		Locations.mora,
		Locations.longyearbyen,
		Locations.shackletonShelf,
		Locations.sabaneta,
		Locations.hamada,
		Locations.forecaError01
	].randomElement() ?? Locations.prague
}

func totallyRandomLocation() -> CLLocation {
	/// nowcast overrides
	// return CLLocation(44.35037200443071, 21.30448226876367)
	// return CLLocation(-112.5643912395135, 42.759164127134746)
	// return CLLocation(42.05497641586511, -85.32465847183467)
	
	// return CLLocation(30.494442899860367, -92.19021129260784) /// sleet nowcast problem with pirate weather
	// return CLLocation(30.321078884628744, -97.71992421934321) /// austin
	// return CLLocation(52.526996375284085, 13.451529880236212) /// empty time axis - sivaramkjs
	// return CLLocation(33.75510823602179, -89.6956771177344)
	// return CLLocation(43.8792979078743, -4.16512383962799)
	// return CLLocation(36.802, 7.442)
	// return CLLocation(49.468, 15.436) /// Simanov :)

	/// ads
	return Locations.jihlava
	// return Locations.helsinki
	
	/// areas
	// return LocationRanges.scandinavia.randomLocation()
	return LocationRanges.europe.randomLocation()
	// return LocationRanges.usa.randomLocation()
	// return LocationRanges.usaRainy.randomLocation()
	// return LocationRanges.canada.randomLocation()
	// return LocationRanges.saharaHotHumid.randomLocation()
	// return LocationRanges.world.randomLocation()
	
	/// hot - uv index and both temps are ugly
	// return CLLocation(latitude: -9.021747787801445, longitude: 122.7573972558489)
	
	// return CLLocation(latitude: 66.42108359637302, longitude: 8.906253436355112)
	
	/// app store sample - hot, rainy and nowcast
	// return CLLocation(latitude: 8.761, longitude: -9.573)
	
	// return Locations.clearMoon
}

#endif

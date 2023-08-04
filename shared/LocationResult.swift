//
//  LocationResult.swift
//  WeathergraphKit
//
//  Created by Tomas Kafka on 25.05.2023.
//

import CoreLocation
import Foundation

public enum LMError: Error {
	case authorizationFailed(String)
	case locationUpdateFailed(String)
	case locationUpdateTimedOut(String)
}

public enum LMResponse {
	public enum LocationSource: DebugPrintable {
		case reusingFreshLocation
		case freshLocation
		case reusingStaleLocation
		
		public func debug() -> String {
			switch self {
			case .reusingFreshLocation:
				return "reusing fresh location"
			case .freshLocation:
				return "fresh location"
			case .reusingStaleLocation:
				return "reusing stale location"
			}
		}
	}
	
	case success(LocationSource, CLLocation)
	case failure(LMError)
}

enum LMLocationAccuracy {
	case kilometer
	case best
	case nearestTenMeters
	case hundredMeter
	case threeKilometers
	case bestForNavigation
	case reducedAccuracy

	public var clAccuracy: CLLocationAccuracy {
		switch self {
		case .best:
			return kCLLocationAccuracyBest
		case .bestForNavigation:
			return kCLLocationAccuracyBestForNavigation
		case .hundredMeter:
			return kCLLocationAccuracyHundredMeters
		case .kilometer:
			return kCLLocationAccuracyKilometer
		case .nearestTenMeters:
			return kCLLocationAccuracyNearestTenMeters
		case .threeKilometers:
			return kCLLocationAccuracyThreeKilometers
		case .reducedAccuracy:
			return kCLLocationAccuracyReduced
		}
	}
}

public struct LMResult {
	var response: LMResponse
	var authorizationStatus: CLAuthorizationStatus
}

/*
 public struct LocationAndAuthorization {
 var location: CLLocation
 var authorizationStatus: CLAuthorizationStatus
 }
 */

extension CLLocation {
	func locationString() -> String {
		return "[lat=\(coordinate.latitude), lon=\(coordinate.longitude)]"
	}

	#if DEBUG
	func mapyCzString() -> String {
		return "https://en.mapy.cz/zakladni?x=\(coordinate.longitude)&y=\(coordinate.latitude)" // &z=11
	}

	func weatherchartLocString() -> String {
		return "?loc=\(coordinate.latitude),\(coordinate.longitude)"
	}
	#endif
}

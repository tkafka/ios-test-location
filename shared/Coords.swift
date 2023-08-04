//
//  Coords.swift
//  Weathergraph
//
//  Created by Tomas Kafka on 02/05/2020.
//  Copyright © 2020 com.tomaskafka. All rights reserved.
//

import CoreLocation
import Foundation

public struct Coords: Equatable, Hashable, DebugPrintable {
	public let latitude: Double
	public let longitude: Double
	
	public init?(latitude: Double, longitude: Double) {
		if latitude.isNaN || latitude < -90.0 || latitude > 90.0 {
			return nil
		}
		if longitude.isNaN || longitude < -180.0 || longitude > 180.0 {
			return nil
		}
		
		self.latitude = latitude
		self.longitude = longitude
	}
	
	/// CLLocation
	
	public var location: CLLocation {
		return CLLocation(latitude: self.latitude, longitude: self.longitude)
	}
	
	public var coordinate2D: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
	}
	
	/// Hashable
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.latitude)
		hasher.combine(self.longitude)
	}
	
	/// DebugPrintable
	
	public func debug() -> String {
		return "lat: \(self.latitude), lon: \(self.longitude)"
	}
}

public extension CLLocation {
	var coords: Coords? {
		return Coords(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}
}

public extension CLLocation {
	static var Empty: CLLocation {
		return .init(0, 0)
	}
}

/*
 public class Coords: NSObject, NSSecureCoding, DebugPrintable {
 public static var supportsSecureCoding: Bool { return true }
	 
 var latitude: Double
 var longitude: Double
	 
 init?(latitude: Double, longitude: Double) {
 if latitude.isNaN || latitude < -90.0 || latitude > 90.0 {
 return nil
 }
 if longitude.isNaN || longitude < -180.0 || longitude > 180.0 {
 return nil
 }
		 
 self.latitude = latitude
 self.longitude = longitude
		 
 super.init()
 }
	 
 override public func isEqual(_ object: Any?) -> Bool {
 if let other = object as? Coords {
 return latitude == other.latitude && longitude == other.longitude
 }
 return false
 }
	 
 /*
 // Equatable
 public static func == (lhs: Coords, rhs: Coords) -> Bool {
 return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
 }
 */
	 
 // NSCoding
	 
 public func encode(with coder: NSCoder) {
 coder.encode(latitude, forKey: "latitude")
 coder.encode(longitude, forKey: "longitude")
 }
	 
 public required convenience init?(coder decoder: NSCoder) {
 let latitude = decoder.decodeDouble(forKey: "latitude")
 let longitude = decoder.decodeDouble(forKey: "longitude")
		 
 self.init(latitude: latitude, longitude: longitude)
 }
	 
 // CLLocation
	 
 var location: CLLocation {
 return CLLocation(latitude: self.latitude, longitude: self.longitude)
 }
	 
 var coordinate2D: CLLocationCoordinate2D {
 return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
 }
	 
 // DebugPrintable
	 
 public func debug() -> String {
 return "lat: \(latitude), lon: \(longitude)"
 }
 }

 extension CLLocation {
 var coords: Coords? {
 return Coords(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
 }
 }
 
 */

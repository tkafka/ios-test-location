//
//  LocationManager2.swift
//  WeathergraphShared
//
//  Created by Tomas Kafka on 25.05.2023.
//

import CoreLocation
import Foundation
import OSLog

/// NSObject, because that's a requirement for it to be passed as a delegate
class LocationManager2: NSObject {
	private struct ContinuationLMTuple {
		let continuation: CheckedContinuation<LMResult, Never>
		let id: UUID
		let manager: CLLocationManager
		let context: ForegroundOrBackground
	}
	
	private let desiredAccuracy: LMLocationAccuracy
	private let locationManagerForeground = CLLocationManager()
	private let locationManagerBackground = CLLocationManager()
	
	private var authorizationStatus: CLAuthorizationStatus = .notDetermined

	///  These get called once and cleared
	// TODO: In iOS 16/watchOS 9+, use OSAllocatedUnfairLock<[ContinuationLMTuple]> = .init(initialState: [])? Or, actors?
	private var locationContinuations: [ContinuationLMTuple] = []
	private let locationContinuationsLock = NSLock()
	
	private var authorizationChangedCompletions: [ArgAction<CLAuthorizationStatus>] = []
	private let authorizationChangedCompletionsLock = NSLock()
	
	/// These are for permanent subscriptions
	private var permanentAuthorizationChangedCallbacks: [ArgAction<CLAuthorizationStatus>] = []
	private var retryWorkItem: DispatchWorkItem?
	
	private var retries: Int = 0
	private var maxRetries: Int = 0

	init(withAccuracy accuracy: LMLocationAccuracy, platformAllowsBackgroundUpdates: Bool) {
		if !Thread.isMainThread {
			assertionFailure("LocationManager needs to be created on main thread!")
		}

		self.desiredAccuracy = accuracy
		super.init()

		self.locationManagerForeground.delegate = self
		self.locationManagerBackground.delegate = self

		// locationManagerForeground.desiredAccuracy = accuracy.clAccuracy
		// locationManagerBackground.desiredAccuracy = accuracy.clAccuracy
		
		self.locationManagerBackground.allowsBackgroundLocationUpdates = platformAllowsBackgroundUpdates
		// locationManagerBackground.showsBackgroundLocationIndicator = true
	}
	
	static let messageNotDeterminedBackground = "No location permission yet, and cannot ask for it in the background."
	static let messageAuthorizedWhenInUseBackground = "Cannot query the location in the background without an 'Always' location permission."
	static let messageDenied = "Location access is denied."
	static let messageRestricted = "Location access is restricted parental controls or the company device management."
	static let messagePromptDeclined = "Weathergraph location prompt was declined by system."
	static let messageNetworkError = "Weathergraph couldn't access the network to get location."
	static let messageHeadingFailure = "Weathergraph couldn't read location, probably because of magnetic interference."
	static let messageRangingFailure = "Weathergraph couldn't read location. Is the watch in airplane mode or is Bluetooth or location services disabled?"
	
	/// Beware: If a location permission dialog is shown, the call resolves as failed, but the `authorizationChangedCompletion` is called after the user changes the permission. And then, the caller needs to retry.
	public func getCurrentLocation(
		context: ForegroundOrBackground,
		timeout requestedTimeout: TimeInterval?,
		allowRetries: Bool,
		authorizationChangedCompletion: ArgAction<CLAuthorizationStatus>? = nil
	) async -> LMResult {
		self.retryWorkItem?.cancel()
		self.retryWorkItem = nil
		self.retries = 0
		/// repeated retries cause the bg refresh to timeout!
		self.maxRetries = allowRetries ? 2 : 0
		
		let timeout: TimeInterval? = requestedTimeout ?? Constants.MaximumOverallForecastLocationTimeoutSeconds
		
		let locationManager: CLLocationManager = self.getLocationManager(for: context)
		/// reset the accuracy which may have been dropped down
		locationManager.desiredAccuracy = self.desiredAccuracy.clAccuracy

		Logger.location.info("LocationManager: getCurrentLocation(\(context.debug())) started, authorization is \(locationManager.authorizationStatus.debug()) ...")
		
		switch locationManager.authorizationStatus {
		case .authorizedAlways:
			/// we have a permission we need, continue
			break
		case .authorizedWhenInUse:
			/// no idea if this will trigger a permission dialog
			switch context {
			case .foreground:
				/// we can either display a dialog or we don't need it, as we are in use -> continue
				break
			case .background:
				/// `authorizedWhenInUse` doesn't apply for bg updates
				return LMResult(response: .failure(.authorizationFailed(Self.messageAuthorizedWhenInUseBackground)), authorizationStatus: locationManager.authorizationStatus)
			}
		case .notDetermined:
			/// definitely will trigger a permission dialog, but meanwhile we will get a .denied callback :/
			switch context {
			case .foreground:
				/// we can display a dialog -> continue
				break
			case .background:
				/// cannot display the dialog in bg, so reject right away
				return LMResult(response: .failure(.authorizationFailed(Self.messageNotDeterminedBackground)), authorizationStatus: locationManager.authorizationStatus)
			}
		case .denied:
			/// we can return right away, no way to recover
			return LMResult(response: .failure(.authorizationFailed(Self.messageDenied)), authorizationStatus: locationManager.authorizationStatus)
		case .restricted:
			/// we can return right away, no way to recover
			return LMResult(response: .failure(.authorizationFailed(Self.messageRestricted)), authorizationStatus: locationManager.authorizationStatus)
		@unknown default:
			/// continue and ask?
			break
		}
		
		/// Start with a request for auth
		/// An application which currently has "when-in-use" authorization and has never before requested "always" authorization may use this method to request "always" authorization one time only.  Otherwise, if `authorizationStatus != kCLAuthorizationStatusNotDetermined`, (ie generally after the first call) this method will do nothing.
		/// BEWARE: If we don't have the permission, we get an error instantly (`.failure`), and the user is expected to call the `getCurrentLocation()` again in `authorizationChangedCompletion` callback.
		
		return await withCheckedContinuation { continuation in
			let id = UUID()
			let tuple = ContinuationLMTuple(
				continuation: continuation,
				id: id,
				manager: locationManager,
				context: context
			)
			self.locationContinuationsLock.withLock {
				self.locationContinuations.append(tuple)
			}
			
			if let authorizationChangedCompletion {
				self.authorizationChangedCompletionsLock.withLock {
					self.authorizationChangedCompletions.append(authorizationChangedCompletion)
				}
			}

			locationManager.requestAlwaysAuthorization()

			#if RANDOM_LOCATION
			let randomLoc = totallyRandomLocation()
			print("LocationManager: success, random = \(randomLoc.locationString())")
			#if DEBUG
			print("LocationManager: map link = \(randomLoc.mapyCzString())")
			print("LocationManager: loc link = \(randomLoc.weatherchartLocString())")
			#endif
			self.resumeStopAndClearContinuations(manager: locationManager, response: .success(.freshLocation, randomLoc))
			#endif

			/// regular flow

			/// set up timeout
			if let timeout {
				Task {
					try? await Task.sleep(interval: timeout)
					
					/// Ideally only cancel the single `continuation`.
					let failureResponse = LMResponse.failure(LMError.locationUpdateTimedOut("Location update timed out"))
					
					if self.resumeStopAndClearContinuation(id: id, manager: locationManager, response: failureResponse) {
						Logger.location.info("LocationManager: timed out (\(timeout) s).")
					} else {
						// Logger.location.info("LocationManager: timed out (\(timeout) s), but already returned before.")
					}
				}
			}
			
			/// and fire it off
			locationManager.requestLocation()
		}
	}
	
	private func continuationsMessage() -> String {
		var continuationsCount: Int = 0
		self.locationContinuationsLock.withLock {
			continuationsCount = self.locationContinuations.count
		}
		return continuationsCount > 0 ? ", calling continuations" : ", continuations already fulfilled"
	}
	
	/*
	 private func hasForegroundContinuation() -> Bool {
	 var result = false
		
	 locationContinuationsLock.withLock {
	 result = locationContinuations.reduce(false) { acc, tuple in
	 if tuple.context == .foreground {
	 return true
	 }
	 /// otherwise preserve
	 return acc
	 }
	 }
		
	 return result
	 }
	 */
	
	private func resumeStopAndClearContinuation(id: UUID, manager: CLLocationManager, response: LMResponse) -> Bool {
		var tuple: ContinuationLMTuple? = nil
		
		self.locationContinuationsLock.withLock {
			if let idIndex = locationContinuations.firstIndex(where: { $0.id == id }) {
				/// get and remove
				tuple = self.locationContinuations[idIndex]
				self.locationContinuations.remove(at: idIndex)
			}
		}
		
		/// handle
		if let tuple {
			tuple.manager.startUpdatingLocation()
			tuple.continuation.resume(returning: LMResult(response: response, authorizationStatus: manager.authorizationStatus))
			return true
		}
		
		/// not found
		return false
	}
	
	private func resumeStopAndClearContinuations(manager: CLLocationManager, response: LMResponse) {
		// TODO: You should definitely use an actor or a more elaborated locking technique for the locationContinuations, to avoid data races, see https://holyswift.app/common-swift-task-continuation-problem/
		self.locationContinuations.removeAndReturnAll(withLock: self.locationContinuationsLock).forEach {
			$0.manager.stopUpdatingLocation()
			$0.continuation.resume(returning: LMResult(response: response, authorizationStatus: manager.authorizationStatus))
		}
	}
	
	public func addAuthorizationChangedCallback(action: @escaping ArgAction<CLAuthorizationStatus>) {
		self.permanentAuthorizationChangedCallbacks.append(action)
	}
	
	public func getCurrentAuthorization(context: ForegroundOrBackground) -> CLAuthorizationStatus {
		let locationManager: CLLocationManager = self.getLocationManager(for: context)
		return locationManager.authorizationStatus
	}
	
	public func isAuthorizedForUpdates(context: ForegroundOrBackground) -> Bool {
		let locationManager: CLLocationManager = self.getLocationManager(for: context)

		return locationManager.authorizationStatus.locationPermissionObtained()
	}
	
	private func getLocationManager(for context: ForegroundOrBackground) -> CLLocationManager {
		switch context {
		case .foreground:
			return self.locationManagerForeground
		case .background:
			return self.locationManagerBackground
		}
	}
}

extension LocationManager2: CLLocationManagerDelegate {
	/// `CLLocationManager` is guaranteed to call the delegate method with the app's initial authorization state and all authorization state changes. If users haven't grant or deny the permission, we will get `.notDetermined` status, which is where we will request for location permission.
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		guard status != self.authorizationStatus else {
			/// we get this callback even when the status doesn't change, so we need to filter
			return
		}
		
		self.authorizationStatus = status
		
		Logger.location.info("LocationManager: authorization status changed to \(status.debug()) (callbacks=\(self.authorizationChangedCompletions.count))")
		
		switch status {
		case .notDetermined:
			/// don't kill the location request with the error, this is okay, we will ask on request ...
			break
		case .denied, .restricted:
			/// we can leave this in, even though it should not be necessary?
			manager.stopUpdatingLocation()

		case .authorizedWhenInUse, .authorizedAlways:
			/// Don't do this - the caller is expected to call the `get...` again inside `authorizationChangedCompletion`.
			/*
			 USE lock here!
			 if self.locationContinuations.count > 0 {
			 /// there is a request in progress
			 Logger.location.info("LocationManager: authorization status changed to \(status.debug()) and there is a request in progress, calling .requestLocation() ...")
			 locationManager.requestLocation()
			 }
			 */
			break
		@unknown default:
			break
		}
		
		self.authorizationChangedCompletions.removeAndReturnAll(withLock: self.authorizationChangedCompletionsLock).forEach { $0(status) }
		/// and call the permanent ones
		self.permanentAuthorizationChangedCallbacks.forEach { $0(status) }
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let lastLocation = locations.last else {
			/// always resolve
			let failureResponse = LMResponse.failure(LMError.locationUpdateFailed("Location update didn't return any locations."))
			Logger.location.info("LocationManager: success, but no location (?)\(self.continuationsMessage()).")
			
			self.resumeStopAndClearContinuations(manager: manager, response: failureResponse)
			return
		}
		
		// trackingHandle(response: successResponse)

		Logger.location.info("LocationManager: success \(lastLocation.locationString())\(self.continuationsMessage()).")
		self.resumeStopAndClearContinuations(manager: manager, response: .success(.freshLocation, lastLocation))
	}
 
	fileprivate func optionallyRetry(_ manager: CLLocationManager) {
		/// If the location service is unable to retrieve a location right away, it reports a CLError.Code.locationUnknown error and keeps trying. In such a situation, you can simply ignore the error and wait for a new event
		/// wait ...
		
		/// but since iOS 16, this seems to be called once and then no further updates are ever got, when a location is disabled?
		/// also, might we disable location updates for other/future continuations with a same LM?
		// locationManager.stopUpdatingLocation()
		
		if
			self.retries < self.maxRetries
		{
			self.retries += 1
			Logger.location.info("LocationManager: location unknown, retrying (#\(self.retries)) ...")
			
			/// reduce desired accuracy
			manager.desiredAccuracy = LMLocationAccuracy.reducedAccuracy.clAccuracy
			
			/// cancel the previous one, just in case
			self.retryWorkItem?.cancel()
			/// wait and retry
			let dispatchTime: DispatchTime = .now() + 0.33 /// seconds
			let workItem = DispatchWorkItem {
				manager.requestLocation()
			}
			DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: workItem)
			self.retryWorkItem = workItem
		} else {
			Logger.location.info("LocationManager: location unknown, max number of retries (\(self.retries)) reached, giving up.")
			self.resumeStopAndClearContinuations(manager: manager, response: .failure(LMError.locationUpdateTimedOut("Location update gave up after \(self.retries) retries.")))
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		if let clError = error as? CLError, case CLError.locationUnknown = clError {
			self.optionallyRetry(manager)
			// } else if hasForegroundContinuation() && manager.authorizationStatus == .notDetermined {
			/// this means the user should get an authorization permission window - but only in foreground
			/// TODO: Can't it happen that we have `notDetermined` but the permission window doesn't show up?
			/// This is probably a wrong approach - it would be better ot just tryUpdateForecast from a top level whenever an auth permission change ...
		} else {
			let lmError: LMError
			if let clError = error as? CLError {
				switch clError {
				case CLError.denied:
					Logger.location.info("LocationManager: error #\(clError.errorCode) - location is \(manager.authorizationStatus.debug()) = denied by the user or restricted (or not have always allow for bg updates, or cannot display permission dialog for widget)\(self.continuationsMessage()).")
					lmError = .authorizationFailed(Self.messageDenied)
				case CLError.promptDeclined:
					Logger.location.info("LocationManager: error #\(clError.errorCode) - prompt declined\(self.continuationsMessage()).")
					lmError = LMError.locationUpdateFailed(Self.messagePromptDeclined)
				case CLError.network:
					Logger.location.info("LocationManager: error #\(clError.errorCode) - couldn't access network\(self.continuationsMessage()).")
					lmError = LMError.locationUpdateFailed(Self.messageNetworkError)
				case CLError.headingFailure:
					Logger.location.info("LocationManager: error #\(clError.errorCode) - magnetic interference (heading failure)\(self.continuationsMessage()).")
					lmError = LMError.locationUpdateFailed(Self.messageHeadingFailure)
				case CLError.rangingFailure, CLError.rangingUnavailable:
					Logger.location.info("LocationManager: error #\(clError.errorCode) - ranging unavailable\(self.continuationsMessage()).")
					lmError = LMError.locationUpdateFailed(Self.messageRangingFailure)
				default:
					Logger.location.info("LocationManager: error #\(clError.errorCode) - other error\(self.continuationsMessage()).")
					lmError = LMError.locationUpdateFailed(error.messageAndCode)
				}
			} else {
				Logger.location.info("LocationManager: other error\(self.continuationsMessage()).")
				lmError = LMError.locationUpdateFailed(error.messageAndCode)
			}
			
			self.resumeStopAndClearContinuations(manager: manager, response: .failure(lmError))
		}
	}
	
	#if !os(watchOS)
	func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
		if let clError = error as? CLError {
			Logger.location.info("LocationManager: didFinishDeferredUpdatesWithError #\(clError.errorCode).")
		} else if let error {
			Logger.location.info("LocationManager: didFinishDeferredUpdatesWithError \(error.localizedDescription).")
		} else {
			Logger.location.info("LocationManager: didFinishDeferredUpdatesWithError ok - no unexpected errors.")
		}
		/// Won't this prevent updates in resuming?
		// manager.stopUpdatingLocation()
	}
	#endif
	
	func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
		/// no need to calibrate the compass for heading
		return false
	}
}

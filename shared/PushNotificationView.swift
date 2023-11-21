//
//  PushNotificationView.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import SwiftUI
import UserNotifications
#if os(iOS)
import UIKit
#endif

struct PushNotificationView: View {
	@State var authorizationState: UNAuthorizationStatus?
	@State var isRegisteredForRemoteNotifications: Bool = false
	@ObservedObject var dataStore: DataStore
	@State var copied: Bool = false

	public init(dataStore: DataStore) {
		self._authorizationState = .init(initialValue: nil)
		self._dataStore = ObservedObject(initialValue: dataStore)
	}
	
	private func refreshAuthorizationState() async {
		let center = UNUserNotificationCenter.current()

		let authorizationState = await center.notificationSettings().authorizationStatus
		
		await MainActor.run {
			self.authorizationState = authorizationState
			self.isRegisteredForRemoteNotifications = NotificationDelegate.isRegisteredForNotifications()
		}
	}
	
	public var body: some View {
		Section(header: Text("Push notifications")) {
			if let authorizationState {
				Text("Authorization state: \(authorizationState.debug())")
			}
			Text("Registered: \(self.isRegisteredForRemoteNotifications ? "Yes" : "No")")
			
			if
				let authorizationState,
				authorizationState.canPush(),
				let devicePushTokenStr = dataStore.devicePushToken?.asTokenString()
			{
				#if os(iOS)
				Button(action: {
					let pasteboard = UIPasteboard.general
					pasteboard.string = "\(devicePushTokenStr)"
					self.copied = true
				}, label: {
					VStack(alignment: .leading) {
						Text("\(devicePushTokenStr)")
						Text(self.copied ? "Copied to clipboard" : "Tap to copy")
							.font(.footnote)
							.foregroundStyle(.secondary)
					}
				})
				#else
				Text("\(devicePushTokenStr)")
				#endif
			}
			
			Button(action: {
				Task {
					await self.refreshAuthorizationState()
				}
			}, label: {
				Text("Check push auth")
			})
			
			Button(action: {
				Task {
					let result = await NotificationDelegate.requestNotificationAuthorization()
					if result {
						await self.refreshAuthorizationState()
					}
				}
			}, label: {
				Text("Request push permission")
			})
		}
		.onChange(of: self.dataStore.devicePushToken, perform: { _ in
			/// reset the copied flag
			self.copied = false
		})
		.onAppear(perform: {
			Task {
				await self.refreshAuthorizationState()
			}
		})
	}
}

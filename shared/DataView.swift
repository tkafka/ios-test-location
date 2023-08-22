//
//  DataView.swift
//  testLocation
//
//  Created by Tomas Kafka on 21.08.2023.
//

import Foundation
import SwiftUI

struct DataView: View {
	@ObservedObject var dataStore: DataStore
	
	var dateText: String {
		if let date = dataStore.date {
			return "\(date)"
		} else {
			return "nil"
		}
	}
	
	var body: some View {
		Section {
			HStack {
				Text("Last push")
				Text("\(self.dateText)")
					.foregroundStyle(.secondary)
			}
		} header: {
			Text("Data")
		}
	}
}

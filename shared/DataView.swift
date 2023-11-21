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
			KeyValueView(key: "Last push", value: self.dateText)
			if let note = dataStore.note {
				KeyValueView(key: "Note", value: note)
			}
		} header: {
			Text("Data")
		}
	}
}

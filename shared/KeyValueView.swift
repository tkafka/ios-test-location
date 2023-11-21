//
// Created by Tomas Kafka on 21.11.2023.
// Copyright © 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import SwiftUI

struct KeyValueView: View {
	var key: String
	var value: String?
	
	var body: some View {
		HStack {
			Text(self.key)
			if let value {
				Spacer()
				Text(value)
					.foregroundStyle(.secondary)
			}
		}
	}
}

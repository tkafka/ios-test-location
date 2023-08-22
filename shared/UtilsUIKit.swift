//
//  UtilsUIKit.swift
//  testLocation
//
//  Created by Tomas Kafka on 22.08.2023.
//

import Foundation
#if !os(watchOS)
import UIKit
#endif

#if !os(watchOS)
private var feedbackGenerator: UISelectionFeedbackGenerator?
#endif

public func triggerFeedback(keepWarm: Bool = false) {
	#if !os(watchOS)
	if feedbackGenerator == nil {
		feedbackGenerator = UISelectionFeedbackGenerator()
		feedbackGenerator?.prepare()
	}
	
	/// Trigger selection feedback.
	feedbackGenerator?.selectionChanged()
	
	if keepWarm {
		feedbackGenerator?.prepare()
	}
	#endif
}

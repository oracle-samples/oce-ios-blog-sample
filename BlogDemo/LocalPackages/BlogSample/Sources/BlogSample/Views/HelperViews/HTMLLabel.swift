// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/// Wraps a UILabel so that it is available in SwiftUI
/// Displays html by way of the attributedText property
/// HTML text is obtained using an extension on String in ``String+convertHTML.swift``
struct HTMLLabel: UIViewRepresentable {
    
    let html: String
    let fontSize: CGFloat
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()
        
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .justified
        label.allowsDefaultTighteningForTruncation = true
        
        // Compression resistance is very important to enable auto resizing of this view
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        label.clipsToBounds = true

        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<Self>) {
        
        DispatchQueue.main.async {
            uiView.attributedText = self.html.convertHtml()
            uiView.preferredMaxLayoutWidth = 0.9 * UIScreen.main.bounds.width
            uiView.font = .systemFont(ofSize: self.fontSize)
        }
    }
    
}

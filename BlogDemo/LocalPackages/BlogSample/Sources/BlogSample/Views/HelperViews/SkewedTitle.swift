// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/// Helper method that displays the title of a topic
/// Transforms the view so that the rectangle background appears slanted
struct SkewedTitle: View {
    
    @Binding var title: String
    @Environment(\.blogColorScheme) var blogColors
    
    init(text: Binding<String>) {
         _title = text
    }
    
    var body: some View {
        ZStack {
      
            self.blogColors
                .red
                .wrappedValue
                .transformEffect(CGAffineTransform(a: 1, b: 0, c: -0.15, d: 1, tx: 2.0, ty: 0))
                
            Text(self.title)
                .bold()
                .frame(width: 100)
                .frame(alignment: .center)
                .foregroundColor(.white)
        }
    }
}

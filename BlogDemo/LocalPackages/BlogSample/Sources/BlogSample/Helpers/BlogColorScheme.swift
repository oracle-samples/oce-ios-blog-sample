// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI

/// Environment key that allows us to pass our color scheme throughout the application
struct BlogColorScheme: EnvironmentKey {
    static var defaultValue: Binding<BlogColors> = .constant(BlogColors())
}

/// Values in our color scheme 
struct BlogColors {
    var borderColor = Color.gray
    var placeholderColor = Color.gray.opacity(0.1)
    var secondaryTextColor = Color.gray
    var red = Color(uiColor: UIColor(red: 188/255.0, green: 8/255.0, blue: 7/255.0, alpha: 0.85))
}

extension EnvironmentValues {
    var blogColorScheme: Binding<BlogColors> {
        get { self[BlogColorScheme.self] }
        set { self[BlogColorScheme.self] = newValue }
    }
}

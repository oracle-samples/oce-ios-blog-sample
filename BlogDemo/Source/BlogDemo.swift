// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import SwiftUI
import OracleContentCore
import BlogSample

@main
struct BlogDemo: App {
    
    init() {
        // The sample code expects the URL and channel token to be provided by ``OracleContentCore.Onboarding``
        // Assign your ``OracleContentCore.URLProvider`` implementation to the ``OracleContentCore.Onboarding.urlProvider`` property
        Onboarding.urlProvider = MyURLProvider()
        
        Onboarding.logger = MyLogger()
    }
    
    var body: some Scene {
        WindowGroup {
            BlogDemoMain()
        }
    }
}

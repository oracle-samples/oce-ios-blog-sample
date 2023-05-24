// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import OracleContentCore
import OracleContentDelivery

/// Actions supported by the BlogDemoModel
enum ModelAction {
    case fetchHomePage
}

/// UI state of the main page 
enum BlogDemoState {
    case error(Error)
    case loading
    case done
}

class BlogDemoModel: ObservableObject {
    
    /// The content item representing the home page of the blog
    @Published var home: Asset!
    
    /// The logo image defined in the home asset
    @Published var logo: BlogImageState = .loading
    
    /// The name of the company defined in the home asset
    @Published var companyName: String = ""
    
    /// URL pointing to the "About" page
    @Published var aboutURL: URL?
    
    /// URL pointing to the "Contact US" page
    @Published var contactURL: URL?
    
    /// The collection of Topics contained in the blog
    @Published var topics = [Asset]()
    
    /// The UI state of the main page
    @Published var state: BlogDemoState = .loading
    
    /// Networking object that performs requests to the Oracle Content Management instance
    private var networking = BlogNetworking.instance
    
    /// Perform an action. All state modifications are driven from this method
    /// - parameter action: The action to perform
    @MainActor func send(_ action: ModelAction) async {
        switch action {
        case .fetchHomePage:
            
            // short-circuit if we've already obtained the "home" Asset
            guard self.home == nil else { return }
            
            self.state = .loading
            
            Task {
                do {
                    try await self.fetch()
                    self.state = .done
                } catch {
                    self.state = .error(error)
                }
            }
        }
    }
    
    @MainActor
    internal func fetch() async throws {
        // Obtain the content item representing the "home" page of the blog
        self.home = try await self.networking.fetchHomePage()
        self.companyName = (try? self.home.customField("company_name") as String) ?? ""
        
        // Download the logo
        Task {
            let logo: Asset = try self.home.customField("company_logo")
            self.logo = try await self.networking.fetchLogo(logoId: logo.identifier)
        }
        
        self.topics = try self.home.customField("topics") as [Asset]
    
        let aboutString: String = try self.home.customField("about_url")
        self.aboutURL = URL(string: aboutString)
        
        let contactString: String = try self.home.customField("contact_url")
        self.contactURL = URL(string: contactString)
    }
}


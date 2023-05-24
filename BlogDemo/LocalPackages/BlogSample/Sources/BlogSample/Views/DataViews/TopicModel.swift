// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import UIKit
import OracleContentCore
import OracleContentDelivery

/// Actions supported by the TopicModel
enum TopicViewAction {
    case fetch
}

class TopicModel: ObservableObject {
    @Published var topicImage: BlogImageState = .loading
    @Published var topicDescriptionText: String
    
    @Published var topic: Asset
    
    private var networking = BlogNetworking.instance
    private var imageIdentifier: String!
    
    
    init(topic: Asset) {
        self.topic = topic
        self.topicDescriptionText = topic.desc
    }
    
    /// Perform an action. All state modifications are driven from this method
    /// - parameter action: The action to perform
    @MainActor
    func send(_ action: TopicViewAction) {
        switch action {
        case .fetch:
            // short-circuit if we already have an image
            // otherwise download it
            switch self.topicImage {
            case .image(_):
                return
                
            default:
                self.topicImage = .loading
                Task {
                    self.topicImage = await self.fetch()
                }
            }
        }
    }

    @MainActor
    internal func fetch() async -> BlogImageState {

        var imageIdentifier = ""
        
        do {
            // If we have not yet retrieved the imageIdentifer, then read the full asset
            if self.imageIdentifier == nil {
                let fullAsset = try await self.networking.readAsset(assetId: self.topic.identifier)
                
                self.topicDescriptionText = fullAsset.desc
                self.topic = fullAsset
                
                imageIdentifier = (try fullAsset.customField("thumbnail") as Asset).identifier
            }
           
            let imageState = await self.networking.downloadMediumRendition(identifier: imageIdentifier)
            return imageState
            
        } catch {
            return .image(UIImage(systemName: "questionmark.circle")!)
        }
       
    }
}

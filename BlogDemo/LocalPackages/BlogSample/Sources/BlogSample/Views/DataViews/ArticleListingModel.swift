// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import OracleContentCore
import OracleContentDelivery

/// Actions supported by the ArticleListingModel
enum ArticleListingAction {
    case fetchArticles
}

class ArticleListingModel: ObservableObject {
    @Published var topic: Asset
    @Published var articles = [Asset]()

    private var networking = BlogNetworking.instance

    init(topic: Asset) {
        self.topic = topic
    }
    
    func description(for article: Asset) -> String {
        return article.desc
    }
    
    func postedDate(for article: Asset) -> String {
        
        guard let publishedDate: Date = try? article.customField("published_date") else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: publishedDate)
        
        return "Posted on \(dateString)"
    }
    
    /// Perform an action. All state modifications are driven from this method
    /// - parameter action: The action to perform
    @MainActor
    func send(_ action: ArticleListingAction) {
        switch action {
        case .fetchArticles:
            // Short-circuit if we've already fetched the articles
            guard self.articles.isEmpty else {
                return
            }
            
            Task {
                self.articles = try await self.networking.fetchArticles(for: self.topic)
            }
        }
    }
}

// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import OracleContentCore
import OracleContentDelivery

/// View that lists the articles for a given topic
/// Each element displayed is an ``ArticlePreview``
/// Selecting a preview navigates to an ``Article``
struct ArticleListing: View {
    
    @StateObject var model: ArticleListingModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// Provides grid layout information based on the \.horizontalSizeClass Environment value
    private var vGridLayout: [GridItem] {
       
        if horizontalSizeClass == .compact {
           return [ GridItem(.adaptive(minimum: 300))]
        } else {
            // Use flexible layouts so that the grid remains centered in the view
            return [
                GridItem(.flexible(minimum: 300)),
                GridItem(.flexible(minimum: 300)),
                GridItem(.flexible(minimum: 300))
            ]
        }
    }
    
    init(topic: Asset) {
        _model = StateObject(wrappedValue: ArticleListingModel(topic: topic))
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: vGridLayout) {
                ForEach(self.model.articles, id: \.self) { article in
                    NavigationLink {
                        Article(article: article)
                    } label: {
                        ArticlePreview(article: article)
                    }
                    .padding(8)
                    .buttonStyle(.plain)
                    .frame(height: 150)
                    .border(.gray.opacity(0.2), width: 1.0)
                }
            }
        }
        .task {
            self.model.send(.fetchArticles)
        }
    }
}

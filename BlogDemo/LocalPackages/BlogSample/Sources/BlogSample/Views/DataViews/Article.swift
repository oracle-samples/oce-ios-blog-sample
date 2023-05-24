// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import OracleContentDelivery

/// The blog article
/// Contains the author avatar (including the posted date), the hero image and the HTML-formatted text of the blog entry
struct Article: View {
    
    @StateObject var model: ArticleModel
    
    @Environment(\.blogColorScheme) var blogColors
    
    init(article: Asset) {
        _model = StateObject(wrappedValue: ArticleModel(article: article))
    }
    
    var body: some View {
        BlogView
            .task {
                do {
                    try await self.model.fetchArticle()
                } catch {
                    print(error.localizedDescription)
                }
            }
    }
    
    @ViewBuilder
    var BlogView: some View {
       
        VStack {
            ScrollView(.vertical) {
                
                AuthorView
                
                HeroImage
                
                HTMLLabel(html: self.model.articleContent, fontSize: 15.0)
            }
        }
    }
    
    @ViewBuilder
    var AuthorView: some View {
        HStack(spacing: 5) {
            Avatar
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(self.model.authorName)
                    .bold()
                    .font(.system(size: 14))
                
                Text(self.model.postedDate)
                    .font(.caption)
                    .foregroundColor(self.blogColors.secondaryTextColor.wrappedValue)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var Avatar: some View {
        switch self.model.avatar {
            
        case .image(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipped()
              
        default:
            self.blogColors.placeholderColor.wrappedValue
        }
    }
    
    @ViewBuilder
    var HeroImage: some View {
        
        VStack {
            switch self.model.heroImage {
            case .image(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                
            default:
                self.blogColors.placeholderColor.wrappedValue
                    .frame(height: 200)

            }
            
            Text(self.model.imageCaption)
                .font(.caption2)
                .foregroundColor(self.blogColors.secondaryTextColor.wrappedValue)
        }
    }
}


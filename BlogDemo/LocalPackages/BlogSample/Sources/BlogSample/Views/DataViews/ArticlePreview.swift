// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import OracleContentDelivery

/// Preview of an article
/// Contains the name, postedDate, descriptive text and a preview image
struct ArticlePreview: View {
    
    @Environment(\.blogColorScheme) var blogColors
    @StateObject var model: ArticleModel
    
    init(article: Asset) {
        _model = StateObject(wrappedValue: ArticleModel(article: article))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(self.model.article.name)
                        .foregroundColor(self.blogColors.red.wrappedValue)
                        .bold()
                    
                    Text(self.model.postedDate)
                        .foregroundColor(self.blogColors.secondaryTextColor.wrappedValue)
                        .font(.subheadline)
                }
                
                Spacer()

                ArticlePreviewImage()
                    .environmentObject(model)
                
            }.padding(.bottom, 10)
            
            Text(self.model.article.desc)
            
            Spacer()
        }
    }
}

/// The preview image itself.
struct ArticlePreviewImage: View {
    
    @EnvironmentObject var model: ArticleModel
    @Environment(\.blogColorScheme) var blogColors
    
    @State var opacity: CGFloat = 0.2
    
    var body: some View {
        
        Group {
            switch self.model.thumbnail {
            case .image(let image):
                Rectangle()
                    .overlay(
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                        
                    )
                    .frame(width: 65, height: 65)
                    .clipped()
                    .opacity(self.opacity)
                    .transition(.opacity)
                    .animation(.easeIn(duration: 0.5), value: self.opacity)
                    .onAppear {
                        withAnimation {
                            self.opacity = 1.0
                        }
                    }
            default:
                self.blogColors
                    .placeholderColor
                    .wrappedValue
                    .frame(width: 65, height: 65)
            }
        }
        .task {
            self.model.send(.fetchThumbnail)
        }
    }
}


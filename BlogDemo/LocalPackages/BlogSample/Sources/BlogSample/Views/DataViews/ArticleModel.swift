// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import UIKit
import OracleContentDelivery

enum ArticleModelAction {
    case fetchArticle
    case fetchThumbnail
}

enum ArticleState {
    case loading
    case done
    case error(Error)
}

class ArticleModel: ObservableObject {
    
    @Published var article: Asset
    @Published var thumbnail: BlogImageState = .loading
    @Published var heroImage: BlogImageState = .loading
    @Published var avatar: BlogImageState = .loading
    
    @Published var state: ArticleState = .loading
    
    private var networking = BlogNetworking.instance
    
    var authorName: String {
        guard let author = try? article.customField("author") as Asset else {
            return ""
        }
        
        return author.name
    }
    
    var postedDate: String {
        
        guard let publishedDate: Date = try? article.customField("published_date") else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: publishedDate)
        
        return "Posted on \(dateString)"
    }
    
    var imageCaption: String {
        guard let caption: String = try? article.customField("image_caption") else {
            return ""
        }
        
        return caption
    }
    
    init(article: Asset) {
        self.article = article
    }
    
    var articleContent: String {
        guard let returnValue: String = try? self.article.customField("article_content") else {
            return ""
        }
        
        return returnValue
    }
    
    @MainActor
    func send(_ action: ArticleModelAction) {
        switch action {
        case .fetchThumbnail:
            // short-circuit if we already have an image
            guard case .loading = self.thumbnail else { return }
            
            Task {
                self.thumbnail = await self.fetchThumbnailRendition(for: self.article)
            }
            
        case .fetchArticle:
            Task {
                do {
                    try await self.fetchArticle()
                    self.state = .done
                } catch {
                    self.state = .error(error)
                }
            }
        }
    }
    
    @MainActor
    func fetchArticle() async throws {

        self.article = try await self.networking.readArticle(assetId: article.identifier)
        
        let author: Asset = try self.article.customField("author")
        let authorAvatar: Asset = try author.customField("avatar")
    
        Task {
            self.avatar = await self.networking.downloadNative(identifier: authorAvatar.identifier)
        }
        
        Task {
            let hero: Asset = try self.article.customField("image_16x9")
            self.heroImage = await self.networking.downloadNative(identifier: hero.identifier)
        }

    }
}

extension ArticleModel {
    private func fetchThumbnailRendition(for article: Asset) async -> BlogImageState {
        do {
            let identifier = (try article.customField("image") as Asset).identifier

            let image = await self.networking.downloadThumbnail(identifier: identifier, fileGroup: article.fileGroup)
            return image
            
        } catch {
            return .image(UIImage(systemName: "questionmark.circle")!)
        }
    }
}

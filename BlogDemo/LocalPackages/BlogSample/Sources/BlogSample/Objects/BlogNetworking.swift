// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import UIKit
import OracleContentCore
import OracleContentDelivery

/// Errors specific to BlogNetworking
public enum BlogNetworkingError: Error {
    case homePageNotFound
    case missingLogoId
}

/// Singleton class that handles all network transport of requests to an Oracle Content Management instance
/// Functionality is dependent on the population of Onboarding.urlProvider
public class BlogNetworking {
    
    public static var instance = BlogNetworking.init()
    
    private init() { }
    
    /// Retrieve the content item which represents the home page of the blog
    /// - returns: Asset
    public func fetchHomePage() async throws -> Asset {
        let typeNode = QueryNode.equal(field: "type", value: "OCEGettingStartedHomePage")
        let nameNode = QueryNode.equal(field: "name", value: "HomePage")
        let q = QueryBuilder(node: typeNode).and(nameNode)
        
        let result = try await DeliveryAPI
            .listAssets()
            .query(q)
            .fields(.all)
            .limit(1)
            .fetchNextAsync()
            .items
            .first
           
        guard let foundResult = result else {
            throw BlogNetworkingError.homePageNotFound
        }
        
        return foundResult
    }
    
    /// Download the logo for display on the home page
    /// - parameter logoId: The identifier of the logo to download
    /// - returns: BlogImageState 
    public func fetchLogo(logoId: String?) async throws -> BlogImageState {
        
        do {
            guard let logoID = logoId else { throw BlogNetworkingError.missingLogoId }
            
            let result = try await DeliveryAPI
                .downloadNative(identifier: logoID)
                .downloadAsync(progress: nil)
            
            guard let image = UIImage(contentsOfFile: result.result.path) else {
                throw OracleContentError.couldNotCreateImageFromURL(URL(string: result.result.path))
            }
            
            return .image(image)
            
        } catch {
            return .error(error)
        }

    }
    
    /// Obtain the collection of articles for a given topic. Limited to a maximum of 50 articles for demo purposes.
    /// - parameter topic: Asset
    /// - returns: [Asset] representing the articles for the specified topic
    public func fetchArticles(for topic: Asset) async throws -> [Asset] {

        let typeNode = QueryNode.equal(field: "type", value: "OCEGettingStartedArticle")
        let fieldsTopicNode = QueryNode.equal(field: "fields.topic", value: topic.identifier)
        let fullQuery = QueryBuilder(node: typeNode).and(fieldsTopicNode)
        
        let result = try await DeliveryAPI
            .listAssets()
            .query(fullQuery)
            .order(.field("fields.published_date", .desc))
            .limit(50)
            .fetchNextAsync()
        
        return result.items
    }
    
    /// Obtain detailed information about an Asset
    /// - parameter assetId: The identifier of the asset to read
    /// - returns: Asset
    public func readAsset(assetId: String) async throws -> Asset {
        let result = try await DeliveryAPI
            .readAsset(assetId: assetId)
            .fetchAsync()
        
        return result
    }
    
    /// Downloads the "Medium" rendition of an asset and returns the value as a `BlogImageState`
    /// Note that any error while downloading the image will result in a placeholder image
    public func downloadMediumRendition(identifier: String) async -> BlogImageState {
        
        do {
            let result = try await DeliveryAPI
                                    .downloadRendition(identifier: identifier,
                                                       renditionName: "Medium",
                                                       format: "jpg")
                                    .downloadAsync(progress: nil)
            
            guard let uiImage = UIImage(contentsOfFile: result.result.path()) else {
                throw OracleContentError.couldNotCreateImageFromURL(result.result)
            }
            
            return .image(uiImage)
            
        } catch {
            return .image(UIImage(systemName: "questionmark.circle")!)
        }

    }
    
    /// Downloads the native rendition of an asset and returns the values as a ``BlogImageState``
    /// Note that any error while downloading the image will result in a placeholder image
    public func downloadNative(identifier: String) async -> BlogImageState {
        do {
            let result = try await DeliveryAPI
                .downloadNative(identifier: identifier)
                .downloadAsync(progress: nil)
            
            guard let uiImage = UIImage(contentsOfFile: result.result.path()) else {
               throw OracleContentError.couldNotCreateImageFromURL(result.result)
            }
            
            return .image(uiImage)
        } catch {
            Onboarding.logError(error.localizedDescription)
            return .image(UIImage(systemName: "questionmark.circle")!)
        }
        
    }
    
    /// Downloads the thumbnail rendition of an asset and returns the values as a ``BlogImageState``
    /// Note that any error while downloading the image will result in a placeholder image
    /// - parameter identifier: The identifier of the asset
    /// - parameter fileGroup: The file group of the asset - used to differentiate thumbnails for digital assets, videos and "advanced videos"
    public func downloadThumbnail(identifier: String, fileGroup: String) async -> BlogImageState {
        do {
            let result = try await DeliveryAPI
                .downloadThumbnail(identifier: identifier, fileGroup: fileGroup)
                .downloadAsync(progress: nil)
            
            guard let uiImage = UIImage(contentsOfFile: result.result.path()) else {
               throw OracleContentError.couldNotCreateImageFromURL(result.result)
            }
            
            return .image(uiImage)
        } catch {
            Onboarding.logError(error.localizedDescription)
            return .image(UIImage(systemName: "questionmark.circle")!)
        }
    }
    
    /// Obtain detailed information about an article. Expands the field "fields.author" so that avatar information is available
    /// - parameter assetId: The identifier of the asset to retrieve
    /// - returns: Asset
    public func readArticle(assetId: String) async throws -> Asset {
        let result = try await DeliveryAPI
            .readAsset(assetId: assetId)
            .expand("fields.author")
            .fetchAsync()
        
        return result
    }
}

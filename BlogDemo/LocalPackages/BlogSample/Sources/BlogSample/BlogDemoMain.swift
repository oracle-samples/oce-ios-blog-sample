// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import OracleContentCore
import OracleContentDelivery

/// Main container view for the Blog demo
/// Cards that display are of type ``Topic``
/// Selecting a card navigates to ``ArticleListing``
public struct BlogDemoMain: View {
    
    @StateObject var model: BlogDemoModel = BlogDemoModel()
    @State var blogColors = BlogColors()
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    public init() { }
    
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
    
    public var body: some View {
        Group {
            switch self.model.state {
            case .loading:
                CustomSpinner()
                
            case .error(let error):
                Text(error.localizedDescription)
                
            case .done:
                NavigationStack {
                    TopicCardLayout
                }
                .padding(.horizontal, 5)
                .tint(blogColors.red)
            }
        }
        .padding()
        .task {
            await self.model.send(.fetchHomePage)
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                AboutUsButton
                
                ContactUsButton
            }
        }
        .buttonStyle(.plain)
        .environment(\.blogColorScheme, $blogColors)
    }
    
    /// Defines presentation style based on size classes
    @ViewBuilder
    var TopicCardLayout: some View {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (_, .compact):
            HStack {
                LogoView
                
                GridView
            }
    
        default:
            VStack {
                LogoView
            
                GridView
                
            }
        }
    }
    
    /// The top-most logo of the blog
    @ViewBuilder
    var LogoView: some View {
        switch self.model.logo {
        case .image(let image):
            HStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    
                Text(self.model.companyName)
                    .foregroundColor(blogColors.red)
                    .font(.system(size: 24, weight: .bold))
            }
            .padding(.bottom, 20)
            
        case .error(_):
            // If there was a problem downloading the logo, just
            // display the company name 
            Text(self.model.companyName)
                .foregroundColor(blogColors.red)
                .font(.system(size: 24, weight: .bold))
            
        default:
            EmptyView()
        }
    }
    
    /// Grid showing ``Topic`` objects that, when selected, navigate to the ``ArticleListing`` for that topic
    @ViewBuilder
    var GridView: some View {
        ScrollView {
            LazyVGrid(columns: vGridLayout, spacing: 50)  {
                ForEach(self.model.topics, id: \.self) { topic in
                    
                    NavigationLink(destination: {
                        ArticleListing(topic: topic)
                    }, label: {
                        Topic(topic: topic)
                            .frame(maxWidth: 300)
                            .border(self.blogColors.borderColor.opacity(0.2), width: 1.0)
                    })
                    .buttonStyle(.plain)
                    
                }
            }
        }
    }
    
    /// Navigates to the "about" URL in the browser
    @ViewBuilder
    var AboutUsButton: some View {
        Button("About Us") {
            UIApplication.shared.open(self.model.aboutURL!)
        }
        .disabled(self.model.aboutURL == nil)
        .foregroundColor(self.blogColors.red)
        .bold()
    }
    
    /// Navigates to the "contact us" URL in the browser
    @ViewBuilder
    var ContactUsButton: some View {
        Button("Contact Us") {
            UIApplication.shared.open(self.model.contactURL!)
        }
        .disabled(self.model.contactURL == nil)
        .foregroundColor(self.blogColors.red)
        .bold()
    }
}

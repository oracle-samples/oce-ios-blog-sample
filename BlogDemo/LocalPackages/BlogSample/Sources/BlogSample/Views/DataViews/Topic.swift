// Copyright © 2023 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import SwiftUI
import OracleContentCore
import OracleContentDelivery

/// Card that displays a blog topic
struct Topic: View {
    
    @StateObject var model: TopicModel
    @State var opacity: CGFloat = 0.0
    
    @Environment(\.blogColorScheme) var blogColors
    
    init(topic: Asset) {
        _model = StateObject(wrappedValue: TopicModel(topic: topic))
    }
    
    var body: some View {
        ZStack {

            VStack(spacing: 0) {
                TopicImage()
                    .environmentObject(model)
                    .frame(width: 300, height: 200)
                    .padding(.top, 10)

                Text(self.model.topic.desc)
                    .padding(.horizontal, 8)
                    .frame(width: 300, height: 85)
                    
            }
            .overlay(
                VStack {
                    SkewedTitle(text: self.$model.topic.name).frame(width: 100, height: 30).padding(.top, 0)
                    Spacer()
                }
            )
        }
        .font(.custom("Arial", size: 16))
        .border(blogColors.borderColor.wrappedValue.opacity(0.3), width: 1)
        .opacity(self.opacity)
        .animation(.easeIn(duration: 0.5), value: self.opacity)
        .onAppear {
            withAnimation {
                self.opacity = 1.0
            }
        }
    }
}

/// The main image for the topic
struct TopicImage: View {

    @EnvironmentObject var model: TopicModel
    @Environment(\.blogColorScheme) var blogColors
    
    @State var opacity: CGFloat = 0.0
    
    var body: some View {
        ZStack {
            switch self.model.topicImage {
                
            case .image(let image):
                
                RoundedRectangle(cornerRadius: 5.0)
                    .overlay(
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            
                        )
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
                self.blogColors.placeholderColor.wrappedValue
                ProgressView()
            }
        }
        .task {
            self.model.send(.fetch)
        }
    
    }
}

//
//  ProgressOverlayModifier.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/8/23.
//

import SwiftUI

/// This is a basic `ViewModifier` used for convenient overlaying of a `ProgressView`.
///
/// This makes it easier for consistency.
struct ProgressOverlayModifier: ViewModifier {
    var isShown: Bool
    var verticalOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isShown {
                    // A transparent fill to cover the main content
                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        // Covers the entire screen edge to edge
                        .ignoresSafeArea()
                        // Add the actual overlay...
                        .overlay {
                            ProgressView("Loading...")
                                .font(.headline)
                                .padding()
                                .padding()
                                // Add a styled background for the ProgressView.
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.regularMaterial)
                                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                                }
                                // Due to possibly being inside a NavigationView, centering vertically could be pushed down from the navigation bar.
                                // This allows it to be pushed back up a bit.
                                .offset(y: verticalOffset)
                        }
                }
            }
            // Fades the overlay in and out when `isShown` changes.
            .animation(.default, value: isShown)
    }
}

extension View {
    func progressOverlay(isShown: Bool, verticalOffset: CGFloat = 0) -> some View {
        modifier(ProgressOverlayModifier(isShown: isShown, verticalOffset: verticalOffset))
    }
}

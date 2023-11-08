//
//  MealDetailIngredientRow.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/8/23.
//

import SwiftUI

/// A convient means to show detail in a `List`.
struct DetailRow<Label: View, Content: View>: View {
    @ViewBuilder var content: () -> Content
    @ViewBuilder var label: () -> Label
    
    var body: some View {
        // Align vertically at the first baseline if either view is taller than a single line of text.
        HStack(alignment: .firstTextBaseline) {
            label()
                // Make sure it's leading-aligned.
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            content()
                // Color the text grey.
                .foregroundColor(.secondary)
                // Make sure it's trailing-aligned, as it's against the trailing edge.
                .multilineTextAlignment(.trailing)
        }
    }
}

extension MealDetailView {
    /// A convenience wrapper of `DetailRow` for specifically listing ingredients.
    struct IngredientRow: View {
        var name: String
        var measurement: String
        
        var body: some View {
            DetailRow {
                Text(measurement)
                    // Make the measurement text monospaced.
                    .font(.body.monospaced())
            } label: {
                Text(name)
            }
        }
    }
}

#Preview {
    // The preview's purpose here is to make sure both DetailRow and IngredientRow render the same as expected.
    List {
        DetailRow {
            Text("200g shredded")
                .font(.body.monospaced())
        } label: {
            Text("Digestive Biscuits")
        }

        MealDetailView.IngredientRow(name: "Digestive Biscuits", measurement: "200g shredded")
    }
}

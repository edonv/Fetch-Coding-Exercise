//
//  MealDetailView.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/7/23.
//

import SwiftUI

struct MealDetailView: View {
    /// A property needed at initialization used to know which meal to load via ``MealDbAPI/MealLookup``.
    var mealID: String
    
    /// The data loaded from the API.
    ///
    /// Is `nil` before it's set, and is set to `nil` if the API loading fails.
    @State private var meal: MealDbAPI.MealLookup.Meal? = nil
    
    /// A `Bool` used to show a loading indicator.
    @State private var isLoading = false
    
    var body: some View {
        // A List, but no iterating, just a container for layout and styling purposes.
        List {
            // Safely unwrap `meal` before showing data.
            if let meal {
                // Section for showing some misc info
                Section("Details") {
                    
                    DetailRow {
                        Text(meal.category)
                    } label: {
                        Text("Category")
                    }
                    
                    // If the meal has tags, list them.
                    if !meal.tags.isEmpty {
                        DetailRow {
                            Text(meal.tags.joined(separator: ", "))
                        } label: {
                            Text("Tags")
                        }
                    }
                }
                
                // Section for listing ingredients.
                Section("Ingredients") {
                    // Iterate through the meal's ingredients.
                    // The type already conforms to Identifiable, so no need to specify a KeyPath to an Identifiable property.
                    ForEach(meal.ingredients) { ingredient in
                        IngredientRow(name: ingredient.name,
                                      measurement: ingredient.measurement)
                    }
                }
                
                // Section for listing instruction steps.
                Section("Instructions") {
                    // Iterate through instructions, broken up by line breaks.
                    ForEach(meal.instructionsByStep, id: \.self) { Text($0) }
                }
                
                // If any of the properties used for this Section are not nil, show the section with the available properties.
                if [meal.sourceURL, meal.youtubeURL].compactMap({ $0 }).isEmpty == false {
                    Section("Other Info") {
                        #warning("TODO: Test these Links in the simulator")
                        if let sourceURL = meal.sourceURL {
                            Link("View Original Recipe", destination: sourceURL)
                        }
                        
                        if let youtubeURL = meal.youtubeURL {
                            Link("View on YouTube", destination: youtubeURL)
                        }
                    }
                }
            }
        }
        
        // Titles the List
        .navigationTitle(meal?.name ?? "")
        
        // Conditionally shows a spinner indicator if loading is happening.
        .progressOverlay(isShown: isLoading, verticalOffset: -50)
        
        // This is called when the view is loaded, before it appears.
        .task {
            await loadData()
        }
    }
    
    /// Load data from the API to populate `meal`.
    private func loadData() async {
        // Show progress overlay before starting.
        isLoading = true
        // Set `isLoading` to `false` at the end of the scope (very end of function).
        defer { isLoading = false }
        
        do {
            // Artificially adds 1 second to the load time so it's not too jarringly fast.
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Load the data from the API, returns a `Response` object.
            meal = try await MealDbAPI.getResponse(from: .mealLookup(mealID: mealID))
                // Get the `meal` property from the response.
                // Technically, the response includes an array of `Meal`s calls `meals`, so this property returns the first of the array.
                .meal
        } catch {
            // Basic error print-out.
            print("Error loading meals for MealDetailView:", error)
        }
    }
}

#Preview {
    // This is in the preview so it matches how it will be in the actual app (nested at the App level)
    NavigationView {
        MealDetailView(mealID: "52894")
    }
}

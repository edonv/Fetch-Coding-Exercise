//
//  DessertListViewModel.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/7/23.
//

import Foundation

extension DessertListView {
    @MainActor
    class ViewModel: ObservableObject {
        /// The array of ``MealDbAPI/MealsListFilter/Meal``s to show in the `List`.
        @Published var meals: [MealDbAPI.MealsListFilter.Meal] = []
        
        /// A `Bool` used to show a loading indicator.
        @Published var isLoading = false
        
        /// Load data from the API to populate ``meals``.
        /// - Parameter showLoadingIndicator: Whether the progress overlay should be shown while loading.
        func loadData(showLoadingIndicator: Bool) async {
            // If `showLoadingIndicator` is `true`, show progress overlay.
            if showLoadingIndicator {
                isLoading = true
            }
            
            // Whether or not `showLoadingIndicator` is `true`, reset `isLoading` to `false` at the end of the scope (very end of function).
            defer { isLoading = false }
            
            do {
                // Load the data from the API, returns a `Response` object.
                let mealsTemp = try await MealDbAPI.getResponse(from: .mealsListFilter())
                    // Get the `meals` property from the response.
                    .meals
                    // Sort by the `name` KeyPath, ascending.
                    .sorted(using: KeyPathComparator(\.name, order: .forward))
                
                // Artificially adds 1 second to the load time so it's not too jarringly fast.
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Assigns loaded data to the `@Published` property.
                meals = mealsTemp
            } catch {
                // Basic error print-out.
                print("Error loading meals for DessertListView:", error)
            }
        }
    }
}

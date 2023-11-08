//
//  DessertListView.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/7/23.
//

import SwiftUI

struct DessertListView: View {
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        // A List of meals from the view model, iterating through the meals.
        // The type already conforms to Identifiable, so no need to specify a KeyPath to an Identifiable property.
        List(viewModel.meals) { meal in
            // This pushes to `MealDetailView` when tapped, passing the meal's `mealID`.
            // It's rendered as text (the meal's title) with a thumbnail, plus an indicator that the row can be tapped on.
            NavigationLink {
                MealDetailView(mealID: meal.mealID)
            } label: {
                Label {
                    Text(meal.name)
                } icon: {
                    // Loads the thumbnail asynchronously
                    AsyncImage(url: meal.thumbnailURL) { image in
                        image
                            // Makes the image resizable.
                            .resizable()
                            // Keeps the image at its original aspect ratio.
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        // Shows a spinner while loading the image.
                        ProgressView()
                    }
                    .frame(height: 36)
                }
            }
        }
        
        // Titles the List
        .navigationTitle("Desserts")
        
        // Conditionally shows a spinner indicator if loading is happening.
        .progressOverlay(isShown: viewModel.isLoading, verticalOffset: -50)
        
        // This is called when the view is loaded, before it appears.
        // It is set to only show the loading indicator when the array of Meals is empty.
        // This is in case it calls this again after returning from a different screen (maybe a view added in the future when this becomes a real app ;) )
        .task {
            await viewModel.loadData(showLoadingIndicator: viewModel.meals.isEmpty)
        }
        
        // Allows the list to be "pulled" down to refresh the list. Doesn't do anything but just call `loadData()` again.
        .refreshable {
            await viewModel.loadData(showLoadingIndicator: true)
        }
    }
}

#Preview {
    // This is in the preview so it matches how it will be in the actual app (nested at the App level)
    NavigationView {
        DessertListView()
    }
}

//
//  Fetch_Coding_ExerciseApp.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/7/23.
//

import SwiftUI

@main
struct Fetch_Coding_ExerciseApp: App {
    var body: some Scene {
        WindowGroup {
            // Wrap `DessertListView` in a `NavigationView` to support use of `NavigationLink` inside it.
            NavigationView {
                DessertListView()
            }
        }
    }
}

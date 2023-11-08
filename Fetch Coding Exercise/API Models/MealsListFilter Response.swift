//
//  MealsListFilter Response.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/7/23.
//

import Foundation

extension MealDbAPI.MealsListFilter {
    /// The top-level API response object.
    public struct Response: Decodable {
        /// The list of meals resulting from the filter.
        public var meals: [Meal]
    }
        
    public struct Meal: Decodable, Identifiable {
        /// Used for the `Identifiable` protocol.
        public var id: String { mealID }
        
        public var name: String
        public var thumbnailURL: URL
        public var mealID: String
        
        /// A convenience computed property that gets the ``MealDbAPI/MealLookup`` endpoint associated with this meal.
        public var lookupEndpoint: MealDbAPI.MealLookup {
            .mealLookup(mealID: mealID)
        }
        
        /// This is used to enable easy decoding of JSON data, while allowing for more convenient naming of properties in Swift.
        ///
        /// The enum cases are named the same as the struct properties, while their raw values are their associated field names in the JSON.
        enum CodingKeys: String, CodingKey {
            case name = "strMeal"
            case thumbnailURL = "strMealThumb"
            case mealID = "idMeal"
        }
    }
}

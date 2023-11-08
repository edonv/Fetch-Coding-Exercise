//
//  MealLookup Response.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/7/23.
//

import Foundation

extension MealDbAPI.MealLookup {
    /// The top-level API response object.
    public struct Response: Decodable {
        /// The actual field from the API response.
        ///
        /// If the lookup was successful, it contains a single ``MealDbAPI/MealLookup/Meal``. Otherwise, `nil`.
        ///
        /// It's private because the purpose of this endpoint is to get a single meal, so the computed property ``meal`` should be used instead.
        private var meals: [Meal]?
        
        /// The requested ``MealDbAPI/MealLookup/Meal``, if the lookup was successful. Otherwise, `nil`.
        public var meal: Meal? {
            meals?.first
        }
    }
    
    public struct Meal: Decodable, Identifiable {
        /// Used for the `Identifiable` protocol.
        public var id: String { mealID }
        
        public var mealID: String
        public var name: String
        public var imageSource: String?
        public var category: String
        public var cuisine: String
        public var instructions: String
        public var tags: [String]
        public var youtubeURL: URL?
        public var thumbnailURL: URL
        public var sourceURL: URL?
        public var ingredients: [Ingredient]
        
        /// A computed property that splits ``instructions`` by new-line characters into an array of steps.
        public var instructionsByStep: [String] {
            instructions
                .replacingOccurrences(of: "\r", with: "")
                .split(separator: "\n")
                .filter { !$0.isEmpty }
                .map(String.init)
        }
        
        /// This is used for decoding JSON data into ``MealDbAPI/MealLookup/Meal`` object.
        ///
        /// - Important: This definitely could be simpler and be structured similarly to ``MealDbAPI/MealsListFilter/Meal/CodingKeys``. But, due to this object having up to 20 separate numbered fields for ingredients and measurements, setting up something more complex like this allows for some more convenient logic to flatten them into ``MealDbAPI/MealLookup/Ingredient`` objects instead (in ``init(from:)``).
        struct CodingKeys: CodingKey {
            /// Required for this complex `CodingKey` setup.
            var stringValue: String
            /// Required for this complex `CodingKey` setup.
            init?(stringValue: String) { self.stringValue = stringValue }
            
            /// Required for this complex `CodingKey` setup, but not used.
            var intValue: Int?
            /// Required for this complex `CodingKey` setup, but not used.
            init?(intValue: Int) { return nil }
            
            // The following static constants are for the non-dynamic JSON keys.
            
            static let mealID = CodingKeys(stringValue: "idMeal")!
            static let name = CodingKeys(stringValue: "strMeal")!
            static let imageSource = CodingKeys(stringValue: "strImageSource")!
            static let category = CodingKeys(stringValue: "strCategory")!
            static let cuisine = CodingKeys(stringValue: "strArea")!
            static let instructions = CodingKeys(stringValue: "strInstructions")!
            static let tags = CodingKeys(stringValue: "strTags")!
            static let youtubeURL = CodingKeys(stringValue: "strYoutube")!
            static let thumbnailURL = CodingKeys(stringValue: "strMealThumb")!
            static let sourceURL = CodingKeys(stringValue: "strSource")!
            
            // The following two functions are used for creating dynamically-numbered JSON keys.
            
            static func ingredientName(_ num: Int) -> CodingKeys {
                CodingKeys(stringValue: "strIngredient\(num)")!
            }
            static func ingredientMeasure(_ num: Int) -> CodingKeys {
                CodingKeys(stringValue: "strMeasure\(num)")!
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Standard decode...
            mealID = try container.decode(String.self, forKey: .mealID)
            
            // Standard decode...
            name = try container.decode(String.self, forKey: .name)
            
            // Standard decode...
            thumbnailURL = try container.decode(URL.self, forKey: .thumbnailURL)
            
            // Non-standard decode...
            // Because this value can either be a URL, null, OR an empty String, some extra code is needed to handle it.
            // Decode as an optional String...
            let sourceTemp = try container.decode(String?.self, forKey: .sourceURL)?
                // ... trim off any empty space from either end of the String
                .trimmingCharacters(in: .whitespacesAndNewlines)
                // ... and if it was null, fallback on an empty String.
                ?? ""
            // If it's not empty, set it to a URL. Otherwise, set it to nil.
            sourceURL = !sourceTemp.isEmpty ? URL(string: sourceTemp) : nil
            
            // Standard decode...
            imageSource = try container.decode(String?.self, forKey: .imageSource)
            
            // Standard decode...
            category = try container.decode(String.self, forKey: .category)
            
            // Standard decode...
            cuisine = try container.decode(String.self, forKey: .cuisine)
            
            // Standard decode...
            instructions = try container.decode(String.self, forKey: .instructions)
            
            // Non-standard decode...
            // Because this value is received as a String, but should be used as a comma-separated list, some extra code is used to interpret it.
            // Decode as an optional String...
            tags = try container.decode(String?.self, forKey: .tags)?
                // ... split by commas
                .split(separator: ",")
                // ... map each resulting Substring to a standard String
                .map { String($0) }
                // ... and if it was null, fallback on an empty array.
                ?? []
            
            // Non-standard decode...
            // Because this value can be a URL, null, or an empty String, some extra code is needed to handle it.
            // Decode as an optional String...
            let youtubeTemp = try container.decode(String?.self, forKey: .youtubeURL)?
                // ... trim off any empty space from either end of the String
                .trimmingCharacters(in: .whitespacesAndNewlines)
                // ... and if it was null, fallback on an empty String.
                ?? ""
            // If it's not empty, set it to a URL. Otherwise, set it to nil.
            youtubeURL = !youtubeTemp.isEmpty ? URL(string: youtubeTemp) : nil
            
            // Non-standard decode...
            // Iterate through the numbers 1 through 20 (inclusive) to decode all ingredients and measurements.
            ingredients = try (1...20).reduce(into: []) { partialResult, num in
                // Create each numbered JSON key...
                let nameKey = CodingKeys.ingredientName(num)
                let measureKey = CodingKeys.ingredientMeasure(num)
                
                // Decode each value as optional Strings and trimming off whitespace from either end
                
                let nameTemp = try container.decode(String?.self, forKey: nameKey)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let measureTemp = try container.decode(String?.self, forKey: measureKey)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // If both values are non-nil and non-empty strings...
                guard let nameTemp, !nameTemp.isEmpty,
                      let measureTemp, !measureTemp.isEmpty else { return }
                // ... add the ingredient to the array.
                partialResult.append(.init(name: nameTemp, measurement: measureTemp))
            }
        }
    }
    
    /// A combined ingredient object.
    public struct Ingredient: Identifiable, Hashable {
        /// Used for `Identifiable`.
        ///
        /// Based on the results of `testCheckForDuplicateIngredientObjects()`, some recipes intentionally have ingredient/measurement pairs that are identical. Therefore, those fields *can't* be used for unique identification.
        public var id: String { UUID().uuidString }
        
        public var name: String
        public var measurement: String
    }
}

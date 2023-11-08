//
//  MealDetail API Tests.swift
//  Fetch Coding Exercise Tests
//
//  Created by Edon Valdman on 11/7/23.
//

import XCTest
import Fetch_Coding_Exercise

final class MealDetailAPITests: XCTestCase {
    
    /// This was used to cycle through all meals' JSON data to check if the data structure is correct and valid for all objects (``Fetch_Coding_Exercise/MealDbAPI/MealLookup/Meal``).
    func testMealDetailStructureCorrectAllMeals() async throws {
        let allMeals = try await MealDbAPI.getResponse(from: .mealsListFilter()).meals
            .sorted(using: KeyPathComparator(\.name, order: .forward))
        
        do {
            for (i, meal) in allMeals.enumerated() {
                let lookup = try await MealDbAPI.getResponse(from: meal.lookupEndpoint)
                print("Meal \(i): Success!")
            }
        } catch {
            print("Error casting meal detail info:", error)
        }
    }
    
    /// This was used when ``testMealDetailStructureCorrectAllMeals()`` failed to get the raw JSON for comparison and correction of the data structure.
    func testGetSpecificMealDataRaw() async throws {
        let mealData = try await MealDbAPI.getData(url: MealDbAPI.MealLookup.mealLookup(mealID: "52958").url)
        print(String(data: mealData, encoding: .utf8))
    }
    
    /// This was used to see if any meals have intentionally-duplicated ingredient/measurement pairs.
    ///
    /// After finding which ones had duplicates, those recipes were checked manually using the `MealLookup` endpoint and using their `strSource` field.
    ///
    /// The result was that there are some that it's a mistake, and others that are intentional.
    func testCheckForDuplicateIngredientObjects() async throws {
        let allMeals = try await MealDbAPI.getResponse(from: .mealsListFilter()).meals
        for (i, meal) in allMeals.enumerated() {
            let lookup = try await MealDbAPI.getResponse(from: meal.lookupEndpoint)
            guard let meal = lookup.meal else { continue }
            
            let temp: [MealDbAPI.MealLookup.Ingredient] = meal.ingredients.reduce(into: []) { partialResult, ing in
                XCTAssertTrue(!partialResult.contains(ing), "[\(meal.mealID)] Ingredients already contains \(ing.id)")
                if !partialResult.contains(ing) {
                    partialResult.append(ing)
                }
            }
            print("Meal \(i)/\(meal.mealID): Success!")
        }
    }
}

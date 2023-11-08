//
//  API.swift
//  Fetch Coding Exercise
//
//  Created by Edon Valdman on 11/7/23.
//

import Foundation

// MARK: - General API

/// A protocol for API endpoints.
public protocol Endpoint {
    /// The type considered to be the API response from the API.
    associatedtype ResponseType: Decodable
    
    /// The endpoint's path to be appended to the base URL.
    var path: String { get }
    /// The query items to be added to the endpoint URL.
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    /// `URL` getter for all `Endpoint` types.
    public var url: URL {
        // Assemble the endpoint's full URL by combining:
        var components = URLComponents(
            // the API's base URL,
            url: MealDbAPI.baseURL
                // the API's key (used as a part of the URL path),
                .appendingPathComponent(MealDbAPI.apiKey, isDirectory: false)
                // the endpoint's path,
                .appendingPathComponent(path, isDirectory: false),
            resolvingAgainstBaseURL: false
        )!
        // and finally the endpoint's query.
        components.queryItems = queryItems
        return components.url!
    }
}

// MARK: - Convenience for `getResponse(from:)`

extension Endpoint where Self == MealDbAPI.MealsListFilter {
    /// Convenience initializer for ``MealDbAPI/MealsListFilter`` in ``MealDbAPI/getResponse(from:)``.
    /// 
    /// - Note: Due to the exercise's requirements only needing the `"Dessert"` category, this is the default value of the `category` parameter.
    /// - Parameter category: The category to filter the list by.
    public static func mealsListFilter(by category: String = "Dessert") -> MealDbAPI.MealsListFilter {
        .init(category: category)
    }
}

extension Endpoint where Self == MealDbAPI.MealLookup {
    /// Convenience initializer for ``MealDbAPI/MealsListFilter`` in ``MealDbAPI/getResponse(from:)``.
    public static func mealLookup(mealID: String) -> MealDbAPI.MealLookup {
        .init(mealID: mealID)
    }
}

// MARK: - Getting Data + Namespace

public enum MealDbAPI {
    /// The base URL for the API.
    fileprivate static let baseURL = URL(string: "https://themealdb.com/api/json/v1/")!
    /// The API key (used for testing).
    fileprivate static let apiKey = "1"
    /// A single `JSONDecoder` to reuse by ``getResponse(from:)`` without having to create a new one every call.
    private static let decoder = JSONDecoder()
    
    /// Gets raw JSON data from a `URL`.
    public static func getData(url: URL) async throws -> Data {
        try await URLSession.shared.data(from: url).0
    }
    
    /// Gets the ``Endpoint/ResponseType`` from the provided ``Endpoint``.
    ///
    /// Uses ``getData(url:)`` internally.
    public static func getResponse<E: Endpoint>(from endpoint: E) async throws -> E.ResponseType {
        let dataResponse = try await getData(url: endpoint.url)
        return try MealDbAPI.decoder.decode(E.ResponseType.self, from: dataResponse)
    }
}

// MARK: - Endpoint Types

extension MealDbAPI {
    /// API endpoint for getting a list of meals filtered by a ``category``.
    public struct MealsListFilter: Endpoint, Hashable {
        public typealias ResponseType = Response
        
        /// The category to filter by.
        var category: String
        
        public var path: String { "filter.php" }
        public var queryItems: [URLQueryItem] {
            [.init(name: "c", value: category)]
        }
    }
    
    /// API endpoint for looking up a meal by its ID.
    public struct MealLookup: Endpoint, Hashable {
        public typealias ResponseType = Response
        
        /// The ID of the meal to lookup.
        var mealID: String
        
        public var path: String { "lookup.php" }
        public var queryItems: [URLQueryItem] {
            [.init(name: "i", value: mealID)]
        }
    }
}

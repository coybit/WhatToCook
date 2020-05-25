//
//  SearchService.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 26/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit
import Nuke

protocol SearchMealService {
    func search(ingredients: [String], completion: @escaping (Result<MealResponse, Error>) -> Void)
}

struct SearchResultsResponse: Decodable {
    let results: [SearchResultResponse]
}

struct SearchResultResponse: Decodable {
    let title: String
    let href: String
    let thumbnail: String
    let ingredients: String
}

struct RecipePuppySearchAPI: MealsService {
    let ingredients: [Ingredient]

    func getRandomFood(completion: @escaping (Result<MealResponse, Error>) -> Void) {
        completion(.failure(RecipePuppySearchAPIError.notSupported))
    }
    
    func getImage(_ url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        completion(.failure(RecipePuppySearchAPIError.notSupported))
    }
    
    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void) {
        completion(.failure(RecipePuppySearchAPIError.notSupported))
    }
    
    func getMeals(category: CategoryResponse, page: Int?, completion: @escaping (Result<MealsResponse, Error>) -> Void) {
        let pageParam = page == nil ? "" : "&p=\(page!)"
        let ingredientParams = ingredients.map(\.name).joined(separator: ",")
        send(url: "http://www.recipepuppy.com/api/?i=\(ingredientParams)\(pageParam)") { result in
            switch result {
            case .success(let data):
                do {
                    let results = try JSONDecoder().decode(SearchResultsResponse.self, from: data)
                    let mealsResponse = MealsResponse(meals: results.results.map { item in
                        return MealResponse(idMeal: "",
                                            strMeal: item.title,
                                            strInstructions: item.ingredients,
                                            strMealThumb: item.thumbnail,
                                            strYoutube: item.href)
                    }, nextPage: page.map { $0 + 1} ?? 2)
                    completion(.success(mealsResponse))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getMeal(meal: MealResponse, completion: @escaping (Result<MealResponse, Error>) -> Void) {
        completion(.failure(RecipePuppySearchAPIError.notSupported))
    }
    
    fileprivate func send(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let url = URL(string: url)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(RecipePuppySearchAPIError.noResponse))
                    return
                }
                
                completion(.success(data))
                
            }
        }
        
        task.resume()
    }
    
    enum RecipePuppySearchAPIError: Error {
        case notSupported
        case noResponse
    }
}

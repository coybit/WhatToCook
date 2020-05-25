//
//  MealsService.swift
//  WhatToCook
//
//  Created by Mohsen Alijanpour on 25/05/2020.
//  Copyright © 2020 mohsen.dev. All rights reserved.
//

import UIKit
import Nuke

protocol MealsService {
    func getRandomFood(completion: @escaping (Result<MealResponse, Error>) -> Void)
    func getImage(_ url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void)
    func getMeals(category: CategoryResponse, page: Int?, completion: @escaping (Result<MealsResponse, Error>) -> Void)
    func getMeal(meal: MealResponse, completion: @escaping (Result<MealResponse, Error>) -> Void)
}

struct MealsResponse: Decodable {
    let meals: [MealResponse]
    let nextPage: Int?
}

struct MealResponse: Decodable {
    let idMeal: String
    let strMeal: String
    let strInstructions: String?
    let strMealThumb: String
    let strYoutube: String?
}

struct CategoriesResponse: Decodable {
    let categories: [CategoryResponse]
}

struct CategoryResponse: Decodable {
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String
}

struct APIFoodService: MealsService {
    func getImage(_ url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        send(url: url) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getMeals(category: CategoryResponse, page: Int? = nil, completion: @escaping (Result<MealsResponse, Error>) -> Void) {
        send(url: "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category.strCategory)") { result in
            switch result {
            case .success(let data):
                do {
                    let meals = try JSONDecoder().decode(MealsResponse.self, from: data)
                    completion(.success(meals))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getMeal(meal: MealResponse, completion: @escaping (Result<MealResponse, Error>) -> Void) {
        send(url: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(meal.idMeal)") { result in
            switch result {
            case .success(let data):
                do {
                    let meals = try JSONDecoder().decode(MealsResponse.self, from: data)
                    
                    guard let meal = meals.meals.first else {
                        completion(.failure(APIError.emptyResponse))
                        return
                    }
                    
                    completion(.success(meal))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getRandomFood(completion: @escaping (Result<MealResponse, Error>) -> Void) {
        send(url: "https://www.themealdb.com/api/json/v1/1/random.php") { result in
            switch result {
            case .success(let data):
                do {
                    let foods = try JSONDecoder().decode(MealsResponse.self, from: data)
                    
                    guard let food = foods.meals.first else {
                        completion(.failure(APIError.emptyResponse))
                        return
                    }
                    
                    completion(.success(food))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void) {
        send(url: "https:www.themealdb.com/api/json/v1/1/categories.php") { result in
            switch result {
            case .success(let data):
                do {
                    let categories = try JSONDecoder().decode(CategoriesResponse.self, from: data)
                    completion(.success(categories))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
                    completion(.failure(APIError.noResponse))
                    return
                }
                
                completion(.success(data))
                
            }
        }
        
        task.resume()
    }
    
    enum APIError: Error {
        case noResponse
        case emptyResponse
        case invalidResponse
        case requestError(Error)
    }
}

struct SavedMealsService: MealsService {
    let savedMealsList: SavedMealsList
    
    func getRandomFood(completion: @escaping (Result<MealResponse, Error>) -> Void) {
        completion(.failure(SavedMealsServiceError.notSupported))
    }
    
    func getImage(_ url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(SavedMealsServiceError.invalidUrl))
            return
        }
        ImagePipeline.shared.loadImage(
            with: url,
            completion: { result in
                switch result {
                case .success(let image):
                    completion(.success(image.image))
                case .failure:
                    completion(.failure(SavedMealsServiceError.failedToDownload))
                }
            }
        )
    }
    
    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void) {
        completion(.failure(SavedMealsServiceError.notSupported))
    }
    
    func getMeals(category: CategoryResponse, page: Int? = nil, completion: @escaping (Result<MealsResponse, Error>) -> Void) {
        completion(.success(.init(meals: savedMealsList.list, nextPage: nil)))
    }
    
    func getMeal(meal: MealResponse, completion: @escaping (Result<MealResponse, Error>) -> Void) {
        guard let meal = savedMealsList.list.first(where: { $0.idMeal == meal.idMeal }) else {
            completion(.failure(SavedMealsServiceError.notFound))
            return
        }
        
        completion(.success(meal))
    }
    
    enum SavedMealsServiceError: Error {
        case notSupported
        case notFound
        case failedToDownload
        case invalidUrl
    }
}

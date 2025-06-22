//
//  RecipeAPIService.swift
//  FoodClassifier_Skip_Filozop
//
//  Created by Dasha Filozop on 18.06.2025.
//

import Foundation

class RecipeAPIService {
    private let apiKey = "57d67011b66e4828a471dae3c78d38bf" 

    func fetchRecipes(for ingredients: [String], completion: @escaping ([SpoonacularRecipe]) -> Void) {
        let ingredientsParam = ingredients.joined(separator: ",")
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientsParam)&number=5&apiKey=\(apiKey)"

        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            print("Invalid URL")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let recipes = try JSONDecoder().decode([SpoonacularRecipe].self, from: data)
                    DispatchQueue.main.async {
                        completion(recipes)
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } else {
                print("Request error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
}

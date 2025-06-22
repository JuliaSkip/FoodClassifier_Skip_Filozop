//
//  RecipeAPIModel.swift
//  FoodClassifier_Skip_Filozop
//
//  Created by Dasha Filozop on 18.06.2025.
//

import Foundation

struct SpoonacularRecipe: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let usedIngredients: [Ingredient]
    let missedIngredients: [Ingredient]
    
    struct Ingredient: Decodable {
        let name: String
        let amount: Double?
        let unit: String?
    }
}

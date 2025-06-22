//
//  Ingredient.swift
//  FoodClassifier_Skip_Filozop
//
//  Created by Dasha Filozop on 18.06.2025.
//

import Foundation

struct Ingredient: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var quantity: String
}

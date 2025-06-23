//
//  SpoonacularSteps.swift
//  FoodClassifier_Skip_Filozop
//
//  Created by Скіп Юлія Ярославівна on 23.06.2025.
//

struct SpoonacularSteps: Decodable {
    let name: String?
    let steps: [Step]
    
    struct Step: Decodable {
        let number: Int
        let step: String
    }
}

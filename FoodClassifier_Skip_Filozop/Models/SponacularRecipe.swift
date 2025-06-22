
import Foundation

struct SpoonacularRecipe: Identifiable, Codable {
    let id: Int
    let title: String
    let image: String
    let usedIngredients: [Ingredient]
    let missedIngredients: [Ingredient]
    
    struct Ingredient: Codable {
        let name: String
        let amount: Double?
        let unit: String?
    }
}

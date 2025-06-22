
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


import Foundation

class RecipeAPIService {
    private let apiKeyD = "57d67011b66e4828a471dae3c78d38bf"
    private let apiKeyJ = "e1125124ce06424d92bd601b5864ddc5"
    private let fileName = "recipes.json"

    func fetchRecipes(for ingredients: [String], completion: @escaping ([SpoonacularRecipe]) -> Void) {
        let ingredientsParam = ingredients.joined(separator: ",")
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(ingredientsParam)&number=100&apiKey=\(apiKeyJ)"

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
    
    func writeRecipesToFile(recipes: [SpoonacularRecipe]){
        var recipesFromFile = loadRecipesFromFile()
        for recipe in recipes{
            if !recipesFromFile.contains(where: {$0.id == recipe.id}){
                recipesFromFile.append(contentsOf: recipes)
            }
        }
        do {
            let data = try JSONEncoder().encode(recipesFromFile)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            try data.write(to: fileURL)
        }catch {
            print("Error saving JSON: \(error)")
        }
    }
    
    func removeRecipesFromFile(recipes: [SpoonacularRecipe]){
        var recipesFromFile = loadRecipesFromFile()
        for recipe in recipes {
            if let index = recipesFromFile.firstIndex(where: { $0.id == recipe.id }) {
                recipesFromFile.remove(at: index)
            }
        }
        
        do {
            let data = try JSONEncoder().encode(recipesFromFile)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            try data.write(to: fileURL)
        }catch {
            print("Error saving JSON: \(error)")
        }
    }
    
    func loadRecipesFromFile() -> [SpoonacularRecipe] {
        guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName),
              let data = try? Data(contentsOf: filePath) else { return [] }
        
        do {
            let results = try JSONDecoder().decode([SpoonacularRecipe].self, from: data)
            return results.reversed()
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}

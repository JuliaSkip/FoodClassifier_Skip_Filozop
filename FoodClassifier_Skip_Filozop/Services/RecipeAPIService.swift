import Foundation

class RecipeAPIService {
    private let apiKeyD = "57d67011b66e4828a471dae3c78d38bf"
    private let apiKeyJ = "e1125124ce06424d92bd601b5864ddc5"
    private let apiKeyD2 = "a1da9a7cf88148678e974631f2a0ad3d"
    private let fileName = "recipes.json"

    private struct ComplexSearchResponse: Codable {
        let results: [SpoonacularRecipe]
    }

    func fetchRecipes(for ingredients: [String], completion: @escaping ([SpoonacularRecipe]) -> Void) {
        let ingredientsParam = ingredients.joined(separator: ",")
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?includeIngredients=\(ingredientsParam)&addRecipeInformation=true&number=100&apiKey=\(apiKeyD2)"

        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            print("here's an error")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(ComplexSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(response.results)
                    }
                } catch {
                    print("here's an error")
                    DispatchQueue.main.async {
                        completion([])
                    }
                }
            } else {
                print("here's an error")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }

    func writeRecipesToFile(recipes: [SpoonacularRecipe]) {
        var recipesFromFile = loadRecipesFromFile()
        for recipe in recipes {
            if !recipesFromFile.contains(where: { $0.id == recipe.id }) {
                recipesFromFile.append(recipe)
            }
        }
        do {
            let data = try JSONEncoder().encode(recipesFromFile)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            try data.write(to: fileURL)
        } catch {
            print("here's an error")
        }
    }

    func removeRecipesFromFile(recipes: [SpoonacularRecipe]) {
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
        } catch {
            print("here's an error")
        }
    }

    func loadRecipesFromFile() -> [SpoonacularRecipe] {
        guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName),
              let data = try? Data(contentsOf: filePath) else {
            return []
        }

        do {
            let results = try JSONDecoder().decode([SpoonacularRecipe].self, from: data)
            return results.reversed()
        } catch {
            print("here's an error")
            return []
        }
    }
}

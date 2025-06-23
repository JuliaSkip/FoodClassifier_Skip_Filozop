
import SwiftUI

struct RecipeDetailView: View {
    var recipe: SpoonacularRecipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(recipe.title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                AsyncImage(url: URL(string: recipe.image)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                            .cornerRadius(12)
                    } else if phase.error != nil {
                        Text("Failed to load image")
                    } else {
                        ProgressView()
                    }
                }
                .padding(.bottom)

                VStack(alignment: .leading, spacing: 8) {
                    if !recipe.usedIngredients.isEmpty {
                        Text(recipe.usedIngredients.map { $0.name }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    if !recipe.missedIngredients.isEmpty {
                        Text(recipe.missedIngredients.map { $0.name }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()
                
            }
            .padding(.horizontal)
        }
        .onAppear {
            RecipeAPIService().writeRecipesToFile(recipes: [recipe])
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

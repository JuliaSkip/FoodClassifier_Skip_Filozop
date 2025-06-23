
import SwiftUI

struct RecipeDetailView: View {
    var recipe: SpoonacularRecipe
    @State var steps: [SpoonacularSteps] = []

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
                        Text(recipe.usedIngredients.map { $0.original }.joined(separator: "; "))
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    if !recipe.missedIngredients.isEmpty {
                        Text(recipe.missedIngredients.map { $0.original }.joined(separator: "; "))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Spacer()
                
                if !steps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 4)
                        
                        ForEach(steps.first?.steps ?? [], id: \.number) { step in
                            HStack(alignment: .top) {
                                Text("\(step.number).")
                                    .bold()
                                Text(step.step)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                
            }
            .padding(.horizontal)
        }
        .onAppear {
            RecipeAPIService().writeRecipesToFile(recipes: [recipe])
            RecipeAPIService().fetchRecipeSteps(for: recipe.id) { res in
                DispatchQueue.main.async {
                    self.steps = res
                }
            }
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

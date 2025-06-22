//
//  MainView.swift
//  FoodClassifier_Skip_Filozop
//
//  Created by Dasha Filozop on 18.06.2025.
//

import SwiftUI

struct MainView: View {
    @State private var selectedIngredients = [
        Ingredient(name: "Tomato", quantity: "500g"),
        Ingredient(name: "Cucumber", quantity: "500g"),
        Ingredient(name: "Onion", quantity: "200g")
    ]

    @State private var fetchedRecipes: [SpoonacularRecipe] = []
    @State private var showCameraView = false
    @State private var newIngredientName: String = ""
    private let recipeAPI = RecipeAPIService()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter new ingredient", text: $newIngredientName, onCommit: {
                        addNewIngredient()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                    Button(action: {
                        addNewIngredient()
                    }) {
                        Text("Add")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(newIngredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.trailing)
                }
                .padding(.vertical, 8)


                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedIngredients) { ingredient in
                            HStack(spacing: 4) {
                                Text(ingredient.quantity.isEmpty ? ingredient.name : "\(ingredient.name), \(ingredient.quantity)")
                                    .padding(8)
                                    .clipShape(Capsule())

                                Button(action: {
                                    if let index = selectedIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                        selectedIngredients.remove(at: index)
                                        fetchRecipes()
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .padding(.trailing, 8)
                            }
                            .background(Color.green.opacity(0.2))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                }

                ScrollView {
                    ForEach(fetchedRecipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(recipe.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal)

                                AsyncImage(url: URL(string: recipe.image)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .clipped()
                                            .cornerRadius(12)
                                            .padding(.horizontal)
                                    } else if phase.error != nil {
                                        Text("Failed to load image")
                                            .padding(.horizontal)
                                    } else {
                                        ProgressView()
                                            .padding()
                                    }
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    if !recipe.usedIngredients.isEmpty {
                                        ForEach(recipe.usedIngredients, id: \.name) { ingredient in
                                            Text("- \(ingredient.name)")
                                                .font(.subheadline)
                                                .foregroundColor(.green)
                                        }
                                    }

                                    if !recipe.missedIngredients.isEmpty {
                                        ForEach(recipe.missedIngredients, id: \.name) { ingredient in
                                            Text("- \(ingredient.name)")
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 4)
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Spacer()

                HStack {
                    Spacer()
                    Image(systemName: "house.fill")
                        .padding()
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                        .padding()
                        .onTapGesture {
                            fetchRecipes()
                        }
                    Spacer()
                }
                .background(Color.green)
                .foregroundColor(.white)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitle("FoodSearch")
            .navigationBarItems(trailing: Button(action: {
                showCameraView = true
            }) {
                Image(systemName: "camera")
                    .imageScale(.large)
                    .padding()
            })
            .sheet(isPresented: $showCameraView) {
                CameraView()
            }
            .onAppear {
                fetchRecipes()
            }
        }
    }

    private func addNewIngredient() {
        let trimmedInput = newIngredientName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        let parts = trimmedInput.split(separator: ",", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        let name = parts.first ?? ""
        let quantity = parts.count > 1 ? parts[1] : ""
        
        let newIngredient = Ingredient(name: name, quantity: quantity)
        selectedIngredients.append(newIngredient)
        newIngredientName = ""
        
        fetchRecipes()
    }

    private func fetchRecipes() {
        let ingredientNames = selectedIngredients.map { $0.name }
        recipeAPI.fetchRecipes(for: ingredientNames) { recipes in
            DispatchQueue.main.async {
                self.fetchedRecipes = recipes
            }
        }
    }
}

#Preview {
    MainView()
}

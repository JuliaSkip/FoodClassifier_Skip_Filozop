
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
    @State private var selectedTab: String = "history"
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if selectedTab == "home" {
                    makeHomePage()
                        .onAppear {
                            fetchRecipes()
                        }
                } else {
                    Text("Recenly Viewed")
                        .font(.title3)
                    makeRecipesList()
                        .onAppear{
                            self.fetchedRecipes = RecipeAPIService().loadRecipesFromFile()
                        }
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    Button(action: {
                        selectedTab = "home"
                    }) {
                        Image(systemName: "house.fill")
                            .padding()
                            .imageScale(.large)
                            .foregroundColor(selectedTab == "home" ? .white : .gray)
                    }
                    Spacer()
                    Button(action: {
                        selectedTab = "history"
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .padding()
                            .imageScale(.large)
                            .foregroundColor(selectedTab == "history" ? .white : .gray)
                    }
                    Spacer()
                }
                .background(Color(red: 138/255, green: 214/255, blue: 151/255))
                
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitle("FoodSearch")
        }
    }
    
    @ViewBuilder
    func makeHomePage() -> some View {
        makeTopLine()
        makeIngredientsList()
        makeRecipesList()
    }
    
    
    @ViewBuilder
    func makeTopLine () -> some View {
        HStack {
            TextField("Enter new ingredient", text: $newIngredientName, onCommit: {
                addNewIngredient(ingredientName: newIngredientName)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.leading, 10)
            
            
            Button(action: {
                addNewIngredient(ingredientName: newIngredientName)
            }) {
                Text("Add")
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background(Color(red: 138/255, green: 214/255, blue: 151/255))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(newIngredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            Button(action: {
                showCameraView = true
            }) {
                Image(systemName: "camera")
                    .imageScale(.large)
                    .font(.title2)
                    .padding(.horizontal, 5)
                    .padding(.bottom, 2)
                    .foregroundStyle(Color(red: 138/255, green: 214/255, blue: 151/255))
            }
            .sheet(isPresented: $showCameraView) {
                CameraView { name, quantity in
                    if name != "" {
                        addNewIngredient(ingredientName: "\(name), \(quantity)")
                        fetchRecipes()
                    }
                    showCameraView = false
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    
    @ViewBuilder
    func makeIngredientsList() -> some View {
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
    }
    
    
    @ViewBuilder
    func makeRecipesList() -> some View {
        ScrollView {
            ForEach(fetchedRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    HStack {
                        AsyncImage(url: URL(string: recipe.image)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipped()
                                    .cornerRadius(12)
                                    .padding(.trailing, -10)
                                    .padding(10)
                            } else if phase.error != nil {
                                Text("Failed to load image")
                                    .padding(.horizontal)
                            } else {
                                ProgressView()
                                    .padding()
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(recipe.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
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
                        .background(.white)
                        .frame(maxWidth: 200)
                        .padding(10)
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
    }
    
    private func addNewIngredient(ingredientName: String) {
        let trimmedInput = ingredientName.trimmingCharacters(in: .whitespacesAndNewlines)
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

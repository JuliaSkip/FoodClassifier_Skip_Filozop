
import SwiftUI
import CoreML
import UIKit

struct CameraView: View {
    
    @StateObject private var classifier = ImageClassifier()
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var isSourceActionPresented = false
    @State private var recognizedText: String = ""
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var onAddIngredient: (String, String) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }
                
                makeTextContent()
                    .foregroundStyle(.white)
                
                Spacer()
                
                makeButtons()
                
            }
            .padding(20)
            .background(Color(red: 138/255, green: 214/255, blue: 151/255))
            .foregroundStyle(.black)
            .actionSheet(isPresented: $isSourceActionPresented) {
                makeActionSheet()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage, sourceType: sourceType) { image in
                    classifier.classifyImage(image)
                    classifier.recognizeText(image) { texts in
                        DispatchQueue.main.async {
                            recognizedText = texts ?? ""
                        }
                    }
                }
            }
        }
    }
    
    @State var weight: String = ""
    @ViewBuilder
    func makeTextContent() -> some View {
        if classifier.classificationResult.isEmpty && recognizedText.isEmpty {
            Text("Recognize product from image!")
                .font(.title)
                .multilineTextAlignment(.center)
        }
        
        if !classifier.classificationResult.isEmpty {
            Text("Product name: \(classifier.classificationResult.replacingOccurrences(of: "\\d", with: "", options: .regularExpression))")
                .font(.headline)
                .padding()
            if recognizedText.isEmpty {
                TextField(
                    "Product weight",
                    text: $weight,
                    onCommit: { recognizedText = weight
                    }
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading, 10)
                .foregroundStyle(.gray)
            }
        }
        
        if !recognizedText.isEmpty {
            Text("Product weight: \(recognizedText)")
                .font(.headline)
                .padding()
        }
        
    }
    
    
    @ViewBuilder
    func makeButtons() -> some View {
        Button {
            isSourceActionPresented = true
        } label: {
            HStack {
                Spacer()
                Image(systemName: "camera.fill")
                Text("Choose image to recognize")
                Spacer()
            }
            .padding(10)
            .background(.white)
            .foregroundColor(Color(red: 138/255, green: 214/255, blue: 151/255))
            .cornerRadius(8)
        }
        
        Spacer()
        
        if !classifier.classificationResult.isEmpty {
            HStack{
                
                Button("Cancel") {
                    onAddIngredient("", "")
                }
                .padding(10)
                .background(.white)
                .foregroundColor(Color(red: 138/255, green: 214/255, blue: 151/255))
                .cornerRadius(8)
                
                Button("Add product") {
                    let name = classifier.classificationResult.replacingOccurrences(of: "\\d", with: "", options: .regularExpression)
                    onAddIngredient(name, recognizedText)
                }
                .padding(10)
                .background(.white)
                .foregroundColor(Color(red: 138/255, green: 214/255, blue: 151/255))
                .cornerRadius(8)
                
            }
        }
    }
    
    
    func makeActionSheet() -> ActionSheet {
        ActionSheet(title: Text("Choose Photo Source"), buttons: [
            .default(Text("Camera")) {
                sourceType = .camera
                isImagePickerPresented = true
            },
            .default(Text("Photo Library")) {
                sourceType = .photoLibrary
                isImagePickerPresented = true
            },
            .cancel()
        ])
    }
    
    
}

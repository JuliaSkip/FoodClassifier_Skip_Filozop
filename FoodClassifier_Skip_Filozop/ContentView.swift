import SwiftUI
import CoreML

struct ContentView: View {
    @StateObject private var classifier = ImageClassifier()
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var recognizedText: String = ""
    
    var body: some View {
        VStack {
            
            Spacer()
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            
            if classifier.classificationResult == "" && recognizedText == ""{
                Text("Recognize product from image!")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            
            if classifier.classificationResult != ""{
                Text("Product name: \(classifier.classificationResult)")
                    .font(.headline)
                    .padding()
            }
            
            if recognizedText != "" {
                VStack{
                    Text("Product weight: \(recognizedText)")
                        .font(.headline)
                        .padding()
                }
            }
            
            Spacer()
            
            Button {
                isImagePickerPresented = true
                classifier.cleanResult()
            } label: {
                HStack{
                    Spacer()
                    Image(systemName: "photo")
                    Text("Upload product photo")
                    Spacer()
                }
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            
            Spacer()
            
        }
        .padding(20)
        .background(Color(red: 220/255, green: 205/255, blue: 205/255))
        .foregroundStyle(.black)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage) { image in
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



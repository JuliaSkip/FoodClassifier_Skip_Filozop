import SwiftUI
import CoreML

struct ContentView: View {
    @StateObject private var classifier = ImageClassifier()
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            
            Button("Select Image") {
                isImagePickerPresented = true
                classifier.cleanResult()
            }
            .padding()
            
            Text("Classification: \(classifier.classificationResult)")
                .font(.headline)
                .foregroundStyle(Color.black)
                .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage) { image in
                classifier.classifyImage(image)
            }
        }
    }
}

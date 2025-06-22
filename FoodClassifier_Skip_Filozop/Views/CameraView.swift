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

    var body: some View {
        VStack {
            Spacer()
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }
            
            if classifier.classificationResult.isEmpty && recognizedText.isEmpty {
                Text("Recognize product from image!")
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            
            if !classifier.classificationResult.isEmpty {
                Text("Product name: \(classifier.classificationResult)")
                    .font(.headline)
                    .padding()
            }
            
            if !recognizedText.isEmpty {
                Text("Product weight: \(recognizedText)")
                    .font(.headline)
                    .padding()
            }
            
            Spacer()
            
            Button {
                isSourceActionPresented = true
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: "camera.fill")
                    Text("Add product photo")
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
        .actionSheet(isPresented: $isSourceActionPresented) {
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

#Preview {
    CameraView()
}

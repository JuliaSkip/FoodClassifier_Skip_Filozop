//
//  ImageClassifier.swift
//  FoodClassifier_Skip_Filozop
//
//  Created by Скіп Юлія Ярославівна on 10.06.2025.
//

import SwiftUI
import CoreML
import Vision

class ImageClassifier: ObservableObject {
    @Published var classificationResult: String = ""
    
    private var model: VNCoreMLModel
    
    init() {
        do {
            let config = MLModelConfiguration()
            let model = try FoodClassifier(configuration: config)
            self.model = try VNCoreMLModel(for: model.model)
        } catch {
            fatalError("Failed to load Core ML model: \(error)")
        }
    }
    
    func classifyImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let result = request.results?.sorted(by: {$0.confidence > $1.confidence}) as? [VNClassificationObservation] else{
                print("error\(String(describing: error))")
                return
            }
            guard let res = result.first?.identifier else{
                return
            }
            
            DispatchQueue.main.async{
                self.classificationResult = res
            }
            
        }
        
#if targetEnvironment(simulator)
        request.usesCPUOnly = true
#endif
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform product recognition: \(error.localizedDescription)")
        }
    }
    
    
    func cleanResult() {
        self.classificationResult = ""
    }
    
    
    
}

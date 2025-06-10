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
                print("Error recognizing image: \(error!.localizedDescription)")
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
    
    func recognizeText(_ image: UIImage, recognizedText: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let result = request.results as? [VNRecognizedTextObservation] else {
                print("Error recognizing text: \(error!.localizedDescription)")
                recognizedText(nil)
                return
            }
            
            let texts = result.compactMap { $0.topCandidates(1).first?.string }
            let filteredTexts = texts.filter {
                $0.range(of: "\\d.*?(g|kg|ml|l|г|кг|мл|л)", options: .regularExpression) != nil
            }
            
            recognizedText(filteredTexts.first)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["uk"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error.localizedDescription)")
        }
    }
    
    
}

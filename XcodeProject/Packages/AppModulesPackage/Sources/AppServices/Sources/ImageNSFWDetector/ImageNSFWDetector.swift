//
import CoreML
import Vision
//import ImageIO

public class ImageNSFWDetector {
    static let openNSFWModel = OpenNSFW()
    
    public static func classificationRequest(compeltionHandler: @escaping (Result<Bool, Error>) -> Void) -> VNCoreMLRequest {
        do {
            let model = try VNCoreMLModel(for: self.openNSFWModel.model)
            return VNCoreMLRequest(model: model, completionHandler: { request, error in
                self.handleClassification(request: request, error: error, compeltionHandler: compeltionHandler)
            })
        } catch {
            fatalError("Cannot load ML model")
        }
    }
    
    static func handleClassification(request: VNRequest, error: Error?, compeltionHandler: (Result<Bool, Error>) -> Void) {
        if let error {
            compeltionHandler(.failure(error))
        } else {
            guard let observations = request.results as? [VNClassificationObservation]
            else { fatalError("unexpected result type from VNCoreMLRequest") }
            guard let best = observations.first
            else { fatalError("can't get best result") }
            
            compeltionHandler(.success(best.identifier == "SFW"))
        }
    }
}

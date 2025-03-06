//
import CoreML
import Vision
import ImageIO

public class ImageNSFWDetector {
    static let openNSFWModel = OpenNSFW()
    
    public static func classificationRequest(compeltionHandler: @escaping (Bool) -> Void) -> VNCoreMLRequest {
        do {
            let model = try VNCoreMLModel(for: self.openNSFWModel.model)
            return VNCoreMLRequest(model: model, completionHandler: { request, error in
                self.handleClassification(request: request, error: error, compeltionHandler: compeltionHandler)
            })
        } catch {
            fatalError("Cannot load ML model")
        }
    }
    
    public static func handleClassification(request: VNRequest, error: Error?, compeltionHandler: (Bool) -> Void) {
        guard let observations = request.results as? [VNClassificationObservation]
            else { fatalError("unexpected result type from VNCoreMLRequest") }
        guard let best = observations.first
            else { fatalError("can't get best result") }
        
        compeltionHandler(best.identifier == "SFW")
    }
}

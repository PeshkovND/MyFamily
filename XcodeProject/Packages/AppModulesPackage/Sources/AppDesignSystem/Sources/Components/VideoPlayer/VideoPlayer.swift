import Foundation
import AVFoundation
import UIKit

final class VideoPlayer: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as? AVPlayerLayer ?? AVPlayerLayer()
    }
    
    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
}

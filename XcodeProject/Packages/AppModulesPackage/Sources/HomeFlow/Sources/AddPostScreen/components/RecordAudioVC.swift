import Foundation
import UIKit
import AVFoundation
import AppDesignSystem

class RecordAudioVC: UIViewController, AVAudioRecorderDelegate {
    
    private let completition: (URL?) -> Void
    
    init(completition: @escaping (URL?) -> Void) {
        self.completition = completition
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    var recordButton: ActionButton = {
        let recordButton = ActionButton()
        recordButton.setTitle("Tap to Record", for: .normal)
        
        recordButton.tintColor = .black
        recordButton.backgroundColor = .black
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        return recordButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = appDesignSystem.colors.backgroundPrimary
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func loadRecordingUI() {
        view.addSubview(recordButton)
        
        recordButton.onTap = {
            self.recordTapped()
        }
        
        recordButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(64)
            $0.height.equalTo(64)
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
        completition(audioRecorder?.url)
        audioRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    @objc func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

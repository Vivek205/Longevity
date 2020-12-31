//
//  CoughRecorderViewController.swift
//  COVID Signals
//
//  Created by Jagan Kumar Mudila on 10/12/2020.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import ResearchKit
import Accelerate

class CoughRecorderViewController: BaseStepViewController {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    var fileKey: String = ""
    var coughData: Data?
    
    private var observingTimer: Timer?
    private var isFileDeleted: Bool = false
    private var isTooShort: Bool! {
        didSet {
            self.tooshorterrorView.isHidden = !isTooShort
        }
    }
    
    lazy var questionView:RKCQuestionView = {
        let questionView = RKCQuestionView()
        questionView.translatesAutoresizingMaskIntoConstraints = false
        guard let questionStep = self.step as? ORKQuestionStep,
              let question = questionStep.question else { return questionView }
        questionView.createLayout(question: question)
        return questionView
    }()
    
    lazy var audioVisualizer: AudioVisualizerView = {
        let aVisualizer = AudioVisualizerView()
        aVisualizer.translatesAutoresizingMaskIntoConstraints = false
        return aVisualizer
    }()
    
    lazy var recordThemeView: UIView = {
        let recordTheme = UIView(frame: CGRect(x: 0.0, y: 0.0,
                                               width: UIScreen.main.bounds.width,
                                               height: UIScreen.main.bounds.height))
        recordTheme.backgroundColor = .clear
        return recordTheme
    }()
    
    lazy var statusLabel: UILabel = {
        let statuslabel = UILabel()
        statuslabel.textAlignment = .center
        statuslabel.translatesAutoresizingMaskIntoConstraints = false
        return statuslabel
    }()
    
    lazy var recorderButton: UIButton = {
        let recorderbutton = UIButton()
        recorderbutton.setImage(UIImage(named: "recordbuttonIcon"), for: .normal)
        recorderbutton.setImage(UIImage(named: "stoprecordingIcon"), for: .highlighted)
        recorderbutton.imageView?.contentMode = .scaleAspectFit
        recorderbutton.translatesAutoresizingMaskIntoConstraints = false
        recorderbutton.addTarget(self, action: #selector(recorderPressed), for: .touchDown)
        recorderbutton.addTarget(self, action: #selector(recorderLeave), for: .touchUpInside)
        recorderbutton.addTarget(self, action: #selector(recorderLeave), for: .touchDragExit)
        return recorderbutton
    }()
    
    lazy var playpauseButton: UIButton = {
        let playpausebutton = UIButton()
        playpausebutton.setImage(UIImage(named: "playButton"), for: .normal)
        playpausebutton.translatesAutoresizingMaskIntoConstraints = false
        playpausebutton.addTarget(self, action: #selector(playPauseAudio), for: .touchUpInside)
        return playpausebutton
    }()
    
    lazy var deleteButton: UIButton = {
        let deletebutton = UIButton()
        deletebutton.setImage(UIImage(named: "deleteButton"), for: .normal)
        deletebutton.translatesAutoresizingMaskIntoConstraints = false
        deletebutton.addTarget(self, action: #selector(deleteRecording), for: .touchUpInside)
        return deletebutton
    }()
    
    lazy var tooshorterrorView: ShortRecordErrorView = {
        let errorView = ShortRecordErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        return errorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.questionView)
        self.view.addSubview(audioVisualizer)
        self.view.addSubview(self.recorderButton)
        self.view.addSubview(self.playpauseButton)
        self.view.addSubview(self.deleteButton)
        self.view.addSubview(self.statusLabel)
        self.view.addSubview(self.tooshorterrorView)
        self.parent?.view.addSubview(self.recordThemeView)
        
        let questionViewHeight = questionView.headerAttributedString.height(containerWidth: self.view.bounds.width - 30.0) + 40.0
        
        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            questionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            questionView.heightAnchor.constraint(equalToConstant: questionViewHeight),
            
            self.audioVisualizer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.audioVisualizer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.audioVisualizer.topAnchor.constraint(equalTo: self.questionView.bottomAnchor, constant: 23.0),
            self.audioVisualizer.heightAnchor.constraint(equalToConstant: 110.0),
            self.statusLabel.topAnchor.constraint(equalTo: self.audioVisualizer.bottomAnchor, constant: 10.0),
            self.statusLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10.0),
            self.statusLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10.0),
            self.recorderButton.topAnchor.constraint(equalTo: self.statusLabel.bottomAnchor, constant: 23.0),
            self.recorderButton.widthAnchor.constraint(equalToConstant: 120.0),
            self.recorderButton.heightAnchor.constraint(equalTo: self.recorderButton.widthAnchor),
            self.recorderButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.playpauseButton.widthAnchor.constraint(equalToConstant: 28.0),
            self.playpauseButton.heightAnchor.constraint(equalTo: self.playpauseButton.widthAnchor),
            self.playpauseButton.centerYAnchor.constraint(equalTo: self.recorderButton.centerYAnchor),
            self.playpauseButton.trailingAnchor.constraint(equalTo: self.recorderButton.leadingAnchor, constant: -25.0),
            self.deleteButton.widthAnchor.constraint(equalToConstant: 28.0),
            self.deleteButton.heightAnchor.constraint(equalTo: self.deleteButton.widthAnchor),
            self.deleteButton.centerYAnchor.constraint(equalTo: self.recorderButton.centerYAnchor),
            self.deleteButton.leadingAnchor.constraint(equalTo: self.recorderButton.trailingAnchor, constant: 25.0),
            self.tooshorterrorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            self.tooshorterrorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            self.tooshorterrorView.centerYAnchor.constraint(equalTo: self.statusLabel.centerYAnchor)
        ])
        
        self.statusLabel.text = "Tap and hold to record"
        self.isTooShort = false
        self.updatebuttonStates()
        self.recordThemeView.isHidden = true
        self.recordThemeView.addShadow(to: [.left, .right, .top, .bottom],
                                       radius: 60.0, color: UIColor(hexString: "#E67381").cgColor)
    }
    
    func startRecording() {
        self.isTooShort = false
        let format = DateFormatter()
        format.dateFormat="yyyyMMddHHmmssSSS"
        self.fileKey = "COUGH_TEST_\(format.string(from: Date()))"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(self.fileKey + ".m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recordingSession = AVAudioSession.sharedInstance()
            try recordingSession.setCategory(.playAndRecord, mode: .default, policy: .default,
                                             options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay, .defaultToSpeaker])
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            self.audioVisualizer.resetWaves()
            audioRecorder?.record(forDuration: 5.0)
            self.isFileDeleted = false
            self.observingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
                guard let time = self?.audioRecorder?.currentTime else { return }
                guard let recordTime = Double(String(format: "%.2f", time)) else { return }
                let wave = self?.averagePowerFromAllChannels() ?? 0
                let signal = AudioWaveSignal(time: recordTime, isPlaying: false, signalLength: wave)
                self?.audioVisualizer.updateWave(signal: signal)
                self?.updateStatus(time: Int(time))
            })
        } catch {
            finishRecording(success: false)
        }
    }
    
    // Calculate average power from all channels
    private func averagePowerFromAllChannels() -> Int {
        self.audioRecorder?.updateMeters()
        guard let audiopower = self.audioRecorder?.averagePower(forChannel: 0) else { return 0 }
        guard let peakPower = self.audioRecorder?.peakPower(forChannel: 0) else { return 0 }
        let power = (audiopower / peakPower)
        return Int(power) == 0 ? 1 : Int(power) * 5
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        self.recorderButton.isSelected = false
        self.recordThemeView.isHidden = true
        self.isFileDeleted = !success
        self.observingTimer?.invalidate()
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        if let time = self.audioRecorder?.currentTime,
           Int(time) < 1,
           (self.audioRecorder?.isRecording ?? false) {
            self.isTooShort = true
            self.audioRecorder?.stop()
            self.audioRecorder?.deleteRecording()
            self.audioVisualizer.resetWaves()
            self.isFileDeleted = true
            generator.notificationOccurred(.error)
        } else {
            self.audioRecorder?.stop()
            generator.notificationOccurred(.success)
        }
        do {
            try recordingSession.setActive(false)
        } catch {
            
        }
        self.updatebuttonStates()
    }
    
    @objc func recorderPressed() {
        self.recordThemeView.isHidden = false
        if self.audioRecorder?.isRecording ?? false {
            finishRecording(success: true)
        } else {
            startRecording()
            self.updatebuttonStates()
        }
    }
    
    @objc func recorderLeave() {
        finishRecording(success: true)
    }
    
    @objc func playPauseAudio() {
        if self.audioPlayer?.isPlaying ?? false {
            self.audioPlayer?.pause()
            try? self.recordingSession.setActive(false)
            self.resetAudioPlayer()
        } else {
            guard let audiourl = self.audioRecorder?.url else {
                return
            }
            
            try? self.recordingSession.setActive(true)
            self.audioPlayer = try? AVAudioPlayer(contentsOf: audiourl)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.volume = 1.0
            self.audioPlayer?.play()
            var index = 0
            self.observingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
                guard let time = self?.audioPlayer?.currentTime else { return }
                if index < (self?.audioVisualizer.audioSignals.count ?? 0) {
                    self?.audioVisualizer.audioSignals[index].isPlaying = true
                }
                self?.updateStatus(time: Int(time))
                index += 1
            })
        }
        self.updatebuttonStates()
    }
    
    @objc func deleteRecording() {
        self.audioRecorder?.deleteRecording()
        self.isFileDeleted = true
        self.updatebuttonStates()
        self.updateStatus(time: 0)
        self.audioVisualizer.resetWaves()
    }
    
    fileprivate func updatebuttonStates() {
        if self.audioRecorder?.isRecording ?? false {
            self.playpauseButton.isEnabled = false
            self.deleteButton.isEnabled = false
            self.playpauseButton.tintColor = .lightGray
            self.deleteButton.tintColor = .lightGray
            self.continueButton.isEnabled = false
        } else {
            if self.audioRecorder?.url != nil && !self.isFileDeleted {
                self.playpauseButton.isEnabled = true
                self.deleteButton.isEnabled = true
                self.playpauseButton.tintColor = .themeColor
                self.deleteButton.tintColor = .themeColor
                
                if self.audioPlayer?.isPlaying ?? false {
                    self.playpauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
                    self.recorderButton.isEnabled = false
                    self.deleteButton.isEnabled = false
                } else {
                    self.playpauseButton.setImage(UIImage(named: "playButton"), for: .normal)
                    self.recorderButton.isEnabled = true
                }
                self.continueButton.isEnabled = true
            } else {
                self.playpauseButton.isEnabled = false
                self.deleteButton.isEnabled = false
                self.playpauseButton.tintColor = .lightGray
                self.deleteButton.tintColor = .lightGray
                self.continueButton.isEnabled = false
            }
        }
    }
    
    fileprivate func updateStatus(time: Int) {
        if self.isFileDeleted {
            self.statusLabel.text = "Tap and hold to record"
        } else {
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.bold, size: 18.0), .foregroundColor: UIColor(hexString: "#4E4E4E")]
            let attributedTime = NSMutableAttributedString(string: "00:0\(time)", attributes: attributes)
            let totalTimeAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: AppFontName.regular, size: 18.0)]
            let attributedTotalTime = NSMutableAttributedString(string: " / 00:05", attributes: totalTimeAttributes)
            attributedTime.append(attributedTotalTime)
            self.statusLabel.attributedText = attributedTime
        }
    }
    
    override func handleContinue() {
        self.showSpinner()
        guard let url = self.audioRecorder?.url, let coughData = try? Data(contentsOf: url) else {
            return
        }
        
        let coughRecordUploader = CoughRecordUploader()
        coughRecordUploader.uploadVoiceData(fileKey: self.fileKey, coughData: coughData, completion: { [weak self] (success) in
            if success {
                guard let filekey = self?.fileKey else { return }
                coughRecordUploader.generateURL(for: filekey) { [weak self] (fileURL) in
                    if let questionId = self?.step?.identifier as? String {
                        SurveyTaskUtility.shared.setCurrentSurveyLocalAnswer(questionIdentifier: questionId, answer: fileURL)
                    }
                    DispatchQueue.main.async {
                        self?.removeSpinner()
                        self?.goForward()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.removeSpinner()
                }
            }
        })
    }
}

extension CoughRecorderViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
        self.observingTimer?.invalidate()
        self.observingTimer = nil
        self.updatebuttonStates()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? recordingSession.setActive(false)
        self.resetAudioPlayer()
        self.updatebuttonStates()
    }
    
    private func resetAudioPlayer() {
        self.observingTimer?.invalidate()
        self.observingTimer = nil
        self.updateStatus(time: 0)
        for index in 0..<self.audioVisualizer.audioSignals.count {
            self.audioVisualizer.audioSignals[index].isPlaying = false
        }
    }
}

extension UIView {
    func addShadow(to edges: [UIRectEdge], radius: CGFloat = 3.0, opacity: Float = 0.6, color: CGColor = UIColor.black.cgColor) {
        let fromColor = color
        let toColor = UIColor.white.withAlphaComponent(0.1).cgColor
        let viewFrame = self.frame
        for edge in edges {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [fromColor, toColor]
            gradientLayer.opacity = opacity

            switch edge {
            case .top:
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: radius)
            case .bottom:
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
                gradientLayer.frame = CGRect(x: 0.0, y: viewFrame.height - radius, width: viewFrame.width, height: radius)
            case .left:
                gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: radius, height: viewFrame.height)
            case .right:
                gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
                gradientLayer.frame = CGRect(x: viewFrame.width - radius, y: 0.0, width: radius, height: viewFrame.height)
            default:
                break
            }
            self.layer.addSublayer(gradientLayer)
        }
    }
}

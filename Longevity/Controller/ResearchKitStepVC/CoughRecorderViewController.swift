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

enum ControlState {
    case norecording
    case recording
    case recorded
    case playing
}

class CoughRecorderViewController: BaseStepViewController {
    
    var sessionState: ControlState! {
        didSet {
            if sessionState == .recorded {
                self.playpauseButton.tintColor = .themeColor
                self.deleteButton.tintColor = .themeColor
                self.playpauseButton.isEnabled = true
                self.deleteButton.isEnabled = true
            } else {
                self.playpauseButton.tintColor = .unselectedColor
                self.deleteButton.tintColor = .unselectedColor
            }
            
            if sessionState == .recording {
                self.recorderButton.setImage(UIImage(named: "stoprecordingIcon"), for: .normal)
                self.playpauseButton.isEnabled = false
                self.deleteButton.isEnabled = false
            } else {
                self.recorderButton.setImage(UIImage(named: "recordbuttonIcon"), for: .normal)
            }
        }
    }
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    var fileKey: String = ""
    var coughData: Data?
    
    private var observingTimer: Timer?
    
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
    
    lazy var statusLabel: UILabel = {
        let statuslabel = UILabel()
        statuslabel.textAlignment = .center
        statuslabel.translatesAutoresizingMaskIntoConstraints = false
        return statuslabel
    }()
    
    lazy var recorderButton: UIButton = {
        let recorderbutton = UIButton()
        recorderbutton.setImage(UIImage(named: "recordbuttonIcon"), for: .normal)
        recorderbutton.imageView?.contentMode = .scaleAspectFit
        recorderbutton.translatesAutoresizingMaskIntoConstraints = false
        recorderbutton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.questionView)
        self.view.addSubview(audioVisualizer)
        self.view.addSubview(self.recorderButton)
        self.view.addSubview(self.playpauseButton)
        self.view.addSubview(self.deleteButton)
        self.view.addSubview(self.statusLabel)
        
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
        ])
        
        self.statusLabel.text = "Tap and hold to record"
    }
    
    func startRecording() {
        let format = DateFormatter()
        format.dateFormat="yyyyMMddHHmmssSSS"
        self.fileKey = "COUGH_TEST_\(format.string(from: Date()))"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(self.fileKey + ".m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recordingSession = AVAudioSession.sharedInstance()
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            self.audioVisualizer.resetWaves()
            audioRecorder?.record(forDuration: 5.0)
            self.observingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] (timer) in
                let wave = self?.averagePowerFromAllChannels() ?? 0
                self?.audioVisualizer.updateWave(length: wave)
                self?.audioVisualizer.setNeedsDisplay()
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
        let power = ((audiopower / peakPower) * 100) - 100
        return Int(power) == 0 ? 2 : Int(power)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        self.observingTimer?.invalidate()
        audioRecorder?.stop()
        
        do {
            try recordingSession.setActive(false)
        } catch {
            
        }
    }
    
    @objc func recordTapped() {
        if self.audioRecorder?.isRecording ?? false {
            finishRecording(success: true)
        } else {
            startRecording()
        }
        self.updatebuttonStates()
    }
    
    @objc func playPauseAudio() {
        if self.audioPlayer?.isPlaying ?? false {
            self.audioPlayer?.pause()
        } else {
            guard let audiourl = self.audioRecorder?.url else {
                return
            }
            self.audioPlayer = try? AVAudioPlayer(contentsOf: audiourl)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.play()
        }
        self.updatebuttonStates()
    }
    
    @objc func deleteRecording() {
        self.audioRecorder?.deleteRecording()
        self.continueButton.isEnabled = false
        self.updatebuttonStates()
    }
    
    fileprivate func updatebuttonStates() {
        if self.audioRecorder?.isRecording ?? false {
            self.playpauseButton.isEnabled = false
            self.deleteButton.isEnabled = false
            self.recorderButton.setImage(UIImage(named: "stoprecordingIcon"), for: .normal)
            
            self.playpauseButton.tintColor = .lightGray
            self.deleteButton.tintColor = .lightGray
            self.continueButton.isEnabled = false
        } else {
            self.recorderButton.setImage(UIImage(named: "recordbuttonIcon"), for: .normal)
            if self.audioRecorder?.url != nil {
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
            }
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
        self.updatebuttonStates()
    }
}

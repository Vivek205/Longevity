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
    
    var recordingStartTimer: Timer?
    
    var fileKey: String = ""
    var coughData: Data?
    
    let settings = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    let audioEngine = AVAudioEngine()
    
    private var renderTs: Double = 0
    private var recordingTs: Double = 0
    private var silenceTs: Double = 0
    private var audioFile: AVAudioFile?
    
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
        recorderbutton.addTarget(self, action: #selector(recordPushed), for: .touchDown)
        recorderbutton.addTarget(self, action: #selector(recordTapped), for: [.touchUpInside, .touchUpOutside])
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
        
        var questionViewHeight = questionView.headerAttributedString.height(containerWidth: self.view.bounds.width - 30.0) + 40.0
        
        NSLayoutConstraint.activate([
            questionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            questionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            questionView.heightAnchor.constraint(equalToConstant: questionViewHeight),
            
            self.audioVisualizer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.audioVisualizer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.audioVisualizer.topAnchor.constraint(equalTo: self.questionView.bottomAnchor, constant: 23.0),
            self.audioVisualizer.bottomAnchor.constraint(equalTo: self.recorderButton.topAnchor, constant: -23.0),
            self.recorderButton.widthAnchor.constraint(equalToConstant: 120.0),
            self.recorderButton.heightAnchor.constraint(equalTo: self.recorderButton.widthAnchor),
            self.recorderButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.recorderButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.playpauseButton.widthAnchor.constraint(equalToConstant: 28.0),
            self.playpauseButton.heightAnchor.constraint(equalTo: self.playpauseButton.widthAnchor),
            self.playpauseButton.centerYAnchor.constraint(equalTo: self.recorderButton.centerYAnchor),
            self.playpauseButton.trailingAnchor.constraint(equalTo: self.recorderButton.leadingAnchor, constant: -25.0),
            self.deleteButton.widthAnchor.constraint(equalToConstant: 28.0),
            self.deleteButton.heightAnchor.constraint(equalTo: self.deleteButton.widthAnchor),
            self.deleteButton.centerYAnchor.constraint(equalTo: self.recorderButton.centerYAnchor),
            self.deleteButton.leadingAnchor.constraint(equalTo: self.recorderButton.trailingAnchor, constant: 25.0),
            self.statusLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10.0),
            self.statusLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10.0),
            self.statusLabel.bottomAnchor.constraint(equalTo: self.recorderButton.topAnchor, constant: -25.0)
        ])
        
        self.statusLabel.text = "Tap and hold to record"
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            // failed to record!
        }
    }
    
    func startRecording() {
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            if allowed {
                DispatchQueue.main.async {
                    
                }
            } else {
                DispatchQueue.main.async {
                    Alert(title: "Microphone Permission", message: "Microphone access is required to record the cough. Please allow in app settings", actions: UIAlertAction(title: "No Thanks", style: .destructive, handler: { (action) in
                        
                    }), UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }))
                    
                    return
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder?.stop()
    }
    
    @objc func recordTapped() {
        if self.audioRecorder?.isRecording ?? false {
//            finishRecording(success: true)
        } else {
//            startRecording()
        }
        self.updatebuttonStates()
    }
    
    @objc func recordPushed() {
        if self.audioRecorder?.isRecording ?? false {
            finishRecording(success: true)
            self.recordingStartTimer?.invalidate()
        } else {
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
                audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.isMeteringEnabled = true
                let startInterval: TimeInterval = (self.audioRecorder?.deviceCurrentTime ?? 0.0) + 0.2
                audioRecorder?.record(atTime: startInterval, forDuration: 0.5)
                self.recordingStartTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(keeppressing), userInfo: nil, repeats: true)
            } catch {
                finishRecording(success: false)
            }
        }
    }
    
    private func format() -> AVAudioFormat? {
        let format = AVAudioFormat(settings: self.settings)
        return format
    }
    
    @objc func keeppressing() {
        DispatchQueue.main.async {
            self.statusLabel.text = "00:0\(Int(self.audioRecorder?.currentTime ?? 0)) / 00:05"
            self.updatebuttonStates()
        }
    }
    
    //MARK:- Paths and files
    private func createAudioRecordPath() -> URL? {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss-SSS"
        let currentFileName = "recording-\(format.string(from: Date()))" + ".m4a"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documentsDirectory.appendingPathComponent(currentFileName)
        return url
    }
    
    private func createAudioRecordFile() -> AVAudioFile? {
        guard let path = self.createAudioRecordPath() else {
            return nil
        }
        do {
            let file = try AVAudioFile(forWriting: path, settings: self.settings, commonFormat: .pcmFormatFloat32, interleaved: true)
            return file
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
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
        self.recordingStartTimer?.invalidate()
        if !flag {
            finishRecording(success: false)
        }
        self.updatebuttonStates()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.updatebuttonStates()
    }
}

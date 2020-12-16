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
    
    private var audioSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    
    private var renderTs: Double = 0
    private var recordingTs: Double = 0
    private var silenceTs: Double = 0
    private var audioFile: AVAudioFile?
    private let audioEngine = AVAudioEngine()
    
    var recordingStartTimer: Timer?
    
    var fileKey: String = ""
    var coughData: Data?
    
    let settings = [AVFormatIDKey: kAudioFormatLinearPCM,
                    AVLinearPCMBitDepthKey: 16,
                    AVLinearPCMIsFloatKey: true,
                    AVSampleRateKey: Float64(44100),
                    AVNumberOfChannelsKey: 1] as [String : Any]
    
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let notificationName = AVAudioSession.interruptionNotification
        NotificationCenter.default.addObserver(self, selector: #selector(recordPushed), name: notificationName, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            NotificationCenter.default.removeObserver(self)
        }
    
    func startRecording() {
        audioSession.requestRecordPermission() { [unowned self] allowed in
            if allowed {
                
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
//        if self.audioRecorder?.isRecording ?? false {
//        } else {
//        }
//        self.updatebuttonStates()
    }
    
    @objc func recordPushed() {
        
        if self.isRecording() {
            self.stopRecording()
            return
        }
        
//        if self.audioRecorder?.isRecording ?? false {
//            finishRecording(success: true)
//            self.recordingStartTimer?.invalidate()
//        } else {
//            let seconds = 1.0
//            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
//                let format = DateFormatter()
//                format.dateFormat="yyyyMMddHHmmssSSS"
//                self.fileKey = "COUGH_TEST_\(format.string(from: Date()))"
//                let audioFilename = self.getDocumentsDirectory().appendingPathComponent(self.fileKey + ".m4a")
                
               
                
                do {
                    self.recordingTs = NSDate().timeIntervalSince1970
                    self.silenceTs = 0
                    
                    do {
                        self.audioSession = AVAudioSession.sharedInstance()
                        try self.audioSession.setCategory(.playAndRecord, mode: .default)
                        try self.audioSession.setActive(true)
                    } catch {
                        // failed to record!
                    }
                    
                    let inputNode = self.audioEngine.inputNode
                    let format = inputNode.outputFormat(forBus: 0)
//                            guard let format = self.format() else {
//                                return
//                            }
                    
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) in
                                let level: Float = -50
                                let length: UInt32 = 1024
                                buffer.frameLength = length
                                let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: Int(buffer.format.channelCount))
                                var value: Float = 0
                                vDSP_meamgv(channels[0], 1, &value, vDSP_Length(length))
                                var average: Float = ((value == 0) ? -100 : 20.0 * log10f(value))
                                if average > 0 {
                                    average = 0
                                } else if average < -100 {
                                    average = -100
                                }
                                let silent = average < level
                                let timesince = NSDate().timeIntervalSince1970
                                if timesince - self.renderTs > 0.1 {
                                    let floats = UnsafeBufferPointer(start: channels[0], count: Int(buffer.frameLength))
                                    let frame = floats.map({ (float) -> Int in
                                        return Int(float * Float(Int16.max))
                                    })
                                    DispatchQueue.main.async {
                                        let seconds = (timesince - self.recordingTs)
                                        self.statusLabel.text = seconds.toTimeString
                                        self.renderTs = timesince
                                        let len = self.audioVisualizer.waveforms.count
                                        for index in 0 ..< len {
                                            let idx = ((frame.count - 1) * index) / len
                                            let float: Float = sqrt(1.5 * abs(Float(frame[idx])) / Float(Int16.max))
                                            self.audioVisualizer.waveforms[index] = min(49, Int(float * 50))
                                        }
                                        self.audioVisualizer.active = !silent
                                        self.audioVisualizer.setNeedsDisplay()
                                    }
                                }
                                
                                let write = true
                                if write {
                                    if self.audioFile == nil {
                                        self.audioFile = self.createAudioRecordFile()
                                    }
                                    if let file = self.audioFile {
                                        do {
                                            try file.write(from: buffer)
                                        } catch let error as NSError {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }
                            }
                            do {
                                self.audioEngine.prepare()
                                try self.audioEngine.start()
                            } catch {
                                print(error.localizedDescription)
                                return
                            }
                    
                    
//                    self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//                    self.audioRecorder?.delegate = self
//                    self.audioRecorder?.isMeteringEnabled = true
//                    let startInterval: TimeInterval = (self.audioRecorder?.deviceCurrentTime ?? 0.0) + 0.2
//                    self.audioRecorder?.record(forDuration: 0.5)
//                    self.recordingStartTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.keeppressing), userInfo: nil, repeats: true)
                } catch {
//                    self.finishRecording(success: false)
                }
//            }
//        }
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
        self.playpauseButton.isEnabled = false
        self.deleteButton.isEnabled = false
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
            if self.audioRecorder?.url != nil  {
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

extension CoughRecorderViewController {
    
    fileprivate func isPlaying() -> Bool {
        return self.audioPlayer?.isPlaying ?? false
    }
    
    fileprivate func stopRecording() {
        self.audioFile = nil
        self.audioEngine.inputNode.removeTap(onBus: 0)
        self.audioEngine.stop()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch  let error as NSError {
            print(error.localizedDescription)
            return
        }
    }
    
    fileprivate func stopPlaying() {
        self.audioPlayer?.pause()
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    private func isRecording() -> Bool {
        if self.audioEngine.isRunning {
            return true
        }
        return false
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

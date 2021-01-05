//
//  SetupProfileMicVC.swift
//  COVID Signals
//
//  Created by vivek on 14/12/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit
import AVFoundation

class SetupProfileMicVC: BaseProfileSetupViewController {
    lazy var imageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "SetupMic"))
        return image
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel(text: "Enable Microphone", font: UIFont(name: AppFontName.semibold, size: 24), textColor: .sectionHeaderColor, textAlignment: .center, numberOfLines: 1)
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel(text: "Please enable your phone’s microphone for the COVID cough test feature.   The microphone will only be active during the test.", font: UIFont(name: AppFontName.regular, size: 20), textColor: .sectionHeaderColor, textAlignment: .left, numberOfLines: 0)
        return label
    }()

    lazy var footerView: UIView = {
        let footer = UIView(backgroundColor: .white)
        return footer
    }()

    lazy var enableButton: CustomButtonFill = {
        let button = CustomButtonFill(title: "Enable Now", target: self, action: #selector(handleEnable(_:)))
        return button
    }()

    lazy var maybeLaterButton: UIButton = {
        let button = UIButton(title: "Maybe Later", target: self, action: #selector(handleMaybeLater(_:)))
        button.setTitleColor(.themeColor, for: .normal  )
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .appBackgroundColor
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(footerView)
        footerView.addSubview(enableButton)
        footerView.addSubview(maybeLaterButton)

        let descriptionHeight: CGFloat = descriptionLabel.text?.height(withConstrainedWidth: view.bounds.size.width - 30, font: descriptionLabel.font) ?? 96

        let navBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (navigationController?.navigationBar.frame.height ?? 0.0)

        imageView.centerXTo(view.centerXAnchor)
        imageView.anchor(.top(view.topAnchor, constant: navBarHeight + 14),
                         .width(236),.height(224))
        titleLabel.anchor(.top(imageView.bottomAnchor, constant: 24),
                          .leading(view.leadingAnchor, constant: 15),
                          .trailing(view.trailingAnchor, constant: 15),
                          .height(29))
        descriptionLabel.anchor(.top(titleLabel.bottomAnchor, constant: 13),
                                .leading(view.leadingAnchor, constant: 15),
                                .trailing(view.trailingAnchor, constant: 15),
                                .height(descriptionHeight))

        footerView.anchor(.leading(view.leadingAnchor),
                          .trailing(view.trailingAnchor),
                          .bottom(view.bottomAnchor),
                          .height(174))
        enableButton.anchor(.top(footerView.topAnchor, constant: 24),
                            .leading(footerView.leadingAnchor, constant: 15),
                            .trailing(footerView.trailingAnchor, constant: 15),
                            .height(48))
        maybeLaterButton.anchor(.top(enableButton.bottomAnchor, constant: 32),
                                .leading(footerView.leadingAnchor, constant: 21),
                                .trailing(footerView.trailingAnchor, constant: 21),
                                .height(24))

        self.addProgressbar(progress: 70)
    }

    func openAppSettings(_ sender: Any) {
        if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: nil)
        }
    }
    
    @objc func handleEnable(_ sender: UIButton) {
        let recordingSession = AVAudioSession.sharedInstance()
        recordingSession.requestRecordPermission() { [weak self] allowed in
            if allowed {
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "SetupProfileMicToDevices", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    Alert(title: "Microphone Access Denied", message: "Access to record audio has been denied. Please enable it in the settings app", action: UIAlertAction(title: "Ok", style: .default, handler: self?.openAppSettings))
                }
            }

        }
    }

    @objc func handleMaybeLater(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SetupProfileMicToDevices", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
    }

}

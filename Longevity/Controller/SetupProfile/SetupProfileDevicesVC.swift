//
//  SetupProfileDevicesVC.swift
//  Longevity
//
//  Created by vivek on 26/06/20.
//  Copyright © 2020 vivek. All rights reserved.
//

import UIKit

class SetupProfileDevicesVC: BaseProfileSetupViewController {
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    var fitbitModel: FitbitModel = FitbitModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeBackButtonNavigation()
        collectionView.delegate = self
        collectionView.dataSource = self
        checkIfDevicesAreConnectedAlready()
        self.addProgressbar(progress: 80.0)
    }

    func checkIfDevicesAreConnectedAlready() {
        AppSyncManager.instance.healthProfile.addAndNotify(observer: self) {
            [weak self] in
            if let devices = AppSyncManager.instance.healthProfile.value?.devices {
                if let fitbit = devices[ExternalDevices.fitbit] {
                    setupProfileConnectDeviceOptionList[2]?.isConnected = fitbit["connected"] == 1
                }
                if let watch = devices[ExternalDevices.watch] {
                    setupProfileConnectDeviceOptionList[3]?.isConnected = watch["connected"] == 1
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
    }

    // MARK: Actions
    @IBAction func handleContinue(_ sender: Any) {
        performSegue(withIdentifier: "SetupProfileDevicesToPreExistingConditions", sender: self)
    }
}

extension SetupProfileDevicesVC: SetupProfileDevicesConnectCellDelegate {
    func connectBtn(wasPressedOnCell cell: SetupProfileDevicesConnectCell) {

        UNUserNotificationCenter.current().getNotificationSettings {
            (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    switch cell.titleLabel.text {
                    case "Fitbit":
                        print("connected fitbit data")
                        if let context = UIApplication.shared.keyWindow {
                            self.fitbitModel.contextProvider = AuthContextProvider(context)
                        }
                        self.fitbitModel.auth { authCode, error in
                            if error != nil {
                                print("Auth flow finished with error \(String(describing: error))")
                                AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 0)
                            } else {
                                print("Your auth code is \(String(describing: authCode))")
                                self.fitbitModel.token(authCode: authCode!)
                                AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.fitbit, connected: 1)
                                DispatchQueue.main.async {
                                    setupProfileConnectDeviceOptionList[2]?.isConnected = true
                                    self.collectionView.reloadData()
                                }
                            }
                        }
                    default:
                        HealthStore.shared.getHealthKitAuthorization(device: .applewatch) { (authorized) in
                            if authorized {
                                AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.watch, connected: 1)
                            } else {
                                AppSyncManager.instance.updateHealthProfile(deviceName: ExternalDevices.watch, connected: 0)
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlert(title: "Enable Notification", message: "Please enable device notifications to connect external devices")
                }
            }
        }


    }
}

extension SetupProfileDevicesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileDevicesImageCell", for: indexPath)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileDevicesInfoCell", for: indexPath)
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupProfileDevicesConnectCell", for: indexPath) as! SetupProfileDevicesConnectCell
            cell.setupCell(index: indexPath.item)
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.size.height
        let width = view.frame.size.width
        switch indexPath.row {
        case 0:
            return CGSize(width: width - 30, height: CGFloat(270))
        case 1:
            return CGSize(width: width - 30, height: CGFloat(150))
        default:
            return CGSize(width: width - 30, height: CGFloat(80))
        }
    }
}

extension UIButton {
  func alignVertical(spacing: CGFloat = 6.0) {
    guard let imageSize = imageView?.image?.size,
      let text = titleLabel?.text,
      let font = titleLabel?.font
    else { return }

    titleEdgeInsets = UIEdgeInsets(
      top: 0.0,
      left: -imageSize.width,
      bottom: -(imageSize.height + spacing),
      right: 0.0
    )

    let titleSize = text.size(withAttributes: [.font: font])
    imageEdgeInsets = UIEdgeInsets(
      top: -(titleSize.height + spacing),
      left: 0.0,
      bottom: 0.0,
      right: -titleSize.width
    )

    let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
    contentEdgeInsets = UIEdgeInsets(
      top: edgeOffset,
      left: 0.0,
      bottom: edgeOffset,
      right: 0.0
    )
  }
}
